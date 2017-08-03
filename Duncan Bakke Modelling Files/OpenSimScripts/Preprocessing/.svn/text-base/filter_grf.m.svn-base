function q = filter_grf(q, filter_order, filter_cutoff, filter_type, fpIndices)

if nargin < 5
	fpIndices=1:2;
end

% Filter
% Seems to create overshooting which may be undesirable
if strcmp(filter_type,'butter')
	%disp(sprintf('butterworth filter order=%f cutoff=%f', filter_order, filter_cutoff));
	[filterb, filtera] = butter(filter_order, filter_cutoff/(0.5*q.analog_rate));
	for fp=fpIndices
		q.data(fp).filteredF = filtfilt(filterb, filtera, q.data(fp).F);
		q.data(fp).filteredM = filtfilt(filterb, filtera, q.data(fp).M);
	end
elseif strcmp(filter_type,'fir')
	%disp(sprintf('fir filter order=%f cutoff=%f', filter_order, filter_cutoff));
	B = fir1(filter_order, filter_cutoff/(0.5*q.analog_rate));
	for fp=fpIndices
		q.data(fp).filteredF = filtfilt(B, 1, q.data(fp).F);
		q.data(fp).filteredM = filtfilt(B, 1, q.data(fp).M);
	end
else
	for fp=fpIndices
		q.data(fp).filteredF = q.data(fp).F;
		q.data(fp).filteredM = q.data(fp).M;
	end
end
