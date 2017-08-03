function err = convertC3DtoTRCandMOT(c3dfile, trcfile, motfile, tInfo)
% Convert c3d data file to .trc and .mot for OpenSim
% USAGE: error = convertC3DtoTRCandMOT(c3dfile, trcfile, motfile)
%
% tInfo.vert_force_label = 'FZ';
% tInfo.FP = {1, 2, 3, 4};
% tInfo.limb = {'R', 'L', 'R', 'L'};
% tInfo.Tstart and tInfo.Tend (specify start and end times);
% tInfo.GRFinds = indices of grfs in the analog signals block.
% tInfo.rotation = rotation matrix from lab to model reference frame
%
% Ajay Seth, Sep 2007
% Stanford University

% Define indices in the AnalogSignals block that correspond to columns of
% GRF data (forces and moments).

if (isfield(tInfo, 'GRFinds')),
    grfInds = tInfo.GRFinds;
else
    % default for Gillette Data
    grfInds = 13:36;
end

% Used to select EMG channels from AnalogSignals
emgPrefix = 'EM';

% define vertical direction
% tInfo.vert_force_label = 'FZ';
% isFZ = 1;
% tInfo.FP = {1, 2, 3, 4};
% tInfo.limb = {'R', 'L', 'R', 'L'};

if isfield(tInfo, 'vert_force_label'),
    isFZ = 1;
else
    isFZ = 0;
end

offsetInds = [];
if isfield(tInfo, 'offsetInds'),
    offsetInds = tInfo.offsetInds;
end

[Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels, AUnits, AnalogFrameRate,Event,ParameterGroup,CameraInfo]... 
    = readC3D(c3dfile, [], offsetInds); % Note: 2nd argument if you want to limit the number of markers

% number of markers
nM = length(MLabels);

% video time
[nvF, nc] = size(Markers);
vFrms = [1:nvF]';
vTime = 1/VideoFrameRate*(vFrms);

% analog time
[naF, nc] = size(AnalogSignals);
aFrms = [1:naF]';
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
    nvF = length(vFrms);
    vTime = vTime(vInds);
    Markers = Markers(vInds,:);
    % trim the Analog data 
    aFrms = aFrms(aInds);
    aTime = aTime(aInds);
    AnalogSignals = AnalogSignals(aInds,:);
end

% After trimming off the ends see if we have any missing markers
[missInds, missCols] = find(abs(Markers) < 1e-2);
uniqueCols = unique(missCols);
missMarks = ~mod(uniqueCols,3).*uniqueCols/3;
missMarks = missMarks(find(missMarks));
allInds = 1:size(Markers);
garbage = [];
if any(missMarks),
    for I = missMarks',
        gapInds = missInds(find(missCols == 3*I));
        mstring = MLabels(I);
        if  length(gapInds) > 10,
            message = sprintf('Marker %s has more than 10 frames missing.', mstring{1}); 
            warning(message);
            garbage = [garbage I];
        else
            % interpolate
            disp(['Interpolating gap for Marker ', mstring{1}]); 
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
        goodCols = [goodCols, 3*good(I)-2:3*good(I)];
    end
    Markers = Markers(:,goodCols);
end
    

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
err = writeMarkersToTRC(trcfile, Markers, MLabels, VideoFrameRate, vFrms, vTime, 'mm');


%========================= Start Processing GRFs ===============================
% find the Analog Signals correspondint to vertical ground reaction forces
vert_f_block = (ismember(strvcat(ALabels), tInfo.vert_force_label));
% has to match vert_force_label characters
vert_f_inds = find(sum(vert_f_block,2)>1);

vert_forces = AnalogSignals(:,vert_f_inds);
% if max(max(abs(vert_forces))) > max(max(vert_forces)), % force has negative peaks
%     vert_forces = -vert_forces;
%     AnalogSignals(:,vert_f_inds) = vert_forces;
% end


% Check if any of the units are in terms of mm
mmBlock = ismember(strvcat(AUnits), 'mm');
% get column indices 
mmInds = find(sum(mmBlock,2)>1);

if mmInds,
    % HACK to get a rid of junk '3M' units in some moment data
    mmInds = [mmInds; strmatch('3M', AUnits)];
end

% change all mm units to meters in one shot
AnalogSignals(:,mmInds) = 0.001 * AnalogSignals(:,mmInds);

% Detect gait events from the vertical GRF
[icFromGRF, toFromGRF] = findIctoFromGRF(abs(vert_forces), 0.01);
  
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
%reactionGRFTz_lab = convert_actionToReaction(actionGRFTz_lab);

% Superimpose GRFTz data from the FP hits corresponding to each limb.
%GRFTz_byLimb = get_GRFTzByLimb(reactionGRFTz_lab, tInfo);
GRFTz_byLimb = get_GRFTzByLimb(actionGRFTz_lab, tInfo);

% Plot the GRFTz data for each limb, and interactively eliminate
% discontinuities in the COP trajectories.
%COP_smoothed = smoothCOP(GRFTz_byLimb, naF, AnalogFrameRate, 0, tInfo)

writeGRFsToMOT(GRFTz_byLimb, aTime(1), AnalogFrameRate, motfile, isFZ);

%============================== EMG Data =================================

% Assume everything that is EMG data has the emgPrefix
% Check if any of the ALabels contain the emgPrefix
emgBlock = ismember(strvcat(ALabels), emgPrefix);
% get column indices 
emgInds = find(sum(emgBlock,2)>1);

rawEMG = AnalogSignals(:,emgInds);

% process the EMG data
[proEMG, rectEMG] = processEMG(rawEMG, AnalogFrameRate);

% for a structure for writing to file
emg.data = [aTime, proEMG];
emg.labels = {'time', ALabels{emgInds}};

emgFile = [strtok(c3dfile,'.'), '_EMG.mot'];

write_motionFile(emg, emgFile);

err = 0;
