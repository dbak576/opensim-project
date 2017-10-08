% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
function writeCeinmsSetupTrialXml(subjectFile,inputDataFile,executionFile,excitationGeneratorFile,outputDirectory,outputXmlFilename,contactModelFile)

subjectXmlTemplateFilename = '../Templates/ceinmsSetupWalk1.xml';

prefXmlRead.Str2Num = 'never';
tree = xml_read(subjectXmlTemplateFilename, prefXmlRead);

tree.subjectFile = subjectFile; %../calibratedSubjects/subjectCalibrated.xml
tree.inputDataFile = inputDataFile; %../trials/ISB15/Walk1.xml
tree.executionFile = executionFile; %executionOpenloop.xml
tree.excitationGeneratorFile = excitationGeneratorFile; %../excitationGenerators/excitationGenerator16to34R.xml
tree.outputDirectory = outputDirectory; %outputData/Walk1/

if nargin==6
    tree=rmfield(tree, 'contactModelFile');
end

if nargin>6
    tree.contactModelFile = contactModelFile; %../trials/ISB15/Walk1_contactModelFile.xml
end

prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
xml_write(outputXmlFilename, tree, 'ceinms', prefXmlWrite);
end