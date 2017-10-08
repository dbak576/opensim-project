function err = loopHJC(model,side,boundWidth,boundRes,directory,hardcoords,coordfilename,pointrange)
%changeHJC: Alters the 3D coordinates of the HJC specified
% HIGHLY RECOMMEND PULLING OUT ORIGINAL HJC AHEAD OF TIME.
% Cancel Button will reset HJC before closing.
% NOTE: boundWidth MUST be in METRES. i.e. for a 1cm cube, boundWidth = 0.01
% boundRes = number of points per side of cube
err = 0;
load(coordfilename); %Bring in the coords variable
modelNum = str2num(model(2:3)); %#ok<ST2NM> %Pull out the number of the model

%Import the OpenSim tools
import org.opensim.modeling.*
Model.LoadOpenSimLibrary('C:\OpenSim 3.3\plugins\MuscleForceDirection.dll');

%SetupTrials (Optional)
setupBool = input('Are all trials set up? [Y or N]','s');
if upper(setupBool) == 'N'
    setuperr = SetupAllTrials(modelNum,modelNum); %#ok<NASGU>
end

% Grab Original Coords
originalCoords = findHJC(model,side);

%Establish Range (based on inputs)
if hardcoords
    numPoints = (pointrange(end)-pointrange(1))+1;   
else
    xRange = linspace((originalCoords(1)-(boundWidth/2)),(originalCoords(1)+(boundWidth/2)),boundRes);
    yRange = linspace((originalCoords(2)-(boundWidth/2)),(originalCoords(2)+(boundWidth/2)),boundRes);
    zRange = linspace((originalCoords(3)-(boundWidth/2)),(originalCoords(3)+(boundWidth/2)),boundRes);
    numPoints = boundRes^3;
end

%Display Progress Bars and Estimate Time
loadingbar = waitbar(0,'HJC Loop','Name',sprintf('HJC Loop: %i Locations',numPoints),...
    'CreateCancelBtn','setappdata(gcbf,''canceling'',1)');
setappdata(loadingbar,'canceling',0)
movegui(loadingbar,'east');
percentage = 0;
fid = fopen('HJCcoords.txt','w');
predHours = floor((numPoints*720)/3600);
predMin = floor(rem((numPoints*720),3600)/60);
progbox = msgbox(sprintf('Approximate Total Time: %i hours, %i minutes',predHours,predMin),'Remaining Time');
set(findobj(progbox,'style','pushbutton'),'Visible','off');
set(progbox, 'position', [100 150 400 75]);
axeshandle = get( progbox, 'CurrentAxes' );
childhandle = get( axeshandle, 'Children' );
set(childhandle, 'FontSize', 14);
movegui(progbox,'northeast');
runtimes = zeros(numPoints);
progressI = 0;
tic
if hardcoords %Case: Predetermines points (likely to be Latin Hypercube Sampling)
    for i = 1:numPoints
        curMem = memory;
        disp(curMem)
        if curMem.MaxPossibleArrayBytes < (5.9480e+09)
            break
        end
        HJCtic = tic;
        progressI = progressI + 1;
        percentage = percentage + (1/numPoints);
        waitbar(percentage,loadingbar)
        set(get(findobj(loadingbar,'type','axes'),'title'), 'string', sprintf('HJC Loop: Analysing HJC %i of %i',(round(percentage*numPoints)),numPoints));
        newCoords = coords(pointrange(i),:);
        setHJC(model,side,newCoords);
        runerr = RunAllTrials(modelNum,modelNum,directory); %#ok<NASGU>
        copyResultFiles(model,newCoords);
        fprintf(fid,'_%f_%f_%f',newCoords);
        fprintf(fid,'\n');
        runtimes(progressI) = toc(HJCtic);
        avgRun = mean(runtimes(1:progressI));
        remainingTime = round((numPoints - progressI)*avgRun);
        if remainingTime < 60
            set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i seconds',remainingTime));
        elseif remainingTime < 3600
            minutes = floor(remainingTime/60);
            set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i minutes',minutes));
        else
            hours = floor(remainingTime/3600);
            leftover = rem(remainingTime,3600);
            minutes = floor(leftover/60);
            set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i hours, %i minutes',hours, minutes));
        end
        if getappdata(loadingbar,'canceling')
            setHJC(model,side,originalCoords);
            break
        end
    end
else
    for x = xRange
        for y = yRange
            for z = zRange
                HJCtic = tic;
                progressI = progressI + 1;
                percentage = percentage + (1/(boundRes^3));
                waitbar(percentage,loadingbar)
                set(get(findobj(loadingbar,'type','axes'),'title'), 'string', sprintf('HJC Loop: Analysing HJC %i of %i',(round(percentage*numPoints)),numPoints));
                newCoords = [x,y,z];
                setHJC(model,side,newCoords);
                runerr = RunAllTrials(modelNum,modelNum,directory); %#ok<NASGU>
                copyResultFiles(model,newCoords);
                fprintf(fid,'_%f_%f_%f',newCoords);
                fprintf(fid,'\n');
                runtimes(progressI) = toc(HJCtic);
                avgRun = mean(runtimes(1:progressI));
                remainingTime = round((numPoints - progressI)*avgRun);
                if remainingTime < 60
                    set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i seconds',remainingTime));
                elseif remainingTime < 3600
                    minutes = floor(remainingTime/60);
                    set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i minutes',minutes));
                else
                    hours = floor(remainingTime/3600);
                    leftover = rem(remainingTime,3600);
                    minutes = floor(leftover/60);
                    set(findobj(progbox,'Tag','MessageBox'), 'string', sprintf('Approximate Time remaining: %i hours, %i minutes',hours, minutes));
                end
                if getappdata(loadingbar,'canceling')
                    setHJC(model,side,originalCoords);
                    break
                end
                curMem = memory;
                if curMem.MaxPossibleArrayBytes < (5.9480e+09)
                    break
                end
            end
            if getappdata(loadingbar,'canceling')
                break
            end
        end
        if getappdata(loadingbar,'canceling')
            break
        end
    end
end
toc
delete(progbox)
if getappdata(loadingbar,'canceling') || (curMem.MaxPossibleArrayBytes < (5.9480e+09))
    fprintf('Completed %i HJC locations of %i total before cancellation.\n',progressI,numPoints);
end
delete(findall(0,'Type','figure'))
setHJC(model,side,originalCoords);
fclose('all');
movefile('HJCLoopOutput',strcat(model,'HJCResults'));
movefile('HJCcoords.txt',strcat(model,'HJCResults'));
end

