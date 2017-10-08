% This is derived from:
% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
% =========================================================================

clear;clc;close all;
disp('Workspace and command window have been cleared.');
disp('Figures have been closed.');
disp('----------------------------------------------------------');

%get current working directory to return to at the end of this skript
origWorkingDir = pwd;
cd('C:\Users\dbak576\Desktop\CEINMS'); %ADJUST THIS DUNCAN

if exist('subjectInfo','var')
    doNotAutoLoadSubjectInfo='true';
else
    doNotAutoLoadSubjectInfo='false';
end
loadGenAllSubjDataAndDirInWorkspace

global useActivationScale;
global activationScaleRange;                             
useActivationScale = false;
activationScaleRange = '0.1 0.7';

global objectiveFunctionType;
objectiveFunctionType = 'minimizeTorqueError'; %'minimizeTorqueErrorAndActivation'

global tendonType;
tendonType = 'stiff'; %'equilibriumElastic';

% create subject XML from .osim
% creates uncalibrated.xml in ceinms/uncalibratedSubjects/
batchConvertOsimToSubjectXml

% creates excitationGenerator, execution files, trial xml files and
% trial_contactmodel xml files.
batchWriteExecutionXml

% creates the calibration setup
batchWriteCalibrationXml

% return to original working directory
cd(origWorkingDir);