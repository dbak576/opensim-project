function writeEMGmot(q, fname)

fid = fopen(fname, 'w');	
if fid == -1								
	error(['unable to open ', fname])		
end

if length(q.labels) ~= size(q.data,2)
	error('Number of labels doesn''t match number of columns')
end

if q.labels{1} ~= 'time'
	error('Expected ''time'' as first column')
end

fprintf(fid, 'Normalized EMG Linear Envelopes\n');
fprintf(fid, 'nRows=%d\n', size(q.data,1));
fprintf(fid, 'nColumns=%d\n\n', size(q.data,2));
fprintf(fid, 'endheader\n');

for i=1:length(q.labels)
    if i == 1
        fprintf(fid, '%s\t', q.labels{i});
    else
        fprintf(fid, '%10s\t', q.labels{i});
    end
end
fprintf(fid, '\n');

for i=1:size(q.data,1)
    fprintf(fid, '%4.3f\t', q.data(i,1));
	fprintf(fid, '%10.6f\t', q.data(i,2:end));
	fprintf(fid, '\n');
end

fclose(fid);
return;
