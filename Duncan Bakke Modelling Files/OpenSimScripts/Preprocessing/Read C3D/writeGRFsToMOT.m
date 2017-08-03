function [] = writeGRFsToMOT(GRFTz, tStart, sF, fname, isFZ)
% Purpose:  Write ground reaction forces applied at COP to a 
%           motion file (fname) for input into the SimTrack
%           workflow.
%
% Input:   GRFTz is a structure containing the following data
%          tStart is the starting time of the data set
%          sF is the sampling frequency of the data
%          fname is the name of the file to be written.
%
% Output:   The file 'fname' is written to the current directory.
% ASeth, 09-07


% Generate column labels for forces, COPs, and vertical torques.
% Order:  rGRF(xyz), rCOP(xyz), lGRF(xyz), lCOP(xyz), rT(xyz), lT(xyz)
label{1} = 'ground_force_vx';
label{2} = 'ground_force_vy';
label{3} = 'ground_force_vz';
label{4} = 'ground_force_px';
label{5} = 'ground_force_py';
label{6} = 'ground_force_pz';
label{7} = 'ground_force_vx';
label{8} = 'ground_force_vy';
label{9} = 'ground_force_vz';
label{10} = 'ground_force_px';
label{11} = 'ground_force_py';
label{12} = 'ground_force_pz';
label{13} = 'ground_torque_x';
label{14} = 'ground_torque_y';
label{15} = 'ground_torque_z';
label{16} = 'ground_torque_x';
label{17} = 'ground_torque_y';
label{18} = 'ground_torque_z';
forceIndex = length(label);

    
% Initialize 'motion file data matrix' for writing data of interest.
nRows = length(GRFTz.R.Fx);
nCols = length(label)+1;   % plus time
motData = zeros(nRows, nCols);

% Write time array to data matrix.
time = [tStart:1/sF:(tStart + (nRows-1)/sF)]'; 
motData(:, 1) = time;

% Write force data to data matrix.
% NOTE:  each field of mCS.forces has xyz components.
forceData = [GRFTz.R.Fx GRFTz.R.Fy GRFTz.R.Fz ...
             GRFTz.R.COPx GRFTz.R.COPy zeros(nRows,1)...
             GRFTz.L.Fx GRFTz.L.Fy GRFTz.L.Fz ...
             GRFTz.L.COPx GRFTz.L.COPy zeros(nRows,1) ...
             zeros(nRows,1) zeros(nRows,1) GRFTz.R.Tz...
             zeros(nRows,1) zeros(nRows,1) GRFTz.L.Tz];

% If the coordinate frame does not have FY as vertical
if isFZ,
    rot90aboutX = [1 0 0;  0 0 1; 0 -1 0];  
    forceData = rot3DVectors(rot90aboutX, forceData);
end
         
motData(:, 2:end) = forceData;          

% Open file for writing.
fid = fopen(fname, 'w');
if fid == -1
    error(['unable to open ', fname])
end

% Write header.
fprintf(fid, 'name %s\n', fname);
fprintf(fid, 'datacolumns %d\n', nCols);
fprintf(fid, 'datarows %d\n', nRows);
fprintf(fid, 'range %d %d\n', time(1), time(nRows));
fprintf(fid, 'endheader\n\n');

% Write column labels.
fprintf(fid, '%20s\t', 'time');
for i = 1:nCols-1,
	fprintf(fid, '%20s\t', label{i});
end

% Write data.
for i = 1:nRows
    fprintf(fid, '\n'); 
	for j = 1:nCols
        fprintf(fid, '%20.8f\t', motData(i, j));
    end
end

fclose(fid);
return;

