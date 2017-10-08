% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% batch write all XMLs required for CEINM execution
% trial, setup trial, execution configuration, excitation generator, contact model
% using relative links, but "hardcoded"
% Todo: allow to choose relative paths
%     : a better way to write moment arm files? mostly hardcoded
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
%fcut_coordinates=6;
prefSetupEx.contact = 'none'; %'OpenSim'; %'knee'

if strcmp(prefSetupEx.contact, 'knee')
    prefSetupEx.contactModelFile = 'contactKneeModel.xml';
    %prefEx.objectiveFunction = 'torqueErrorAndSumKneeContactForces'; %is this needed like in calibration?
elseif strcmp(prefSetupEx.contact, 'OpenSim')
    prefSetupEx.contactModelFile = 'contactOpenSimModel.xml';
end

excitationGeneratorPassive = 'false'; %if true, will use passive excitation generator, only for testing, do not use

% write Contact Model Xml; write Trial Xml
for s=1:length(subject)
    disp(subject{s}) 

    if strcmp(prefSetupEx.contact, 'knee') %same contact model for all trials
        outputContactXmlFilename=[dirTrials{s} prefSetupEx.contactModelFile];
        intercondyleDistance = getIntercondyleDistance(modelFileFullPath{s}, OpenSimSide{s}); %uses OpenSim API
        writeContactKneeModelXml(intercondyleDistance, OpenSimSide{s}, outputContactXmlFilename);
    end
    
    jointsForContactModel{s}=['hip_' OpenSimSide{s} ' knee_' OpenSimSide{s} ' ankle_' OpenSimSide{s}];
    trialsList{s}=folderListGeneration(dirMuscleAnalysis{s}); %need this folder to run ceinms
    
    for t=1:length(trialsList{1,s})
        
        if strcmp(prefSetupEx.contact, 'OpenSim') %different contact model for each trials
            osimModelFilename=['../../../staticElaborations/' modelFile{s}];
            motion=['../../../inverseKinematics/' idOPENSIM '/' trialsList{1,s}{1,t} '/ik.mot'];
            externalLoads=['../../../inverseDynamics/' idOPENSIM '/' trialsList{1,s}{1,t} '/external_loads.xml'];
            ContactXmlFilename{s,t} = [trialsList{1,s}{1,t} '_' prefSetupEx.contactModelFile];
            outputContactXmlFilename=[dirTrials{s} ContactXmlFilename{s,t}];
            
            writeContactOpenSimModelXml(osimModelFilename,motion,externalLoads,jointsForContactModel{s},outputContactXmlFilename)
        end
        
        muscleTendonLengthFile=['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_Length.sto'];
        
        excitationsFile=['../../../dynamicElaborations/' idMOTONMS '/' trialsList{1,s}{1,t} '/emg.mot'];
        
        momentArmsFile={['hip_flexion_' OpenSimSide{s}] ['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_MomentArm_hip_flexion_' OpenSimSide{s} '.sto'];
        	['hip_adduction_' OpenSimSide{s}] ['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_MomentArm_hip_adduction_' OpenSimSide{s} '.sto'];
        	['hip_rotation_' OpenSimSide{s}] ['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_MomentArm_hip_rotation_' OpenSimSide{s} '.sto'];
        	['knee_angle_' OpenSimSide{s}] ['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_MomentArm_knee_angle_' OpenSimSide{s} '.sto'];
        	['ankle_angle_' OpenSimSide{s}] ['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_MomentArm_ankle_angle_' OpenSimSide{s} '.sto']};
        
        if strcmp(prefSetupEx.contact, 'knee') || strcmp(prefSetupEx.contact, 'OpenSim')
            momentArmsFileKnee = {['knee_varus_med_' OpenSimSide{s}] ['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_MomentArm_knee_varus_med_' OpenSimSide{s} '.sto'];
                                ['knee_valgus_lat_' OpenSimSide{s}] ['../../../muscleAnalysis/' idOPENSIM '/' trialsList{1,s}{1,t} '/analyzeTool_MuscleAnalysis_MomentArm_knee_valgus_lat_' OpenSimSide{s} '.sto']};

            momentArmsFile =[momentArmsFile; momentArmsFileKnee];
        end
        externalTorquesFile=['../../../inverseDynamics/' idOPENSIM '/' trialsList{1,s}{1,t} '/inverse_dynamics.sto'];
        outputTrialXmlFilename=[dirTrials{s} trialsList{1,s}{1,t} '.xml'];
        %write XML
        writeCeinmsTrialXml(muscleTendonLengthFile,excitationsFile,momentArmsFile,externalTorquesFile,outputTrialXmlFilename)
    end
