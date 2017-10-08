% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% load all subjects Data and Directories in Workspace for Controls
% you may not use all of the variables generated in all scripts
% the goal is to keep consistency in resused variables in all scripts
% nothing here is dependent on already generated data, so this should not cause errors
% todo:
%==========================================================================

if exist('massBatch','var')
    if strcmp(massBatch,'true'); %useful if batch processing everything
        disp('did not load new data, it has previously been loaded for mass batching')
    end
else
    if ~exist('doNotAutoLoadSubjectInfo','var') %allows it to run by itself without errors
        doNotAutoLoadSubjectInfo='false';
    end
    %% CHANGE DIRECTORIES HERE (all directories have \ at the end)
    % all following folder based on these root directories (as long as you keep it consistent)
    dirViconRoot='C:\Users\dbak576\Desktop\Other\';
    dirRoot='C:\Users\dbak576\Desktop\CEINMS\'; %inputData and ElaboratedData should be located here
    dirMOTONMSsource='C:\MATLAB\MOtoNMS-batch\src\';
    %These ids do not have to be the same, saves from regenerating all data
    idMOTONMS='StanceEMG'; %used in MOTONMS
    idOPENSIM='StanceEMG'; %to be able to use different configurations in OpenSim
    idCEINMS='StanceEMG'; %to be able to use different configurations in ceinms
    
    model='.osim'; %hardcoded to be subject + this suffix, change as needed
    
    %% enviromental variables
    % best to not include environmental path in your opensim install (GUI does not need path anyways)
    pathOriginal=getenv('PATH');
    pathOpenSim64='C:\OpenSim 3.3\bin\'; %location of installed opensim (usually with MATLAB API enabled)
    pathCeinmsOpenSim='C:\OpenSim 3.3\bin\'; %compiled OpenSim for CEINMS, if this nis not the same as above
    %% subject information
    if strcmp(doNotAutoLoadSubjectInfo,'false')
        %============= CHANGE SUBJECT INFO HERE =============
        % {subject, emgSide, footStrike, gender}
        % emgSide: L assumes EMGs are on left leg
        % footStrike: L assumes first foot hits FP2, then R hit FP1. change to your setup.
        %            This also assumes all trials are the same (which may not be true for)
        %            Fix if required for your data
        % FOOTSTRIKE NOT USED!!!
        
        %This is not true for my subjects... e.g. H20s1 SlowWalk is
        %different from Walk
        subjectInfo={...
            'H20s1','R','R','M';
            'H21s1','L','L','F';
            'H22s1','L','L','F';
            'H23s1','R','L','M';
            'H24s1','L','L','M';
            'H25s1','R','L','M';
            'H26s1','R','L','F';
            'H27s1','R','L','F';
            'H28s1','L','L','F';
            'H30s1','L','L','F';
            };
        
        %year, cm, kg
        % NOTE: only mass is important for ID
        ageHeightMass=[...
            67.87, 170.6,  76.2;  %H20s1
            68.87, 165.2,  64.4;  %H21s1
            55.77, 158.8,  70.5;  %H22s1
            66.63, 172.5,  76.5;  %H23s1
            63.52, 176.2,  84.3;  %H24s1
            54.50, 181.7, 108.4;  %H25s1
            49.84, 165.7, 101.6;  %H26s1
            59.58, 167.0,  83.7;  %H27s1
            63.41, 150.0,  80.15; %H28s1
            58.71, 167.0,  57.9;  %H30s1
            ];
        
        disp('subject data has been loaded from script')
        
    else %useful if only wanting a few subjects (define in script), but still wanting to generate consistent directories
        disp('----------------------------------------------------------')
        disp('subject info has already been provided, generating folders')
        disp('----------------------------------------------------------')
    end
    %============================================================
    
    subject=subjectInfo(:,1)';
    emgSide=subjectInfo(:,2)';
    footStrike=subjectInfo(:,3)';
    gender=subjectInfo(:,4)';
    
    age=ageHeightMass(:,1);
    height=ageHeightMass(:,2)*0.01; %convert cm to m
    massOriginal=ageHeightMass(:,3);
    
    %mean and std of subjects
    meanBW=mean(massOriginal);
    stdBW=std(massOriginal);
    meanHeight=mean(height);
    stdHeight=std(height);
    meanAge=mean(age);
    stdAge=std(age);
    
    %% processing information
    fcut_coordinates=6;
    
    %has to be exactly one thes, as it coincide with template filenames {'Openloop','Hybrid', 'Assisted', 'StaticOpt'}
    executionModes={'Openloop' 'Hybrid' 'Assisted' 'StaticOpt'};
    nExMode=length(executionModes);
    
    %% =========== shouldn't have to change anything below here ===========
    dirInput=[dirRoot 'InputData\'];
    dirElab=[dirRoot 'ElaboratedData\'];
    dirMOtoNMSxml=[dirMOTONMSsource 'XMLgenerator\'];
    nSubject=length(subject);
    
    %% Preallocate Variables (ugly but allevaites memory issues later on)
    dirInputSubj = cell(1,nSubject);
    dirElabSubj = cell(1,nSubject);
    dirSessionSubj = cell(1,nSubject);
    dirElabDynamic = cell(1,nSubject);
    dirStaticElab = cell(1,nSubject);
    modelFile = cell(1,nSubject);
    modelFileFullPath = cell(1,nSubject);
    %OPENSIM
    dirScaleModels = cell(1,nSubject);
    dirIK = cell(1,nSubject);
    dirID = cell(1,nSubject);
    dirMuscleAnalysis = cell(1,nSubject);
    dirSO = cell(1,nSubject);
    dirJCF = cell(1,nSubject);
    OpenSimSide= cell(1,nSubject);
    %CEINMS
    dirCeinms = cell(1,nSubject);
    dirCalSubj = cell(1,nSubject);
    dirUnCal = cell(1,nSubject);
    dirExcitationGen = cell(1,nSubject);
    dirExecution = cell(1,nSubject);
    dirTrials = cell(1,nSubject);
    
    for s=1:nSubject %all following folders saved in structure array according to subject
        %MOTONMS
        dirInputSubj{s}=[dirInput subject{s} '\'];
        dirElabSubj{s}=[dirElab subject{s} '\'];
        dirSessionSubj{s}=[dirElabSubj{s} 'sessionData\'];%all data from c3d converted in this folder
        dirElabDynamic{s}=[dirElabSubj{s} 'dynamicElaborations\' idMOTONMS '\'];
        dirStaticElab{s}=[dirElabSubj{s} 'staticElaborations\'];
        %OPENSIM
        dirScaleModels{s}=dirStaticElab{s};
        modelFile{s}=[subject{s} model]; % <---CHANGE THIS IF YOUR MODEL NAMING CONVENTION IS DIFFERENT
        modelFileFullPath{s}=[dirScaleModels{s} modelFile{s}];
        dirIK{s}=[dirElabSubj{s} 'inverseKinematics\' idOPENSIM '\'];
        dirID{s}=[dirElabSubj{s} 'inverseDynamics\' idOPENSIM '\'];
        dirMuscleAnalysis{s}=[dirElabSubj{s} 'muscleAnalysis\' idOPENSIM '\'];
        dirSO{s}=[dirElabSubj{s} 'staticOpt\' idOPENSIM '\'];
        dirJCF{s}=[dirElabSubj{s} 'jointcontactAnalysis\' idOPENSIM '\'];
        %CEINMS
        dirCeinms{s}=[dirElabSubj{s} 'ceinms\'];
        dirCalSubj{s}=[dirCeinms{s} 'calibratedSubjects\'];
        dirUnCal{s}=[dirCeinms{s} 'uncalibratedSubjects\'];
        dirExcitationGen{s}=[dirCeinms{s} 'excitationGenerators\'];
        dirExecution{s}=[dirCeinms{s} 'execution\'];
        dirTrials{s}=[dirCeinms{s} 'trials\' idMOTONMS '\'];
        %CEINMS Execution Output
        for exMode=1:nExMode
            dir.CeinmsEx.(executionModes{exMode}){s}=[dirExecution{s} executionModes{exMode} '\'];
        end
        
        if strcmp(emgSide{s},'L')
            OpenSimSide{s}='l';
        elseif strcmp(emgSide{s},'R')
            OpenSimSide{s}='r';
        else
            error('emgSide not defined')
        end
        
    end
    
    disp('folders have been generated')
    
end