function newR = prune_short_ranges(R, threshold)

newR = {};

for i=1:length(R)
	if length(R{i}) > threshold
		newR = { newR{:} R{i} };
	end
end
