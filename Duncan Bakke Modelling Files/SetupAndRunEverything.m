%Script to Setup and Run every single trial for every single subject.
% 7 Minute run-time for setting up and running all trials, all subjects, IK and ID
directory = fullfile(pwd,'Output');
tic
err = SetupAllTrials(20,30);
err = RunAllTrials(20,30,directory);
fclose('all');
err = PlotEverything(20,30,directory);
toc