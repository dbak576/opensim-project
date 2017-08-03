function newR = remove_gaps_from_ranges(R, threshold)

newR = {};

if length(R)
	newR = { R{1} };
end

for i=2:length(R)
	if (R{i}(1) - newR{end}(end) - 1) <= threshold
		newR{end} = newR{end}(1):R{i}(end);
	else
		newR = { newR{:} R{i} };
	end
end
