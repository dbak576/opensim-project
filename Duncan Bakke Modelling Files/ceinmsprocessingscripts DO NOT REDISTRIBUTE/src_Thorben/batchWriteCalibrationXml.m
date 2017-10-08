% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% batch write calibration XML 
% run batchWriteCeinmsTrialAndContactModelXml and OSIMtoXML
%       calibration require trials XMLs and uncalibrated.xml
% CHECK calibration templates, modify to your naming convention as required
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
global objectiveFunctionType;
global tendonType;

prefCal.NMSmodelType='hybrid'; %'openLoop'
prefCal.tendonType= tendonType; %'stiff'; %'equilibriumElastic'; 'integrationElastic'
prefCal.activationType='exponential'; %'piecewise'
prefCal.objectiveFunction = objectiveFunctionType; %'minimizeTorqueError';% 'minimizeTorqueErrorAndActivation';
prefSetupCal.contact = 'none'; %'knee'; %'OpenSim'; %'MinTorq'

if strcmp(prefSetupCal.contact, 'knee')
    prefSetupCal.contactModelFile = 'contactKneeModel.xml';
    prefCal.objectiveFunction = 'torqueErrorAndSumKneeContactForces';
elseif strcmp(prefSetupCal.contact, 'OpenSim')
    prefSetupCal.contactModelFile = 'contactOpenSimModel.xml';
end

for s=1:nSubject 
    disp(subject{s}) 
    createDir(dirCalSubj{s});
    createDir(dirExcitationGen{s});

    if exist([dirExcitationGen{s} 'excitationGenerator16to34' emgSide{s} '.xml'], 'file')~=2 %copy excitation generator if doesn't exist
        copyfile(['..\Templates\excitationGenerator16to34' emgSide{s} '.xml'], dirExcitationGen{s});
    end

    trialsListW{s} = folderListGeneration([dirMuscleAnalysis{s} 'Walk*'],'yes'); %need this folder to run ceinms
    trialsListSW{s} = folderListGeneration([dirMuscleAnalysis{s} 'SlowWalk*'],'yes');

    nW = round(0.4*length(trialsListW{s})); %arbitrary number of trials to calibrate, change as needed 
    nSW = round(0.3*length(trialsListSW{s}));

    trialSet = ['../trials/' idOPENSIM '/' trialsListW{1,s}{1,1} '.xml']; %initialize set, change as needed
    if nW > 1
        for t=2:nW
            trialSet = [trialSet ' ../trials/' idOPENSIM '/' trialsListW{1,s}{1,t} '.xml'];
        end
    end
    for t=1:nSW
            trialSet = [trialSet ' ../trials/' idOPENSIM '/' trialsListSW{1,s}{1,t} '.xml'];
    end

    templateCalXML=['..\Templates\calibrationFile' emgSide{s} '.xml']; %can also give hard path
    jointsForCalibration{s}={['hip_flexion_' OpenSimSide{s} ' hip_adduction_' OpenSimSide{s} ' hip_rotation_' OpenSimSide{s} ' knee_angle_' OpenSimSide{s} ' ankle_angle_' OpenSimSide{s}]};
    calFile = ['calibrationFile' emgSide{s} '.xml'];
    dirCalFileOut=[dirCalSubj{s} calFile];

    writeCalibrationFileXml(templateCalXML, trialSet, jointsForCalibration{s}, dirCalFileOut, prefCal)

    %Setup Calibration file, using relative paths; can use hard as well, but need to change the following in XML
    calSetupFile = 'setupCalibration.xml';
    templateSetupCalXML = ['..\Templates\' calSetupFile];
    unCalSubFile = '../uncalibratedSubjects/uncalibrated.xml'; %should have been created from OSIMtoXML
    exGenerator=['../excitationGenerators/excitationGenerator16to34' emgSide{s} '.xml'];
    outCalFile = 'subjectCalibrated.xml';
    fileSetupCalOut = [dirCalSubj{s} calSetupFile];

    writeSetupCalibrationFileXml(templateSetupCalXML, unCalSubFile, exGenerator, calFile, outCalFile, fileSetupCalOut, prefSetupCal)

    if strcmp(prefSetupCal.contact, 'knee')
        fileCalContactOut = [dirCalSubj{s} prefSetupCal.contactModelFile];
        intercondyleDistance = getIntercondyleDistance(modelFileFullPath{s}, OpenSimSide{s}); %uses OpenSim API
        writeContactKneeModelXml(intercondyleDistance, OpenSimSide{s}, fileCalContactOut);
    elseif strcmp(prefSetupCal.contact, 'OpenSim') %this is not implemented in Calibration ATM
        fileCalContactOut = [dirCalSubj{s} prefSetupCal.contactModelFile];
        writeContactOpenSimModelXml(osimModelFilename,motion,externalLoads,joints,fileCalContactOut)
    end
end