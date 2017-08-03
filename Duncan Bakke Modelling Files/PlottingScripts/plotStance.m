function [resultantData, headerLine, ParameterGroup, leftTrajectory, rightTrajectory, leftStDev, rightStDev] = plotStance(filename, title, number, model, directory, forPlotting) % err = plotStance(IKResults, Walk, 10)
%plotStance: Plots mean joint angles/moments as a function of stance percentage.
% Note that forPlotting should contain all string titles of columns for
% plotting WITHOUT _l OR _r SUFFIXES. These are taken care of by the func.
% Get data, headers, and times for interpolation
interpolationPointNumber = 101;
heelStrikeTimes = zeros(number,2,2);
for i = 1:number
    c3dFilename = strcat(directory,'\',model,'\',title,num2str(i),'\',title,num2str(i),'.c3d');
    dataFilename = strcat(directory,'\',model,'\',title,num2str(i),'\',title,num2str(i),filename);
    [Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels,AUnits,AnalogFrameRate,Event,ParameterGroup,CameraInfo] = readC3D(c3dFilename);
    heelStrikeTimes(i,1,1:2) = ParameterGroup(7).Parameter(7).data(2,1:2)-(ParameterGroup(1).Parameter(1).data(1)*0.005);
    heelStrikeTimes(i,2,1:2) = ParameterGroup(7).Parameter(7).data(2,3:4)-(ParameterGroup(1).Parameter(1).data(1)*0.005);
    % NOTE THAT heelStrikeTimes (:,1,:) is the SECOND STEP in the
    % H20sets, and vice versa.
    [resultantData{i}, headerLine(i,:)] = RetrieveMOTData(dataFilename);
    % THIS should be reviewed if wrong entries are coming through
    leftStrikeStart = (heelStrikeTimes(i,1,1)-resultantData{i}(1,1))/0.005 + 1;
    leftStrikeEnd = (heelStrikeTimes(i,1,2)-resultantData{i}(1,1))/0.005 + 1;
    rightStrikeStart = (heelStrikeTimes(i,2,1)-resultantData{i}(1,1))/0.005 + 1;
    rightStrikeEnd = (heelStrikeTimes(i,2,2)-resultantData{i}(1,1))/0.005 + 1;
    if leftStrikeStart < 1
        leftStrikeStart = 1;
    end
    if rightStrikeStart < 1
        rightStrikeStart = 1;
    end
    if leftStrikeEnd >(resultantData{i}(end,1)-resultantData{i}(1,1))/0.005 + 1
        leftStrikeEnd = (resultantData{i}(end,1)-resultantData{i}(1,1))/0.005 + 1;
    end
    if rightStrikeEnd >(resultantData{i}(end,1)-resultantData{i}(1,1))/0.005 + 1
        rightStrikeEnd = (resultantData{i}(end,1)-resultantData{i}(1,1))/0.005 + 1;
    end
    leftStanceData{i} = resultantData{i}(leftStrikeStart:leftStrikeEnd,:);
    rightStanceData{i} = resultantData{i}(rightStrikeStart:rightStrikeEnd,:);
end

if strfind(filename,'.mot')
    leftSuffix = '_l';
    rightSuffix = '_r';
elseif strfind(filename,'.sto')
    leftSuffix = '_l_moment';
    rightSuffix = '_r_moment';
end

% Pull columns/timeranges out of full arrays
for j = 1:length(forPlotting)
    forPlottingLeft = strcat(forPlotting{j},leftSuffix);
    forPlottingRight = strcat(forPlotting{j},rightSuffix);
    for i = 1:number
        stanceColLeft = find(strcmp(headerLine(i,:),forPlottingLeft));
        stanceColRight = find(strcmp(headerLine(i,:),forPlottingRight));
        if j == 1;
            %Only have to set time column once
            leftTrajectories{i}(:,1) = leftStanceData{i}(:,1);
            rightTrajectories{i}(:,1) = rightStanceData{i}(:,1);
        end
        leftTrajectories{i}(:,(1+j)) = leftStanceData{i}(:,stanceColLeft);
        rightTrajectories{i}(:,(1+j)) = rightStanceData{i}(:,stanceColRight);
    end
end

% Interpolate
for i = 1:number
    leftInterpolated{i}(:,1) = linspace(leftTrajectories{i}(1,1),leftTrajectories{i}(end,1),interpolationPointNumber);
    rightInterpolated{i}(:,1) = linspace(rightTrajectories{i}(1,1),rightTrajectories{i}(end,1),interpolationPointNumber);
    if rightInterpolated{i}(1,1) == rightInterpolated{i}(2,1)
        disp(rightInterpolated{i}(1,1));
    end
    for j = 1:length(forPlotting)
        leftInterpolated{i}(:,j+1) = interp1(leftTrajectories{i}(:,1),leftTrajectories{i}(:,(1+j)),leftInterpolated{i}(:,1));
        rightInterpolated{i}(:,j+1) = interp1(rightTrajectories{i}(:,1),rightTrajectories{i}(:,(1+j)),rightInterpolated{i}(:,1));
    end
end
percentageValues = 0:0.01:1;
leftTrajectory(:,1) = percentageValues;
rightTrajectory(:,1) = percentageValues;
leftStDev(:,1) = percentageValues;
rightStDev(:,1) = percentageValues;
leftTrajVector = zeros(number,1);
rightTrajVector = zeros(number,1);
for i = 1:length(percentageValues)
    for j = 1:length(forPlotting)
        for k = 1:number
            leftTrajVector(k) = leftInterpolated{k}(i,j+1);
            rightTrajVector(k) = rightInterpolated{k}(i,j+1);
        end
        leftTrajectory(i,j+1) = mean(leftTrajVector);
        leftStDev(i,j+1) = std(leftTrajVector);
        rightTrajectory(i,j+1) = mean(rightTrajVector);
        rightStDev(i,j+1) = std(leftTrajVector);
    end
end
err = 0;
end

