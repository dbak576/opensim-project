docNode = com.mathworks.xml.XMLUtils.createDocument('toc');

toc = docNode.getDocumentElement;
toc.setAttribute('version','2.0');

product = docNode.createElement('tocitem');
product.setAttribute('target','upslope_product_page.html');
product.appendChild(docNode.createTextNode('Upslope Area Toolbox'));
toc.appendChild(product)

product.appendChild(docNode.createComment(' Functions '));

functions = {'demFlow','facetFlow','flowMatrix','pixelFlow'};
for idx = 1:numel(functions)
    curr_node = docNode.createElement('tocitem');
    
    curr_file = [functions{idx} '_help.html']; 
    curr_node.setAttribute('target',curr_file);
    
    % Child text is the function name.
    curr_node.appendChild(docNode.createTextNode(functions{idx}));
    product.appendChild(curr_node);
end

xmlwrite('info.xml',docNode);
type('info.xml');