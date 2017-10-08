% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% uncalibrated subject xml generation for CEINMS
% Todo:
%% Load subject data
% subjectInfo={...
%    'C01s1','L','L','F'; %uncomment if wanting to define subjects here, instead of loadGenAllSubjDataAndDirInWorkspace.m
%        }; 
% ageHeightMass=[... 
%     49.53, 162.5, 54; %C01s1
%        ]; 


if exist('subjectInfo','var')
    doNotAutoLoadSubjectInfo='true';
else
    doNotAutoLoadSubjectInfo='false';
end
loadGenAllSubjDataAndDirInWorkspace

%%
% fcut_coordinates=6;
if ~exist('subjectXmlTemplateFilename','var')
    subjectXmlTemplateFilename = '../Templates/subjectTemplate.xml';
    %subjectXmlTemplateFilename = '../Templates/subjectTemplate_MillardCurve.xml';
end
for s=1:length(subject)
	createDir(dirUnCal{s});
    
    outputUnCalXmlFilename{s} = [dirUnCal{s} 'uncalibrated.xml'];
	
    dofList{s} = {['hip_flexion_' OpenSimSide{s}], ['hip_adduction_' OpenSimSide{s}], ['hip_rotation_' OpenSimSide{s}], ['knee_angle_' OpenSimSide{s}], ['ankle_angle_' OpenSimSide{s}]};

    convertOsimToSubjectXml(subject{s},modelFileFullPath{s},dofList{s},outputUnCalXmlFilename{s},subjectXmlTemplateFilename)
    
    disp(['generated uncalibrated subject xml for ' subject{s}]) 
end