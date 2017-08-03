function err = SetupAllTrials(first,last)
% Setup all trial files for H20s1-H30s1
%   Detailed explanation goes here
err = 0;

for i = first:last
    model = strcat('H',num2str(i),'s1');
    if i == 25
        err = setupTrials(model, 'Walk', 8, fullfile(pwd,'Output'));
    elseif i == 26
        err = setupTrials(model, 'Walk', 9, fullfile(pwd,'Output'));
    else
        err = setupTrials(model, 'Walk', 10, fullfile(pwd,'Output'));
    end
    copyfile(strcat(model,'.osim'),'Output');
end
end

