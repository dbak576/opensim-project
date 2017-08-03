function outArray = fill_gaps(inArray, validIndices)
% EG, this is based on Allison's interpolate_array

% fill endpoints with average value if endpoints not valid
avg = mean(inArray(validIndices,:));
if validIndices(1) ~= 1
	validIndices = [1 validIndices];
	inArray(1,:) = avg;
end
if validIndices(end) ~= size(inArray,1)
	validIndices = [validIndices size(inArray,1)];
	inArray(end,:) = avg;
end

gapIndices = setdiff(1:size(inArray,1), validIndices);
validValues = inArray(validIndices,:);

gapValues = interp1(validIndices, validValues, gapIndices, 'cubic');

outArray = inArray;
outArray(gapIndices,:) = gapValues;
