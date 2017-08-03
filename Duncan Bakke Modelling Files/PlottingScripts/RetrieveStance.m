function [headerLine, numRows, numCols] = RetrieveStance(filename)
%RetrieveStance: Pull Data vector from a results file for use in plotting.
% ,columnHeader,tStart,tEnd
fileID = fopen(filename,'r');
filetext = fileread(filename);
notInData = 1;
while notInData == 1;
   curLine = fgetl(fileID);
   if strncmpi(curLine,'nRows',5)
       numRows=str2num(curLine((strfind(curLine,'=')+1):end));
   elseif strncmpi(curLine,'nColumns',8)
       numCols=str2num(curLine((strfind(curLine,'=')+1):end));
   elseif strncmpi(curLine,'endheader',9)
       notInData = 0;
   end
end
for i = 1:numCols
headerLine(i) = fscanf(fileID,'%s');
end
for j = 1:numRows
    for i = 1:numCols
fileData(j,i) = fscanf(fileID,'%f');
    end
end
end

