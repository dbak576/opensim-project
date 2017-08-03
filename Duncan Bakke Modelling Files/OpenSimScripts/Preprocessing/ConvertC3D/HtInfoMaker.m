% Example set-up file for a single trial to convert from c3d to .trc/.mot
%% NOTE %%
% You MUST run this script with your own tInfo data for
% convertC3DtoTRCandMOT to be able to function.

% The function convertC3DtoTRCandMOT requires a variable tInfo:
tInfo.vert_force_label = 'Fz';  % This identifies the vertical direction in the gait lab for the force plates
tInfo.FP = [2, 1]; % This is the order the person hits the force plates (in some gait labs they can hit 3 before 2, etc.)
tInfo.limb = {'L','R'}; %Which foot strikes each force plate (it doesn't have to be exact if it is not a good strike)
tInfo.Tstart = 0; tInfo.Tend = 3; %The start and end times for the trial
tInfo.offsetInds = [1:12]; %The indices of the force plate data in the analog portion of the C3D file 
tInfo.GRFinds = [1:12]; %Identifies the indices of the force plate data in the C3D file
tInfo.rotation = [0 1 0; 0 0 1; 1 0 0]; %90 degrees about y, then x (OpenSim custom)


