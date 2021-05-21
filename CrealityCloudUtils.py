import os
import json
from PyQt5.QtCore import (QSysInfo, pyqtProperty, pyqtSignal, pyqtSlot, QObject, QUrl, QVariant, QFileInfo, QFile, QByteArray, QUuid, QStandardPaths)
from PyQt5.QtNetwork import (QNetworkAccessManager, QNetworkReply, QNetworkRequest, QNetworkInterface)
from PyQt5.QtGui import QDesktopServices

from UM.Logger import Logger

class CrealityCloudUtils(QObject):

    def __init__(self, parent=None):
        super(CrealityCloudUtils, self).__init__(parent)

        self._osVersion = QSysInfo.productType() + " " + QSysInfo.productVersion()
        self._duid = self._generateDUID()
        self._userInfo = {"token": "", "userId": ""}
        self._appDataFolder = os.path.join(QStandardPaths.writableLocation(QStandardPaths.AppDataLocation), "CrealityCloud")
        self._tokenFile = os.path.join(self._appDataFolder, "token")

    @pyqtSlot(result=str)
    def getOsVersion(self):
        return self._osVersion

    @pyqtSlot(result=str)
    def getDUID(self):

        return self._duid

    def _generateDUID(self):
        macAddress = ""
        nets = QNetworkInterface.allInterfaces()
        # Filter out the MAC address
        for net in nets:
            if net.flags()&QNetworkInterface.IsUp and \
            net.flags()&QNetworkInterface.IsRunning and not\
            (net.flags()&QNetworkInterface.IsLoopBack):
                macAddress = str(net.hardwareAddress())
                break
        return macAddress

    @pyqtSlot(str, str)
    def saveToken(self, token, userId):
        self._userInfo["token"] = token
        self._userInfo["userId"] = userId
        os.makedirs(self._appDataFolder, exist_ok=True)
        file = open(os.path.join(self._appDataFolder, "token"), "w")
        file.write(json.dumps(self._userInfo))
        file.close()

    @pyqtSlot(result=str)
    def loadToken(self):
        os.makedirs(self._appDataFolder, exist_ok=True)
        if not os.path.exists(self._tokenFile):
            return ""
        file = open(self._tokenFile, "r")
        self._userInfo = json.loads(file.readline())
        file.close()
        return self._userInfo["token"]

    @pyqtSlot(result=str)
    def getUserId(self):
        return self._userInfo["userId"]

    @pyqtSlot()
    def clearToken(self):
        os.remove(self._tokenFile)
        self._userInfo["token"] = ""
        self._userInfo["userId"] = ""

    @pyqtSlot(str)
    def qmlLog(self, text):
        Logger.log("d", "CrealityCloudUtils: %s", text)
        

