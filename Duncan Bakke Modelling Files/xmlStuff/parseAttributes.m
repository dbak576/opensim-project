
function attributes = parseAttributes(theNode)
    % Create attributes structure.

    attributes = struct;
    if hasAttributes(theNode)
       theAttributes = getAttributes(theNode);
       numAttributes = getLength(theAttributes);

       for count = 1:numAttributes
            %attrib = item(theAttributes,count-1);
            %attr_name = regexprep(char(getName(attrib)),'[-:.]','_');
            %attributes.(attr_name) = char(getValue(attrib));

            %Suggestion of Adrian Wanner
            str = toCharArray(toString(item(theAttributes,count-1)))';
            k = strfind(str,'='); 
            attr_name = str(1:(k(1)-1));
            attr_name = strrep(attr_name, '-', '_dash_');
            attr_name = strrep(attr_name, ':', '_colon_');
            attr_name = strrep(attr_name, '.', '_dot_');
            attributes.(attr_name) = str((k(1)+2):(end-1));
       end
    end
end