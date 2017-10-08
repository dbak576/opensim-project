function err = convertC3DtoTRCandMOT(model, title, directory)
%% convertC3DtoTRCandMOT
% Convert c3d data file to .trc and .mot for OpenSim
% Original Author: Ajay Seth, Sep 2007, Stanford University
% Edited by Duncan Bakke, 2017, Auckland Bioengineering Institute

% NOTE: This code is being saved for use as part of a project
% undertaken by Duncan Bakke at the Auckland Bioengineering Institute.
% The original can be found at
% http://simtk-confluence.stanford.edu:8080/display/OpenSim/Tools+for+Preparing+Motion+Data
% Delp SL, Anderson FC, Arnold AS, Loan P, Habib A, John CT, Guendelman E, Thelen DG. 
% OpenSim: Open-source Software to Create and Analyze Dynamic Simulations of Movement. 
% IEEE Transactions on Biomedical Engineering. (2007) 

%% Inputs:
% model = name of subject
% title = prefix for all files (replaces the below)
% directory = file directory for results

%% Outputs:
% err NEEDS WORK
err = 0;

%% Read C3D to TRC
% Define indices in the AnalogSignals block that correspond to columns of
% GRF data (forces and moments).
% NOTE that the tInfo section below is specific to H20 series trials! May
% be worth deleting and re-thinking.

% --------DEFINING tInfo FOR H2ns1 SET------------------------------------
tInfo.vert_force_label = 'Fz';  % This identifies the vertical direction in the gait lab for the force plates
tInfo.FP = [2, 1]; % This is the order the person hits the force plates (in some gait labs they can hit 3 before 2, etc.)
tInfo.offsetInds = 1:12; %The indices of the force plate data in the analog portion of the C3D file 
tInfo.GRFinds = 1:12; %Identifies the indices of the force plate data in the C3D file
tInfo.rotation = [0 1 0; 0 0 1; 1 0 0]; %90 degrees about y, then x (OpenSim custom)
if strcmp(model,'H20s1')
    tInfo.limb = {'L','R'}; % i.e. the left foot is on plate 1 (the SECOND plate)
else
    tInfo.limb = {'R','L'}; % i.e. the left foot is on plate 2 (the FIRST plate)
end
% -------------------------------------------------------------------

warningMessage = false;

if (isfield(tInfo, 'GRFinds')),
    grfInds = tInfo.GRFinds;
else
    % default
    grfInds = 1:12;
end

% Used to select EMG channels from AnalogSignals (Not applicable for H2Ns1 set)
emgPrefix = 'EM';

% define vertical direction
if isfield(tInfo, 'vert_force_label'),
    isFZ = 1;
else
    isFZ = 0;
end

offsetInds = [];
if isfield(tInfo, 'offsetInds'),
    offsetInds = tInfo.offsetInds;
end

c3dFilename = fullfile(pwd,model,strcat(title,'.c3d'));

% Use "readC3D.m" to read in the C3D data (largely unchanged from Seth's
% original, review if needed, but pulls all data out quite effectively.)
[Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels, AUnits, AnalogFrameRate,~,ParameterGroup,~]... 
    = readC3D(c3dFilename, [], offsetInds); % Note: 2nd argument if you want to limit the number of markers

% number of markers
nM = length(MLabels);

% Bound by the first and last heel strikes
tInfo.Tstart = min(ParameterGroup(7).Parameter(7).data(2,1:4))-(ParameterGroup(1).Parameter(1).data(1)*0.005);
tInfo.Tend = max(ParameterGroup(7).Parameter(7).data(2,1:4))-(ParameterGroup(1).Parameter(1).data(1)*0.005);

% video time
[nvF, ~] = size(Markers);
vFrms = (1:nvF)';
vTime = 1/VideoFrameRate*(vFrms);

% analog time
[naF, ~] = size(AnalogSignals);
aFrms = (1:naF)';
aTime = 1/AnalogFrameRate*(aFrms);

% trim data region of interest by time if indicated
if isfield(tInfo, 'Tstart')
    t1 = tInfo.Tstart;
    t2 = tInfo.Tend;
    % get corresponding indices in video (markers) and analog data
    vInds = find(vTime >= t1 & vTime <= t2);
    aInds = find(aTime >= t1 & aTime <= t2);
    % trim the Marker data 
    vFrms = vFrms(vInds);
    %nvF = length(vFrms); THIS COULD BE IT
    vTime = vTime(vInds);
    Markers = Markers(vInds,:);
    % trim the Analog data 
    %aFrms = aFrms(aInds); THIS COULD BE IT
    aTime = aTime(aInds);
    AnalogSignals = AnalogSignals(aInds,:);
