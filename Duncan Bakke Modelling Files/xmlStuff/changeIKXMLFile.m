function timeRange = changeIKXMLFile(filename,title,timerange,model,directory,allmarkers,badmarkers)
%% Rewrite IK Setup XML file for new title
err = 0;
docNode = xmlread(filename);

%% Get Hierarchy Access
IKTool = docNode.getElementsByTagName('InverseKinematicsTool');
IKToolChild = IKTool.item(0);

resDirectory = IKToolChild.getElementsByTagName('results_directory');
resDirectoryChild = resDirectory.item(0);

inputDirectory = IKToolChild.getElementsByTagName('input_directory');
inputDirectoryChild = inputDirectory.item(0);

model_file = IKToolChild.getElementsByTagName('model_file');
model_fileChild = model_file.item(0);

IKTaskSet = IKToolChild.getElementsByTagName('IKTaskSet');
IKTaskSetChild = IKTaskSet.item(0);

IKTaskSetObjects = IKTaskSetChild.getElementsByTagName('objects');
IKTaskSetObjectsChild = IKTaskSetObjects.item(0);

IKMarkerTasks = IKTaskSetObjectsChild.getElementsByTagName('IKMarkerTask');
numMarkers = IKMarkerTasks.getLength();

marker_file = IKToolChild.getElementsByTagName('marker_file');
marker_fileChild = marker_file.item(0);

time_range = IKToolChild.getElementsByTagName('time_range');
time_rangeChild = time_range.item(0);

output_motion_file = IKToolChild.getElementsByTagName('output_motion_file');
output_motion_fileChild = output_motion_file.item(0);

%% Set New Directory, Filenames, and number inputs

resultDirectory = strcat(directory,'\',model,'\',title);
resDirectoryChild.getFirstChild.setData(resultDirectory);

inputDirectoryString = strcat(directory,'\',model,'\',title);
inputDirectoryChild.getFirstChild.setData(inputDirectoryString);

modelFileName = strcat(directory,'\',model,'.osim');
model_fileChild.getFirstChild.setData(modelFileName);

markerFileName = strcat(directory,'\',model,'\',title,'\',title,'.trc');
marker_fileChild.getFirstChild.setData(markerFileName);

outputFileName = strcat(directory,'\',model,'\',title,'\',title,'IKResults.mot');
output_motion_fileChild.getFirstChild.setData(outputFileName);

timeRange = strcat(num2str(timerange(1)), {' '}, num2str(timerange(2)));
time_rangeChild.getFirstChild.setData(timeRange);

%% Remove any absent markers

for i = 0:numMarkers-1
   currentMarker = IKMarkerTasks.item(i);
   currentMarkerName = char(currentMarker.getAttribute('name'));
   apply = currentMarker.getElementsByTagName('apply');
       applyChild = apply.item(0);
   if ismember(currentMarkerName,allmarkers) && ~ismember(currentMarkerName,badmarkers)
       applyChild.getFirstChild.setData('true');
   else
       applyChild.getFirstChild.setData('false');
   end
end

%% Write file
newfilename = strcat(title, filename);
xmlwrite(newfilename,docNode);
end