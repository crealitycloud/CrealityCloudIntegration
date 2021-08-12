# Uranium is released under the terms of the LGPLv3 or higher.

from UM.Logger import Logger
from UM.Extension import Extension
from UM.i18n import i18nCatalog
from . CrealityCloudUtils import CrealityCloudUtils
from typing import List
from PyQt5.QtCore import QObject, pyqtSlot
import json

i18n_catalog = i18nCatalog("uranium")

import os
from cura.CuraApplication import CuraApplication

class CrealityCloudModelBrowserPlugin(QObject, Extension):
    def __init__(self):
        super().__init__()
        self.setMenuName(i18n_catalog.i18nc("@item:inmenu", "Creality Integration"))
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Model Library"), self._showModelBrowser)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "My Model"), self._showModelBrowser)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "My Gcode"), self._showModelBrowser)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Upload Model"), None)
        self.addMenuItem(i18n_catalog.i18nc("@item:inmenu", "Settings"), self._showSettingDlg)

        self._utils = CrealityCloudUtils.getInstance()
        self._modelBrowserDialog = None
        self._pageSize = 28
        self._listType = 2
        self._settingDlg = None
        CuraApplication.getInstance().applicationShuttingDown.connect(self.clearTmpfiles)

    def _showModelBrowser(self) -> None:
        if not self._modelBrowserDialog:
            plugin_dir_path = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))
            path = os.path.join(plugin_dir_path, "qml/ModelLibraryInfoDlg.qml")
            self._modelBrowserDialog = CuraApplication.getInstance().createQmlComponent(path, {"ManageModelBrowser": self})

        if self._modelBrowserDialog:
            self._modelBrowserDialog.show()
            self.loadCategoryListResult()
    
    def _showSettingDlg(self) -> None:
        if not self._settingDlg:
            plugin_dir_path = os.path.abspath(os.path.expanduser(os.path.dirname(__file__)))
            path = os.path.join(plugin_dir_path, "qml/Setting.qml")
            self._settingDlg = CuraApplication.getInstance().createQmlComponent(path)
        if self._settingDlg:
            self._settingDlg.show()

    @pyqtSlot(int)
    def loadCategoryListResult(self, type: int = 2) -> None:
        strjson = self._utils.getCategoryListResult(type)
        response = json.loads(strjson)
        if (response["code"] == 0):
            self._modelBrowserDialog.setModelTypeListBtn(strjson)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])
    
    @pyqtSlot(int, int, bool)
    def loadPageModelLibraryList(self, page: int, id: int, additionFlag: bool) -> None:
        strjson = self._utils.getPageModelLibraryList(page, self._pageSize, self._listType, id)
        response = json.loads(strjson)
        if (response["code"] == 0):
            self._modelBrowserDialog.setModelLibraryList(strjson, additionFlag)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])

    @pyqtSlot(int, int, result=int)
    def getTotalPage(self, id: int, pageCount: int) -> int:
        """get count of total page
        :param pageCount: The count of components per page.
        """
        strjson = self._utils.getPageModelLibraryList(1, self._pageSize, self._listType, id)
        response = json.loads(strjson)
        totalPage = 0
        if (response["code"] == 0):
            totalCount = int(response["result"]["count"])
            totalPage = int(totalCount / pageCount)
            if totalCount % pageCount != 0:
                totalPage += 1

        return totalPage

    @pyqtSlot(str, int)
    def loadModelGroupDetailInfo(self, modelGroupId: str, count: int) -> None:
        strjson = self._utils.getModelGroupDetailInfo(1, count, modelGroupId)
        response = json.loads(strjson)
        if (response["code"] == 0):
            self._modelBrowserDialog.setModelDetailInfo(strjson)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])
    
    @pyqtSlot("QStringList", "QStringList")
    def importModel(self, urls: List[str], filenames: List[str]) -> None:
        dir = self._utils.modelFilePath
        if not os.path.exists(dir):
            os.makedirs(dir, exist_ok=True)
        count = len(filenames)

        for index in range(count):
            file = os.path.join(dir, filenames[index])
            filenames[index] = file
        self._utils.downloadModel(urls, filenames)
    
    @pyqtSlot(str, int)
    def importModelGroup(self, modelGroupId: str, count: int) -> None:
        strjson = self._utils.getModelGroupDetailInfo(1, count, modelGroupId)
        response = json.loads(strjson)
        modelUrls = []
        modelNames = []
        try:
            if (response["code"] == 0):           
                for index in range(count):
                    url = response["result"]["list"][index]["downloadUrl"]
                    name = response["result"]["list"][index]["fileName"]+".stl"
                    modelUrls.append(url)
                    modelNames.append(name)
            if modelUrls and modelNames:
                self.importModel(modelUrls, modelNames)
        except Exception as e:
            Logger.log("e", e)

    def clearTmpfiles(self) -> None:
        dir = self._utils.modelFilePath
        if not os.path.exists(dir):
            return
        filename = ""
        try:
            for root, dirs, files in os.walk(dir):
                for name in files:
                    filename = os.path.join(root, name)
                    os.remove(filename)
        except Exception as e:
            Logger.log("e", e)
    
    @pyqtSlot(str, int, int, bool)
    def loadModelSearchResult(self, keyword: str, page: int, pageSize: int, additionFlag: bool) -> None:
        strjson = self._utils.getModelSearchResult(page, pageSize, keyword)
        response = json.loads(strjson)
        if (response["code"] == 0):
            totalCount = 0
            totalCount = int(response["result"]["count"])
            if page == 1:
                self._modelBrowserDialog.deleteCompent("buttonMap")
                totalPage = 0
                totalPage = int(totalCount / pageSize)
                if totalCount % pageSize != 0:
                    totalPage += 1
                self._modelBrowserDialog.setProperty("sourceType", 2)
                self._modelBrowserDialog.setProperty("currentModelLibraryPage", page)
                print("current page:%d"%page)
                self._modelBrowserDialog.setProperty("totalPage", totalPage)
                self._modelBrowserDialog.setProperty("backMainpageBtnVis", True)
                self._modelBrowserDialog.setProperty("searchLabelVis", True)
                self._modelBrowserDialog.showNofoundTip(False)
            
            if totalCount != 0:
                self._modelBrowserDialog.setModelLibraryList(strjson, additionFlag)
            else:
                self._modelBrowserDialog.deleteCompent("modelGroupMap")
                self._modelBrowserDialog.showNofoundTip(True)
        else:
            self._modelBrowserDialog.showMessage(response["msg"])

