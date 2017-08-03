% Example set-up file for a single trial to convert from c3d to .trc/.mot

% The function convertC3DtoTRCandMOT requires a variable tInfo:


% Specify C3D file, output trc and mot files and tInfo for convertC3DtoTRCandMOT
err = convertC3DtoTRCandMOT('C:\Crouch_Gait\Crouch_MuscleForces\Data\7374\7374_06.c3d', ...
    'C:\Crouch_Gait\Crouch_MuscleForces\Data\7374\7374_06.trc', ...
    'C:\Crouch_Gait\Crouch_MuscleForces\Data\7374\7374_06.mot', tInfo)


