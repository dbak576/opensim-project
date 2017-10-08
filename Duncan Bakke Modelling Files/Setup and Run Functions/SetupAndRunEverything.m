%Script to Setup and Run every single trial for every single subject.
% 7 Minute run-time for setting up and running all trials, all subjects, IK and ID
% define directory
directory = fullfile(pwd,'Output');
tic
%run SetupAllTrials
err = SetupAllTrials(20,30);
%run RunAllTrials
err = RunAllTrials(20,30,directory);
fclose('all');
%run PlotEverything
err = PlotEverything(20,30,directory);
toc