% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% exclude maxemg, Figures folder, hard-coded
function [folderList] = folderListGeneration(inputDir,wildcard)
folders=dir(inputDir);
j=1;
if ~exist('wildcard','var')
    wildcard='no';
end

if strcmp(wildcard,'yes')
    startFolder = 1;
else
    startFolder = 3;
end
for k=startFolder:length(folders)

    if folders(k).isdir==1 && strcmp(folders(k).name,'maxemg')==0 && strcmp(folders(k).name,'Figures')==0
        folderList{j}=folders(k).name;
        j=j+1;
    end
end

end