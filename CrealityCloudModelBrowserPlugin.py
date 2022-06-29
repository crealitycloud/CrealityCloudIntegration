# Uranium is released under the terms of the LGPLv3 or higher.
USE_QT5 = False
from UM.Logger import Logger
from UM.Extension import Extension
from UM.i18n import i18nCatalog
from . CrealityCloudUtils import CrealityCloudUtils
from typing import List, Any, Dict
try:
    from PyQt6.QtCore import QObject, pyqtSlot
except ImportError:
    from PyQt5.QtCore import QObject, pyqtSlot
    USE_QT5 = True
import json

i18n_catalog = i18nCatalog("uranium")

import os
from cura.CuraApplication import CuraApplication

from UM.Message import Message
from UM.Scene.Selection import Selection
import UM.Qt.QtApplication
from UM.FileHandler.WriteFileJob import WriteFileJob
from UM.Mesh.MeshWriter import MeshWriter
from UM.OutputDevice import OutputDeviceError
from UM.OutputDevice.OutputDevice import OutputDevice
from UM.Scene.Iterator.DepthFirstIterator import DepthFirstIterator

class CrealityCloudModelBrowserPlugin(QObject, Extension):
    def __init__(self):
        super().__init__()
        self.setMenuName(i18n_catalog.i18nc("@item:inmenu", "Creality Integration"))
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Model Library"), self._showModelLibrary)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "My Model"), self._showMyModelDlg)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "My Gcode"), self._showMyGcodeDlg)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Upload Model"), self._showUploadModelDlg)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Settings"), self._showSettingDlg)

        self._utils = CrealityCloudUtils.getInstance()
        self._modelBrowserDialog = None
        self._category = [1, 2, 3]#model lib, my model, my gocde
        self._pageSize = 28
        self._listType = [2, 7]#model lib, my upload model
        self._modelUploadDlg = None
        self._settingDlg = None
        self._loginDlg = None
        self._qml_folder = "qml" if not USE_QT5 else "qml_qt5"
        self._myModelCursor = ''
        CuraApplication.getInstance().applicationShuttingDown.connect(self._clearTmpfiles)
        self._utils.loginSuccess.connect(self.loginRes)
    
    def _createModelDialog(self) -> None:
        if not self._modelBrowserDialog:
            plugin_dir_path = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))
            path = os.path.join(plugin_dir_path, self._qml_folder, "ModelLibraryMainPage.qml")
            self._modelBrowserDialog = CuraApplication.getInstance().createQmlComponent(path, {"ManageModelBrowser": self})
    
    def _showModelLibrary(self) -> None:
        self._createModelDialog()
        if self._modelBrowserDialog:
            self._modelBrowserDialog.setProperty("categoryCurIndex", self._category[0]-1)
            self._modelBrowserDialog.setProperty("selCategory", self._category[0])
            self._modelBrowserDialog.show()
            self._modelBrowserDialog.initUI()
            self.loadCategoryListResult()
        if self._loginDlg:
            self._loginDlg.setProperty("nextPage", 0)

    def _showMyModelDlg(self) -> None:       
        if self._utils.getLogin():
            self._createModelDialog()
            if self._modelBrowserDialog:
                self._modelBrowserDialog.setProperty("categoryCurIndex", self._category[1]-1)
                self._modelBrowserDialog.setProperty("selCategory", self._category[1])
                self._modelBrowserDialog.show()
                self._modelBrowserDialog.initUI()
                self.loadPageMyModelList("",False)          
        else:
            self._showLoginDlg(1)
            
    def _showMyGcodeDlg(self) -> None:       
        if self._utils.getLogin():
            self._createModelDialog()
            if self._modelBrowserDialog:
                self._modelBrowserDialog.setProperty("categoryCurIndex", self._category[2]-1)
                self._modelBrowserDialog.setProperty("selCategory", self._category[2])
                self._modelBrowserDialog.show()
                self._modelBrowserDialog.initUI()
                self.loadPageMyGcodeList(1, self._pageSize, False)
        else:
            self._showLoginDlg(2)

    def _showUploadModelDlg(self) -> None:
        nodelist = DepthFirstIterator(CuraApplication.getInstance().getController().getScene().getRoot())
        haveModel = False
        for node in nodelist:
            if node.callDecoration("isSliceable"):
                haveModel = True
                break
        if haveModel is not True:
            tipDlg = Message(i18n_catalog.i18nc("@info:status","Please import the model first!"), 
                title = i18n_catalog.i18nc("@Tip:title", "Tip"))
            tipDlg.show()
            return

        if not Selection.hasSelection():
            tipDlg = Message(i18n_catalog.i18nc("@info:status","Please select the model first!"), 
                title = i18n_catalog.i18nc("@Tip:title", "Tip"))
            tipDlg.show()
            return

        if self._utils.getLogin():
            if not self._modelUploadDlg:
                plugin_dir_path = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))
                path = os.path.join(plugin_dir_path, self._qml_folder, "UploadModelDlg.qml")
                self._modelUploadDlg = CuraApplication.getInstance().createQmlComponent(path, {"ManageUploadModel": self})
            if self._modelUploadDlg:
                self._modelUploadDlg.show()

                strjson = self._utils.getCategoryListResult(self._listType[1])
                if(strjson != ""):
                    response = json.loads(strjson)
                    if (response["code"] == 0):
                        self._modelUploadDlg.insertListModeData(strjson)
                    else:
                        Logger.log("e", response["msg"])
        else:
            self._showLoginDlg(3)

    def _showSettingDlg(self) -> None:
        if not self._settingDlg:
            plugin_dir_path = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))
            path = os.path.join(plugin_dir_path, self._qml_folder, "Setting.qml")
            self._settingDlg = CuraApplication.getInstance().createQmlComponent(path)
        if self._settingDlg:
            self._settingDlg.show()
    
    @pyqtSlot(result="QStringList")
    def getCategoryText(self) -> List[str]:
        categoryText = []
        categoryText.append(i18n_catalog.i18nc("@item:inmenu", "Model Library"))
        categoryText.append(i18n_catalog.i18nc("@item:inmenu", "My Model"))
        categoryText.append(i18n_catalog.i18nc("@item:inmenu", "My Gcode"))
        return categoryText

    def _showLoginDlg(self, type:int) -> None:
        if not self._loginDlg:
            self._loginDlg = self._utils.getLoginDlg()
        if self._loginDlg:
            self._loginDlg.setProperty("nextPage", type)
            self._loginDlg.show()

    def loginRes(self, type: int, userimg: str, username: str, userid: str) -> None:
        if type == 1:
            self._showMyModelDlg()           
            self._modelBrowserDialog.showuserInfo(userimg, username)
        elif type == 2:
            self._showMyGcodeDlg()
            self._modelBrowserDialog.showuserInfo(userimg, username)
        elif type == 3:
            self._showUploadModelDlg()

    @pyqtSlot(int)
    def loadCategoryListResult(self, type: int = 7) -> None:
        strjson = self._utils.getCategoryListResult(type)
        if(strjson != ""):
            response = json.loads(strjson)
            if (response["code"] == 0):
                self._modelBrowserDialog.setModelTypeComboData(strjson)
            else:
                self._modelBrowserDialog.showMessage(response["msg"])
    
    @pyqtSlot(int, int, bool)
    def loadPageModelLibraryList(self, cursor: str, id: int, additionFlag: bool) -> None:
        strjson = self._utils.getPageModelLibraryList(str(cursor), self._pageSize, str(id))        
        if(strjson == ""):
            return
        response = json.loads(strjson)
        if (response["code"] == 0):
            nextCursor = response["result"]["nextCursor"]
            self._modelBrowserDialog.setProperty("nextCursor", nextCursor)
            self._modelBrowserDialog.setModelLibraryList(strjson, additionFlag)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])    

    @pyqtSlot(str, int)
    def loadModelGroupDetailInfo(self, modelGroupId: str, count: int) -> None:
        strjson = self._utils.getModelGroupDetailInfo("", count, modelGroupId)
        if(strjson == ""):
            return
        response = json.loads(strjson)
        if (response["code"] == 0):
            self._modelBrowserDialog.setModelDetailInfo(strjson)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])
    
    @pyqtSlot("QStringList", "QStringList", int)
    def importModel(self, urls: List[str], filenames: List[str], category: int) -> None:
        if(len(urls) == 0):
            return
        dir = self._utils.getModelDir()
        if category == 2:
            dir = self._utils.getMymodelDir()
        elif category == 3:
            dir = self._utils.getMygcodeDir()

        count = len(filenames)

        for index in range(count):
            tmpfilename = filenames[index]
            # Handling special characters
            tmpfilename = tmpfilename.replace('\\','-').replace('/','-').replace(':','-').replace('*','-').replace('?','-').replace('\"','-').replace('<','-').replace('>','-').replace('|','-')
            filepath = os.path.join(dir, tmpfilename)
            filenames[index] = filepath
        self._utils.downloadModel(self._modelBrowserDialog.property("selCategory"), urls, filenames)
    
    @pyqtSlot(str, int, int)
    def importModelGroup(self, modelGroupId: str, count: int, category: int) -> None:       
        strjson = self._utils.getModelGroupDetailInfo("", count, modelGroupId)
        if(strjson == ""):
            return
        response = json.loads(strjson)
        modelUrls = []
        modelNames = []
        try:
            if (response["code"] == 0):           
                for index in range(count):
                    url,msg = self._utils.modelUrl(response["result"]["list"][index]["id"])#url = response["result"]["list"][index]["downloadUrl"]
                    if(url == ""):
                        if(msg != ""):
                            self._modelBrowserDialog.showMessage(msg)
                        continue
                    name = response["result"]["list"][index]["fileName"]+".stl"                   
                    modelUrls.append(url)
                    modelNames.append(name)
            if modelUrls and modelNames:
                self.importModel(modelUrls, modelNames, category)
        except Exception as e:
            Logger.log("e", e)

    def _clearTmpfiles(self) -> None:
        self._delfiles(self._utils.getModelDir())
        self._delfiles(self._utils.getMymodelDir())
        self._delfiles(self._utils.getMygcodeDir())
        self._delfiles(self._utils.getUploadfileDir())

    def _delfiles(self, dirpath: str) -> None:
        if not os.path.exists(dirpath):
            return
        filename = ""
        try:
            for root, dirs, files in os.walk(dirpath):
                for name in files:
                    filename = os.path.join(root, name)
                    os.remove(filename)
        except Exception as e:
            Logger.log("e", e)
    
    @pyqtSlot(str, int, int, bool)
    def loadModelSearchResult(self, keyword: str, page: int, pageSize: int, additionFlag: bool) -> None:
        strjson = self._utils.getModelSearchResult(page, pageSize, keyword)
        if(strjson == ""):
            return
        response = json.loads(strjson)
        if (response["code"] == 0):
            totalCount = 0
            totalCount = int(response["result"]["count"])
            if page == 1:
                totalPage = 0
                totalPage = int(totalCount / pageSize)
                if totalCount % pageSize != 0:
                    totalPage += 1
                self._modelBrowserDialog.setProperty("sourceType", 2)
                self._modelBrowserDialog.setProperty("currentModelLibraryPage", page)
                self._modelBrowserDialog.setProperty("totalPage", totalPage)
                self._modelBrowserDialog.showSearchPage()#
                self._modelBrowserDialog.showNofoundTip(False)
            
            if totalCount != 0:
                self._modelBrowserDialog.setModelLibraryList(strjson, additionFlag)
            else:
                # self._modelBrowserDialog.deleteCompent("modelGroupMap")
                self._modelBrowserDialog.showNofoundTip(True)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])

    @pyqtSlot(int, bool)
    def loadPageMyModelList(self, cursor: str, additionFlag: bool) -> None:
        #  chenbiwei 2022.06.25
        #  qml传入的字符串被转换成整型了，服务器返回的cursor到这里值就不对了，改为python端保存
        
        if(additionFlag == False):
            self._myModelCursor = ''
        strjson = self._utils.getListUploadModel(self._myModelCursor, self._pageSize)
        if(strjson == ""):
            return
        response = json.loads(strjson)
        if (response["code"] == 0):          
            nextCursor = response["result"]["nextCursor"]
            self._modelBrowserDialog.setProperty("nextCursor", nextCursor)
            self._myModelCursor = nextCursor
            self._modelBrowserDialog.setModelLibraryList(strjson, additionFlag)
        else:
            self._modelBrowserDialog.showMessage("mymodel:"+response["msg"])
        
        
    @pyqtSlot(str)
    def deleteModelGroup(self, modelGid: str) -> None:
        strjson = self._utils.getModelGDeleteRes(modelGid)
        if(strjson == ""):
            return
        response = json.loads(strjson)
        if (response["code"] == 0):
            self._modelBrowserDialog.flushMyMLibAfterDelGroup(modelGid)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])

    @pyqtSlot(int, int, bool)
    def loadPageMyGcodeList(self, page: int, pageSize: int, additionFlag: bool) -> None:
        strjson = self._utils.getGcodeListRes(page, pageSize)
        if(strjson == ""):
            return
        response = json.loads(strjson)
        if (response["code"] == 0):
            totalCount = 0
            totalCount = int(response["result"]["count"])
            if page == 1:
                totalPage = 0
                totalPage = int(totalCount / pageSize)
                if totalCount % pageSize != 0:
                    totalPage += 1
                self._modelBrowserDialog.setProperty("curMyGcodePage", page)
                self._modelBrowserDialog.setProperty("totalPageMyGcode", totalPage)

            self._modelBrowserDialog.setMyGcodeList(strjson, additionFlag)
        else:
            self._modelBrowserDialog.showMessage("mygcode:"+response["msg"])

    @pyqtSlot(str)
    def deleteGcode(self, gcodeId: str) -> None:
        strjson = self._utils.getGcodeDelRes(gcodeId)
        if(strjson == ""):
            return
        response = json.loads(strjson)
        if (response["code"] == 0):
            self._modelBrowserDialog.flushMyGcodeList(gcodeId)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])

    @pyqtSlot()
    def uploadModel(self) -> None:
        self._saveSTL()
        self._modelUploadDlg.setProperty("progressValue", 10)
    
    def _saveSTL(self) -> None:
        output_device_manager = CuraApplication.getInstance().getOutputDeviceManager()
        device = STLOutputDevice(self._modelUploadDlg.property("saveWay"))
        self._utils.saveStlEnd.connect(self._uploadServer)
        if device.getId() not in output_device_manager.getOutputDeviceIds():
            output_device_manager.addOutputDevice(device)
      
        file_handler = UM.Qt.QtApplication.QtApplication.getInstance().getMeshFileHandler()
        preferred_mimetypes = None
        CuraApplication.getInstance().callLater(device.requestWrite, Selection.getAllSelectedObjects(), "", False, file_handler, preferred_mimetypes = preferred_mimetypes)
        
    def _uploadServer(self, filenames: list) -> None:
        self._modelUploadDlg.setProperty("progressValue", 40)
        CuraApplication.getInstance().getOutputDeviceManager().removeOutputDevice("crealityTmpStlFile")
        self._utils.saveStlEnd.disconnect(self._uploadServer)
        self._utils.createModelsStarted.connect(self._modelGroupCreate)
        self._utils.getOssAuth(2)#used only once 

        for filename in filenames:
            if os.path.exists(filename):
                self._utils.uploadOss(2, filename)

    def _modelGroupCreate(self) -> None:
        self._modelUploadDlg.setProperty("progressValue", 70)
        self._utils.createModelsStarted.disconnect(self._modelGroupCreate)

        strjson = self._utils.getModelGroupCreateRes(self._modelUploadDlg.property("categoryId"),
            self._modelUploadDlg.property("groupName"),
            self._modelUploadDlg.property("groupDesc"),
            self._modelUploadDlg.property("bShare"),           
            self._modelUploadDlg.property("license"),
            self._modelUploadDlg.property("bIsOriginal"))
        if(strjson == ""):
            return
        response = json.loads(strjson)
        self._modelUploadDlg.setProperty("progressValue", 100)
        if (response["code"] == 0):
            self._modelUploadDlg.uploadModelSuccess()
        else:
            self._modelUploadDlg.uploadModelFail(response["msg"])

    @pyqtSlot("QStringList")
    def addModels(self, strlist: List[str]) -> None:
        self._utils.addModelsStarted.connect(self._modelGroupAdd)
        self._utils.getOssAuth(2)#used only once
        for filename in strlist:
            if os.path.exists(filename):
                self._utils.uploadOss(3, filename)
    
    def _modelGroupAdd(self) -> None:
        self._utils.addModelsStarted.disconnect(self._modelGroupAdd)
        strjson = self._utils.getModelGroupAddRes(self._modelBrowserDialog.property("curSelModelGroupID"))
        response = json.loads(strjson)
        self._modelBrowserDialog.hideBusy()
        if (response["code"] == 0):
            self._modelBrowserDialog.showMessage(i18n_catalog.i18nc("@title:Label", "Uploaded Successfully!"))
            self._modelBrowserDialog.flushMyModelAfterAdd()
        else:
            self._modelBrowserDialog.showMessage(i18n_catalog.i18nc("@title:Label", "Upload failed!") + ' ' +response["msg"])


