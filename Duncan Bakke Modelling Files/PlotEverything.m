function err = PlotEverything(first,last,directory)
err = 0;
forPlotting = {'hip_flexion','hip_adduction','hip_rotation','knee_angle','ankle_angle','subtalar_angle'};
for i = first:last
    if i == 25
        number = 8;
    elseif i == 26
        number = 9;
    else
        number = 10;
    end
    model = strcat('H',num2str(i),'s1');
    plotIKandID('Walk',number,model,directory,forPlotting);
end
end

