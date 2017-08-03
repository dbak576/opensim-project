% Example set-up file for a single trial to convert from c3d to .trc/.mot

% The function convertC3DtoTRCandMOT requires a variable tInfo:
tInfo.vert_force_label = 'FZ';  % This identifies the vertical direction in the gait lab for the force plates
tInfo.FP = [1, 2, 3, 4]; % This is the order the person hits the force plates (in some gait labs they can hit 3 before 2, etc.)
tInfo.limb = {'L','R', 'R', 'L'}; %Which foot strikes each force plate (it doesn't have to be exact if it is not a good strike)
tInfo.Tstart = .01; tInfo.Tend = 5.92; %The start and end times for the trial
tInfo.offsetInds = [19:42]; %The indices of the force plate data in the analog portion of the C3D file 
tInfo.GRFinds = [19:42]; %Identifies the indices of the force plate data in the C3D file

% Specify C3D file, output trc and mot files and tInfo for convertC3DtoTRCandMOT
err = convertC3DtoTRCandMOT('C:\Crouch_Gait\Crouch_MuscleForces\Data\7374\7374_06.c3d', ...
    'C:\Crouch_Gait\Crouch_MuscleForces\Data\7374\7374_06.trc', ...
    'C:\Crouch_Gait\Crouch_MuscleForces\Data\7374\7374_06.mot', tInfo)


