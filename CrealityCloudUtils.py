from typing import Dict, List

from requests.models import Response
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
from PyQt5.QtCore import (QSysInfo, pyqtSignal, pyqtSlot, pyqtProperty, QObject, QUrl)
from PyQt5.QtNetwork import (QNetworkAccessManager)

from UM.Job import Job
from UM.OutputDevice import OutputDeviceError
catalog = i18nCatalog("uranium")
from cura.CuraApplication import CuraApplication
from UM.Resources import Resources
from PyQt5.QtWidgets import QApplication

class CrealityCloudUtils(QObject):

    __instance = None

    @classmethod
    def getInstance(cls, *args, **kwargs) -> "CrealityCloudUtils":
        if cls.__instance is None:
            cls.__instance = cls(*args, **kwargs)
        return cls.__instance
    
    def __init__(self, parent=None):
        if self.__instance is not None:
            raise RuntimeError("This is a Singleton. use getInstance()")
        
        super(CrealityCloudUtils, self).__init__(parent)

        # Modify this parameter to configure the server. test, release_local, release_oversea
        self._env = "test"
        self._testEnv = "http://2-model-admin-dev.crealitygroup.com"
        self._localEnv = "https://model-admin.crealitygroup.com"
        self._overseaEnv = "https://model-admin2.creality.com"
        self._cloudUrl = ""
        self._filePath = ""# path of saved gcode file
        self._gzipFilePath = ""
        self._osVersion = QSysInfo.productType() + " " + QSysInfo.productVersion()
        self._qnam = QNetworkAccessManager()
        self._qnam.finished.connect
        self._duid = self._generateDUID()
        self._userInfo = {"token": "", "userId": "", "userImg":"", "userName":""} # type: Dict[str, str]
        self._bucketInfo = {"endpoint": "", "bucket": "", "prefixPath": "", "accessKeyId": "",
                            "secretAccessKey": "", "sessionToken": "", "lifeTime": "",
                            "expiredTime": ""}  # type: Dict[str, str]
        self._ossKey = ""
        self._appDataFolder = Resources.getStoragePath(Resources.Resources, "CrealityCloud")
        self._tokenFile = os.path.join(self._appDataFolder, "token")
        self._urlFile = os.path.join(self._appDataFolder, "cloudurl")
        self._defaultFileName = ""
        self._fileName = ""# gcode file name "No suffix"

        self._isLogin = False
        self._loginDlg = None
        self._modelsDir = os.path.join(self._appDataFolder, "models")
        self._mymodelDir = os.path.join(self._appDataFolder, "mymodels")
        self._mygcodesDir = os.path.join(self._appDataFolder, "mygcodes")
        self._uploadfilesDir = os.path.join(self._appDataFolder, "uploadfiles")

        self._downloadType = 0 # 1 and 2: stl, 3: gcode
        self._isDownloading = False
        self._downfileCount = 0
        self._importfileCount = 0
        self._uploadFileList = []
        self._uploadFileCounts = 0
        self._filekeyList = []

        self.autoSetUrl()

    saveGCodeStarted = pyqtSignal(str)
    updateProgressText = pyqtSignal(str)
    updateProgress = pyqtSignal(float)
    updateStatus = pyqtSignal(str)

    downloadingStateChanged = pyqtSignal()

    saveStlEnd = pyqtSignal(list)
    createModelsStarted = pyqtSignal()
    addModelsStarted = pyqtSignal()

    loginSuccess = pyqtSignal(int, str, str, str)

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

    def getModelDir(self) -> str:
        os.makedirs(self._modelsDir, exist_ok=True)
        return self._modelsDir
    
    def getMymodelDir(self) -> str:
        os.makedirs(self._mymodelDir, exist_ok=True)
        return self._mymodelDir

    def getMygcodeDir(self) -> str:
        os.makedirs(self._mygcodesDir, exist_ok=True)
        return self._mygcodesDir

    def getUploadfileDir(self) -> str:
        os.makedirs(self._uploadfilesDir, exist_ok=True)
        return self._uploadfilesDir

    @pyqtSlot(str, str, str, str)
    def saveToken(self, token: str, userId: str, userImg: str, userName: str) -> None:
        self._userInfo["token"] = token
        self._userInfo["userId"] = userId
        self._userInfo["userImg"] = userImg
        self._userInfo["userName"] = userName
        os.makedirs(self._appDataFolder, exist_ok=True)
        file = open(os.path.join(self._appDataFolder, "token"), "w")
        file.write(json.dumps(self._userInfo))
        file.close()

    @pyqtSlot(str)
    def saveUrl(self, env: str) -> None:
        #os.remove(self._urlFile)
        os.makedirs(self._appDataFolder, exist_ok=True)
        file = open(os.path.join(self._appDataFolder, "cloudurl"), "w")
        file.write(env)
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

    def loadUrl(self) -> str:
        os.makedirs(self._appDataFolder, exist_ok=True)
        if not os.path.exists(self._urlFile):
            return ""
        file = open(self._urlFile, "r")
        env = file.readline()
        file.close()
        return env

    @pyqtSlot(bool)
    def setLogin(self, flag=bool) -> None:
        self._isLogin = flag

    @pyqtSlot(result=bool)
    def getLogin(self) -> bool:
        return self._isLogin

    @pyqtSlot(result=QObject)
    def getLoginDlg(self) -> QObject:
        if not self._loginDlg:
            plugin_dir_path = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))
            path = os.path.join(plugin_dir_path, "qml/Login.qml")
            self._loginDlg = CuraApplication.getInstance().createQmlComponent(path)

        return self._loginDlg

    @pyqtSlot(result=str)
    def getUserId(self) -> str:
        return self._userInfo["userId"]

    @pyqtSlot(result=str)
    def getUserImg(self) -> str:
        return self._userInfo["userImg"]
    
    @pyqtSlot(result=str)
    def getUserName(self) -> str:
        return self._userInfo["userName"]

    @pyqtSlot()
    def clearToken(self) -> None:
        os.remove(self._tokenFile)
        self._userInfo["token"] = ""
        self._userInfo["userId"] = ""
        self._userInfo["userImg"] = ""
        self._userInfo["userName"] = ""

    @pyqtSlot(str)
    def qmlLog(self, text: str) -> None:
        Logger.log("d", "CrealityCloudUtils: %s", text)
        

    @pyqtSlot(str)
    def saveUploadFile(self, fileName: str) -> None:
        self._fileName = fileName + ".gcode"
        self._filePath = os.path.join(self.getUploadfileDir(), self._fileName)
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
        self.uploadOss(1, '')

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
            "__CXY_OS_LANG_": self.getLangCode(),
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
    
    def setOssKey(self, key: str) -> None:
        self._ossKey = key
    
    def uploadOss(self, type: int, filename: str) -> None:
        obj_file = ''
        if type == 1:
            self.updatedProgressTextSlot(catalog.i18nc("@info:status", "3/4 Uploading file..."))
            self.getOssAuth()
            obj_file = self._gzipFilePath
            self._ossKey = self._bucketInfo["prefixPath"] + "/" + \
                self.getFileMd5(obj_file) + ".gcode.gz"          
        elif type == 2 or type == 3:
            obj_file = filename           
            self.setOssKey(self.getFileKey(self.getFileMd5(obj_file), 0))
            self._uploadFileList.append(obj_file)
            self._filekeyList.append(self._ossKey)
        Logger.log("d", self._ossKey)

        try:
            job = UploadFileJob(self._bucketInfo, self._ossKey, obj_file)
            job.setType(type)
            if type == 1:
                job.progress.connect(self._onUploadFileJobProgress)
            job.finished.connect(self._onUploadFileJobFinished)
            job.start()
        except Exception as e:
            Logger.log(
                "e", "oss upload faild")
            if type == 1:
                self.updateStatus.emit("bad")

    def _onUploadFileJobFinished(self, job: Job) -> None:
        if job.getType() == 1:
            self.commitFile()
        elif job.getType() == 2:            
            self._uploadFileCounts += 1
            if self._uploadFileCounts ==  len(self._uploadFileList):
                self.createModelsStarted.emit()
                self._uploadFileCounts = 0
        elif job.getType() == 3:
            self._uploadFileCounts += 1
            if self._uploadFileCounts ==  len(self._uploadFileList):
                self.addModelsStarted.emit()
                self._uploadFileCounts = 0

    def _onUploadFileJobProgress(self, job: Job, progress: float) -> None:
        self.updateProgress.emit(progress)

    def updatedProgressTextSlot(self, message: str) -> None:
        Logger.log("i", "%s" % message)
        self.updateProgressText.emit(message)

    def getReponseTime(self, url: str) -> int:
        try:
            r = requests.get(url)
            returnTime = r.elapsed.total_seconds()
        except:
            returnTime = 10000
        return returnTime

    @pyqtSlot()
    def autoSetUrl(self) -> None:
        env = self.loadUrl()
        if env:
            self._env = env
        else:
            localTime = self.getReponseTime(self._localEnv)
            overseaTime = self.getReponseTime(self._overseaEnv)
            if localTime < overseaTime: 
                self._env = "release_local"
            else:
                self._env = "release_oversea"
            self.saveUrl(self._env)

        if self._env == "test":
            self._cloudUrl = self._testEnv
            self._webUrl = "http://model-dev.crealitygroup.com"
        elif self._env == "release_local":
            self._cloudUrl = self._localEnv
            self._webUrl = "https://www.crealitycloud.cn"
        else:
            self._cloudUrl = self._overseaEnv
            self._webUrl = "https://www.crealitycloud.com"
    
    def getLangCode(self) -> str:
        code = CuraApplication.getInstance().getPreferences().getValue("general/language")
        if code == "en_US":
            return "0"
        elif code == "cs_CZ":
            return "0"
        elif code == "de_DE":
            return "8"
        elif code == "es_ES":
            return "7"
        elif code == "fi_FI":
            return "0"
        elif code == "fr_FR":
            return "9"
        elif code == "it_IT":
            return "0"
        elif code == "ja_JP":
            return "10"
        elif code == "ko_KR":
            return "5"
        elif code == "th_TH":
            return "12"
        elif code == "nl_NL":
            return "0"
        elif code == "pl_PL":
            return "0"
        elif code == "pt_BR":
            return "11"
        elif code == "pt_PT":
            return "11"
        elif code == "ru_RU":
            return "4"
        elif code == "tr_TR":
            return "0"
        elif code == "zh_CN":
            return "1"
        elif code == "zh_TW":
            return "2"
        else:
            return "0"

    def getModelHeaders(self) -> Dict[str, str]:
        headers = {
            "Content-Type": "application/json; charset=UTF-8",
            "__CXY_APP_ID_": "creality_model",
            "__CXY_OS_LANG_": self.getLangCode(),
            "__CXY_DUID_": self._duid,
            "__CXY_OS_VER_": self._osVersion,
            "__CXY_PLATFORM_": "6",
            "__CXY_REQUESTID_": str(uuid.uuid1())
        }
        return headers
    
    def getCategoryListResult(self, type: int) -> str:
        url = self._cloudUrl + "/api/cxy/category/categoryList"
        response = requests.post(url, data=json.dumps({"type": type}), headers=self.getModelHeaders()).text
        return response
    
    def getModelGroupDetailInfo(self, page: int, pageSize: int, groupId: str) -> str:
        url = self._cloudUrl + "/api/cxy/v2/model/modelList"
        response = requests.post(url, 
                    data=json.dumps({"page": page, "pageSize": pageSize, "groupId": groupId}), 
                    headers=self.getModelHeaders()).text
        return response

    def downloadModel(self, downType: int, urls: List[str], filepaths: List[str]) -> bool:
        self._downloadType = downType
        self._isDownloading = True
        self.downloadingStateChanged.emit()
        job = DownloadJob(urls, filepaths)
        job.finished.connect(self._DownloadModelJobFinished)
        job.start()
    
    def _DownloadModelJobFinished(self, job: Job) -> None:
        
        filenames = job.getFileNames()
        CuraApplication.getInstance().fileCompleted.connect(self._showImportFileFinished)
        self._downfileCount = 0
        self._importfileCount = 0
        for downloadedFile in filenames:
            if os.path.exists(downloadedFile):
                self._downfileCount += 1

                if(self._downloadType == 3):#gcode
                    try:
                        extractedFile = os.path.splitext(downloadedFile)[0] + '.gcode'
                        job = ExtractFileJob(downloadedFile, extractedFile)
                        job.finished.connect(self._onExtractFileJobFinished)
                        job.start()
                    except Exception as e:
                        Logger.log("e", "file extract failed")                        
                else:#stl
                    CuraApplication.getInstance().readLocalFile(QUrl().fromLocalFile(downloadedFile), "open_as_model")
    
    def _onExtractFileJobFinished(self, job: Job) -> None:
        file = job.getFileName()
        CuraApplication.getInstance().readLocalFile(QUrl().fromLocalFile(file))
    
    def _showImportFileFinished(self, filename: str) -> None:
        self._importfileCount += 1
        if self._importfileCount == self._downfileCount:
            CuraApplication.getInstance().fileCompleted.disconnect(self._showImportFileFinished)
            self._isDownloading = False
            self.downloadingStateChanged.emit()

    @pyqtProperty(bool, notify=downloadingStateChanged)
    def getDownloadState(self) -> bool:
        return self._isDownloading

    def getModelSearchResult(self, page: int, pageSize: int, keyword: str) -> str:
        url = self._cloudUrl + "/api/cxy/search/modelSearch"
        response = requests.post(url, 
                    data=json.dumps({"page": page, "pageSize": pageSize, "keyword": keyword}), 
                    headers=self.getModelHeaders()).text
        return response

    def getPageModelLibraryList(self, page: int, pageSize: int, listType: int, categoryId: int) -> str:
        url = self._cloudUrl + "/api/cxy/model/modelGroupList"
        response = ""
        if listType == 2:
            response = requests.post(url, 
                        data=json.dumps({"page": page, "pageSize": pageSize, "listType": listType, "categoryId": categoryId}), 
                        headers=self.getModelHeaders()).text
        elif listType == 7:
            response = requests.post(url, 
                        data=json.dumps({"page": page, "pageSize": pageSize, "listType": listType}), 
                        headers=self.getCommonHeaders()).text
        return response

    def getModelGDeleteRes(self, modelGid: str) -> str:
        url = self._cloudUrl + "/api/cxy/model/modelGroupDelete"
        response = requests.post(url, 
                    data=json.dumps({"id": modelGid}), 
                    headers=self.getCommonHeaders()).text
        return response

    def getGcodeListRes(self, page: int, pageSize: int) -> str:
        url = self._cloudUrl + "/api/cxy/v2/gcode/ownerList"
        response = requests.post(url, 
                    data=json.dumps({"page": page, "pageSize": pageSize, "isUpload": True}),
                    headers=self.getCommonHeaders()).text
        return response
    
    def getGcodeDelRes(self, id: str) -> str:
        url = self._cloudUrl + "/api/cxy/v2/gcode/deleteGcode"
        response = requests.post(url, 
                    data=json.dumps({"id": id}),
                    headers=self.getCommonHeaders()).text
        return response

    def getFileKey(self, md5: str, fileType: int) -> str:
        url = self._cloudUrl + "/api/cxy/common/filePreUpload"
        response = requests.post(url, 
                    data=json.dumps({"md5s": md5, "fileType": fileType}),
                    headers=self.getCommonHeaders()).text
        response = json.loads(response)
        if (response["code"] == 0):
            return response["result"]["list"][0]["fileKey"]
        else:
            raise Exception("get filekey error: "+json.dumps(response))

    @pyqtSlot(str, result=int)
    def getFileSize(self, file: str) -> int: #The unit is B
        size = os.path.getsize(file)       
        return size

    @pyqtSlot(str, result=str)
    def getFileName(self, filepath: str) -> str: #"No suffix"
        name = os.path.basename(filepath)
        return os.path.splitext(name)[0]

    def getModelGroupCreateRes(self, categoryId:int, groupName:str, groupDesc:str, bShare:bool, modelType:int, license:str, bIsOriginal:bool) -> str:
        url = self._cloudUrl + "/api/cxy/model/modelGroupCreate"      
        modelList = []
        length = len(self._filekeyList)
        for i in range(length):
            itemDict = {
                "fileKey":self._filekeyList[i], "fileName":self.getFileName(self._uploadFileList[i]), "fileSize":os.path.getsize(self._uploadFileList[i])
            }
            modelList.append(itemDict)

        contentDict = {
            "groupItem":{"categoryId":categoryId, "groupName":groupName, "groupDesc":groupDesc, "share":bShare, "type":modelType, "license":license, "isOriginal":bIsOriginal},
            "modelList": modelList
        }

        response = requests.post(url, data=json.dumps(contentDict), headers=self.getCommonHeaders()).text
        self._filekeyList.clear()
        for tmpfile in self._uploadFileList:
            os.remove(tmpfile)
        self._uploadFileList.clear()
        return response

    def getModelGroupAddRes(self, groupId: str) -> str:
        url = self._cloudUrl + "/api/cxy/model/modelGroupEdit"
        modelList = []
        length = len(self._filekeyList)
        for i in range(length):
            itemDict = {
                "fileKey":self._filekeyList[i], "fileName":self.getFileName(self._uploadFileList[i]), "fileSize":os.path.getsize(self._uploadFileList[i])
            }
            modelList.append(itemDict)

        contentDict = {
            "hasGroup": False,
            "groupItem": {"id": groupId},
            "hasModel": True,
            "modelList": modelList,
            "isClearCovers": False
        }
        response = requests.post(url, data=json.dumps(contentDict), headers=self.getCommonHeaders()).text

        self._filekeyList.clear()
        self._uploadFileList.clear()
        return response

    @pyqtSlot(str)
    def addToClipboard(self, content: str) -> None:
        cb = QApplication.clipboard()   
        cb.setText(content)

