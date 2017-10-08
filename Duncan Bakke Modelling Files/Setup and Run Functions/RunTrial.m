function err = RunTrial(model,title,directory)
% RunTrial: Run the specified trial using the MATLAB OpenSim API.
%   Detailed explanation goes here
import org.opensim.modeling.*
Model.LoadOpenSimLibrary('C:\OpenSim 3.3\plugins\MuscleForceDirection.dll');
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
%% MuscleAnalysis
MAsetupfilepath = fullfile(directory,model,title,strcat(title,'MuscleAnalysisSetup.xml'));
analysisTool = AnalyzeTool(MAsetupfilepath);
analysisTool.run();
clear analysisTool
%% MuscleAnalysis
MFDsetupfilepath = fullfile(directory,model,title,strcat(title,'MuscleForceDirectionSetup.xml'));
ForceDirectionTool = AnalyzeTool(MFDsetupfilepath);
ForceDirectionTool.run();
clear ForceDirectionTool
err = 0;
end

