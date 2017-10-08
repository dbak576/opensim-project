startTime = datestr(now);
directory = fullfile(pwd,'Output');
err = loopHJC('H23s1','r',0.01,11,directory);
err = plotHJCs('Walk','H23s1',fullfile(pwd,'H23s1HJCResults'),'HJCcoords.txt');
endTime = datestr(now);
fprintf('Began at %s, and finished at %s\n',startTime,endTime);