# Copyright (c) 2021 Creality
# Uranium is released under the terms of the LGPLv3 or higher.

from . import CrealityCloudOutputDevicePlugin
from . import CrealityCloudModelBrowserPlugin
from UM.Application import Application
from . CrealityCloudUtils import CrealityCloudUtils
def getMetaData():
    return{}

def _onEngineCreated():
    Application.getInstance()._qml_engine.rootContext().setContextProperty("CloudUtils", CrealityCloudUtils.getInstance())

def register(app):
    Application.getInstance().engineCreatedSignal.connect(_onEngineCreated)
    return { "output_device": CrealityCloudOutputDevicePlugin.CrealityCloudOutputDevicePlugin(),
            "extension": CrealityCloudModelBrowserPlugin.CrealityCloudModelBrowserPlugin()
     }