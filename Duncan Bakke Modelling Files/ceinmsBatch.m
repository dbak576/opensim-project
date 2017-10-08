function err = ceinmsBatch(model,dirCeinms)
%ceinmsBatch: makes batch file for all trials of a given model
hjcfolder = fullfile(dirCeinms,strcat(model,'HJCResults'));
k = strfind(hjcfolder,'\');
newHJCfolder = hjcfolder(1:k(1));
% for i = 1:length(k)-1
%     if i == length(k)-1
%         newHJCfolder = strcat(newHJCfolder,hjcfolder(k(i):end));
%     else
%         newHJCfolder = strcat(newHJCfolder,hjcfolder(k(i):k(i+1)));
%     end
% end
for i = 1:length(k)
    if i == length(k)
        newHJCfolder = strcat(newHJCfolder,hjcfolder(k(i):end));
    else
        newHJCfolder = strcat(newHJCfolder,hjcfolder(k(i):k(i+1)));
    end
end
hjcs = folderListGeneration(hjcfolder);
batchName = strcat(model,'CEINMSbatch.bat');
batchID = fopen(batchName,'w');
fprintf(batchID,'@echo off\n');
for i = 1:length(hjcs)
    currentFolder = strcat(newHJCfolder,'\\',hjcs{i});
    for j = 1:10;
        location = strcat(currentFolder,'\\execution\\',strcat('HybridSetupWalk',num2str(j),'.xml\n'));
        cmdString = strcat('CEINMS -S',{' '},location);
        fprintf(batchID,cmdString{1});
    end
end
fclose('all');
err = 0;
end
