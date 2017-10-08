% Copyright (C) 2014 Hoa X. Hoang
% Hoa X. Hoang <hoa.hoang@griffithuni.edu.au>
% PLEASE DO NOT REDISTRIBUTE WITHOUT PERMISSION
%__________________________________________________________________________
% write setup calibration file xml
% Todo:
function writeSetupCalibrationFileXml(templateSetupCalXML, unCalSubFile, exGenerator, calFile, outCalFile, fileOut, pref)
%========default preferences==================================
prefDef.contact='none'; %true, if true must provide contactModelFile path in pref.contactModelFile
%prefDef.contactModelFile='contactKneeModel.xml';
if (nargin>6)
    if (isfield(pref, 'contact')), prefDef.contact=pref.contact; end
    %if (isfield(pref, 'contactModelFile')), prefDef.contactModelFile=pref.contactModelFile; end
end
%Calibration File
prefXmlRead.Str2Num = 'never';
tree=xml_read(templateSetupCalXML, prefXmlRead);

tree.subjectFile = unCalSubFile;
tree.excitationGeneratorFile = exGenerator;
tree.calibrationFile = calFile;
tree.outputSubjectFile = outCalFile;

if strcmp(prefDef.contact,'knee')
    tree.contactModelFile = pref.contactModelFile;
elseif strcmp(prefDef.contact,'OpenSim')
    disp('minimize hip JCF in OpenSim is not working in Calibration ATM')
end

prefXmlWrite.StructItem = false;
prefXmlWrite.CellItem   = false;

xml_write(fileOut,tree,'ceinmsCalibration',prefXmlWrite);
end