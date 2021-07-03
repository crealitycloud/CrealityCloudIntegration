from typing import Dict
from UM.Logger import Logger
from UM.i18n import i18nCatalog
import os, sys
import json
import hashlib
import gzip
import uuid
import requests
import importlib
#Import package into sys.modules so that the library can reference itself with absolute imports.
this_plugin_path = os.path.dirname(__file__)
def importExtLib(libName, dirName=""):
    if(dirName == ""):
        dirName = libName
    path = os.path.join(this_plugin_path, dirName, "__init__.py")
    spec = importlib.util.spec_from_file_location(libName, path)
    module = importlib.util.module_from_spec(spec)
    sys.modules[libName] = module
    spec.loader.exec_module(module)

importExtLib("jmespath")
importExtLib("crcmod")
if sys.platform.startswith('darwin'):
    importExtLib("Crypto", "Crypto-mac")
else:
    importExtLib("Crypto")
importExtLib("aliyunsdkcore")
importExtLib("aliyunsdkkms")
importExtLib("oss2")
from oss2 import SizedFileAdapter, determine_part_size, headers
from oss2.models import PartInfo
import oss2
from PyQt5.QtCore import (QSysInfo, pyqtSignal, pyqtSlot, QObject, QStandardPaths)
from PyQt5.QtNetwork import (QNetworkAccessManager)

from UM.Job import Job
from UM.OutputDevice import OutputDeviceError
catalog = i18nCatalog("uranium")


