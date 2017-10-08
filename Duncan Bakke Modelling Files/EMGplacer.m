for i = 1:10
    err = processEMGs('H23s1',strcat('Walk',num2str(i)));
    filename = 'emg.mot';
    newfolder = strcat('C:\Users\dbak576\Desktop\CEINMS\ElaboratedData\H23s1\dynamicElaborations\StanceEMG\Walk',num2str(i));
    movefile(filename,newfolder);
end