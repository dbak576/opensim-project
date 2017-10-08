
'''
MAP Client Plugin Step
'''
import json

from PySide import QtGui
import json

from mapclient.mountpoints.workflowstep import WorkflowStepMountPoint
from mapclientplugins.trcframeselectorstep.configuredialog import ConfigureDialog

import numpy as np


class TRCFrameSelectorStep(WorkflowStepMountPoint):
    '''
    Skeleton step which is intended to be a helpful starting point
    for new steps.
    '''

    def __init__(self, location):
        super(TRCFrameSelectorStep, self).__init__('TRC Frame Selector', location)
        self._configured = False # A step cannot be executed until it has been configured.
        self._category = 'Anthropometry'
        # Add any other initialisation code here:
        self._icon = QtGui.QImage(':/trcframeselectorstep/images/trcframeselectoricon.png')
        # Ports:
        self.addPort(('http://physiomeproject.org/workflow/1.0/rdf-schema#port',
                      'http://physiomeproject.org/workflow/1.0/rdf-schema#uses',
                      'http://physiomeproject.org/workflow/1.0/rdf-schema#trcdata'))
        self.addPort(('http://physiomeproject.org/workflow/1.0/rdf-schema#port',
                      'http://physiomeproject.org/workflow/1.0/rdf-schema#uses',
                      'integer'))
        self.addPort(('http://physiomeproject.org/workflow/1.0/rdf-schema#port',
                      'http://physiomeproject.org/workflow/1.0/rdf-schema#provides',
                      'http://physiomeproject.org/workflow/1.0/rdf-schema#landmarks'))
        self._config = {}
        self._config['identifier'] = ''
        self._config['Frame'] = '1'

        self._trcdata = None
        self._inputFrame = None
        self._landmarks = None


    def execute(self):
        '''
        Add your code here that will kick off the execution of the step.
        Make sure you call the _doneExecution() method when finished.  This method
        may be connected up to a button in a widget for example.
        '''
        # Put your execute step code here before calling the '_doneExecution' method.
        if self._inputFrame is None:
            frame = int(self._config['Frame'])
        else:
            frame = self._inputFrame

        # print self._trcdata.keys()

        landmarksNames = self._trcdata['Labels']
        try:
            time, landmarksCoords = self._trcdata[frame]
        except KeyError:
            print('Frame {} not found'.format(frame))
            raise KeyError
            
        landmarksNamesData = [frame, time] + landmarksCoords
        self._landmarks = dict(zip(landmarksNames, landmarksNamesData))
        if 'Frame#' in self._landmarks:
            del self._landmarks['Frame#']
        if 'Time' in self._landmarks:
            del self._landmarks['Time']

        for k, v in self._landmarks.items():
            self._landmarks[k] = np.array(v)
        self._doneExecution()

    def setPortData(self, index, dataIn):
        '''
        Add your code here that will set the appropriate objects for this step.
        The index is the index of the port in the port list.  If there is only one
        uses port for this step then the index can be ignored.
        '''
        if index == 0:
            self._trcdata = dataIn # trcdata
        else:
            self._inputFrame = dataIn # integer

    def getPortData(self, index):
        '''
        Add your code here that will return the appropriate objects for this step.
        The index is the index of the port in the port list.  If there is only one
        provides port for this step then the index can be ignored.
        '''
        return self._landmarks # ju#landmarks

    def configure(self):
        '''
        This function will be called when the configure icon on the step is
        clicked.  It is appropriate to display a configuration dialog at this
        time.  If the conditions for the configuration of this step are complete
        then set:
            self._configured = True
        '''
        dlg = ConfigureDialog(QtGui.QApplication.activeWindow().currentWidget())
        dlg.identifierOccursCount = self._identifierOccursCount
        dlg.setConfig(self._config)
        dlg.validate()
        dlg.setModal(True)
        
        if dlg.exec_():
            self._config = dlg.getConfig()
        
        self._configured = dlg.validate()
        self._configuredObserver()

    def getIdentifier(self):
        '''
        The identifier is a string that must be unique within a workflow.
        '''
        return self._config['identifier']

    def setIdentifier(self, identifier):
        '''
        The framework will set the identifier for this step when it is loaded.
        '''
        self._config['identifier'] = identifier

    def serialize(self):
        '''
        Add code to serialize this step to disk. Returns a json string for
        mapclient to serialise.
        '''
        return json.dumps(self._config, default=lambda o: o.__dict__, sort_keys=True, indent=4)

    def deserialize(self, string):
        '''
        Add code to deserialize this step from disk. Parses a json string
        given by mapclient
        '''
        self._config.update(json.loads(string))

        d = ConfigureDialog()
        d.identifierOccursCount = self._identifierOccursCount
        d.setConfig(self._config)
        self._configured = d.validate()


