function err = setupTrials(model, title, number, directory)
% setupTrials: A loop to use convert c3d files for one subject into all
% files needed for sunning simulations of said subject's trials.
% Duncan Bakke, 2017
% Auckland Bioengineering Institute

err = 0;
loadingbar = waitbar(0,strcat('Processing Subject ', model));
loadingbar.Name = 'Trial Setup';
movegui(loadingbar,'north');

%% Convert Each c3d file into Trial files and xmls.
for i = 1:number
    numTitle = strcat(title,num2str(i));
    convertC3DtoTRCandMOT(model, numTitle, directory);
    copyfile(fullfile(pwd,model,strcat(numTitle,'.c3d')),fullfile(directory,model,numTitle));
    waitbar(i/number)
end

%% Printout OpenSim commands NOTE: This should be replaced with Matlab calls to OpenSim.
for i = 1:number
    IKstring = strcat(model,'\',title,num2str(i),'\',title,num2str(i),'IKSetup.xml');
    IDstring = strcat(model,'\',title,num2str(i),'\',title,num2str(i),'IDSetup.xml');
    fullIKstring = ['ik -S ' IKstring];
    fullIDstring = ['id -S ' IDstring];
    disp(fullIKstring);
    disp(fullIDstring);
end
close(loadingbar)
% %% Move Static File (for cleanliness)
% staticFilename = strcat('Static_',model,'.c3d');
% movefile(staticFilename, model);
end

