function err = RunAllTrials(first,last,directory)
% RunAllTrials: Runs all specified H20s1-H30s1 trials
%   Detailed explanation goes here
i = first;
while (i<=last)
    model = strcat('H',num2str(i),'s1');
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
    end
    i = i + 1;
end
end

