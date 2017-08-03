function err = plotIKandID(title, number, model, directory, forPlotting)

IKfilename = 'IKResults.mot';
IDfilename = 'IDResults.sto';

[IKData, IKHeaders, IKParameters, IKleftTrajectory, IKrightTrajectory, IKleftStDev, IKrightStDev] = ...
    plotStance(IKfilename, title, number, model, directory, forPlotting);

[IDData, IDHeaders, IDParameters, IDleftTrajectory, IDrightTrajectory, IDleftStDev, IDrightStDev] = ...
    plotStance(IDfilename, title, number, model, directory, forPlotting);

plot_stance_kinematics(IKleftTrajectory,IKrightTrajectory,IKleftStDev,IKrightStDev, forPlotting, model);
plot_stance_kinetics(IDleftTrajectory,IDrightTrajectory,IDleftStDev,IDrightStDev, forPlotting, model);

err = 0;
end