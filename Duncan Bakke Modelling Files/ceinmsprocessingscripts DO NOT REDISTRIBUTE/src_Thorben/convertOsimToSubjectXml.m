%__________________________________________________________________________
% Author: Claudio Pizzolato, August 2014
% email: claudio.pizzolato@griffithuni.edu.au
% DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
%
% modified to a function by Hoa X. Hoang
function convertOsimToSubjectXml(subjectID,osimModelFilename,dofList,outputUnCalXmlFilename, subjectXmlTemplateFilename)
import org.opensim.modeling.*

% baseDir = 'Z:\HipOA_Data\ElaboratedData';
% subjectID = 'C01s1';
% osimModelPath = 'staticElaborations\Static_C01s1\ISB15';
% osimModelName = 'C01s1_FullBodyModel_HipOA_Adjusted.osim';
% osimModelFilename = [baseDir '\' subjectID '\' osimModelPath '\' osimModelName ];
if ~exist('subjectXmlTemplateFilename','var')
subjectXmlTemplateFilename = 'Templates/subjectTemplate.xml';
%subjectXmlTemplateFilename = '../Templates/subjectTemplate_MillardCurve.xml';
end
%dofList = {'hip_flexion_r', 'knee_flexion_r', 'ankle_angle_r'};
dofList = {'hip_flexion_r', 'hip_adduction_r', 'hip_rotation_r', 'knee_angle_r', 'ankle_angle_r'};

dofToMuscles = containers.Map();
osimModel = Model(osimModelFilename);
for i=1:length(dofList)
    currentDofName = dofList{i}; 
    dofToMuscles(currentDofName) = getMusclesOnDof(currentDofName, osimModel); 
end

allMuscles = dofToMuscles.values;
i = 1:length(allMuscles);
allMuscles = unique(sort([allMuscles{i}]));

prefXmlRead.Str2Num = 'never';
tree = xml_read(subjectXmlTemplateFilename, prefXmlRead);
global useActivationScale;

for iMuscle=1:length(allMuscles)
   currentMuscleName = allMuscles{iMuscle};
   osimMuscle = osimModel.getMuscles().get(currentMuscleName);
   tree.mtuSet.mtu(iMuscle).name = currentMuscleName;
   tree.mtuSet.mtu(iMuscle).c1 =  -0.5;
   tree.mtuSet.mtu(iMuscle).c2 =  -0.5;
   tree.mtuSet.mtu(iMuscle).shapeFactor = 0.1;
   if exist('useActivationScale','var') && useActivationScale == true
       tree.mtuSet.mtu(iMuscle).activationScale = 1.0;
   end
   tree.mtuSet.mtu(iMuscle).optimalFibreLength =  osimMuscle.getOptimalFiberLength();
   tree.mtuSet.mtu(iMuscle).pennationAngle = osimMuscle.getPennationAngleAtOptimalFiberLength();
   tree.mtuSet.mtu(iMuscle).tendonSlackLength = osimMuscle.getTendonSlackLength();
   tree.mtuSet.mtu(iMuscle).maxIsometricForce = osimMuscle.getMaxIsometricForce();
   tree.mtuSet.mtu(iMuscle).strengthCoefficient = 1.0; 
end

if exist('useActivationScale','var') && useActivationScale == true
    structureOrder = {'name','c1','c2','shapeFactor','activationScale','optimalFibreLength','pennationAngle','tendonSlackLength','maxIsometricForce','strengthCoefficient'};
    tree.mtuSet.mtu = orderfields(tree.mtuSet.mtu,structureOrder);
end

for iDof=1:length(dofList)
    dof = dofList{iDof};
    tree.dofSet.dof(iDof).name = dof;
    muscles = dofToMuscles(dof);
    muscleList = muscles{1};
    for j = 2:length(muscles)
        muscleList = [muscleList, ' ', muscles{j}];
    end
    tree.dofSet.dof(iDof).mtuNameSet = muscleList;
end
tree.calibrationInfo.uncalibrated.subjectID = subjectID;
tree.calibrationInfo.uncalibrated.additionalInfo = 'TendonSlackLength and OptimalFibreLength scaled with Winby-Modenese';
prefXmlWrite.StructItem = false;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = false;
% outputUnCalXmlFilename = [baseDir '\' subjectID '\ceinms\uncalibratedSubjects\uncalibrated.xml'];
xml_write(outputUnCalXmlFilename, tree, 'subject', prefXmlWrite);