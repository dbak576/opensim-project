% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% create directory if it doesn't exist

function createDir(outputDirectory)

 if ~exist(outputDirectory, 'dir')
     mkdir(outputDirectory)
 end
