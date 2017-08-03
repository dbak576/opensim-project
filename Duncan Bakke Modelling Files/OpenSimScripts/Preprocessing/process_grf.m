function [q, offsets] = process_grf(anc_file, output_mot_file, trc_file, do_plot, offsets_only)

%anc_file='SS_walking1.anc';
%trc_file='delaware3_ss_walking1.trc';
%output_mot_file='delaware3_ss_walking1_newgrfprocessing.mot';

if nargin < 2
	output_mot_file = '';
end
if nargin < 3
	trc_file = '';
end
if nargin < 4
	do_plot = 1;
end
if nargin < 5
	offsets_only = 0;
end

transform = delaware_lcs; % TODO: allow user to override this

filter_order = 50; % 2 for butter
filter_cutoff = 20;
filter_type = 'fir'; % 'none' or 'butter' or 'fir'

zero_derivative_threshold = 200;
force_implying_contact = 300;
allowed_gap_threshold = 100;
range_length_threshold = 0;
cop_Fy_threshold = 200;

% FOR FAST WALKING, THE FOLLOWING MIGHT BE BETTER VALUES:
zero_derivative_threshold = 500;
allowed_gap_threshold = 50;
range_length_threshold = 80;

%------------------------------------------------------------------

q=read_anc(anc_file,transform);

n = length(q.time);

q = filter_grf(q, filter_order, filter_cutoff, filter_type);

FyDeriv = zeros(n, 2);
for fp=1:2
	FyDeriv(1:(n-1), fp) = diff(q.data(fp).filteredF(:,2))./diff(q.time);
end
FyDeriv(n, :) = FyDeriv(n-1, :);

contact = zeros(n, 2);
copcalc = zeros(n, 2);

for fp=1:2

	for step=1:2
		% Find contact ranges/indices
		contactIndices = find(abs(FyDeriv(:,fp)) > zero_derivative_threshold | q.data(fp).filteredF(:,2) > force_implying_contact);
		contactRanges = indices_to_ranges(contactIndices);
		contactRanges = remove_gaps_from_ranges(contactRanges, allowed_gap_threshold);
		if range_length_threshold > 0
			contactRanges = prune_short_ranges(contactRanges, range_length_threshold);
		end
		contactIndices = ranges_to_indices(contactRanges);
		contact(:,fp) = zeros(n, 1);
		contact(contactIndices,fp) = 100*ones(length(contactIndices), 1);
		q.data(fp).contactIndices = contactIndices;

		% For COP computation, need to narrow down the "contact" range in which we can divide by Fy
		copIndices = contactIndices;
		copRanges = indices_to_ranges(copIndices);
		for i=1:length(copRanges)
			I = find(q.data(fp).filteredF(copRanges{i},2) > cop_Fy_threshold);
			if length(I) == 0
				copRanges{i} = [];
			else
				copRanges{i} = copRanges{i}(I(1)):copRanges{i}(I(end));
			end
		end
		copIndices = ranges_to_indices(copRanges);
		copcalc(:,fp) = zeros(n, 1);
		copcalc(copIndices,fp) = 120*ones(length(copIndices), 1);
		q.data(fp).copIndices = copIndices;

		% Manually zero the forceplates
		noncontactIndices = setdiff(1:n, contactIndices);	

		if length(noncontactIndices) == 0
			error(sprintf('WARNING: did not find any times with no foot-floor contact (force plate %d)',fp));
		end
		meanF = mean(q.data(fp).F(noncontactIndices,:));
		meanM = mean(q.data(fp).M(noncontactIndices,:));

		offsets(fp).meanF = meanF;
		offsets(fp).meanM = meanM;

		if offsets_only
			break;
		end

		if 1
		disp(sprintf('Forceplate %d step %d', fp, step));
		disp(sprintf_ranges(contactRanges, q.time));
		disp(sprintf('Forces and moments during no contact:'));
		disp(sprintf('MEAN Fx=%f Fy=%f Fz=%f Mx=%f My=%f Mz=%f', meanF(1), meanF(2), meanF(3), meanM(1), meanM(2), meanM(3)));
		minF = min(q.data(fp).F(noncontactIndices,:));
		minM = min(q.data(fp).M(noncontactIndices,:));
		disp(sprintf('MIN Fx=%f Fy=%f Fz=%f Mx=%f My=%f Mz=%f', minF(1), minF(2), minF(3), minM(1), minM(2), minM(3)));
		maxF = max(q.data(fp).F(noncontactIndices,:));
		maxM = max(q.data(fp).M(noncontactIndices,:));
		disp(sprintf('MAX Fx=%f Fy=%f Fz=%f Mx=%f My=%f Mz=%f', maxF(1), maxF(2), maxF(3), maxM(1), maxM(2), maxM(3)));
		peaks = [];
		for i=1:length(contactRanges)
			peaks = [ peaks max(q.data(fp).filteredF(contactRanges{i},2)) ];
		end
		disp(sprintf('Max overall filtered Fy peak=%f', max(q.data(fp).filteredF(:,2))));
		disp(sprintf('Average filtered Fy peak=%f', mean(peaks)));
		end

		if step == 1
			disp('Applying DC offset');
			Foffset = meanF;
			Moffset = meanM;
			q.data(fp).F = q.data(fp).F - ones(n,1)*Foffset;
			q.data(fp).M = q.data(fp).M - ones(n,1)*Moffset;
			q.data(fp).filteredF = q.data(fp).filteredF - ones(n,1)*Foffset;
			q.data(fp).filteredM = q.data(fp).filteredM - ones(n,1)*Moffset;
		end

		if step == 2
			disp('Zeroing non-contact forces and torques');
			q.data(fp).F(noncontactIndices,:) = zeros(length(noncontactIndices), 3);
			q.data(fp).M(noncontactIndices,:) = zeros(length(noncontactIndices), 3);
			disp('Filtering again');
			filter_grf(q, filter_order, filter_cutoff, filter_type, fp);
			disp('Manually zeroing filtered data too!');
			q.data(fp).filteredF(noncontactIndices,:) = zeros(length(noncontactIndices), 3);
			q.data(fp).filteredM(noncontactIndices,:) = zeros(length(noncontactIndices), 3);
		end

		disp(sprintf('\n'));
	end

	COP = compute_COP(q.data(fp).filteredF, q.data(fp).filteredM, q.data(fp).FPorigin_model, q.data(fp).copIndices);
	COP = fill_gaps(COP, q.data(fp).copIndices);
	T = compute_T_at_COP(COP, q.data(fp).filteredF, q.data(fp).filteredM, q.data(fp).FPorigin_model);
	q.data(fp).COP = COP;
	q.data(fp).T = T;
