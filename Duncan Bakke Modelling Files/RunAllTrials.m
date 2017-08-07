function err = RunAllTrials(first,last,directory)
% RunAllTrials: Runs all specified H20s1-H30s1 trials
%   Detailed explanation goes here
tic
toploadingbar = waitbar(0,'Running all Trials');
toploadingbar.Name = 'Running All Trials';
movegui(toploadingbar,'north');
for i = first:last
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
        waitbar(j/10,loadingbar)
        waitbar((((i-first)/((last-first)+1))+(j/((last-first)*10))),toploadingbar);
    end
    close(loadingbar)
end
close(toploadingbar)
toc
end

