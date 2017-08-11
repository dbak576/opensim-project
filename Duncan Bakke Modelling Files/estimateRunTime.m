function totalTime = estimateRunTime(subjects,HJCres)
%Estimate the run time for a set of trials.
totalTime = 0; % Minutes
totalTime = totalTime + (subjects/11)*4;
totalTime = totalTime + (HJCres^3)*((subjects/11)*3);
hours = floor(totalTime/60);
minutes = rem(totalTime,60);
days = floor(hours/24);
hours = rem(hours,24);
estimate = sprintf('These trials will take approximately %i days, %i hours, and %i minutes to complete.',days, hours, minutes);
disp(estimate);
end

