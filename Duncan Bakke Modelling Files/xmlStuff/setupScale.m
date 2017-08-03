function ParameterGroup = setupScale(model)
% Set up a Scale .xml file for a model based on a c3d file and template
% scale file.
% Duncan Bakke, 2017
% Auckland Bioengineering Institute

%% User chooses a C3D file, height and weight are retrieved.
filename = strcat('Static_',model,'.c3d');
[Markers,MLabels,VideoFrameRate,AnalogSignals,ALabels,AUnits,AnalogFrameRate,Event,ParameterGroup,CameraInfo]= readC3D(filename);

height = ParameterGroup(10).Parameter(1).data;
weight = ParameterGroup(10).Parameter(2).data;

%% Get Hierarchy Access
docNode = xmlread('ScaleSetup.xml');

% Get overall Scale Tool
ScaleTool = docNode.getElementsByTagName('ScaleTool');
ScaleToolChild = ScaleTool.item(0);

% Mass and Height Nodes
massNode = ScaleToolChild.getElementsByTagName('mass');
massChild = massNode.item(0);

heightNode = ScaleToolChild.getElementsByTagName('height');
heightChild = heightNode.item(0);

% Generic Model (model, marker folder)
genericModelNode = ScaleToolChild.getElementsByTagName('GenericModelMaker');
genericModelChild = genericModelNode.item(0);

genericModelFile = genericModelChild.getElementsByTagName('model_file');
genericModelFileChild = genericModelFile.item(0);

genericModelMarkerFile = genericModelChild.getElementsByTagName('marker_set_file');
genericModelMarkerFileChild = genericModelMarkerFile.item(0);

% Model Scaler
ModelScalerNode = ScaleToolChild.getElementsByTagName('ModelScaler');
ModelScalerChild = ModelScalerNode.item(0);

markerScalerNode = ModelScalerChild.getElementsByTagName('marker_file');
markerScalerChild = markerScalerNode.item(0);

timeRangeScalerNode = ModelScalerChild.getElementsByTagName('time_range');
timeRangeScalerChild = timeRangeScalerNode.item(0);

outputFileScalerNode = ModelScalerChild.getElementsByTagName('output_model_file');
outputFileScalerChild = outputFileScalerNode.item(0);

% Marker Placer
MarkerPlacerNode = ScaleToolChild.getElementsByTagName('MarkerPlacer');
MarkerPlacerChild = MarkerPlacerNode.item(0);

markerFilePlacerNode = MarkerPlacerChild.getElementsByTagName('marker_file');
markerFilePlacerChild = markerFilePlacerNode.item(0);

timeRangePlacerNode = MarkerPlacerChild.getElementsByTagName('time_range');
timeRangePlacerChild = timeRangePlacerNode.item(0);

outputFilePlacerNode = MarkerPlacerChild.getElementsByTagName('output_model_file');
outputFilePlacerChild = outputFilePlacerNode.item(0);

%% Set Scale Name
ScaleToolChild.setAttribute('name',model);

%% Set Height and Weight
massChild.getFirstChild.setData(num2str(weight));
heightChild.getFirstChild.setData(num2str(height));

%% Set Generic Model
genericModel = 'C:\OpenSim 3.3\Models\Gait2392_Simbody\gait2392_simbody.osim';
genericModelFileChild.getFirstChild.setData(genericModel);
modelMarkerSet = strcat('C:\Users\dbak576\Documents\MAPClientStuff\HipOAData\MarkerSets\',model,'_MarkerSet_from_MarkerPlacer.xml');
genericModelMarkerFileChild.getFirstChild.setData(modelMarkerSet);

%% Set Static Trial .trc
staticTrialData = strcat('Static_',model,'.trc');
markerScalerChild.getFirstChild.setData(staticTrialData);
markerFilePlacerChild.getFirstChild.setData(staticTrialData);

%% Set Time Range
timeRange = strcat(num2str(0), {' '}, num2str(ParameterGroup(1).Parameter(1).data(2)*0.005));
timeRangeScalerChild.getFirstChild.setData(timeRange);
timeRangePlacerChild.getFirstChild.setData(timeRange);

%% Output Files
outputFilename = strcat(model,'.osim');
outputFileScalerChild.getFirstChild.setData(outputFilename);
outputFilePlacerChild.getFirstChild.setData(outputFilename);

%% Write xml File

newfilename = strcat(model,'ScaleSetup.xml');
xmlwrite(newfilename,docNode);
xmlShorten(strcat(newfilename));
end