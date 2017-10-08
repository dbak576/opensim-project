function maxAdd = plotID(title, number, model, directory, forPlotting, ParameterGroups)
%plotID: Plot ID Results
err = 0;
IDfilename = 'IDResults.sto';
[IDData, IDHeaders, IDParameters, IDleftTrajectory, IDrightTrajectory, IDleftStDev, IDrightStDev] = ...
    plotStance(IDfilename, title, number, model, directory, forPlotting, ParameterGroups);
% plot_stance_kinetics(IDleftTrajectory,IDrightTrajectory,IDleftStDev,IDrightStDev, forPlotting, model);
% figHandle = gcf;
% figHandle.OuterPosition = [960 0 960 1100];
maxAdd = max(abs(IDrightTrajectory(:,3)));
fclose('all');
end

