function t = time_data(q)

time_column = find_columns_by_label(q.labels, '^[Tt]ime$');
if length(time_column) == 1
	t = q.data(:,time_column);
else
	t = []
end
