

model = 'H23s1';
title = 'Walk1';
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
c3dFilename = fullfile(pwd,model,strcat(title,'.c3d'));

% Use "readC3D.m" to read in the C3D data (largely unchanged from Seth's
% original, review if needed, but pulls all data out quite effectively.)
[Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels, AUnits, AnalogFrameRate,~,ParameterGroup,~]... 
    = readC3D(c3dFilename, [], tInfo.offsetInds); % Note: 2nd argument if you want to limit the number of markers
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
%% EMG Data
emgInds = (13:28);
rawEMG = AnalogSignals(:,emgInds);

% process the EMG data
[proEMG, ~] = processEMG(rawEMG, AnalogFrameRate);
emgLabels = {'vasmed_r' 'vaslat_r' 'recfem_r' 'gra_r' 'sar_r' 'tibant_r' 'perlong_r' 'addmag_r' 'semimem_r' 'bicfemlh_r' 'gasmed_r' 'gaslat_r' 'sol_r' 'tfl_r' 'gmed_r' 'gmax_r'};
for i = 1:length(proEMG)
    for j = 1:length(emgInds)
        if proEMG(i,j) < 0
            proEMG(i,j) = 0;
        end
    end
end
% for a structure for writing to file
emg.data = [aTime, proEMG];
emg.labels = {'time', emgLabels{:}};
emgFilename = strcat(title,'_EMG.mot');
write_motionFile(emg, emgFilename);