class CrealityCloudUtils(QObject):

    def __init__(self, parent=None):
        super(CrealityCloudUtils, self).__init__(parent)

        # Modify this parameter to configure the server. test, release_local, release_oversea
        self._env = "test"
        self._filePath = ""
        self._gzipFilePath = ""
        self._osVersion = QSysInfo.productType() + " " + QSysInfo.productVersion()
        self._qnam = QNetworkAccessManager()
        self._qnam.finished.connect
        self._duid = self._generateDUID()
        self._userInfo = {"token": "", "userId": ""} # type: Dict[str, str]
        self._bucketInfo = {"endpoint": "", "bucket": "", "prefixPath": "", "accessKeyId": "",
                            "secretAccessKey": "", "sessionToken": "", "lifeTime": "",
                            "expiredTime": ""}  # type: Dict[str, str]
        self._ossKey = ""
        self._appDataFolder = os.path.join(QStandardPaths.writableLocation(QStandardPaths.AppDataLocation), "CrealityCloud")
        self._tokenFile = os.path.join(self._appDataFolder, "token")
        self._defaultFileName = ""
        self._fileName = ""

        if (self._env == "test"):
            self._cloudUrl = "http://2-model-admin-dev.crealitygroup.com"
            self._webUrl = "http://model-dev.crealitygroup.com"
        elif(self._env == "release_local"):
            self._cloudUrl = "https://model-admin.crealitygroup.com"
            self._webUrl = "https://www.crealitycloud.cn"
        else:
            self._cloudUrl = "https://model-admin2.creality.com"
            self._webUrl = "https://www.crealitycloud.com"

    saveGCodeStarted = pyqtSignal(str)
    updateProgressText = pyqtSignal(str)
    updateProgress = pyqtSignal(float)
    updateStatus = pyqtSignal(str)

    @pyqtSlot(result=str)
    def getOsVersion(self) -> str:
        return self._osVersion

    @pyqtSlot(result=str)
    def getDUID(self) -> str:
        return self._duid

    @pyqtSlot(result=str)
    def getCloudUrl(self) -> str:
        return self._cloudUrl

    @pyqtSlot(result=str)
    def getWebUrl(self) -> str:
        return self._webUrl

    @pyqtSlot(result=str)
    def getEnv(self) -> str:
        return self._env

    def _generateDUID(self) -> str:
        # macAddress = ""
        # nets = QNetworkInterface.allInterfaces()
        # # Filter out the MAC address
        # for net in nets:
        #     if net.flags()&QNetworkInterface.IsUp and \
        #     net.flags()&QNetworkInterface.IsRunning and not\
        #     (net.flags()&QNetworkInterface.IsLoopBack):
        #         macAddress = str(net.hardwareAddress())
        #         break
        # return macAddress
        return str(uuid.uuid1())[-12:]


    @pyqtSlot(str, str)
    def saveToken(self, token: str, userId: str) -> None:
        self._userInfo["token"] = token
        self._userInfo["userId"] = userId
        os.makedirs(self._appDataFolder, exist_ok=True)
        file = open(os.path.join(self._appDataFolder, "token"), "w")
        file.write(json.dumps(self._userInfo))
        file.close()

    @pyqtSlot(result=str)
    def loadToken(self) -> str:
        os.makedirs(self._appDataFolder, exist_ok=True)
        if not os.path.exists(self._tokenFile):
            return ""
        file = open(self._tokenFile, "r")
        self._userInfo = json.loads(file.readline())
        file.close()
        return self._userInfo["token"]

    @pyqtSlot(result=str)
    def getUserId(self) -> str:
        return self._userInfo["userId"]

    @pyqtSlot()
    def clearToken(self) -> None:
        os.remove(self._tokenFile)
        self._userInfo["token"] = ""
        self._userInfo["userId"] = ""

    @pyqtSlot(str)
    def qmlLog(self, text: str) -> None:
        Logger.log("d", "CrealityCloudUtils: %s", text)
        

    @pyqtSlot(str)
    def saveUploadFile(self, fileName: str) -> None:
        self._fileName = fileName + ".gcode"
        self._filePath = os.path.join(self._appDataFolder, self._fileName)
        self.saveGCodeStarted.emit(self._filePath)

    @pyqtSlot(result=str)
    def defaultFileName(self) -> str:
        return self._defaultFileName

    @pyqtSlot(str)
    def setDefaultFileName(self, filename: str) -> None:
        self._defaultFileName = filename

    def clearUploadFile(self) -> None:
        os.remove(self._filePath)
        os.remove(self._gzipFilePath)

    # Compression gcode file
    def gzipFile(self) -> None:
        if os.path.isfile(self._filePath) is False:
            return
        self.updatedProgressTextSlot(catalog.i18nc("@info:status", "2/4 Compressing file..."))
        self._gzipFilePath = self._filePath + ".gz"
        try:
            job = CompressFileJob(self._filePath, self._gzipFilePath)
            job.progress.connect(self._onCompressFileJobProgress)
            job.finished.connect(self._onCompressFileJobFinished)
            job.start()
        except Exception as e:
            Logger.log(
                "e", "file compress faild")
            self.updateStatus.emit("bad")

    def _onCompressFileJobFinished(self, job: Job) -> None:
        self.uploadOss()

    def _onCompressFileJobProgress(self, job: Job, progress: float) -> None:
        self.updateProgress.emit(progress)

    # Calculate file MD5
    def getFileMd5(self, fileName: str) -> str:
        try:
            mObj = hashlib.md5()
            with open(fileName,'rb') as fObj:
                while True:
                    data = fObj.read(4096)
                    if not data:
                        break
                    mObj.update(data)
        except Exception as e:
            Logger.log(
                "e", "Failed to evaluate %s file MD5: %s", fileName, str(e))
            raise OutputDeviceError.WriteRequestFailedError(catalog.i18nc(
                "@info:status Don't translate the XML tags <filename> or <message>!", "Could not evaluate <filename>{0}</filename> MD5: <message>{1}</message>").format(fileName)) from e
        else:
            return mObj.hexdigest()

    def commitFile(self) -> None:
        self.updatedProgressTextSlot(catalog.i18nc("@info:status", "4/4 Committing file..."))
        self.updateProgress.emit(0)
        url = self._cloudUrl + "/api/cxy/v2/gcode/uploadGcode"
        response = requests.post(
            url, data=json.dumps({"list": [{"name": self._fileName, "filekey": self._ossKey}]}), 
            headers=self.getCommonHeaders()).text
        response = json.loads(response)
        if (response["code"] == 0):
            self.updateProgress.emit(1)
            Logger.log("d", "upload success")
            self.updateStatus.emit("good")
            self.clearUploadFile()
        else:
            self.updateStatus.emit("bad")
            Logger.log("e", "oss commit api: %s", json.dumps(response))

    def getCommonHeaders(self) -> Dict[str, str]:
        headers = {
            "Content-Type": "application/json; charset=UTF-8",
            "__CXY_APP_ID_": "creality_model",
            "__CXY_OS_LANG_": "0",
            "__CXY_DUID_": self._duid,
            "__CXY_OS_VER_": self._osVersion,
            "__CXY_PLATFORM_": "6",
            "__CXY_REQUESTID_": str(uuid.uuid1()),
            "__CXY_UID_": self._userInfo["userId"],
            "__CXY_TOKEN_": self._userInfo["token"]
        }
        return headers

    def getOssAuth(self) -> None:
        url = self._cloudUrl + "/api/cxy/common/getOssInfo"
        url2 = self._cloudUrl + "/api/account/getAliyunInfo"
        response = requests.post(url, data="{}", headers=self.getCommonHeaders()).text
        response = json.loads(response)
        if (response["code"] == 0):
            self._bucketInfo["endpoint"] = response["result"]["info"]["endpoint"]
            self._bucketInfo["bucket"] = response["result"]["info"]["file"]["bucket"]
            self._bucketInfo["prefixPath"] = response["result"]["info"]["file"]["prefixPath"]
        else:
            raise Exception("oss bucket api error: "+json.dumps(response))
        response = requests.post(
            url2, data="{}", headers=self.getCommonHeaders()).text
        response = json.loads(response)
        if (response["code"] == 0):
            self._bucketInfo["accessKeyId"] = response["result"]["aliyunInfo"]["accessKeyId"]
            self._bucketInfo["secretAccessKey"] = response["result"]["aliyunInfo"]["secretAccessKey"]
            self._bucketInfo["sessionToken"] = response["result"]["aliyunInfo"]["sessionToken"]
            self._bucketInfo["lifeTime"] = response["result"]["aliyunInfo"]["lifeTime"]
            self._bucketInfo["expiredTime"] = response["result"]["aliyunInfo"]["expiredTime"]
        else:
            raise Exception("oss auth api error: "+json.dumps(response))
        
    def uploadOss(self) -> None:
        self.updatedProgressTextSlot(catalog.i18nc("@info:status", "3/4 Uploading file..."))
        self.getOssAuth()
        self._ossKey = self._bucketInfo["prefixPath"] + "/" + \
            self.getFileMd5(self._gzipFilePath) + ".gcode.gz"
        Logger.log("d", self._ossKey)
        try:
            job = UploadFileJob(self._bucketInfo, self._ossKey, self._gzipFilePath)
            job.progress.connect(self._onCompressFileJobProgress)
            job.finished.connect(self._onUploadFileJobFinished)
            job.start()
        except Exception as e:
            Logger.log(
                "e", "oss upload faild")
            self.updateStatus.emit("bad")

    def _onUploadFileJobFinished(self, job: Job) -> None:
        self.commitFile()

    def _onUploadFileJobProgress(self, job: Job, progress: float) -> None:
        self.updateProgress.emit(progress)

    def updatedProgressTextSlot(self, message: str) -> None:
        Logger.log("i", "%s" % message)
        self.updateProgressText.emit(message)

      

