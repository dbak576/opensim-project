function [text,name,attr,childs,textflag] = getNodeData(theNode)
    % Create structure of node info.
    
    %make sure name is allowed as structure name
    name = toCharArray(getNodeName(theNode))';
    name = strrep(name, '-', '_dash_');
    name = strrep(name, ':', '_colon_');
    name = strrep(name, '.', '_dot_');

    attr = parseAttributes(theNode);
    if (isempty(fieldnames(attr))) 
        attr = []; 
    end
    
    %parse child nodes
    [childs,text,textflag] = parseChildNodes(theNode);
    
    if (isempty(fieldnames(childs)) && isempty(fieldnames(text)))
        %get the data of any childless nodes
        % faster than if any(strcmp(methods(theNode), 'getData'))
        % no need to try-catch (?)
        % faster than text = char(getData(theNode));
        text.(textflag) = toCharArray(getTextContent(theNode))';
    end
    
end