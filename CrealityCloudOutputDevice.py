import os
import os.path

from . CrealityCloudUtils import CrealityCloudUtils
from PyQt5.QtCore import *
from PyQt5.QtGui import *
from PyQt5.QtNetwork import *
from PyQt5.QtQml import *
from PyQt5.QtQuick import (QQuickView)

from UM.Application import Application
from UM.PluginRegistry import PluginRegistry
from UM.OutputDevice.OutputDevice import OutputDevice
from UM.OutputDevice import OutputDeviceError


class CrealityCloudOutputDevice(OutputDevice):
    def __init__(self, pluginId):
        super().__init__("crealitycloud")

        self._pluginId = pluginId
        self.setName("Local File")
        self.setShortDescription("Upload to Creality Cloud")
        self.setDescription("Upload to Creality Cloud")
        self.setIconName("upload_gcode")
        self.utils = CrealityCloudUtils()

        self.plugin_window = None
        self._writing = False
        self._nodes = None

    def requestWrite(self, nodes, file_name = None, limit_mimetypes = None, file_handler = None, **kwargs):
        if self._writing:
            raise OutputDeviceError.DeviceBusyError()

        self._nodes = None
        self._nodes = nodes
        if self.plugin_window is not None:
            self.plugin_window = None
        

        self.plugin_window = self._createDialogue()
        self.plugin_window.show()

    def _createDialogue(self):
        Application.getInstance()._qml_engine.rootContext().setContextProperty("CloudUtils", self.utils)
        qml_file = os.path.join(PluginRegistry.getInstance().getPluginPath(self._pluginId), "PluginMain.qml")
        component = Application.getInstance().createQmlComponent(qml_file)
        
        return component