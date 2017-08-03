function put_forces_in_mot(forces_fname, mot_fname, out_fname)

if nargin < 3
	out_fname = mot_fname;
end

F = read_motionFile(forces_fname);
M = read_motionFile(mot_fname);

notI = find_columns_by_label(M.labels, 'ground_force|ground_torque');
I = setdiff(1:length(M.labels), notI);
M.labels = M.labels(I);
M.data = M.data(:,I);

forcecolumns = length(F.labels)-1;

M.labels = {M.labels{:} F.labels{2:end}};
M.data(:,(end+1):(end+forcecolumns)) = interp1(F.data(:,1),F.data(:,2:end),M.data(:,1));

write_motionFile(M,out_fname);
