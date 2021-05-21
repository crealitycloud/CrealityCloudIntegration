# Copyright (c) 2021 Creality
# Uranium is released under the terms of the LGPLv3 or higher.

from . import CrealityCloudOutputDevicePlugin

def getMetaData():
    return{}

def register(app):
    return { "output_device": CrealityCloudOutputDevicePlugin.CrealityCloudOutputDevicePlugin() }