end

% write setupTrials
for s=1:length(subject)
    createDir(dirExcitationGen{s})
    createDir(dirExecution{s})
    
    if strcmp(excitationGeneratorPassive,'false')
        excitationGenerator{s}=['excitationGenerator16to34' emgSide{s} '.xml'];
        copyfile(['../Templates/' excitationGenerator{s}],dirExcitationGen{s});
        excitationGeneratorFile{s}=['../excitationGenerators/' excitationGenerator{s}];
    elseif strcmp(excitationGeneratorPassive,'true')
        excitationGenerator{s}=['excitationGeneratorPassive' emgSide{s} '.xml']; %passive has all weights = 0
        copyfile(['../Templates/' excitationGenerator{s}],dirExcitationGen{s});
        excitationGeneratorFile{s}=['../excitationGenerators/' excitationGenerator{s}];
    else
        error('define excitationGeneratorPassive true or false')
    end
    
    subjectFile{s}=['../calibratedSubjects/subjectCalibrated.xml'];
    
    for m=1:length(executionModes) %executionModes defined in loadGenAllSubjDataAndDirInWorkspace
        if strcmp(executionModes{m},'Openloop'); %Todo: write xml instead of copy
            executionFile{s,m}='executionOpenloop.xml';
        else
            executionFile{s,m}=['execution' executionModes{m} emgSide{s} '.xml'];
        end
        copyfile(['../Templates/' executionFile{s,m}],dirExecution{s});

        for t=1:length(trialsList{1,s})
            inputDataFile=['../trials/' idCEINMS '/' trialsList{1,s}{1,t} '.xml'];
            outputDirectory=[executionModes{m} '/' trialsList{1,s}{1,t} '/'];
            createDir([dirExecution{s} outputDirectory]);

            outputXmlFilename=[dirExecution{s} executionModes{m} 'Setup' trialsList{1,s}{1,t} '.xml'];
            
            %write XML
            if strcmp(prefSetupEx.contact, 'knee')
                contactModelFile=['../trials/' idCEINMS '/' prefSetupEx.contactModelFile];
                writeCeinmsSetupTrialXml(subjectFile{s},inputDataFile,executionFile{s,m},excitationGeneratorFile{s},outputDirectory,outputXmlFilename,contactModelFile);
            elseif strcmp(prefSetupEx.contact, 'OpenSim')
                contactModelFile=['../trials/' idCEINMS '/' ContactXmlFilename{s,t}];
                writeCeinmsSetupTrialXml(subjectFile{s},inputDataFile,executionFile{s,m},excitationGeneratorFile{s},outputDirectory,outputXmlFilename,contactModelFile);
            else
                writeCeinmsSetupTrialXml(subjectFile{s},inputDataFile,executionFile{s,m},excitationGeneratorFile{s},outputDirectory,outputXmlFilename);
            end
        end
    end
end

% write execution file
global tendonType;
executionXmlTemplateFile = '../Templates/executionOpenloop.xml';
prefXmlRead.Str2Num = 'never';
[tree,RootNameExe,~] = xml_read(executionXmlTemplateFile, prefXmlRead);

prefDef.NMSmodelType = 'hybrid'; %'openLoop' - not sure if this is in Calibration
prefDef.tendonType = tendonType; %'stiff' 'integrationElastic'
prefDef.activationType = 'exponential'; %'piecewise'

tree.NMSmodel.type.(prefDef.NMSmodelType) = struct;
tree.NMSmodel.activation.(prefDef.activationType) = struct;
tree.NMSmodel.tendon.(prefDef.tendonType) = struct;
tree.offline = struct;

prefXmlWrite.StructItem = true;  % allow arrays of structs to use 'item' notation
prefXmlWrite.CellItem   = true;
xml_write([dirExecution{1} 'executionOpenloop.xml'],tree,RootNameExe,prefXmlWrite);