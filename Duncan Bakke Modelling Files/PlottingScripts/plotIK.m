function err = plotIK(title, number, model, directory, forPlotting, ParameterGroups)
%plotIK: Plot IK Results
err = 0;
IKfilename = 'IKResults.mot';
[IKData, IKHeaders, IKParameters, IKleftTrajectory, IKrightTrajectory, IKleftStDev, IKrightStDev] = ...
    plotStance(IKfilename, title, number, model, directory, forPlotting, ParameterGroups);
plot_stance_kinematics(IKleftTrajectory,IKrightTrajectory,IKleftStDev,IKrightStDev, forPlotting, model);
figHandle = gcf;
figHandle.OuterPosition = [0 0 960 1100];
fclose('all');
end