class STLOutputDevice(OutputDevice):
    def __init__(self, saveWay: int):
        super().__init__("crealityTmpStlFile")
        self._writing = False
        self._saveWay = saveWay
        self._selCounts = 0
        self._outputCounts = 0
        self._filelist = []

    def requestWrite(self, nodes, file_name = None, limit_mimetypes = None, file_handler = None, **kwargs):
        if self._writing:
            raise OutputDeviceError.DeviceBusyError()

        file_types = file_handler.getSupportedFileTypesWrite()
        file_types.sort(key = lambda k: k["description"])
        if limit_mimetypes:
            file_types = list(filter(lambda i: i["mime_type"] in limit_mimetypes, file_types))

        file_types = [ft for ft in file_types if not ft["hide_in_file_dialog"]]

        if len(file_types) == 0:
            Logger.log("e", "There are no file types available to write with!")
            raise OutputDeviceError.WriteRequestFailedError(i18n_catalog.i18nc("@info:warning", "There are no file types available to write with!"))

        
        self.writeStarted.emit(self)
        if file_handler:
            file_writer = file_handler.getWriter('STLWriter')
        else:
            file_writer = CuraApplication.getInstance().getMeshFileHandler().getWriter('STLWriter')
        try:
            dir = CrealityCloudUtils.getInstance().getUploadfileDir()
            if not os.path.exists(dir):
                os.makedirs(dir, exist_ok=True)
            filename = ''
            if self._saveWay == 1:
                self._selCounts = len(nodes)
                for node in nodes:                   
                    filename = os.path.join(dir, node.getName())
                    Logger.log("d", "Writing to temp stl File %s in binary mode", filename)
                    stream = open(filename, "wb")
                    myNodes = []
                    myNodes.append(node)
                    job = WriteFileJob(file_writer, stream, myNodes, MeshWriter.OutputMode.BinaryMode)
                    job.setFileName(filename)
                    job.setAddToRecentFiles(False)
                    job.progress.connect(self._onJobProgress)
                    job.finished.connect(self._onWriteJobFinished)
                    self._writing = True
                    job.start()
            elif self._saveWay == 2:
                self._selCounts = 1               
                filename = os.path.join(dir, nodes[0].getName())
                Logger.log("d", "Writing to temp stl File %s in binary mode", filename)
                stream = open(filename, "wb")
                job = WriteFileJob(file_writer, stream, nodes, MeshWriter.OutputMode.BinaryMode)
                job.setFileName(filename)
                job.setAddToRecentFiles(False)
                job.progress.connect(self._onJobProgress)
                job.finished.connect(self._onWriteJobFinished)
                self._writing = True
                job.start()

        except PermissionError as e:
            Logger.log("e", "Permission denied when trying to write to %s: %s", file_name, str(e))
            raise OutputDeviceError.PermissionDeniedError(i18n_catalog.i18nc("@info:status Don't translate the XML tags <filename>!", "Permission denied when trying to save <filename>{0}</filename>").format(file_name)) from e
        except OSError as e:
            Logger.log("e", "Operating system would not let us write to %s: %s", file_name, str(e))
            raise OutputDeviceError.WriteRequestFailedError(i18n_catalog.i18nc("@info:status Don't translate the XML tags <filename> or <message>!", "Could not save to <filename>{0}</filename>: <message>{1}</message>").format(file_name, str(e))) from e

    def _onJobProgress(self, job, progress):
        self.writeProgress.emit(self, progress)

    def _onWriteJobFinished(self, job):
        self._writing = False
        self.writeFinished.emit(self)
        if job.getResult():
            self.writeSuccess.emit(self)
            self._filelist.append(job.getFileName())
            self._outputCounts += 1
            if self._outputCounts == self._selCounts:               
                CrealityCloudUtils.getInstance().saveStlEnd.emit(self._filelist)
        else:
            self.writeError.emit(self)

        try:
            job.getStream().close()
        except (OSError, PermissionError):
            self.writeError.emit(self)