end

if offsets_only
	return;
end

if do_plot
	close all;

	%plot(q.time, [q.data(1).filteredF q.data(2).filteredF]);

	if trc_file
		markers=read_trcFile(trc_file);
		markers.data(:,3:end) = markers.data(:,3:end) * .001; % mm -> m
	end

	for fp=1:2
		if fp == 1
			prefix = 'R.';
		else
			prefix = 'L.';
		end

		foot_markers={[prefix 'Toe.Med_tz'], [prefix 'Toe.Lat_tz'], [prefix 'Toe.Tip_tx'], [prefix 'Heel_tx']};

		figure	
		%plot(q.time, [q.data(fp).F(:,:) q.data(fp).filteredF contact(:,fp) copcalc(:,fp)]);
		plot(q.time, [q.data(fp).filteredF contact(:,fp) copcalc(:,fp)]);
		%plot(q.time, [q.data(fp).filteredF]);
		title(sprintf('Forceplate %d', fp));

		figure
		%plot(q.time, [T .01*copcalc(:,fp)]);
		plot(q.time, [q.data(fp).COP .002*copcalc(:,fp)]);
		legend({'x','y','z'});
		if trc_file
			hold on;
			plot_columns(markers, foot_markers);
			hold off;
		end
		title(sprintf('Forceplate %d', fp));
	end
end

if output_mot_file
	% WRITE MOTION FILE
	mot.labels = { 'time', ...
						'ground_force_vx', 'ground_force_vy', 'ground_force_vz', ...
						'ground_force_px', 'ground_force_py', 'ground_force_pz', ...
						'ground_force_vx', 'ground_force_vy', 'ground_force_vz', ...
						'ground_force_px', 'ground_force_py', 'ground_force_pz', ...
						'ground_torque_x', 'ground_torque_y', 'ground_torque_z', ...
						'ground_torque_x', 'ground_torque_y', 'ground_torque_z' };
	mot.data = [ q.time q.data(1).filteredF q.data(1).COP q.data(2).filteredF q.data(2).COP q.data(1).T q.data(2).T ];
	write_motionFile(mot, output_mot_file);
end
