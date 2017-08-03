function err = RunTrial(model,title,directory)
% RunTrial: Run the specified trial using the MATLAB OpenSim API.
%   Detailed explanation goes here
import org.opensim.modeling.*
%% Inverse Kinematics
IKsetupfilepath = fullfile(directory,model,title,strcat(title,'IKSetup.xml'));
ikTool = InverseKinematicsTool(IKsetupfilepath);
ikTool.run();
clear ikTool
%% Inverse Dynamics
IDsetupfilepath = fullfile(directory,model,title,strcat(title,'IDSetup.xml'));
idTool = InverseDynamicsTool(IDsetupfilepath);
idTool.run();
clear idTool
err = 0;
end

