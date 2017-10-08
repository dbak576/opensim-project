for i = 3:166
   hjc{i-2} = outputs(i).name(8:end);
   hjcX(i-2) = str2num(hjc{i-2}(1:9));
   hjcY(i-2) = str2num(hjc{i-2}(11:19));
   hjcZ(i-2) = str2num(hjc{i-2}(21:end));
end
fid = fopen('HJCcoords.txt','w');
for j = 1:length(hjcX)
    fprintf(fid,'_%f_%f_%f',hjcX(j),hjcY(j),hjcZ(j));
    fprintf(fid,'\n');
end
fclose(fid);
% movefile('HJCcoords.txt','HJCLoopOuput');