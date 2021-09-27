from UM.OutputDevice.OutputDevicePlugin import OutputDevicePlugin
from .CrealityCloudOutputDevice import CrealityCloudOutputDevice

class CrealityCloudOutputDevicePlugin(OutputDevicePlugin):
    def __init__(self):
        super().__init__()
        
    def start(self):
        self.getOutputDeviceManager().addOutputDevice(CrealityCloudOutputDevice(self.getPluginId()))

    def stop(self):
        self.getOutputDeviceManager().removeOutputDevice("crealitycloud")