% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
function writeContactOpenSimModelXml(osimModelFilename,motion,externalLoads,joints,outputXmlFilename)

subjectXmlTemplateFilename = '../Templates/Walk1_contactOpenSimModelFile.xml';

prefXmlRead.Str2Num = 'never';
tree = xml_read(subjectXmlTemplateFilename, prefXmlRead);
tree.fromOpenSim.osimModel=osimModelFilename;%../../../staticElaborations/ISB15/C01s1_LLM_Hip_OA.osim
tree.fromOpenSim.motion=motion;%../../../inverseKinematics/ISB15/Walk2/ik.mot
tree.fromOpenSim.externalLoads=externalLoads;%../../../inverseDynamics/ISB15/Walk2/Setup/external_loads.xml
tree.fromOpenSim.joints=joints; %'hip_l ankle_l'
prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
xml_write(outputXmlFilename, tree, 'contactModel', prefXmlWrite);
end