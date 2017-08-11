function err = RunAllTrials(first,last,directory)
% RunAllTrials: Runs all specified H20s1-H30s1 trials
%   Detailed explanation goes here
toploadingbar = waitbar(0,'Running all Trials');
toploadingbar.Name = 'Running All Trials';
movegui(toploadingbar,'north');
i = first;
while (i<=last)
    model = strcat('H',num2str(i),'s1');
    loadingbar = waitbar(0,strcat('Processing Trials for Subject ', model));
    loadingbar.Name = 'Running Trials';
    for j = 1:10
        if i == 25
            if j < 9
                err = RunTrial(model,strcat('Walk',num2str(j)),directory);
            end
        elseif i == 26
            if j < 10
                err = RunTrial(model,strcat('Walk',num2str(j)),directory);
            end
        else
            err = RunTrial(model,strcat('Walk',num2str(j)),directory);
        end
        jprog = j/10;
        waitbar(jprog,loadingbar)
        numMods = (first-last)+1;
        waitbar((((i-first)+1)/numMods)+jprog/numMods,toploadingbar);
    end
    close(loadingbar)
    i = i + 1;
end
close(toploadingbar)
end

