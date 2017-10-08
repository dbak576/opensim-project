"""
Module for customising opensim segmented muscle points 
"""
import os
import numpy as np
import copy
from gias2.fieldwork.field import geometric_field
from gias2.fieldwork.field.tools import fitting_tools
from gias2.common import transform3D
from gias2.registration import alignment_fitting as af
from gias2.musculoskeletal.bonemodels import bonemodels
from gias2.musculoskeletal import osim
import muscleVolumeCalculator
import re
import math
import json
from numpy import pi
from scipy.interpolate import interp1d

import pdb

SELF_DIR = os.path.split(__file__)[0]
DATA_DIR = os.path.join(SELF_DIR, 'data/node_numbers/')
TEMPLATE_OSIM_PATH = os.path.join(SELF_DIR, 'data', 'gait2392_simbody_wrap.osim')

VALID_SEGS = set(['pelvis',
                  'femur-l', 'femur-r',
                  'tibia-l', 'tibia-r',
                  ])
OSIM_FILENAME = 'gait2392_simbody.osim'
VALID_UNITS = ('nm', 'um', 'mm', 'cm', 'm', 'km')

TIBFIB_SUBMESHES = ('tibia', 'fibula')
TIBFIB_SUBMESH_ELEMS = {'tibia': range(0, 46),
                        'fibula': range(46,88),
                        }
TIBFIB_BASISTYPES = {'tri10':'simplex_L3_L3','quad44':'quad_L3_L3'}

def dim_unit_scaling(in_unit, out_unit):
    """
    Calculate the scaling factor to convert from the input unit (in_unit) to
    the output unit (out_unit). in_unit and out_unit must be a string and one
    of ['nm', 'um', 'mm', 'cm', 'm', 'km']. 

    inputs
    ======
    in_unit : str
        Input unit
    out_unit :str
        Output unit

    returns
    =======
    scaling_factor : float
    """

    unit_vals = {
        'nm': 1e-9,
        'um': 1e-6,
        'mm': 1e-3,
        'cm': 1e-2,
        'm':  1.0,
        'km': 1e3,
        }

    if in_unit not in unit_vals:
        raise ValueError(
            'Invalid input unit {}. Must be one of {}'.format(
                in_unit, list(unit_vals.keys())
                )
            )
    if out_unit not in unit_vals:
        raise ValueError(
            'Invalid input unit {}. Must be one of {}'.format(
                in_unit, list(unit_vals.keys())
                )
            )

    return unit_vals[in_unit]/unit_vals[out_unit]

def update_femur_opensim_acs(femur_model):
    femur_model.acs.update(
        *bonemodels.model_alignment.createFemurACSOpenSim(
            femur_model.landmarks['femur-HC'],
            femur_model.landmarks['femur-MEC'],
            femur_model.landmarks['femur-LEC'],
            side=femur_model.side
            )
        )

def update_tibiafibula_opensim_acs(tibiafibula_model):
    tibiafibula_model.acs.update(
        *bonemodels.model_alignment.createTibiaFibulaACSOpenSim(
            tibiafibula_model.landmarks['tibiafibula-MM'],
            tibiafibula_model.landmarks['tibiafibula-LM'],
            tibiafibula_model.landmarks['tibiafibula-MC'],
            tibiafibula_model.landmarks['tibiafibula-LC'],
            side=tibiafibula_model.side
            )
        )

def splitTibiaFibulaGFs(tibfibGField):
    tib = tibfibGField.makeGFFromElements(
            'tibia',
            TIBFIB_SUBMESH_ELEMS['tibia'],
            TIBFIB_BASISTYPES,
            )
    fib = tibfibGField.makeGFFromElements(
            'fibula',
            TIBFIB_SUBMESH_ELEMS['fibula'],
            TIBFIB_BASISTYPES,
            )

    return tib, fib

def localOsim2Global(body, model):
	
	#find the knee angle
    knee = model.joints['knee_l']
    kneeAngle = model.joints['knee_l'].coordSets['knee_angle_l'].defaultValue
    knee_lTrans = np.zeros(3)

    #get the spline values
    trans1X = knee.getSimmSplineParams('translation1')[0]
    trans1Y = knee.getSimmSplineParams('translation1')[1]
    f = interp1d(trans1X, trans1Y, kind='cubic')

    knee_lTrans[0] = f(kneeAngle)

    trans2X = knee.getSimmSplineParams('translation2')[0]
    trans2Y = knee.getSimmSplineParams('translation2')[1]
    f2 = interp1d(trans2X, trans2Y, kind='cubic')
    knee_lTrans[1] = f2(kneeAngle)
    
	#find the knee angle
    knee = model.joints['knee_r']
    kneeAngle = model.joints['knee_r'].coordSets['knee_angle_r'].defaultValue
    knee_rTrans = np.zeros(3)

    #get the spline values
    trans1X = knee.getSimmSplineParams('translation1')[0]
    trans1Y = knee.getSimmSplineParams('translation1')[1]
    f = interp1d(trans1X, trans1Y, kind='cubic')

    knee_rTrans[0] = f(kneeAngle)

    trans2X = knee.getSimmSplineParams('translation2')[0]
    trans2Y = knee.getSimmSplineParams('translation2')[1]
    f2 = interp1d(trans2X, trans2Y, kind='cubic')
    knee_rTrans[1] = f2(kneeAngle)    
	
    if body == 'pelvis':
        trans = np.zeros(3)
    elif body == 'femur_l':
        trans = model.joints['hip_l'].locationInParent
    elif body == 'femur_r':
        trans = model.joints['hip_r'].locationInParent
    elif body == 'tibia_l':
        trans = (model.joints['hip_l'].locationInParent +
            knee_lTrans)
    elif body == 'tibia_r':
        trans = (model.joints['hip_r'].locationInParent +
            knee_rTrans)
    elif body == 'talus_l':
        trans = (model.joints['hip_l'].locationInParent +
            knee_lTrans +
            model.joints['ankle_l'].locationInParent)			
    elif body == 'talus_r':
        trans = (model.joints['hip_r'].locationInParent +
            knee_rTrans	+
            model.joints['ankle_r'].locationInParent)			
    elif body == 'calcn_l': 
        trans = (model.joints['hip_l'].locationInParent +
            knee_lTrans	+
            model.joints['ankle_l'].locationInParent +
            model.joints['subtalar_l'].locationInParent)			
    elif body == 'calcn_r':
        trans = (model.joints['hip_r'].locationInParent +
            knee_rTrans	+
            model.joints['ankle_r'].locationInParent +
            model.joints['subtalar_r'].locationInParent)		
    elif body == 'toes_l':
       trans = (model.joints['hip_l'].locationInParent +
            knee_lTrans	+
            model.joints['ankle_l'].locationInParent +
            model.joints['subtalar_l'].locationInParent +
            model.joints['mtp_l'].locationInParent)		
    elif body == 'toes_r':
        trans = (model.joints['hip_r'].locationInParent +
            knee_rTrans	+
            model.joints['ankle_r'].locationInParent +
            model.joints['subtalar_r'].locationInParent +
            model.joints['mtp_r'].locationInParent)
	
    return trans


