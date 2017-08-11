function err = plotHJCs(title, model, directory, hjcfile)
%plotHJCs: Plots the standard plots for the varied HJCs within an output folder
% Define forPlotting array
forPlotting = {'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle','subtalar_angle'};
err = 0;
if strcmp('H25s1',model)
    number = 8;
elseif strcmp('H26s1',model)
    number = 9;
else
    number = 10;
end

% Retrieve HJC file suffixes
hjcfileID = fopen(fullfile(directory,hjcfile),'r');
i = 1;
while ~feof(hjcfileID)
    newsuffix = fgetl(hjcfileID);
    if ~isempty(newsuffix)
        hjcsuffixes{i} = newsuffix;
        i = i + 1;
    end
end
fclose(hjcfileID);


% Potentially replace with just ID Plotting
for i = 1:length(hjcsuffixes)
    specificDirectory = fullfile(directory,'HJCLoopOutput',strcat('Output',hjcsuffixes{i}));
    plotIKandID(title,number,model,specificDirectory,forPlotting);
end


end

