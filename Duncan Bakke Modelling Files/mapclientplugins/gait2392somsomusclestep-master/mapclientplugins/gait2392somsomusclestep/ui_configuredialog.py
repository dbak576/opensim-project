# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'qt/configuredialog.ui'
#
# Created: Fri Jul 15 14:22:18 2016
#      by: pyside-uic 0.2.15 running on PySide 1.2.2
#
# WARNING! All changes made in this file will be lost!

from PySide import QtCore, QtGui

class Ui_ConfigureDialog(object):
    def setupUi(self, ConfigureDialog):
        ConfigureDialog.setObjectName("ConfigureDialog")
        ConfigureDialog.resize(550, 303)
        self.gridLayout = QtGui.QGridLayout(ConfigureDialog)
        self.gridLayout.setObjectName("gridLayout")
        self.configGroupBox = QtGui.QGroupBox(ConfigureDialog)
        self.configGroupBox.setTitle("")
        self.configGroupBox.setObjectName("configGroupBox")
        
        self.formLayout = QtGui.QFormLayout(self.configGroupBox)
        self.formLayout.setFieldGrowthPolicy(QtGui.QFormLayout.AllNonFixedFieldsGrow)
        self.formLayout.setObjectName("formLayout")
        
        self.label_identifier = QtGui.QLabel(self.configGroupBox)
        self.label_identifier.setObjectName("label_identifier")
        self.formLayout.setWidget(0, QtGui.QFormLayout.LabelRole, self.label_identifier)
        self.lineEdit_identifier = QtGui.QLineEdit(self.configGroupBox)
        self.lineEdit_identifier.setObjectName("lineEdit_identifier")
        self.formLayout.setWidget(0, QtGui.QFormLayout.FieldRole, self.lineEdit_identifier)
        
        self.label_input_unit = QtGui.QLabel(self.configGroupBox)
        self.label_input_unit.setObjectName("label_input_unit")
        self.formLayout.setWidget(1, QtGui.QFormLayout.LabelRole, self.label_input_unit)
        self.comboBox_in_unit = QtGui.QComboBox(self.configGroupBox)
        self.comboBox_in_unit.setObjectName("comboBox_in_unit")
        self.formLayout.setWidget(1, QtGui.QFormLayout.FieldRole, self.comboBox_in_unit)

        self.label_output_unit = QtGui.QLabel(self.configGroupBox)
        self.label_output_unit.setObjectName("label_output_unit")
        self.formLayout.setWidget(2, QtGui.QFormLayout.LabelRole, self.label_output_unit)
        self.comboBox_out_unit = QtGui.QComboBox(self.configGroupBox)
        self.comboBox_out_unit.setObjectName("comboBox_out_unit")
        self.formLayout.setWidget(2, QtGui.QFormLayout.FieldRole, self.comboBox_out_unit)

        self.label_write_osim_file = QtGui.QLabel(self.configGroupBox)
        self.label_write_osim_file.setObjectName("label_write_osim_file")
        self.formLayout.setWidget(3, QtGui.QFormLayout.LabelRole, self.label_write_osim_file)
        self.checkBox_write_osim_file = QtGui.QCheckBox(self.configGroupBox)
        self.checkBox_write_osim_file.setText("")
        self.checkBox_write_osim_file.setObjectName("checkBox_write_osim_file")
        self.formLayout.setWidget(3, QtGui.QFormLayout.FieldRole, self.checkBox_write_osim_file)

        self.label_update_knee_splines = QtGui.QLabel(self.configGroupBox)
        self.label_update_knee_splines.setObjectName("label_update_knee_splines")
        self.formLayout.setWidget(4, QtGui.QFormLayout.LabelRole, self.label_update_knee_splines)
        self.checkBox_update_knee_splines = QtGui.QCheckBox(self.configGroupBox)
        self.checkBox_update_knee_splines.setText("")
        self.checkBox_update_knee_splines.setObjectName("checkBox_update_knee_splines")
        self.formLayout.setWidget(4, QtGui.QFormLayout.FieldRole, self.checkBox_update_knee_splines)

        self.label_static_vas = QtGui.QLabel(self.configGroupBox)
        self.label_static_vas.setObjectName("label_static_vas")
        self.formLayout.setWidget(5, QtGui.QFormLayout.LabelRole, self.label_static_vas)
        self.checkBox_static_vas = QtGui.QCheckBox(self.configGroupBox)
        self.checkBox_static_vas.setText("")
        self.checkBox_static_vas.setObjectName("checkBox_static_vas")
        self.formLayout.setWidget(5, QtGui.QFormLayout.FieldRole, self.checkBox_static_vas)
        
        self.label_update_max_iso_forces = QtGui.QLabel(self.configGroupBox)
        self.label_update_max_iso_forces.setObjectName("label_update_max_iso_forces")
        self.formLayout.setWidget(6, QtGui.QFormLayout.LabelRole, self.label_update_max_iso_forces)
        self.checkBox_update_max_iso_forces = QtGui.QCheckBox(self.configGroupBox)
        self.checkBox_update_max_iso_forces.setText("")
        self.checkBox_update_max_iso_forces.setObjectName("checkBox_update_max_iso_forces")
        self.formLayout.setWidget(6, QtGui.QFormLayout.FieldRole, self.checkBox_update_max_iso_forces)
        
        self.label_subject_height = QtGui.QLabel(self.configGroupBox)
        self.label_subject_height.setObjectName("label_subject_height")
        self.formLayout.setWidget(7, QtGui.QFormLayout.LabelRole, self.label_subject_height)
        self.lineEdit_subject_height = QtGui.QLineEdit(self.configGroupBox)
        self.lineEdit_subject_height.setObjectName("lineEdit_subject_height")
        self.formLayout.setWidget(7, QtGui.QFormLayout.FieldRole, self.lineEdit_subject_height)
  
        self.label_subject_mass = QtGui.QLabel(self.configGroupBox)
        self.label_subject_mass.setObjectName("label_subject_mass")
        self.formLayout.setWidget(8, QtGui.QFormLayout.LabelRole, self.label_subject_mass)
        self.lineEdit_subject_mass = QtGui.QLineEdit(self.configGroupBox)
        self.lineEdit_subject_mass.setObjectName("checkBox_subject_mass")
        self.formLayout.setWidget(8, QtGui.QFormLayout.FieldRole, self.lineEdit_subject_mass)
        
        self.label_osim_output_dir = QtGui.QLabel(self.configGroupBox)
        self.label_osim_output_dir.setObjectName("label_osim_output_dir")
        self.formLayout.setWidget(9, QtGui.QFormLayout.LabelRole, self.label_osim_output_dir)
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.lineEdit_osim_output_dir = QtGui.QLineEdit(self.configGroupBox)
        self.lineEdit_osim_output_dir.setObjectName("lineEdit_osim_output_dir")
        self.horizontalLayout.addWidget(self.lineEdit_osim_output_dir)
        self.pushButton_osim_output_dir = QtGui.QPushButton(self.configGroupBox)
        self.pushButton_osim_output_dir.setObjectName("pushButton_osim_output_dir")
        self.horizontalLayout.addWidget(self.pushButton_osim_output_dir)
        self.formLayout.setLayout(9, QtGui.QFormLayout.FieldRole, self.horizontalLayout)
        
        self.gridLayout.addWidget(self.configGroupBox, 0, 0, 1, 1)
        self.buttonBox = QtGui.QDialogButtonBox(ConfigureDialog)
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName("buttonBox")
        self.gridLayout.addWidget(self.buttonBox, 1, 0, 1, 1)

        self.retranslateUi(ConfigureDialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL("accepted()"), ConfigureDialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL("rejected()"), ConfigureDialog.reject)
        QtCore.QMetaObject.connectSlotsByName(ConfigureDialog)
        ConfigureDialog.setTabOrder(self.lineEdit_identifier, self.comboBox_in_unit)
        ConfigureDialog.setTabOrder(self.comboBox_in_unit, self.comboBox_out_unit)
        ConfigureDialog.setTabOrder(self.comboBox_out_unit, self.checkBox_write_osim_file)
        ConfigureDialog.setTabOrder(self.checkBox_write_osim_file, self.checkBox_static_vas)
        ConfigureDialog.setTabOrder(self.checkBox_static_vas, self.lineEdit_osim_output_dir)
        ConfigureDialog.setTabOrder(self.lineEdit_osim_output_dir,self.checkBox_update_max_iso_forces)
        ConfigureDialog.setTabOrder(self.checkBox_update_max_iso_forces, self.lineEdit_subject_height)
        ConfigureDialog.setTabOrder(self.lineEdit_subject_height, self.lineEdit_subject_mass)
        ConfigureDialog.setTabOrder(self.lineEdit_subject_mass, self.lineEdit_osim_output_dir)
        ConfigureDialog.setTabOrder(self.lineEdit_osim_output_dir, self.pushButton_osim_output_dir)
        ConfigureDialog.setTabOrder(self.pushButton_osim_output_dir, self.buttonBox)

    def retranslateUi(self, ConfigureDialog):
        ConfigureDialog.setWindowTitle(QtGui.QApplication.translate("ConfigureDialog", "Configure Fieldwork Gait2392 Muscle HMF Step", None, QtGui.QApplication.UnicodeUTF8))
        self.label_identifier.setText(QtGui.QApplication.translate("ConfigureDialog", "identifier:  ", None, QtGui.QApplication.UnicodeUTF8))
        self.label_input_unit.setText(QtGui.QApplication.translate("ConfigureDialog", "Input unit:", None, QtGui.QApplication.UnicodeUTF8))
        self.label_output_unit.setText(QtGui.QApplication.translate("ConfigureDialog", "Output unit:", None, QtGui.QApplication.UnicodeUTF8))
        self.label_write_osim_file.setText(QtGui.QApplication.translate("ConfigureDialog", "Write Osim file:", None, QtGui.QApplication.UnicodeUTF8))
        self.label_update_knee_splines.setText(QtGui.QApplication.translate("ConfigureDialog", "Update Knee Splines:", None, QtGui.QApplication.UnicodeUTF8))
        self.label_static_vas.setText(QtGui.QApplication.translate("ConfigureDialog", "Static Vastus:", None, QtGui.QApplication.UnicodeUTF8))
        self.label_update_max_iso_forces.setText(QtGui.QApplication.translate("ConfigureDialog", "Update Max Isometric Forces:", None, QtGui.QApplication.UnicodeUTF8))
        self.label_subject_height.setText(QtGui.QApplication.translate("ConfigureDialog", "Subject Height (m):", None, QtGui.QApplication.UnicodeUTF8))
        self.label_subject_mass.setText(QtGui.QApplication.translate("ConfigureDialog", "Subject Mass (kg):", None, QtGui.QApplication.UnicodeUTF8))
        self.label_osim_output_dir.setText(QtGui.QApplication.translate("ConfigureDialog", "Output folder:", None, QtGui.QApplication.UnicodeUTF8))
        self.pushButton_osim_output_dir.setText(QtGui.QApplication.translate("ConfigureDialog", "...", None, QtGui.QApplication.UnicodeUTF8))

