# -*- coding: utf-8 -*-

# Form implementation generated from reading ui file 'qt/configuredialog.ui'
#
# Created: Sat Apr 25 14:11:31 2015
#      by: pyside-uic 0.2.15 running on PySide 1.2.2
#
# WARNING! All changes made in this file will be lost!

from PySide import QtCore, QtGui

class Ui_ConfigureDialog(object):
    def setupUi(self, ConfigureDialog):
        ConfigureDialog.setObjectName("ConfigureDialog")
        ConfigureDialog.resize(562, 238)
        self.gridLayout = QtGui.QGridLayout(ConfigureDialog)
        self.gridLayout.setObjectName("gridLayout")
        self.configGroupBox = QtGui.QGroupBox(ConfigureDialog)
        self.configGroupBox.setTitle("")
        self.configGroupBox.setObjectName("configGroupBox")
        self.gridLayout_2 = QtGui.QGridLayout(self.configGroupBox)
        self.gridLayout_2.setObjectName("gridLayout_2")
        self.horizontalLayout = QtGui.QHBoxLayout()
        self.horizontalLayout.setObjectName("horizontalLayout")
        self.locLineEdit = QtGui.QLineEdit(self.configGroupBox)
        self.locLineEdit.setObjectName("locLineEdit")
        self.horizontalLayout.addWidget(self.locLineEdit)
        self.locButton = QtGui.QPushButton(self.configGroupBox)
        self.locButton.setObjectName("locButton")
        self.horizontalLayout.addWidget(self.locButton)
        self.gridLayout_2.addLayout(self.horizontalLayout, 1, 1, 1, 1)
        self.idLineEdit = QtGui.QLineEdit(self.configGroupBox)
        self.idLineEdit.setObjectName("idLineEdit")
        self.gridLayout_2.addWidget(self.idLineEdit, 0, 1, 1, 1)
        self.locLabel = QtGui.QLabel(self.configGroupBox)
        self.locLabel.setObjectName("locLabel")
        self.gridLayout_2.addWidget(self.locLabel, 1, 0, 1, 1)
        self.idLabel = QtGui.QLabel(self.configGroupBox)
        self.idLabel.setObjectName("idLabel")
        self.gridLayout_2.addWidget(self.idLabel, 0, 0, 1, 1)
        spacerItem = QtGui.QSpacerItem(20, 40, QtGui.QSizePolicy.Minimum, QtGui.QSizePolicy.Expanding)
        self.gridLayout_2.addItem(spacerItem, 2, 1, 1, 1)
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
        ConfigureDialog.setTabOrder(self.idLineEdit, self.locLineEdit)
        ConfigureDialog.setTabOrder(self.locLineEdit, self.locButton)
        ConfigureDialog.setTabOrder(self.locButton, self.buttonBox)

    def retranslateUi(self, ConfigureDialog):
        ConfigureDialog.setWindowTitle(QtGui.QApplication.translate("ConfigureDialog", "Configure TRC Source Step", None, QtGui.QApplication.UnicodeUTF8))
        self.locButton.setText(QtGui.QApplication.translate("ConfigureDialog", "...", None, QtGui.QApplication.UnicodeUTF8))
        self.locLabel.setText(QtGui.QApplication.translate("ConfigureDialog", "Location:  ", None, QtGui.QApplication.UnicodeUTF8))
        self.idLabel.setText(QtGui.QApplication.translate("ConfigureDialog", "identifier:  ", None, QtGui.QApplication.UnicodeUTF8))

