
import os
from PySide import QtGui
from mapclientplugins.gait2392somsomusclestep.ui_configuredialog import Ui_ConfigureDialog
from mapclientplugins.gait2392somsomusclestep.gait2392musclecustsomso import VALID_UNITS
import pdb

INVALID_STYLE_SHEET = 'background-color: rgba(239, 0, 0, 50)'
DEFAULT_STYLE_SHEET = ''

class ConfigureDialog(QtGui.QDialog):
    '''
    Configure dialog to present the user with the options to configure this step.
    '''

    def __init__(self, parent=None):
        '''
        Constructor
        '''
        QtGui.QDialog.__init__(self, parent)

        self._ui = Ui_ConfigureDialog()
        self._ui.setupUi(self)

        # Keep track of the previous identifier so that we can track changes
        # and know how many occurrences of the current identifier there should
        # be.
        self._previousIdentifier = ''
        # Set a place holder for a callable that will get set from the step.
        # We will use this method to decide whether the identifier is unique.
        self.identifierOccursCount = None

        self._setupDialog()
        self._makeConnections()

    def _setupDialog(self):
        for s in VALID_UNITS:
            self._ui.comboBox_in_unit.addItem(s)
            self._ui.comboBox_out_unit.addItem(s)

    def _makeConnections(self):
        self._ui.lineEdit_identifier.textChanged.connect(self.validate)
        self._ui.lineEdit_subject_height.textChanged.connect(self.validate)
        self._ui.lineEdit_subject_mass.textChanged.connect(self.validate)
        self._ui.lineEdit_osim_output_dir.textChanged.connect(self._osimOutputDirEdited)
        self._ui.pushButton_osim_output_dir.clicked.connect(self._osimOutputDirClicked)

    def accept(self):
        '''
        Override the accept method so that we can confirm saving an
        invalid configuration.
        '''
        result = QtGui.QMessageBox.Yes
        if not self.validate():
            result = QtGui.QMessageBox.warning(self, 'Invalid Configuration',
                'This configuration is invalid.  Unpredictable behaviour may result if you choose \'Yes\', are you sure you want to save this configuration?)',
                QtGui.QMessageBox.Yes | QtGui.QMessageBox.No, QtGui.QMessageBox.No)

        if result == QtGui.QMessageBox.Yes:
            QtGui.QDialog.accept(self)

    def validate(self):
        '''
        Validate the configuration dialog fields.  For any field that is not valid
        set the style sheet to the INVALID_STYLE_SHEET.  Return the outcome of the
        overall validity of the configuration.
        '''
        # Determine if the current identifier is unique throughout the workflow
        # The identifierOccursCount method is part of the interface to the workflow framework.
        idValue = self.identifierOccursCount(self._ui.lineEdit_identifier.text())
        idValid = (idValue == 0) or (idValue == 1 and self._previousIdentifier == self._ui.lineEdit_identifier.text())
        if idValid:
            self._ui.lineEdit_identifier.setStyleSheet(DEFAULT_STYLE_SHEET)
        else:
            self._ui.lineEdit_identifier.setStyleSheet(INVALID_STYLE_SHEET)
            
        osimOutputDirValid = os.path.exists(self._ui.lineEdit_osim_output_dir.text())
        if osimOutputDirValid:
            self._ui.lineEdit_osim_output_dir.setStyleSheet(DEFAULT_STYLE_SHEET)
        else:
            self._ui.lineEdit_osim_output_dir.setStyleSheet(INVALID_STYLE_SHEET)
            
        valid = idValid and osimOutputDirValid
        self._ui.buttonBox.button(QtGui.QDialogButtonBox.Ok).setEnabled(valid)

        return valid

    def getConfig(self):
        '''
        Get the current value of the configuration from the dialog.  Also
        set the _previousIdentifier value so that we can check uniqueness of the
        identifier over the whole of the workflow.
        '''
        
        self._previousIdentifier = self._ui.lineEdit_identifier.text()
        config = {}
        config['identifier'] = self._ui.lineEdit_identifier.text()
        config['subject_height'] = self._ui.lineEdit_subject_height.text()
        config['subject_mass'] = self._ui.lineEdit_subject_mass.text()
        config['osim_output_dir'] = self._ui.lineEdit_osim_output_dir.text()
        config['in_unit'] = self._ui.comboBox_in_unit.currentText()
        config['out_unit'] = self._ui.comboBox_out_unit.currentText()
        if self._ui.checkBox_write_osim_file.isChecked():
            config['write_osim_file'] = True
        else:
            config['write_osim_file'] = False
        if self._ui.checkBox_update_knee_splines.isChecked():
            config['update_knee_splines'] = True
        else:
            config['update_knee_splines'] = False
        if self._ui.checkBox_static_vas.isChecked():
            config['static_vas'] = True
        else:
            config['static_vas'] = False
        if self._ui.checkBox_update_max_iso_forces.isChecked():
            config['update_max_iso_forces'] = True
        else:
            config['update_max_iso_forces'] = False
        return config

    def setConfig(self, config):
        '''
        Set the current value of the configuration for the dialog.  Also
        set the _previousIdentifier value so that we can check uniqueness of the
        identifier over the whole of the workflow.
        '''
        
        self._previousIdentifier = config['identifier']
        self._ui.lineEdit_identifier.setText(config['identifier'])
        self._ui.lineEdit_subject_height.setText(config['subject_height'])
        self._ui.lineEdit_subject_mass.setText(config['subject_mass'])
        self._previousOsimOutputDir = config['osim_output_dir']
        self._ui.lineEdit_osim_output_dir.setText(config['osim_output_dir'])
        self._ui.comboBox_in_unit.setCurrentIndex(
            VALID_UNITS.index(
                config['in_unit']
                )
            )
        self._ui.comboBox_out_unit.setCurrentIndex(
            VALID_UNITS.index(
                config['out_unit']
                )
            )

        if config['write_osim_file']:
            self._ui.checkBox_write_osim_file.setChecked(bool(True))
        else:
            self._ui.checkBox_write_osim_file.setChecked(bool(False))

        if config.get('update_knee_splines') is None:
            config['update_knee_splines'] = False
        if config['update_knee_splines']:
            self._ui.checkBox_update_knee_splines.setChecked(bool(True))
        else:
            self._ui.checkBox_update_knee_splines.setChecked(bool(False))

        if config['static_vas']:
            self._ui.checkBox_static_vas.setChecked(bool(True))
        else:
            self._ui.checkBox_static_vas.setChecked(bool(False))
            
        if config['update_max_iso_forces']:
            self._ui.checkBox_update_max_iso_forces.setChecked(bool(True))
        else:
            self._ui.checkBox_update_max_iso_forces.setChecked(bool(False))



    def _osimOutputDirClicked(self):
        location = QtGui.QFileDialog.getExistingDirectory(self, 'Select Directory', self._previousOsimOutputDir)
        if location:
            self._previousOsimOutputDir = location
            self._ui.lineEdit_osim_output_dir.setText(location)

    def _osimOutputDirEdited(self):
        self.validate()
