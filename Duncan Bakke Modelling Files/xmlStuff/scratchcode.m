%Set up xml files for "Walk1".
exLoadsFilename = 'ExternalLoads.xml';
IKfilename = 'IKSetup.xml';
IDfilename = 'IDSetup.xml';
title = 'Walk1';
model = 'H20s1';
timerange = [1.2 3.8];

err1 = changeIKXMLFile(IKfilename,title,timerange,model,Mlabels,badMarkerNames);
xmlShorten(strcat(title,IKfilename));
err2 = changeIDXMLFile(IDfilename,title,timerange,model,8);
xmlShorten(strcat(title,IDfilename));
err3 = changeLoadXMLFile(exLoadsFilename,title);
xmlShorten(strcat(title,exLoadsFilename));