function err = loopHJC(model,side,boundWidth,boundRes,directory)
%changeHJC: Alters the 3D coordinates of the HJC specified
% NOTE: boundWidth MUST be in METRES. i.e. for a 1cm cube, boundWidth = 0.01
% boundRes = number of points per side of cube
err = 0;

modelNum = str2num(model(2:3)); %#ok<ST2NM>

setupBool = input('Are all trials set up? [Y or N]','s');
if upper(setupBool) == 'N'
    setuperr = SetupAllTrials(modelNum,modelNum); %#ok<NASGU>
end

originalCoords = findHJC(model,side);
xRange = linspace((originalCoords(1)-(boundWidth/2)),(originalCoords(1)+(boundWidth/2)),boundRes);
yRange = linspace((originalCoords(2)-(boundWidth/2)),(originalCoords(2)+(boundWidth/2)),boundRes);
zRange = linspace((originalCoords(3)-(boundWidth/2)),(originalCoords(3)+(boundWidth/2)),boundRes);
numPoints = boundRes^3;
loadingbar = waitbar(0,'HJC Loop');
loadingbar.Name = sprintf('HJC Loop: %i Locations',numPoints);
movegui(loadingbar,'southeast');
percentage = 0;
tic
fid = fopen('HJCcoords.txt','w');
for x = xRange
    for y = yRange
        for z = zRange
            percentage = percentage + (1/(boundRes^3));
            waitbar(percentage,loadingbar)
            set( get(findobj(loadingbar,'type','axes'),'title'), 'string', sprintf('HJC Loop: Analysing HJC %i of %i',(percentage*numPoints),numPoints));
            newCoords = [x,y,z];
            setHJC(model,side,newCoords);
            runerr = RunAllTrials(modelNum,modelNum,directory); %#ok<NASGU>
            copyResultFiles(model,newCoords);
            fprintf(fid,'_%f_%f_%f',newCoords);
            fprintf(fid,'\n');
        end
    end
end
close(loadingbar)
setHJC(model,side,originalCoords);
fclose(fid);
movefile('HJCLoopOutput',strcat(model,'HJCResults'));
movefile('HJCcoords.txt',strcat(model,'HJCResults'));
toc
end

