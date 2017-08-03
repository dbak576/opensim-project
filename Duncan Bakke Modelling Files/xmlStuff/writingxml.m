docNode = xmlread('ExternalLoads.xml');

a = docNode.getElementsByTagName('ExternalLoads');
        b = a.item(0);
        c = b.getElementsByTagName('datafile');
        d = c.item(0);
        d.getFirstChild.setData('LOOK AT ME')

xmlFileName = 'productfile.xml';
xmlwrite(xmlFileName,docRootNode);