class CompressFileJob(Job):

    def __init__(self, inputFilePath: str, outputFilePath: str):
        super().__init__()
        self._inputFilePath = inputFilePath
        self._outputFilePath = outputFilePath
        self._message = None
        self.progress.connect(self._onProgress)
        self.finished.connect(self._onFinished)

    def _onFinished(self, job: Job) -> None:
        if self == job and self._message is not None:
            self._message.hide()
            self._message = None

    def _onProgress(self, job: Job, amount: float) -> None:
        if self == job and self._message:
            self._message.setProgress(amount)

    def run(self) -> None:
        Job.yieldThread()
        with open(self._inputFilePath, 'rb') as f_in:
            with gzip.open(self._outputFilePath, 'wb') as f_out:
                # shutil.copyfileobj(f_in, f_out)
                copied = 0
                total = os.path.getsize(self._inputFilePath)
                while True:
                    buf = f_in.read(16*1024)
                    if not buf:
                        break
                    f_out.write(buf)
                    copied += len(buf)
                    self.progress.emit(Job, copied/total)


class UploadFileJob(Job):
    def __init__(self, bucketInfo: Dict[str, str], ossKey: str, uploadFilePath: str):
        super().__init__()
        self._bucketInfo = bucketInfo
        self._ossKey = ossKey
        self._uploadFilePath = uploadFilePath
        self._message = None
        self.progress.connect(self._onProgress)
        self.finished.connect(self._onFinished)

    def _onFinished(self, job: Job) -> None:
        if self == job and self._message is not None:
            self._message.hide()
            self._message = None

    def _onProgress(self, job: Job, amount: float) -> None:
        if self == job and self._message:
            self._message.setProgress(amount)

    def run(self) -> None:
        Job.yieldThread()
        auth = oss2.StsAuth(
            self._bucketInfo["accessKeyId"], self._bucketInfo["secretAccessKey"], self._bucketInfo["sessionToken"])

        bucket = oss2.Bucket(
            auth, self._bucketInfo["endpoint"], self._bucketInfo["bucket"])

        totalSize = os.path.getsize(self._uploadFilePath)
        partSize = determine_part_size(totalSize, preferred_size=100 * 1024)
        uploadId = bucket.init_multipart_upload(self._ossKey).upload_id
        parts = []
        with open(self._uploadFilePath, 'rb') as fileobj:
            part_number = 1
            offset = 0
            while offset < totalSize:
                num_to_upload = min(partSize, totalSize - offset)
                result = bucket.upload_part(self._ossKey, uploadId, part_number,
                                            SizedFileAdapter(fileobj, num_to_upload))
                parts.append(PartInfo(part_number, result.etag))

                offset += num_to_upload
                part_number += 1
                self.progress.emit(Job, offset/totalSize)
        bucket.complete_multipart_upload(self._ossKey, uploadId, parts)

        # Check integrity
        # with open(self._uploadFilePath, 'rb') as fileobj:
        #     assert bucket.get_object(self._ossKey).read() == fileobj.read()
