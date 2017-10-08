# README #
This is a MATLAB script to batch generate XMLs required for CEINMS, run calibration in CEINMS, and execute CEINMS. The CEINMS version provided has been modified to output joint contact forces. This script has been tested with OpenSim 3.2 and MATLAB 2012a (both 32bit and 64 bit versions). Folder structure is the same as MOtoNMS v 2.1 (the latest version of the manual is available at http://goo.gl/Ukrw5B) and OpenSimProcessingScript (folder structure from BOPS should be the same). Feel free to add your own templates and contribute to the repo.

NOTE: template for assisted mode not optimized at the moment. the results from assisted mode will probably not look good. On the todo list is writing an optimization to choose parameters for the assisted mode.

* * * * * 
# Files Included  #
run batchMAIN.m to run everything
OR run in this order: batchConvertOsimToSubjectXml.m --> batchWriteCeinmsSetupTrialXml.m --> batchWriteCeinmsTrialAndContactModelXml.m --> batchCalibrate.m --> batchCEINMS_withHJCF.m

1. loadGenAllSubjDataAndDirInWorkspace.m
> script to load all directories in workspace, recommended to put this script in your MATLAB path as it is used for OpenSimProcessingScripts. They are the same, only provided here for convenience if you're using your own OpenSimProcessingScript pipeline 
2. _batchConvertOsimToSubjectXml.m_
> create uncalibrated subject XMLs from opensim model
3. _batchWriteCalibrationXml.m_
> write all XMLs needed for calibration
4. _batchWriteExecutionXml.m_
> write all XMLs required for execution
5. _batchCalibrate.m_
> batch script to run calibration
6. _batchCEINMS.m_
> batch script to run CEINMS
7. _Templates_ (no need to run anything in here)
> folder with XML templates required to run CEINMS, most of the changes to customize to work with your data are in here 
8. _various other functions needed for batch scripts_

# Additional Required Files #
Files can be obtained here: https://www.dropbox.com/sh/4oyt7ss17jc1n2l/AACyx8nrM8NFzqQc8vupmh5wa?dl=0

* OpenSim.zip
> compiled Opensim with debug (version 3.2 provided), unzip OpenSim.zip and put it in your path
* CEINMS.exe and CEINMScalibrate.exe version with joint loading 
> put them both in your path, updated version will usually be in the dropbox folder
* xsdbin.exe 
> install version 3.3.0, the executable is in the Dropbox if you can't find it online

# Folder Structure #
> Note that there may be an additional folder with dates after subjectXXX folder, this has been taken out in a modified MOtoNMS. Modify your code as needed if this is the case for your data. This is important as this process assumes the following folder structure.

* ElaboratedData _(from MOtoNMS)_
	* subjectXXX _(from MOtoNMS)_
		* dynamicElaborations _(from MOtoNMS)_
			* idMOTONMS
				* trials
					* _emg.mot_
		* staticElaborations _(from MOtoNMS)_
		* sessionData _(from MOtoNMS)_
		* staticElaborations _(from MOtoNMS)_
			* _static.xml_
			* _Static_subject.trc_
		* scaleModels _(from scaling repo)_
			* idOPENSIM
				* _subject.osim_
				* _Setup_Scale.xml_
				* _Static_subject.mot_
		* inverseKinematics _(from OpenSimProcessingScript repo)_
			* idOPENSIM
				* trials
					* _setup_IK.xml_
					* _ik.mot_
		* inverseDynamics _(from OpenSimProcessingScript repo)_
			* idOPENSIM
				* trials
					* _setup_ID.xml_
					* _external_loads.xml_
					* _id.mot_
		* staticOpt _(from OpenSimProcessingScript repo)_
			* idOPENSIM
				* trials
					* _setup_SO.xml_
					* _SO_StaticOptimization_force.sto_
		* jointcontactAnalysis _(from OpenSimProcessingScript repo)_
			* idOPENSIM
				* trials
					* _setup_JCF.xml_
					* _JCF_JointReaction_ReactionLoads.sto_
		* muscleAnalysis _(from OpenSimProcessingScript repo)_
			* idOPENSIM
				* trials
					* setup_MA.xml
					* _(all .sto outputs needed for ceinms)_
		* __ceinms__ 
			* __idCEINMS__
				* __calibratedSubjects__
					* _calibrationFileL.xml_
					* _setupCalibration.xml_
					* _subjectCalibrated.xml_
					* _uncalibrated.xml_
				* __excitationGenerators__
					* _excitationGenerator16to34L.xml_
				* __execution__
					* Assisted
						* trials
							* __executionOutputs.sto__
					* Hybrid
						* trials
							* __executionOutputs.sto__
					* Openloop
						* trials
							* __executionOutputs.sto__
					* StaticOpt
						* trials
							* __executionOutputs.sto__
					* _execution.xml_
					* _executionMode_SetupTrial.xml_
				* __trials__
					* _trial.xml_
					* _trial_contactModelFile.xml_

## Contacts ##
contact David Saxby or Hoa Hoang

## Acknowledgement ##
We would like to acknowledge Claudio Pizzolato, Monica Reggiani, and the rest of the CEINMS team at RehabEngGroup for their support and work on MOtoNMS and CEINMS.