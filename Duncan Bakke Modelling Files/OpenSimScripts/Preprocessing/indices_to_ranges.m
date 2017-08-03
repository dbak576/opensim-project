function R = indices_to_ranges(I)

if length(I) == 0
	R = {};
	return;
end

R = { [] };

for i=1:length(I)
	R{end} = [R{end} I(i)];
	if i < length(I) && I(i+1) ~= I(i) + 1
		R = { R{:} [] };
	end
end
