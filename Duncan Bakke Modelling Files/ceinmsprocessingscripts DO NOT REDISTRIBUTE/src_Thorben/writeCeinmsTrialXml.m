% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% write trial xml
% Todo: a better way to write moment arm files?
function writeCeinmsTrialXml(muscleTendonLengthFile,excitationsFile,momentArmsFile,externalTorquesFile,outputXmlFilename)

subjectXmlTemplateFilename = '../Templates/Walk1.xml';


prefXmlRead.Str2Num = 'never';
tree = xml_read(subjectXmlTemplateFilename, prefXmlRead);

tree.muscleTendonLengthFile = muscleTendonLengthFile;%../../../muscleAnalysis/StanceEMG/Walk1/analyzeTool_MuscleAnalysis_Length.sto
tree.excitationsFile = excitationsFile;%../../../dynamicElaborations/StanceEMG/Walk1/emg.mot

for k=1:size(momentArmsFile,1) %template has default 2 files, if only 1, will cause error 
    tree.momentArmsFiles.momentArmsFile(1,k).CONTENT= momentArmsFile{k,2};%e.g. ../../../muscleAnalysis/StanceEMG/Walk1/analyzeTool_MuscleAnalysis_MomentArm_hip_rotation_l.sto
    tree.momentArmsFiles.momentArmsFile(1,k).ATTRIBUTE.dofName= momentArmsFile{k,1};%e.g hip_rotation_l
end

tree.externalTorquesFile=externalTorquesFile; %../../../inverseDynamics/StanceEMG/Walk1/inverse_dynamics.sto

prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
xml_write(outputXmlFilename, tree, 'inputData', prefXmlWrite);
end