end
% After trimming off the ends see if we have any missing markers
[missInds, missCols] = find(abs(Markers) < 1e-2);
uniqueCols = unique(missCols);
missMarks = ~mod(uniqueCols,3).*uniqueCols/3;
missMarks = missMarks(find(missMarks)); %#ok<FNDSB>
allInds = 1:size(Markers);
garbage = [];
badMarkerIndex = 1;
badMarkerNames = {'FAKE'};
if any(missMarks),
    for I = missMarks'
        gapInds = missInds(find(missCols == 3*I)); %#ok<FNDSB>
        mstring = MLabels(I);
        if  length(gapInds) > 10
            if warningMessage == true
            message = sprintf('Marker %s has more than 10 frames missing.', mstring{1}); 
            warning(message); %#ok<SPWRN>
            end
            garbage = [garbage I]; %#ok<AGROW>
            badMarkerNames(badMarkerIndex) = mstring(1);
            badMarkerIndex = badMarkerIndex + 1;
        else
            % interpolate
            if warningMessage == true
            disp(['Interpolating gap for Marker ', mstring{1}]); 
            end
            goodInds = setdiff(allInds, gapInds);
            gapVals = interp1(goodInds, Markers(goodInds, 3*I-2:3*I), gapInds, 'spline');
            Markers(gapInds,3*I-2:3*I) = gapVals;
        end
    end
end

% remove garbage markers
if any(garbage),
    good = setdiff(1:nM, garbage);
    MLabels = MLabels(good);
    goodCols = [];
    for I = 1:length(good),
        goodCols = [goodCols, 3*good(I)-2:3*good(I)]; %#ok<AGROW>
    end
    Markers = Markers(:,goodCols);
end
    
% Set rotation matrix for changing into OpenSim system
rot90aboutX = [1 0 0;  0 0 1; 0 -1 0];
if isfield(tInfo, 'rotation')
    rot = tInfo.rotation;
else
    rot = rot90aboutX;
end

% If the coordinate frame does not have FY as vertical
if  isFZ,
    Markers = rot3DVectors(rot, Markers);
end
trcFilename = strcat(title,'.trc');
err = writeMarkersToTRC(trcFilename, Markers, MLabels, VideoFrameRate, vFrms, vTime, 'mm');


%% GRF Data
% find the Analog Signals correspondint to vertical ground reaction forces
vert_f_block = (ismember(char(ALabels), tInfo.vert_force_label));
% has to match vert_force_label characters
vert_f_inds = find(sum(vert_f_block,2)>1); %#ok<NASGU>

%vert_forces = AnalogSignals(:,vert_f_inds);
% if max(max(abs(vert_forces))) > max(max(vert_forces)), % force has negative peaks
%     vert_forces = -vert_forces;
%     AnalogSignals(:,vert_f_inds) = vert_forces;
% end


% Check if any of the units are in terms of mm
mmBlock = ismember(strvcat(AUnits), 'mm'); %#ok<DSTRVCT>
% get column indices 
mmInds = find(sum(mmBlock,2)>1);

if mmInds,
    % HACK to get a rid of junk '3M' units in some moment data
    mmInds = [mmInds; strmatch('3M', AUnits)]; %#ok<MATCH2>
end

% change all mm units to meters in one shot
AnalogSignals(:,mmInds) = 0.001 * AnalogSignals(:,mmInds);

% Detect gait events from the vertical GRF
%[icFromGRF, toFromGRF] = findIctoFromGRF(abs(vert_forces), 0.01);
% Write motion file with ground reaction forces and center of pressure
% First get the necessary force-plate (fp) information
f = getForcePlatformFromC3DParameters(ParameterGroup);
% convert forec-plate coordinate to m from mm:
for I = 1:length(tInfo.FP),
    f(I).corners = 0.001*f(I).corners;
    f(I).origin = 0.001*f(I).origin;
end

fpForces = AnalogSignals(:,grfInds);
fpForces = smooth(fpForces,100,AnalogFrameRate);

% Convert FP forces and moments to COP and torque about vertical axis
actionGRFTz_FP =  computeCOPfromGRFM(fpForces, f, AnalogFrameRate);

% Convert 'action' forces, Tz, and COP from the FP coordinate systems
% to the lab coordinate system, for each FP that was hit.
actionGRFTz_lab = convert_FPtoLabCS(actionGRFTz_FP, f);

