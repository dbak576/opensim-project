function hjcsuffixes = HJCsuffixes(hjcfileID)
%pull HJC suffixes
i = 1;
while ~feof(hjcfileID)
    newsuffix = fgetl(hjcfileID);
    if ~isempty(newsuffix)
        hjcsuffixes{i} = newsuffix; %#ok<AGROW>
        i = i + 1;
    end
end
fclose(hjcfileID);
end