class DownloadJob(Job):
    def __init__(self, urls: List[str], filepaths: List[str]):
        super().__init__()
        self._message = None
        self._urls = urls
        self._filepaths = filepaths
        self.progress.connect(self._onProgress)
        self.finished.connect(self._onFinished)

    def getFileNames(self) -> List[str]:
        return self._filepaths

    def _onFinished(self, job: Job) -> None:
        if self == job and self._message is not None:
            self._message.hide()
            self._message = None
                
    def _onProgress(self, job: Job, amount: float) -> None:
        if self == job and self._message:
            self._message.setProgress(amount)
    
    def run(self) -> None:
        Job.yieldThread()
        try:
            count = len(self._urls)
            for index in range(count):
                r = requests.get(self._urls[index])
                with open(self._filepaths[index], "wb") as f:
                    f.write(r.content)
        except Exception as e:
            Logger.log("e", e)


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
        self._type = 1
        self.progress.connect(self._onProgress)
        self.finished.connect(self._onFinished)

    def setType(self, type: int) -> None:
        self._type = type

    def getType(self) -> int:
        return self._type

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

        headers = dict()
        filename = os.path.basename(self._uploadFilePath)
        filename = filename.encode('utf-8').decode('unicode_escape')
        headers['Content-Disposition'] = 'attachment;filename=' + filename
        headers['mime'] = 'application/x-www-form-urlencoded'

        totalSize = os.path.getsize(self._uploadFilePath)
        partSize = determine_part_size(totalSize, preferred_size=100 * 1024)
        uploadId = bucket.init_multipart_upload(self._ossKey, headers=headers).upload_id
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
        bucket.complete_multipart_upload(self._ossKey, uploadId, parts, headers=headers)

        # Check integrity
        # with open(self._uploadFilePath, 'rb') as fileobj:
        #     assert bucket.get_object(self._ossKey).read() == fileobj.read()


class ExtractFileJob(Job):
    def __init__(self, inputFilePath: str, outputFilePath: str):
        super().__init__()
        self._inputFilePath = inputFilePath
        self._outputFilePath = outputFilePath
        self._message = None
        self.progress.connect(self._onProgress)
        self.finished.connect(self._onFinished)

    def getFileName(self) -> str:
        return self._outputFilePath

    def _onFinished(self, job: Job) -> None:
        if self == job and self._message is not None:
            self._message.hide()
            self._message = None

    def _onProgress(self, job: Job, amount: float) -> None:
        if self == job and self._message:
            self._message.setProgress(amount)

    def run(self) -> None:
        Job.yieldThread()
        with gzip.GzipFile(self._inputFilePath, 'rb') as inF:
            with open(self._outputFilePath, 'wb') as outF:
                s = inF.read()
                outF.write(s)