% Convert 'action' forces and moments to 'reaction' forces and moments,
% for each FP that was hit (in the lab coordinate system).
% reactionGRFTz_lab = convert_actionToReaction(actionGRFTz_lab);

% Superimpose GRFTz data from the FP hits corresponding to each limb.
% GRFTz_byLimb = get_GRFTzByLimb(reactionGRFTz_lab, tInfo)

GRFTz_byLimb = get_GRFTzByLimb(actionGRFTz_lab, tInfo);
CutOffFrequency = 10;
GRFTz_byLimb = clean_grfs(GRFTz_byLimb, AnalogFrameRate, CutOffFrequency, tInfo, aTime, vTime);

% Plot the GRFTz data for each limb, and interactively eliminate
% discontinuities in the COP trajectories.
% COP_smoothed = smoothCOP(GRFTz_byLimb, naF, AnalogFrameRate, 0, tInfo)

% NOTE: If you interpolate GRF data to the video framerate, replace aTime
% and AFR below with their respective counterparts.
motFilename = strcat(title,'.mot');
writeGRFsToMOT(GRFTz_byLimb, aTime(1), AnalogFrameRate, motFilename, isFZ);

%% EMG Data

% Assume everything that is EMG data has the emgPrefix
% Check if any of the ALabels contain the emgPrefix
emgBlock = ismember(strvcat(ALabels), emgPrefix); %#ok<DSTRVCT>
% get column indices 
emgInds = find(sum(emgBlock,2)>1);

rawEMG = AnalogSignals(:,emgInds);

% process the EMG data
[proEMG, ~] = processEMG(rawEMG, AnalogFrameRate);

% for a structure for writing to file
emg.data = [aTime, proEMG];
emg.labels = {'time', ALabels{emgInds}};

emgFilename = strcat(title,'_EMG.mot');
write_motionFile(emg, emgFilename);

%% XML Files
exLoadsFilename = 'ExternalLoads.xml';
IKfilename = 'IKSetup.xml';
IDfilename = 'IDSetup.xml';
MuscleAnalysisfilename = 'MuscleAnalysisSetup.xml';
MuscleForceDirectionfilename = 'MuscleForceDirectionSetup.xml';
timerange = [tInfo.Tstart tInfo.Tend];
IKerr = changeIKXMLFile(IKfilename,title,timerange,model,directory,MLabels,badMarkerNames); %#ok<NASGU>
xmlShorten(strcat(title,IKfilename));
IDerr = changeIDXMLFile(IDfilename,title,timerange,model,directory,6); %#ok<NASGU>
xmlShorten(strcat(title,IDfilename));
ExLerr = changeLoadXMLFile(exLoadsFilename,title,model,directory); %#ok<NASGU>
xmlShorten(strcat(title,exLoadsFilename));
MAerr = changeMuscleAnalysisXMLFile(MuscleAnalysisfilename,title,timerange,model,directory);
xmlShorten(strcat(title,MuscleAnalysisfilename));
MAerr = changeMuscleForceDirectionXMLFile(MuscleForceDirectionfilename,title,timerange,model,directory);
xmlShorten(strcat(title,MuscleForceDirectionfilename));

%% Move all files
mkdir('Output',model);
mkdir(strcat('Output','\',model),title);
newFolder = fullfile(pwd,'Output',model,title);

fullIKfilename = strcat(title,IKfilename);
movefile(fullIKfilename, newFolder);
fullIDfilename = strcat(title,IDfilename);
movefile(fullIDfilename, newFolder);
fullexLoadsFilename = strcat(title,exLoadsFilename);
movefile(fullexLoadsFilename, newFolder);
fullMALoadsFilename = strcat(title,MuscleAnalysisfilename);
movefile(fullMALoadsFilename, newFolder);
fullMFDLoadsFilename = strcat(title,MuscleForceDirectionfilename);
movefile(fullMFDLoadsFilename, newFolder);

movefile(trcFilename, newFolder);
movefile(motFilename, newFolder);
movefile(emgFilename, newFolder);
% movefile(c3dFilename, newFolder)

osimFilename = strcat(model,'.osim');
copyfile(osimFilename, newFolder)
%% Cut Markers
if warningMessage == true
message = sprintf('The following markers have more than 10 frames missing, might wanna give a bit of a review.'); 
warning(message); %#ok<SPWRN>
disp(badMarkerNames);
end