class gait2392MuscleCustomiser(object):

    def __init__(self, config, ll=None, osimmodel=None, landmarks=None):
        """
        Class for customising gait2392 muscle points using host-mesh fitting

        inputs
        ======
        config : dict
            Dictionary of option. (work in progress) Example:
            {
            'osim_output_dir': '/path/to/output/model.osim',
            'in_unit': 'mm',
            'out_unit': 'm',
            'write_osim_file': True,
            'update_knee_splines': False,
            'static_vas': False,
            }
        ll : LowerLimbAtlas instance
            Model of lower limb bone geometry and pose
        osimmodel : opensim.Model instance
            The opensim model instance to customise

        """
        self.config = config
        self.ll = ll
        self.trcdata = landmarks
        self.gias_osimmodel = None
        if osimmodel is not None:
            self.set_osim_model(osimmodel)
        self._unit_scaling = dim_unit_scaling(
            self.config['in_unit'], self.config['out_unit']
            )

    def set_osim_model(self, model):
        self.gias_osimmodel = osim.Model(model=model)
    
    def cust_pelvis(self):
		
        pelvis = self.ll.models['pelvis']
		
		#load the pelvis muscle attachment node numbers
        with open(DATA_DIR + 'pelvisNodeNumbers.txt') as infile:
            pelvisData = json.load(infile)
        
        pelvisAttachmentNodeNums = pelvisData.values()
        pelvisMuscleNames = pelvisData.keys()
        pelvisMuscleNames = [str(item) for item in pelvisMuscleNames]
		
		#the muscle attachments were selected an a 24x24 mesh
        pelvisPoints, lhF = pelvis.gf.triangulate([24,24])
		
		#align the discretised pelvis points and the muscle attachments to the opensims pelvis local coordinate system
        localPelvisPoints = pelvis.acs.map_local(pelvisPoints)/1000
        pelvisAttachments = localPelvisPoints[pelvisAttachmentNodeNums]
		
        for i in range(len(pelvisMuscleNames)):
            muscle = self.gias_osimmodel.muscles[str(pelvisMuscleNames[i])]
            pathPoints = muscle.path_points
            s = sorted(muscle.path_points.keys())
			
            #aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPoints[s[0]].body.name == 'pelvis':
                aSite = 0
            elif pathPoints[s[-1]].body.name == 'pelvis':
                aSite = -1
			
			#update the location of the pathpoint	
            pp = pathPoints[s[aSite]]
            pp.location = pelvisAttachments[i]

    def cust_femur_l(self):
		
        leftFemur = self.ll.models['femur-l']
		
		#load in the femur muscle attachment node numbers
        with open(DATA_DIR + 'leftFemurNodeNumbers.txt') as infile:
            leftFemurData = json.load(infile)
            
        leftFemurAttachmentNodeNums = leftFemurData.values()
        leftFemurMuscleNames = leftFemurData.keys()
        leftFemurMuscleNames = [str(item) for item in leftFemurMuscleNames]
        
        #update the geometric field coordinate system to match opensims
        update_femur_opensim_acs(leftFemur)
        
        #the muscle attachments were selected an a 24x24 mesh
        leftFemurPoints, lhF = leftFemur.gf.triangulate([24,24])
        
   		#align the discretised femur points and the muscle attachments to the opensims femur local coordinate system
        localLeftFemurPoints = leftFemur.acs.map_local(leftFemurPoints)/1000
        leftFemurAttachments = localLeftFemurPoints[leftFemurAttachmentNodeNums]
        
        for i in range(len(leftFemurMuscleNames)):
            muscleLeft = self.gias_osimmodel.muscles[str(leftFemurMuscleNames[i])]
            pathPointsLeft = muscleLeft.path_points
            sL = sorted(muscleLeft.path_points.keys())
		
			#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsLeft[sL[0]].body.name == 'femur_l':
                aSite = 0
            elif pathPointsLeft[sL[-1]].body.name == 'femur_l':
                aSite = -1
			
			#update the location of the pathpoint
            ppL = pathPointsLeft[sL[aSite]]
            ppL.location = leftFemurAttachments[i]
       
    def cust_femur_r(self):
		
        rightFemur = self.ll.models['femur-r']
        rightFemur.side = 'right'
		
        with open(DATA_DIR + 'rightFemurNodeNumbers.txt') as infile:
            rightFemurData = json.load(infile)
            
        rightFemurAttachmentNodeNums = rightFemurData.values()
        rightFemurMuscleNames = rightFemurData.keys()
        rightFemurMuscleNames = [str(item) for item in rightFemurMuscleNames]
        
        #update the geometric field coordinate system to match opensims
        update_femur_opensim_acs(rightFemur)
        
        rightFemurPoints, rhF = rightFemur.gf.triangulate([24,24])
        
        localRightFemurPoints = rightFemur.acs.map_local(rightFemurPoints)/1000
        rightFemurAttachments = localRightFemurPoints[rightFemurAttachmentNodeNums]
        
		#update attachments
        for i in range(len(rightFemurMuscleNames)):
            muscleRight = self.gias_osimmodel.muscles[str(rightFemurMuscleNames[i])]
            pathPointsRight = muscleRight.path_points
            sR = sorted(muscleRight.path_points.keys())
		
			#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsRight[sR[0]].body.name == 'femur_r':
                aSite = 0
            elif pathPointsRight[sR[-1]].body.name == 'femur_r':
                aSite = -1
			
            ppR = pathPointsRight[sR[aSite]]
            ppR.location = rightFemurAttachments[i]

    def cust_tibia_l(self):
		
		#the tibia, patella and fibula all use the same fieldwork model to align with opensim
		
        leftTibFib = self.ll.models['tibiafibula-l']
        leftPatella = self.ll.models['patella-l']
        update_tibiafibula_opensim_acs(leftTibFib)
        
        leftTib, leftFib = splitTibiaFibulaGFs(leftTibFib.gf)
        
        leftTibia = bonemodels.TibiaFibulaModel('tibia', leftTibFib.gf)
                
		#load in the tibia muscle attachment node numbers
        with open(DATA_DIR + 'leftTibiaNodeNumbers.txt') as infile:
            leftTibiaData = json.load(infile)
            
        leftTibiaAttachmentNodeNums = leftTibiaData.values()
        leftTibiaMuscleNames = leftTibiaData.keys()
        leftTibiaMuscleNames = [str(item) for item in leftTibiaMuscleNames]
		
		#load in the fibula muscle attachment node numbers
        with open(DATA_DIR + 'leftFibulaNodeNumbers.txt') as infile:
            leftFibulaData = json.load(infile)
            
        leftFibulaAttachmentNodeNums = leftFibulaData.values()
        leftFibulaMuscleNames = leftFibulaData.keys()
        leftFibulaMuscleNames = [str(item) for item in leftFibulaMuscleNames]
        
        #load in the patella muscle attachment node numbers
        with open(DATA_DIR + 'leftPatellaNodeNumbers.txt') as infile:
            leftPatellaData = json.load(infile)
            
        leftPatellaAttachmentNodeNums = leftPatellaData.values()
        leftPatellaMuscleNames = leftPatellaData.keys()
        leftPatellaMuscleNames = [str(item) for item in leftPatellaMuscleNames]
        
        leftTibiaPoints, lhF = leftTib.triangulate([24,24])
        leftFibulaPoints, lhF = leftFib.triangulate([24,24])
        leftPatellaPoints, lhf = leftPatella.gf.triangulate([24,24])
        
        localLeftTibiaPoints = leftTibFib.acs.map_local(leftTibiaPoints)/1000
        leftTibiaAttachments = localLeftTibiaPoints[leftTibiaAttachmentNodeNums]
        
        localLeftFibulaPoints = leftTibFib.acs.map_local(leftFibulaPoints)/1000
        leftFibulaAttachments = localLeftFibulaPoints[leftFibulaAttachmentNodeNums]

        localLeftPatellaPoints = leftTibFib.acs.map_local(leftPatellaPoints)/1000
        leftPatellaAttachments = localLeftPatellaPoints[leftPatellaAttachmentNodeNums]
        
        #update the tibia attachments
        for i in range(len(leftTibiaMuscleNames)):
            muscleLeft = self.gias_osimmodel.muscles[str(leftTibiaMuscleNames[i])]
            pathPointsLeft = muscleLeft.path_points
            sL = sorted(muscleLeft.path_points.keys())
	
        	#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsLeft[sL[0]].body.name == 'tibia_l':
                aSite = 0
            elif pathPointsLeft[sL[-1]].body.name == 'tibia_l':
                aSite = -1
	
            ppL = pathPointsLeft[sL[aSite]]
            ppL.location = leftTibiaAttachments[i]

        #update the fibula attachments
        for i in range(len(leftFibulaMuscleNames)):
            muscleLeft = self.gias_osimmodel.muscles[str(leftFibulaMuscleNames[i])]
            pathPointsLeft = muscleLeft.path_points
            sL = sorted(muscleLeft.path_points.keys())
	
        	#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsLeft[sL[0]].body.name == 'tibia_l':
                aSite = 0
            elif pathPointsLeft[sL[-1]].body.name == 'tibia_l':
                aSite = -1
	
            ppL = pathPointsLeft[sL[aSite]]
            ppL.location = leftFibulaAttachments[i]

        #update the patella attachments    
        for i in range(len(leftPatellaMuscleNames)):
            muscleLeft = self.gias_osimmodel.muscles[str(leftPatellaMuscleNames[i])]
            pathPointsLeft = muscleLeft.path_points
            sL = sorted(muscleLeft.path_points.keys())
	
        	#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsLeft[sL[0]].body.name == 'tibia_l':
                aSite = 0
            elif pathPointsLeft[sL[-1]].body.name == 'tibia_l':
                aSite = -1
	
            ppL = pathPointsLeft[sL[aSite]]
            ppL.location = leftPatellaAttachments[i]        
        
    def cust_tibia_r(self):
		
        rightTibFib = self.ll.models['tibiafibula-r']
        rightPatella = self.ll.models['patella-r']
        update_tibiafibula_opensim_acs(rightTibFib)
        
        rightTib, rightFib = splitTibiaFibulaGFs(rightTibFib.gf)
        
        rightTibia = bonemodels.TibiaFibulaModel('tibia', rightTibFib.gf)
                
		#load in the tibia attachment node numbers
        with open(DATA_DIR + 'rightTibiaNodeNumbers.txt') as infile:
            rightTibiaData = json.load(infile)
            
        rightTibiaAttachmentNodeNums = rightTibiaData.values()
        rightTibiaMuscleNames = rightTibiaData.keys()
        rightTibiaMuscleNames = [str(item) for item in rightTibiaMuscleNames]
		
		#load in the fibula attachment node numbers
        with open(DATA_DIR + 'rightFibulaNodeNumbers.txt') as infile:
            rightFibulaData = json.load(infile)
            
        rightFibulaAttachmentNodeNums = rightFibulaData.values()
        rightFibulaMuscleNames = rightFibulaData.keys()
        rightFibulaMuscleNames = [str(item) for item in rightFibulaMuscleNames]
        
        #load in the patella attachment node numbers
        with open(DATA_DIR + 'rightPatellaNodeNumbers.txt') as infile:
            rightPatellaData = json.load(infile)
            
        rightPatellaAttachmentNodeNums = rightPatellaData.values()
        rightPatellaMuscleNames = rightPatellaData.keys()
        rightPatellaMuscleNames = [str(item) for item in rightPatellaMuscleNames]
        
        rightTibiaPoints, lhF = rightTib.triangulate([24,24])
        rightFibulaPoints, lhF = rightFib.triangulate([24,24])
        rightPatellaPoints, lhf = rightPatella.gf.triangulate([24,24])
        
        localRightTibiaPoints = rightTibFib.acs.map_local(rightTibiaPoints)/1000
        rightTibiaAttachments = localRightTibiaPoints[rightTibiaAttachmentNodeNums]
        
        localRightFibulaPoints = rightTibFib.acs.map_local(rightFibulaPoints)/1000
        rightFibulaAttachments = localRightFibulaPoints[rightFibulaAttachmentNodeNums]

        localRightPatellaPoints = rightTibFib.acs.map_local(rightPatellaPoints)/1000
        rightPatellaAttachments = localRightPatellaPoints[rightPatellaAttachmentNodeNums]

        for i in range(len(rightTibiaMuscleNames)):
            muscleRight = self.gias_osimmodel.muscles[str(rightTibiaMuscleNames[i])]
            pathPointsRight = muscleRight.path_points
            sR = sorted(muscleRight.path_points.keys())
	
        	#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsRight[sR[0]].body.name == 'tibia_r':
                aSite = 0
            elif pathPointsRight[sR[-1]].body.name == 'tibia_r':
                aSite = -1
	
            ppR = pathPointsRight[sR[aSite]]
            ppR.location = rightTibiaAttachments[i]

        for i in range(len(rightFibulaMuscleNames)):
            muscleRight = self.gias_osimmodel.muscles[str(rightFibulaMuscleNames[i])]
            pathPointsRight = muscleRight.path_points
            sR = sorted(muscleRight.path_points.keys())
	
        	#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsRight[sR[0]].body.name == 'tibia_r':
                aSite = 0
            elif pathPointsRight[sR[-1]].body.name == 'tibia_r':
                aSite = -1
	
            ppR = pathPointsRight[sR[aSite]]
            ppR.location = rightFibulaAttachments[i]
            
        for i in range(len(rightPatellaMuscleNames)):
            muscleRight = self.gias_osimmodel.muscles[str(rightPatellaMuscleNames[i])]
            pathPointsRight = muscleRight.path_points
            sR = sorted(muscleRight.path_points.keys())
	
        	#aSite will be 0 if the attachment is an origin and -1 if insertion
            if pathPointsRight[sR[0]].body.name == 'tibia_r':
                aSite = 0
            elif pathPointsRight[sR[-1]].body.name == 'tibia_r':
                aSite = -1
	
            ppR = pathPointsRight[sR[aSite]]
            ppR.location = rightPatellaAttachments[i] 

    def write_cust_osim_model(self):
        self.gias_osimmodel.save(
            os.path.join(str(self.config['osim_output_dir']), OSIM_FILENAME)
            )

    def customise(self):

        init_muscle_ofl = dict([(m.name, m.optimalFiberLength) for m in self.gias_osimmodel.muscles.values()])
        init_muscle_tsl = dict([(m.name, m.tendonSlackLength) for m in self.gias_osimmodel.muscles.values()])
        
        # prescale muscles
        self.prescale_muscles()

        prescale_muscle_ofl = dict([(m.name, m.optimalFiberLength) for m in self.gias_osimmodel.muscles.values()])
        prescale_muscle_tsl = dict([(m.name, m.tendonSlackLength) for m in self.gias_osimmodel.muscles.values()])

        self.cust_pelvis()
        self.cust_femur_l()
        self.cust_tibia_l()
        self.cust_femur_r()
        self.cust_tibia_r()
        
        # post-scale muscles
        self.postscale_muscles()
        self.updateHipMuscles()
        self.updateKneeMuscles()
        self.updateFootMuscles()
        self.updateWrapPoints()
        self.updateMarkerSet()

        if self.config['update_max_iso_forces']:
            self.updateMaxIsoForces()
        
        postscale_muscle_ofl = dict([(m.name, m.optimalFiberLength) for m in self.gias_osimmodel.muscles.values()])
        postscale_muscle_tsl = dict([(m.name, m.tendonSlackLength) for m in self.gias_osimmodel.muscles.values()])

        for mn in sorted(self.gias_osimmodel.muscles.keys()):
            print('{} OFL: {:8.6f} -> {:8.6f} -> {:8.6f}'.format(
                mn, 
                init_muscle_ofl[mn],
                prescale_muscle_ofl[mn],
                postscale_muscle_ofl[mn]
                )
            )
        for mn in sorted(self.gias_osimmodel.muscles.keys()):
            print('{} TSL: {:8.6f} -> {:8.6f} -> {:8.6f}'.format(
                mn, 
                init_muscle_tsl[mn],
                prescale_muscle_tsl[mn],
                postscale_muscle_tsl[mn]
                )
            )
		

        if self.config['write_osim_file']:
            self.write_cust_osim_model()

    def prescale_muscles(self):
        """
        Apply prescaling and scaling to muscles before bodies and joints are
        customised
        """
        state_0 = self.gias_osimmodel._model.initSystem()

        # create dummy scale factor
        scale_factors = [
            osim.Scale([1,1,1], 'dummy_scale', 'dummy_body')
            ]
        for m in self.gias_osimmodel.muscles.values():
            m.preScale(state_0, *scale_factors)
            # m.scale(state_0, *scale_factors)

    def postscale_muscles(self):
        """
        Postscale muscles after bodies and joints are customised to update
        optimal fiber lengths and tendon slack lengths
        """
        state_1 = self.gias_osimmodel._model.initSystem()
        # create dummy scale factor
        scale_factors = [
            osim.Scale([1,1,1], 'dummy_scale', 'dummy_body')
            ]
        for m in self.gias_osimmodel.muscles.values():
            m.postScale(state_1, *scale_factors)
	
    def updateMaxIsoForces(self):
		
		osimModel = self.gias_osimmodel
		subjectHeight = float(self.config['subject_height'])
		subjectMass = float(self.config['subject_mass'])
	
		# calculate muscle volumes using Handsfield (2014)
		osimAbbr, muscleVolume = muscleVolumeCalculator.muscleVolumeCalculator(subjectHeight,subjectMass)
		
		# load Opensim model muscle set
		allMuscles = osimModel._model.getMuscles()
		
		allMusclesNames = range(allMuscles.getSize());
		oldValue = np.zeros([allMuscles.getSize(),1]);
		optimalFibreLength = np.zeros([allMuscles.getSize(),1]);
		penAngleAtOptFibLength = np.zeros([allMuscles.getSize(),1]);
		
		for i in range(allMuscles.getSize()):
			allMusclesNames[i] = allMuscles.get(i).getName()
			oldValue[i] = allMuscles.get(i).getMaxIsometricForce()
			optimalFibreLength[i] = allMuscles.get(i).getOptimalFiberLength()
			penAngleAtOptFibLength[i] = np.rad2deg(allMuscles.get(i).getPennationAngleAtOptimalFiberLength())
		
		# convert opt. fibre length from [m] to [cm] to match volume units
		# [cm^3]
		optimalFibreLength *= 100;
		
		allMusclesNamesCut = range(allMuscles.getSize())
		for i in range(len(allMusclesNames)):
			# delete trailing '_r' or '_l'
			currMuscleName = allMusclesNames[i][0:-2];
			
			# split the name from any digit in its name and only keep the first
			# string.
			currMuscleName = re.split('(\d+)',currMuscleName)
			currMuscleName = currMuscleName[0]
			
			# store in cell
			allMusclesNamesCut[i] = currMuscleName
		
		# calculate ratio of old max isometric forces for multiple-lines-of-action muscles.
		newAbsVolume = np.zeros([allMuscles.getSize(),1]);
		fracOfGroup = np.zeros([allMuscles.getSize(),1]);
		
		for i in range(allMuscles.getSize()):
			
			currMuscleName = allMusclesNamesCut[i]
			currIndex = [ j for j, x in enumerate(osimAbbr) if x==currMuscleName]
			#currIndex = osimAbbr.index(currMuscleName)
			if currIndex:
				currValue = muscleVolume[currIndex];
				newAbsVolume[i] = currValue;
			
			# The peroneus longus/brevis and the extensors (EDL, EHL) have
			# to be treated seperatly as they are represented as a combined muscle
			# group in Handsfield, 2014. The following method may not be the best!
			if currMuscleName == 'per_brev' or currMuscleName == 'per_long':
				currMuscleNameIndex = np.array([0,0])
				tmpIndex = [ j for j, x in enumerate(allMusclesNamesCut) if x=='per_brev']
				currMuscleNameIndex[0] = tmpIndex[0]
				tmpIndex = [ j for j, x in enumerate(allMusclesNamesCut) if x=='per_long']
				currMuscleNameIndex[1] = tmpIndex[0]
				
				currIndex = [ j for j, x in enumerate(osimAbbr) if x=='per_']
				currValue = muscleVolume[currIndex]
				newAbsVolume[i] = currValue;
				
			elif currMuscleName == 'ext_dig' or currMuscleName == 'ext_hal':
				currMuscleNameIndex = np.array([0,0])
				tmpIndex = [ j for j, x in enumerate(allMusclesNamesCut) if x=='ext_dig']
				currMuscleNameIndex[0] = tmpIndex[0]
				tmpIndex = [ j for j, x in enumerate(allMusclesNamesCut) if x=='ext_hal']
				currMuscleNameIndex[1] = tmpIndex[0]
				
				currIndex = [ j for j, x in enumerate(osimAbbr) if x=='ext_']
				currValue = muscleVolume[currIndex]
				newAbsVolume[i] = currValue
			else:
				#find all instances of each muscle
				currMuscleNameIndex = [ j for j, x in enumerate(allMusclesNamesCut) if x==currMuscleName]
				#only require half of the results as we only need muscles from one side
				currMuscleNameIndex = currMuscleNameIndex[0:len(currMuscleNameIndex)/2]
			
			#find how much of the total muscle volume this muscle contributes	
			fracOfGroup[i] = oldValue[i]/sum(oldValue[currMuscleNameIndex]);
			
		# calculate new maximal isometric muscle forces
		
		specificTension = 61 # N/cm^2 from Zajac 1989
		newVolume = fracOfGroup*newAbsVolume;
		#maxIsoMuscleForce = specificTension * (newVolume/optimalFibreLength) * np.cos(math.degrees(penAngleAtOptFibLength))
			
		# Update muscles of loaded model (in workspace only!), change model name and print new osim file.
		maxIsoMuscleForce = np.zeros([allMuscles.getSize(),1])
		for i in range(allMuscles.getSize()):
			maxIsoMuscleForce[i] = specificTension * (newVolume[i]/optimalFibreLength[i]) * np.cos(math.radians(penAngleAtOptFibLength[i]))
		
			# only update, if new value is not zero. Else do not override the
			# original value.
			if maxIsoMuscleForce[i] != 0:
				allMuscles.get(i).setMaxIsometricForce(maxIsoMuscleForce[i][0]);
	
    def updateHipMuscles(self):
        
        muscleNames = ['glut_max1_l','glut_max2_l','glut_max3_l', 'peri_l', 'iliacus_l', 'psoas_l', 'glut_max1_r','glut_max2_r','glut_max3_r', 'peri_r', 'psoas_r', 'iliacus_r']
        joint = 'hip'
        body = 'pelvis'
        #joint - the joint that the muscles cross (currently only works for muscles that cross a single joint)
        #body - the body that the origins of the muscles are attached to
        
        #this has only been tested for muscles that cross the hip
    
        #load in the original model
        mO = osim.Model(TEMPLATE_OSIM_PATH)

        stateO =  mO._model.initSystem()

        #for each muscle
        for i in range(len(muscleNames)):
	
            #display the pathpoints for both muscles
            muscleO = mO.muscles[muscleNames[i]]
            muscle = self.gias_osimmodel.muscles[muscleNames[i]]
	
            side = muscle.name[-2:]
	
            #find the transformation between the two bodies the muscles are attached to
            transO = mO.joints[joint + side].locationInParent
            trans = self.gias_osimmodel.joints[joint + side].locationInParent

            pathPointsO = copy.copy(muscleO.path_points)
            pathPoints = copy.copy(muscle.path_points)

            for j in range(len(pathPointsO)):
	
                if (pathPointsO.values()[j].body.name == body):
                    pathPointsO.values()[j].location -= transO
                    pathPoints.values()[j].location -= trans
	
	        ######################################################
	        #################Transform Points#####################
	        ######################################################
	
            #find the path point names for the origin and the insertion
            sortedKeys = sorted(muscle.path_points.keys())
	
            #the origin will be the first sorted key and the insertion the last
            orig = sortedKeys[0]
            ins = sortedKeys[-1]
	
            #find vector between origins and insertions
            v1 = pathPoints[orig].location -  pathPointsO[orig].location
            v2 = pathPoints[ins].location -  pathPointsO[ins].location

            #the new points are going to be found by translating the points based on a 
            #weighting mulitplied by these two vectors

            #the weighting will be how far along the muscle the point it

            #find the total muscle length
            segments = np.zeros([len(pathPointsO)-1,3])
            lengths = np.zeros(len(pathPointsO)-1)
        
            for j in range(len(pathPointsO)-1):
                segments[j] = pathPointsO[muscle.name + '-P' + str(j+2)].location - pathPointsO[muscle.name + '-P' + str(j+1)].location
                lengths[j] = np.linalg.norm(segments[j])

            Tl = np.sum(lengths)

            #Define the weighting function
            #for the points calculate the magnitude of the new vector and at what angle

            for j in range(len(pathPointsO)-2):
            
                #the second pathpoint will be the first via point
                p = pathPointsO[muscle.name + '-P' + str(j+2)].location
	
                #find how far along the muscle the point is
                dl = np.sum(lengths[:j+1])

                #create the new points by finding adding a weighted vector
                pNew = ((dl/Tl)*v2) + ((1-dl/Tl)*v1) + p
	
                #update the opensim model
                muscle.path_points[muscle.name + '-P' + str(j+2)].location = pNew
	
            #tranform the points back to the main body local coordinate system
            for j in range(len(pathPoints)):
	
		        if (pathPoints.values()[j].body.name == body):
			        pathPoints.values()[j].location += trans

    def updateKneeMuscles(self):
		
        muscleNames = ['bifemlh_l', 'semimem_l', 'semiten_l', 'sar_l', 'tfl_l', 
                       'grac_l', 'rect_fem_l', 'bifemlh_r', 'semimem_r', 'semiten_r',
                       'sar_r', 'tfl_r', 'grac_r', 'rect_fem_r', 'bifemsh_l', 'vas_med_l',
                       'vas_int_l', 'vas_lat_l', 'bifemsh_r', 'vas_med_r', 'vas_int_r',
                       'vas_lat_r', 'med_gas_l', 'lat_gas_l', 'med_gas_r', 'lat_gas_r']

        #load in the original model
        mO = osim.Model(TEMPLATE_OSIM_PATH)

        stateO =  mO._model.initSystem()
        
        for i in range(len(muscleNames)):
            #display the pathpoints for both muscles
            muscleO = mO.muscles[muscleNames[i]]
            muscle = self.gias_osimmodel.muscles[muscleNames[i]]
	
            side = muscle.name[-1]
	    
            pathPointsO = copy.copy(muscleO.path_points)
            pathPoints = copy.copy(muscle.path_points)

            for j in range(len(pathPointsO)):
                pathPointsO.values()[j].location += localOsim2Global(pathPointsO.values()[j].body.name, mO)
                pathPoints.values()[j].location += localOsim2Global(pathPoints.values()[j].body.name, self.gias_osimmodel)

            #find the path point names for the origin and the insertion
            sortedKeys = sorted(muscle.path_points.keys())
	
            #the origin will be the first sorted key and the insertion the last
            orig = sortedKeys[0]
            ins = sortedKeys[-1]
	
            #find vector between origins and insertions
            v1 = pathPoints[orig].location -  pathPointsO[orig].location
            v2 = pathPoints[ins].location -  pathPointsO[ins].location

            # the new points are going to be found by translating the points based on a 
            # weighting mulitplied by these two vectors

            #the weighting will be how far along the muscle the point it

            #find the total muscle length
            segments = np.zeros([len(pathPointsO)-1,3])
            lengths = np.zeros(len(pathPointsO)-1)
            for j in range(len(pathPointsO)-1):
                segments[j] = pathPointsO[muscle.name + '-P' + str(j+2)].location - pathPointsO[muscle.name + '-P' + str(j+1)].location
                lengths[j] = np.linalg.norm(segments[j])

            Tl = np.sum(lengths)
     
            #Define the weighting function
            #for the points calculate the magnitude of the new vector and at what angle

            for j in range(len(pathPointsO)-2):
            
                #the second pathpoint will be the first via point
                p = pathPointsO[muscle.name + '-P' + str(j+2)].location
	
                #find how far along the muscle the point is
                dl = np.sum(lengths[:j+1])

                #create the new points by finding adding a weighted vector
                pNew = ((dl/Tl)*v2) + ((1-dl/Tl)*v1) + p
	
                #update the opensim model
                muscle.path_points[muscle.name + '-P' + str(j+2)].location = pNew
	
            #tranform the pelvis points back to the pelvis region
            for j in range(len(pathPoints)):
               pathPoints.values()[j].location -= localOsim2Global(pathPoints.values()[j].body.name, self.gias_osimmodel)

    def updateFootMuscles(self):
        
        muscleNames = ['ext_dig_l','ext_hal_l','flex_dig_l', 'flex_hal_l', 'per_brev_l',
				'per_long_l', 'per_tert_l', 'tib_ant_l', 'tib_post_l',
				'ext_dig_r','ext_hal_r','flex_dig_r', 'flex_hal_r', 'per_brev_r',
				'per_long_r', 'per_tert_r', 'tib_ant_r', 'tib_post_r']

        #load in the original model
        mO = osim.Model(TEMPLATE_OSIM_PATH)
        stateO =  mO._model.initSystem()

        for i in range(len(muscleNames)):
			
			#get the pathPoints for the old and new muscle
            muscleO = mO.muscles[muscleNames[i]]
            muscle = self.gias_osimmodel.muscles[muscleNames[i]]
			
            side = muscle.name[-1]
		
			#find the transformation between the two bodies the muscles are attached to
            transO = mO.joints['ankle_' + side].locationInParent + mO.joints['subtalar_' + side].locationInParent
            trans = self.gias_osimmodel.joints['ankle_' + side].locationInParent + self.gias_osimmodel.joints['subtalar_' + side].locationInParent
		
            pathPointsO = copy.copy(muscleO.path_points)
            pathPoints = copy.copy(muscle.path_points)
		
			######################################################
			#################Transform Points#####################
			######################################################
			
			#find the path point names for the origin and the insertion
            sortedKeys = sorted(muscle.path_points.keys())
			
			#the origin will be the first sorted key
            orig = sortedKeys[0]
			
			#find the first point on the calcn
            for j in sortedKeys:
                if pathPoints[j].body.name == 'calcn_' + side:
                    ins = j
                    break
			
            endPP = sortedKeys.index(ins)
			
            for j in range(endPP+1):
			
                if (pathPointsO[sortedKeys[j]].body.name == 'calcn_' + side):
                    pathPointsO[sortedKeys[j]].location += transO
                    pathPoints[sortedKeys[j]].location += trans
				
			#find vector between origins and insertions
            v1 = pathPoints[orig].location -  pathPointsO[orig].location
            v2 = pathPoints[ins].location -  pathPointsO[ins].location
		
			# the new points are going to be found by translating the points based on a 
			# weighting mulitplied by these two vectors
		
			#the weighting will be how far along the muscle the point it
		
			#find the total muscle length
            segments = np.zeros([endPP,3])
            lengths = np.zeros(endPP)
            for j in range(endPP):
                segments[j] = pathPointsO[muscle.name + '-P' + str(j+2)].location - pathPointsO[muscle.name + '-P' + str(j+1)].location
                lengths[j] = np.linalg.norm(segments[j])
		
            Tl = np.sum(lengths)
		
			#Define the weighting function
			#for the points calculate the magnitude of the new vector and at what angle
		
            for j in range(endPP-1):
				#the second pathpoint will be the first via point
                p = pathPointsO[muscle.name + '-P' + str(j+2)].location
			
				#find how far along the muscle the point is
                dl = np.sum(lengths[:j+1])
		
				#create the new points by finding adding a weighted vector
                pNew = ((dl/Tl)*v2) + ((1-dl/Tl)*v1) + p
		
				#update the opensim model
                muscle.path_points[muscle.name + '-P' + str(j+2)].location = pNew
			
            for j in range(endPP+1):
                if (pathPoints[sortedKeys[j]].body.name == 'calcn_' + side):
                    pathPoints[sortedKeys[j]].location -= trans
					    
    def updateWrapPoints(self):
		
        muscleNames =['psoas_l','iliacus_l', 'psoas_r','iliacus_r']
        wrapNames = ['PS_at_brim_l', 'IL_at_brim_l', 'PS_at_brim_r', 'IL_at_brim_r']
        joint = 'hip'
        wrapPoints = {'psoas_l':26, 'psoas_r':26, 'iliacus_l':4926, 'iliacus_r':26}

        for i in range(len(muscleNames)):
		
            wrap = self.gias_osimmodel.wrapObjects[wrapNames[i]]

            radiiString = wrap.getDimensions()
	
	        #increase the radii by a small amount so the via point don't sit directly on the wrap object
            radii = np.array(str.split(radiiString))[1:].astype(float) + 0.002

            theta = np.linspace(0,2*pi, 100)
            phi = np.linspace(0,pi, 50)
            sphere = np.zeros([1, 3])
            wrapCentre = wrap.translation
	
            for j in range(len(theta)):
                for k in range(len(phi)):
                    x = wrapCentre[0] + radii[0] * np.cos(theta[j]) * np.sin(phi[k])
                    y = wrapCentre[1] + radii[1] * np.sin(theta[j]) * np.sin(phi[k])
                    z = wrapCentre[2] + radii[2] * np.cos(phi[k])
		
                    if (i==0 and j == 0):
                        sphere[i,:] = [x,y,z]
                    else:
                        sphere = np.vstack([sphere, [x,y,z]])
	
	        #with the sphere created get the via point
            muscle = self.gias_osimmodel.muscles[muscleNames[i]]
	
            viaPoint = muscle.path_points[muscle.name+'-P2']
	
            #find the closest point on the sphere
            newPoint = sphere[wrapPoints[muscle.name]]
	
            #update the path point
            viaPoint.location = newPoint
	
            #check if P-3 is inside the wrap surface
            checkPoint = muscle.path_points[muscle.name+'-P3']
	
            #tranform to global coordinates
	
            side = muscleNames[i][-2:]
	
            #find the transformation between the two bodies the muscles are attached to
            trans = self.gias_osimmodel.joints[joint + side].locationInParent
	
            oldPoint = checkPoint.location + trans
		
            #find the distance between the closest point on the sphere and the centre
            dists = sphere - (checkPoint.location + trans)
	
            #normalize the distances to each point
            normDists = np.linalg.norm(dists, axis=1)
	
            nodeNum = np.argmin(normDists)
	
            d1 = np.linalg.norm(wrapCentre - sphere[nodeNum])
	
            #find the distance between the point and the centre of the sphere
            d2 = np.linalg.norm(wrapCentre - (checkPoint.location + trans))
	
            #If the distance d1 is larger than d2 move the point is inside the sphere
            #and needs to be moved to the closest point on the sphere
            if (d1>d2):
                checkPoint.location = sphere[nodeNum] - trans
	    
    def updateMarkerSet(self):

        #create dictionary linking landmarks to bodies
        fieldworkMarkers = {
            'pelvis': ['RASI','LASI','RPSI','LPSI','LHJC','RHJC'],
            'femur_l': ['LTH1','LTH2','LTH3','LTH4','LLFC', 'LMFC','LKJC'],
            'femur_r': ['RTH1','RTH2','RTH3','RTH4','RLFC', 'RMFC','RKJC'],
            'tibia_l': ['LTB1','LTB2','LTB3','LTB4','LLMAL','LMMAL','LAJC'],
            'tibia_r': ['RTB1','RTB2','RTB3','RTB4','RLMAL','RMMAL','RAJC']
            }

        otherMarkers = {
            'torso': ['C7','T10','CLAV','STRN','RBack','RACR1','LACR1'],
            'calcn_l': ['LCAL'],
            'toes_l' : ['LMT1','LMT5','LToe'],
            'calcn_r': ['RCAL'],
            'toes_r' : ['RMT1','RMT5','RToe']
            }
   
        ###create dictionary linking landmarks to bodies
        #fieldworkMarkers = {
            #'pelvis': ['L.ASIS','R.ASIS','V.Sacral', 'LHJC', 'RHJC'],
            #'femur_l': ['L.Knee.Lat','L.Knee.Med','L.Thigh.Upper','L.Thigh.Front','L.Thigh.Rear', 'LKJC'],
            #'femur_r': ['R.Knee.Lat','R.Knee.Med','R.Thigh.Upper','R.Thigh.Front','R.Thigh.Rear', 'RKJC'],
            #'tibia_l': ['L.Ankle.Lat','L.Ankle.Med','L.Shank.Upper','L.Shank.Front','L.Shank.Rear', 'LAJC'],
            #'tibia_r': ['R.Ankle.Lat','R.Ankle.Med','R.Shank.Upper','R.Shank.Front','R.Shank.Rear', 'RAJC']
            #}

        #otherMarkers = {
            #'torso': ['L.Acromium','R.Acromium'],
            #'calcn_l': ['L.Heel'],
            #'toes_l' : ['L.Toe.Tip'],
            #'calcn_r': ['R.Heel'],
            #'toes_r' : ['R.Toe.Tip']
            #}

        ##create dictionary linking landmarks to bodies
        #fieldworkMarkers = {
            #'pelvis': ['LAsis','RAsis','LPsis', 'RPsis'],
            #'femur_l': ['LKneeLateral','LKneeMedial','LThighSuperior','LThighInferior','LThighLateral'],
            #'femur_r': ['RKneeLateral','RKneeMedial','RThighSuperior','RThighInferior','RThighLateral'],
            #'tibia_l': ['LAnkleLateral','LAnkleMedial','LShankSuperior','LShankInferior','LShankLateral'],
            #'tibia_r': ['RAnkleLateral','RankleMedial','RShankSuperior','RShankInferior','RShankLateral']
            #}

        #otherMarkers = {
            #'torso': ['LShoulder','RShoulder'],
            #'calcn_l': ['LHeel', 'LMidfootLateral'],
            #'toes_l' : ['LToe'],
            #'calcn_r': ['RHeel', 'RMidfootLateral'],
            #'toes_r' : ['RToe']
            #}
            
        ##create dictionary linking landmarks to bodies based on the Cleveland Marker Set
        #fieldworkMarkers = {
            #'pelvis': ['RASI','LASI','RPSI','LPSI','SACR','LHJC','RHJC'],
            #'femur_l': ['LT1','LT2','LT3','LKNE', 'LKNM','LKJC'],
            #'femur_r': ['RT1','RT2','RT3','RKNE', 'RKNM','RKJC'],
            #'tibia_l': ['LS1','LS2','LS3','LANK','LANM','LAJC'],
            #'tibia_r': ['RS1','RS2','RS3','RANK','RANM','RAJC'],
           #}

        #otherMarkers = {
            #'torso': ['C7','T10','CLAV','STRN','BackExtra','LSHO','LTRI','LELB',
                #'LWRI','RSHO','RTRI','RELB','RWRI'],
            #'calcn_l': ['LHEE'],
            #'toes_l' : ['LTOE'],
            #'calcn_r': ['RHEE'],
            #'toes_r' : ['RTOE']
            #}

        #create dictionary linking landmarks to bodies
        #fieldworkMarkers = {
            #'pelvis': ['LASI','RASI','VSAC','RILC','RPSI','LPSI','LILC'],
            #'femur_l': ['LGTR','LTTL','LTTM','LTBL','LTBM','LKNL','LKNM'],
            #'femur_r': ['RGTR','RTTL','RTTM','RTBL','RTBM','RKNL','RKNM'],
            #'tibia_l': ['LSTL','LSTM','LSBM','LSBL','LMAL','LMAN'],
            #'tibia_r': ['RSTL','RSTM','RSBM','RSBL','RMAL','RMAM']
            #}

        #otherMarkers = {
            #'torso': ['LACR','T7','MST','LWRI','RACR','RTRI','RELB','RWRI'],
            #'calcn_l': ['LHEP','LHED'],
            #'toes_l' : ['LTOE','LMH5','LMH1'],
            #'calcn_r': ['RHEP','RHED'],
            #'toes_r' : ['RTOE','RMH5','RMH1']
            #}

        state =  self.gias_osimmodel._model.initSystem()

        #load in the geometric fields and update their coordinate systems to align with opensim
        pelvis = self.ll.models['pelvis']
        
        femur_l = self.ll.models['femur-l']
        update_femur_opensim_acs(femur_l)
        
        femur_r = self.ll.models['femur-r']
        femur_r.side = 'right'
        update_femur_opensim_acs(femur_r)
        
        tibia_l = self.ll.models['tibiafibula-l']
        update_tibiafibula_opensim_acs(tibia_l)

        tibia_r = self.ll.models['tibiafibula-r']
        tibia_r.side = 'right'
        update_tibiafibula_opensim_acs(tibia_r)

        markerSet = osim.opensim.MarkerSet()
        
        #for each body with a fieldwork model, map the markers to its body
        data = self.landmarks
        
        #for each marker
        for i in data:
			
            body = None
			
			#find what body the marker belongs to
            for j in fieldworkMarkers.keys():
                for k in range(len(fieldworkMarkers[j])):
                    if fieldworkMarkers[j][k] == i:

                        body = self.gias_osimmodel.bodies[j]

                        newMarker = osim.Marker(bodyname=j, offset=eval(j).acs.map_local(np.array([data[fieldworkMarkers[j][k]]])).flatten()/1000)
                        newMarker.name = i
                        markerSet.adoptAndAppend(newMarker._osimMarker)
                        break
	            
	            if body is not None:
					break
	        
		    #if the body has no fieldwork model check if it can be found in the extra dictionary
            if body is None:
			
                #import pdb
                #pdb.set_trace()
			
                for j in otherMarkers.keys():
                    for k in range(len(otherMarkers[j])):
                        if otherMarkers[j][k] == i:
                            body = j
                            
                            if body == 'torso':
                                pointOnParent = pelvis.acs.map_local(np.array([data[i]])).flatten()/1000
                                #find the difference in body coordinates
                                diff = self.gias_osimmodel.joints['back'].locationInParent
                                markerPos = pointOnParent - diff
                                newMarker = osim.Marker(bodyname=body, offset=markerPos)
                                newMarker.name = i 
                                markerSet.adoptAndAppend(newMarker._osimMarker)
                            
                            elif body == 'calcn_l':
                                pointOnParent = tibia_l.acs.map_local(np.array([data[i]])).flatten()/1000
	
                                #find the difference in body coordinates
                                diff = self.gias_osimmodel.joints['ankle_l'].locationInParent + self.gias_osimmodel.joints['subtalar_l'].locationInParent
                                markerPos = pointOnParent - diff
                                newMarker = osim.Marker(bodyname=body, offset=markerPos)
                                newMarker.name = i
                                markerSet.adoptAndAppend(newMarker._osimMarker)
                            
                            elif body == 'calcn_r':
                                pointOnParent = tibia_r.acs.map_local(np.array([data[i]])).flatten()/1000
	
                                #find the difference in body coordinates
                                diff = self.gias_osimmodel.joints['ankle_r'].locationInParent + self.gias_osimmodel.joints['subtalar_r'].locationInParent
                                markerPos = pointOnParent - diff
                                newMarker = osim.Marker(bodyname=body, offset=markerPos)
                                newMarker.name = i
                                markerSet.adoptAndAppend(newMarker._osimMarker)
                            
                            elif body == 'toes_l':
                                 pointOnParent = tibia_l.acs.map_local(np.array([data[i]])).flatten()/1000
	
                                 #find the difference in body coordinates
                                 diff = self.gias_osimmodel.joints['ankle_r'].locationInParent + self.gias_osimmodel.joints['subtalar_r'].locationInParent + self.gias_osimmodel.joints['mtp_l'].locationInParent
                                 markerPos = pointOnParent - diff
                                 newMarker = osim.Marker(bodyname=body, offset=markerPos)
                                 newMarker.name = i
                                 markerSet.adoptAndAppend(newMarker._osimMarker)                
    
                            elif body == 'toes_r':
                                pointOnParent = tibia_r.acs.map_local(np.array([data[i]])).flatten()/1000

                                #find the difference in body coordinates
                                diff = self.gias_osimmodel.joints['ankle_r'].locationInParent + self.gias_osimmodel.joints['subtalar_r'].locationInParent + self.gias_osimmodel.joints['mtp_r'].locationInParent
                                markerPos = pointOnParent - diff
                                newMarker = osim.Marker(bodyname=body, offset=markerPos)
                                newMarker.name = i
                                markerSet.adoptAndAppend(newMarker._osimMarker)        
                
            if body is None:
                print('{} can not be identified as a valid landmark'.
                    format(i))

		#update the marker set of the model
        self.gias_osimmodel._model.replaceMarkerSet(state, markerSet)

