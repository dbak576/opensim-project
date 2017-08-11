function err = copyResultFiles(model,hipcoords)
%copyResultFiles: Copy all result files into a new folder named for the HJC
%   Detailed explanation goes here
modelNum = str2num(model(2:3)); %#ok<ST2NM>
coordString = sprintf('_%f_%f_%f',hipcoords);
mkdir('HJCLoopOutput',strcat('Output',coordString));
mkdir(strcat('HJCLoopOutput','\','Output',coordString),model);
for j = 1:10
    if modelNum == 25
        if j < 9
            trial = strcat('Walk',j);
            mkdir(fullfile('HJCLoopOutput',strcat('Output',coordString),model),trial);
            curFile = fullFile('HJCLoopOutput',strcat('Output',coordString),model,trial);
            copyfile(fullfile(pwd,'Output',model,trial,strcat(trial,'IKResults.mot')), curFile);
            copyfile(fullfile(pwd,'Output',model,trial,strcat(trial,'IDResults.sto')), curFile);
            %TO DO: Copy over muscle force data
        end
    elseif modelNum == 26
        if j < 10
            trial = strcat('Walk',j);
            mkdir(fullfile('HJCLoopOutput',strcat('Output',coordString),model),trial);
            curFile = fullFile('HJCLoopOutput',strcat('Output',coordString),model,trial);
            copyfile(fullfile(pwd,'Output',model,trial,strcat(trial,'IKResults.mot')), curFile);
            copyfile(fullfile(pwd,'Output',model,trial,strcat(trial,'IDResults.sto')), curFile);
            %TO DO: Copy over muscle force data
        end
    else
        trial = strcat('Walk',num2str(j));
        mkdir(fullfile('HJCLoopOutput',strcat('Output',coordString),model),trial);
        curFile = fullfile('HJCLoopOutput',strcat('Output',coordString),model,trial);
        copyfile(fullfile(pwd,'Output',model,trial,strcat(trial,'IKResults.mot')), curFile);
        copyfile(fullfile(pwd,'Output',model,trial,strcat(trial,'IDResults.sto')), curFile);
        %TO DO: Copy over muscle force data
    end
end


end

