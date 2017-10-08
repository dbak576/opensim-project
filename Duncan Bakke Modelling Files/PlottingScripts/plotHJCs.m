function [maxAdd,hjcsuffixes] = plotHJCs(title, model, directory, hjcfile, samples)
%plotHJCs: Plots the standard plots for the varied HJCs within an output folder
% NOTE: This will very easily crash matlab as it opens many files!
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
hjcsuffixes = HJCsuffixes(directory,hjcfile);
predHours = 0;
predMin = 30;
progbox = msgbox(sprintf('Approximate Total Time: %i hours, %i minutes',predHours,predMin),'Remaining Time');
set(findobj(progbox,'style','pushbutton'),'Visible','off');
set(progbox, 'position', [100 150 400 75]);
axeshandle = get( progbox, 'CurrentAxes' );
childhandle = get( axeshandle, 'Children' );
set(childhandle, 'FontSize', 14);
movegui(progbox,'northeast');
progressI = 0;
runtimes = zeros(length(hjcsuffixes));
% Potentially replace with just ID Plotting
for j = 1:number
   c3dFilename = fullfile(pwd,model,strcat(title,num2str(j),'.c3d'));
   [~,~,~,~,~, ~, ~,~,ParameterGroup,~] = readC3D(c3dFilename);
   ParameterGroups{j} = ParameterGroup;
end
i = 1;
stepsize = floor(length(hjcsuffixes)/samples);
toploadingbar = waitbar(0,'Plotting all HJCs');
toploadingbar.Name = 'Plotting all HJCs';
movegui(toploadingbar,'north');
while i < length(hjcsuffixes)
    plottic = tic;
    specificDirectory = fullfile(directory,strcat('Output',hjcsuffixes{i}));
    maxAdd(i) = plotIKandID(title,number,model,specificDirectory,forPlotting,ParameterGroups);
    progressI = progressI + 1;
    runtimes(progressI) = toc(plottic);
    avgRun = mean(runtimes(1:progressI));
    remainingTime = round((length(hjcsuffixes) - progressI)*avgRun);
    if remainingTime < 60
        set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i seconds',remainingTime));
    elseif remainingTime < 3600
        minutes = floor(remainingTime/60);
        set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i minutes',minutes));
    else
        hours = floor(remainingTime/3600);
        leftover = rem(remainingTime,3600);
        minutes = floor(leftover/60);
        set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i hours, %i minutes',hours, minutes));
    end
    i = i + stepsize;
    waitbar((i/length(hjcsuffixes)),toploadingbar);
end
delete(progbox)
delete(toploadingbar)
end

