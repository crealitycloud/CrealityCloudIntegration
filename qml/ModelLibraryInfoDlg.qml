import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1

import UM 1.1 as UM

Window{
    property var buttonMap: {0:0}
    property var modelGroupMap: {0:0}
    property var imageMap: {0:0}
    property var modelMap: {0:0}

    property var currentModelLibraryPage: 1
    property var totalPage: 0
    property var pageSize: 28//the count of per page
    property var currentBtnType: 0
    property var isDetailPage: false
    property var modelCurrentGroupId: 0
    property var modelCurrentGroupCount: 0

    property int curSelImgNumber: 1

    property string searchText: ""
    property int sourceType: 1
    property alias backMainpageBtnVis: idBackMainPage.visible
    property alias searchLabelVis: idSearchLabel.visible
    property alias modelScrollvPos: idVScroll.position

    UM.I18nCatalog { id: catalog; name: "uranium"}

    id: idModelLibraryDlg
    width: 1192
    height: 706
    minimumWidth: 720
    minimumHeight: 650
    title: catalog.i18nc("@window:title", "Model Library")

    function setModelTypeListBtn(strjson)
    {
        var componentButton = Qt.createComponent("BasicButton.qml")
        if (componentButton.status === Component.Ready )
        {           
            deleteCompent("buttonMap")
            var objectArray = JSON.parse(strjson);
            var objResult = objectArray.result.list;
            
            for( var key in objResult)
            {
                var obj = componentButton.createObject(idModelTypeListBtn, 
                                                            {"btnRadius": 8,
                                                            "width": 180,
															"height" : 30,
                                                            "keyStr": objResult[key].id,
															"text": catalog.i18nc("@action:Button", objResult[key].name)})
                obj.sigButtonClickedWithKey.connect(onClassTypeButtonClicked)
                buttonMap[objResult[key].id] = obj
            }
            //---initialize the mainPage
            if(sourceType == 2){
                idSearch.text = "" 
                showNofoundTip(false)
            }
            if(isDetailPage){
                isDetailPage = false;
                idModelLibraryDetail.visible = false
                idModelLibraryContent.visible = true

                idModelTypeListBtn.enabled = true;
                idSearch.enabled = true;
            }
            //---

            sourceType = 1
            backMainpageBtnVis = false;
            searchLabelVis = false;
            ManageModelBrowser.loadPageModelLibraryList(1, objResult[0].id, false)
            currentBtnType = objResult[0].id
            buttonMap[objResult[0].id].defaultBtnBgColor = "#1E9BE2"
            totalPage = ManageModelBrowser.getTotalPage(objResult[0].id, pageSize)

            currentModelLibraryPage = 1;
            isDetailPage = false
            console.log("current page: %1".arg(currentModelLibraryPage))
        }
        else{
            console.log("create BasicButton fail!")
        }
    }

    function setModelLibraryList(strjson, appendFlag)
    {
        var componentButton = Qt.createComponent("CusModelLibraryItem.qml")
        if (componentButton.status === Component.Ready )
        {
            if(!appendFlag)//not append
                deleteCompent("modelGroupMap")
            
            var objectArray = JSON.parse(strjson);
            if(objectArray.code === 0)
            {
                var objResult = objectArray.result.list;
                for( var key in objResult){
                    var obj = componentButton.createObject(idModelLibraryList, {"btnNameText": catalog.i18nc("@action:Label", objResult[key].groupName), 
                                                                        "btnModelImage": objResult[key].coversUrl[0], 
                                                                        "modelGroupId": objResult[key].id,
                                                                        "btnAuthorText": catalog.i18nc("@action:Label", objResult[key].userInfo.nickName), 
                                                                        "btnAvtarImage": objResult[key].userInfo.avatar,
                                                                        "modelCount": objResult[key].modelCount})
                    obj.sigButtonDownClicked.connect(onSigButtonDownClicked) 
                    obj.sigButtonClicked.connect(onSigButtonClicked)
                    modelGroupMap[objResult[key].id] = obj
                }
            }           
        }
        else{
            console.log("create CusModelLibraryItem fail!")
        }
    }

      
    function setModelDetailInfo(strjson)
    {
        var componentButton = Qt.createComponent("BasicImageButton.qml")
        var componentModelItem = Qt.createComponent("CusModelItem.qml")
        if (componentButton.status === Component.Ready )
        {
            
            deleteCompent("imageMap")
            deleteCompent("modelMap")
            
            var objectArray = JSON.parse(strjson);
            if(objectArray.code === 0)
            {
                var objResult = objectArray.result.list;
                for( var key in objResult){
                    var imageNumber = Number(key) +1
                    var obj = componentButton.createObject(idModelDetailListImage, {
                                                                        "width": 30,
                                                                        "height": 30,
                                                                        "keystr": imageNumber,
                                                                        "modelid": objResult[key].id,
                                                                        "btnImgUrl": objResult[key].coverUrl})  
                    obj.sigBtnClicked.connect(onSigBtnClicked)
                    imageMap[imageNumber] = obj

                    var obj1 = componentModelItem.createObject(idModelListItem, {"modelname": catalog.i18nc("@action:Button", objResult[key].fileName), 
                                                                        "modeSize": objResult[key].fileSize,
                                                                        "modelid": objResult[key].id,
                                                                        "keystr": imageNumber,
                                                                        "modellink": objResult[key].downloadUrl})
                    obj1.sigBtnDetailClicked.connect(onSigBtnDetailItemClicked)
                    obj1.sigDownModel.connect(onDownloadModel)
                    modelMap[objResult[key].id] = obj1
                }
                curSelImgNumber = 1;
                idDetailImage.source = imageMap[curSelImgNumber].btnImgUrl
                imageMap[curSelImgNumber].btnSelect = true
                modelMap[imageMap[curSelImgNumber].modelid].btnIsSelected = true               
            }                        
        }
        else{
            console.log("create BasicImageButton fail!")
        }
    }

    function onSigBtnClicked(key)//image list
    {
        if(curSelImgNumber != key){
            imageMap[curSelImgNumber].btnSelect = false
            modelMap[imageMap[curSelImgNumber].modelid].btnIsSelected = false

            curSelImgNumber = key
            idDetailImage.source = imageMap[key].btnImgUrl
            imageMap[key].btnSelect = true
            modelMap[imageMap[key].modelid].btnIsSelected = true
        }        
    }

    function onSigBtnDetailItemClicked(keyValue)//model item list
    {
        var number = modelMap[keyValue].keystr;
        
        if(curSelImgNumber != number){
            imageMap[curSelImgNumber].btnSelect = false
            modelMap[imageMap[curSelImgNumber].modelid].btnIsSelected = false

            curSelImgNumber = number;
            idDetailImage.source = imageMap[curSelImgNumber].btnImgUrl
            imageMap[curSelImgNumber].btnSelect = true
            modelMap[keyValue].btnIsSelected = true
        }
    }

    function onSigButtonClicked(id, name, count, author, avtar)//view details
    {
        isDetailPage = true;
        idModelLibraryContent.visible = false
        idModelLibraryDetail.visible = true
        idModelNameLabel.text =  name;//
        idModelCountLabel.text = count;//
        idAvtarImage.img_src = avtar
        idAuthorName.text = author//
        modelCurrentGroupId = id
        modelCurrentGroupCount = count
        ManageModelBrowser.loadModelGroupDetailInfo(id, count);

        idModelTypeListBtn.enabled = false;
        idSearch.enabled = false;
    }

    function onSigButtonDownClicked(modelid, count)//mainPage：download model group
    {
        ManageModelBrowser.importModelGroup(modelid, count);
    }

    function downloadModels()//detailPage：download model group
    {
        var urlList = []; var fileList = []
        var url = ""; var filename = ""       
        for(var key in modelMap)
        {
            url = modelMap[key].modellink
            filename = modelMap[key].modelname
            urlList.push(url);
            fileList.push("%1.stl".arg(filename));
        }
        ManageModelBrowser.importModel(urlList, fileList)
    }

    function onDownloadModel(name, url)//detailPage：download a single model
    {
        var urlList = []; var fileList = []
        urlList.push(url);
        fileList.push("%1.stl".arg(name));
        ManageModelBrowser.importModel(urlList, fileList)
    }

    function onClassTypeButtonClicked(keystr)
    {
        for(var key in buttonMap)
		{
			if(key != 0)
			{
				if(key == keystr)
                {
                    buttonMap[key].defaultBtnBgColor = "#1E9BE2"
                   
                    if(currentBtnType != keystr){                        
                        currentBtnType = keystr
                    }
                    else{}

                    currentModelLibraryPage = 1;
                    modelScrollvPos = 0;
                    ManageModelBrowser.loadPageModelLibraryList(1, key, false)                   
                    totalPage = ManageModelBrowser.getTotalPage(key, pageSize)               
                    console.log("current page: %1".arg(currentModelLibraryPage))                    
                }
                else{
                    buttonMap[key].defaultBtnBgColor = "#F5F5F5"
                }
			}	
		}
    }

    function refreshModelLibraryList()
    {
        if (currentModelLibraryPage+1 <= totalPage)
        {
            currentModelLibraryPage++;
            console.log("current page--%1".arg(currentModelLibraryPage))
            if(sourceType == 1)
                ManageModelBrowser.loadPageModelLibraryList(currentModelLibraryPage, currentBtnType, true)
            else if(sourceType == 2)
                if(searchText != "")
                    ManageModelBrowser.loadModelSearchResult(searchText, currentModelLibraryPage, pageSize, true)
        }
    }

    function deleteCompent(compentMap)
    {
        var tMap = {}
        if(compentMap === "buttonMap")
        {
            tMap = buttonMap;
        }
        else if(compentMap === "modelGroupMap")
        {
            tMap = modelGroupMap;
        }
        else if(compentMap === "imageMap")
        {
            tMap = imageMap;
        }
        else if(compentMap === "modelMap")
        {
            tMap = modelMap;
        }

        for(var key in tMap)
		{
			var strkey = "-%1-".arg(key)
			if(strkey != "-0-")
			{
				tMap[key].destroy()
				delete tMap[key]
			}
            else{
                delete tMap[key]
            }
		}
    }

    function showMessage(text) {
        msgDialog.text = text;
        msgDialog.visible = true
    }

    function showNofoundTip(isShow)
    {
        idSearchResultTip.visible = isShow;
    }

    MessageDialog{
        id: msgDialog
        title: catalog.i18nc("@Tip:title", "Tip")
        icon: StandardIcon.Warning
        modality: Qt.ApplicationModal
        visible: false
        onAccepted: {
            msgDialog.visible = false
        }
    }
    AnimatedImage {
        id: idLoadingImg
        //anchors.centerIn: parent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top;
        anchors.topMargin: 12;
        visible: {
            if(CloudUtils.getDownloadState){
                idMainPage.enabled = false;//idModelLibraryDlg
                return true;
            }
            else{
                idMainPage.enabled = true;
                return false;
            } 
        }
        source: "../res/loading.gif"
    }

    MouseArea {
        anchors.fill: parent
        focus: true
        onClicked: {
            focus = true
        }
    }
    
    onClosing:{
        //console.log("before window close")
        if(idLoadingImg.visible)
            close.accepted = false
        else
            close.accepted = true
    }

    Column{
        id: idMainPage
        anchors.fill: parent
        anchors.topMargin: 20
        anchors.bottomMargin: 30
        anchors.leftMargin: 20
        anchors.rightMargin: 38
        width: idModelLibraryDlg.width
        height: idModelLibraryDlg.height
        spacing:5
        Row
        {
            spacing:10
            BasicSkinButton{
                id: idBackMainPage
                visible: false;
                width: 20; height: 22
                imgW:width; imgH:height;
                tipText: catalog.i18nc("@Tip:Button", "Return to the home page")
                btnImgUrl: "../res/btn_back.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked:
                {
                    if(isDetailPage){
                        idModelLibraryDetail.visible = false
                        idModelLibraryContent.visible = true
                        idModelTypeListBtn.enabled = true;
                        idSearch.enabled = true;
                    }

                    ManageModelBrowser.loadCategoryListResult(2)
                    idSearch.text = "" 
                    showNofoundTip(false)
                }
            }
            TextField
            {
                id : idSearch
                height: 32
                width: 280
                selectByMouse: true
                text: ""
                font.family: "Source Han Sans CN Normal"
                font.weight: Font.Normal
                font.pixelSize: 12
                color: "black"
                padding: 8
                leftPadding: padding + 8 + headImage.width
                rightPadding: padding + 8
                Image {
                    id: headImage                   
                    x: idSearch.padding; y: idSearch.topPadding
                    height:sourceSize.height
                    width: sourceSize.width
                    source: "../res/seach.png"
                }
                placeholderText: catalog.i18nc("@info:label", "search")
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    radius: 10
                    opacity: enabled ? 1 : 0.3
                    color:  idSearch.focus ? "white" : "#F5F5F5"
                    border.width: 1
                    border.color: idSearch.focus ? "#1E9BE2" : "#DDDFE0"
                }
                Keys.onPressed:{
                    if(event.key === Qt.Key_Return)
                    {                       
                        idSearch.focus = false;
                        if(idSearch.text != ""){
                            searchText = idSearch.text;
                            ManageModelBrowser.loadModelSearchResult(searchText, 1, pageSize, false);//deal with things in python
                        }
                    }
                }
            }
        }
        Item {
            id: idSeparator
            width:parent.width
            height: 2
            Rectangle
            {
                anchors.fill: parent
                //color: "#262626"
            }
        }
        Row{
            height: idMainPage.height-idSearch.height-idSeparator.height-5*2
            spacing: 10
            ScrollView
            {
                id: idSrollViewBtn
                width: 185
                height: parent.height
                clip : true
                Column
                {
                    id: idModelTypeListBtn
                    width: idSrollViewBtn.width-5
                    spacing: 10
                    Label{
                        id: idSearchLabel
                        width: 130; height: 30
                        visible: false
                        text: catalog.i18nc("@info:label", "search results")
                        font.family: "Source Han Sans CN Normal"
                        font.weight: Font.Medium
                        font.pixelSize: 14
                        color: "#333333"
                        verticalAlignment: Text.AlignVCenter
                        clip :true
                        elide: Text.ElideRight
                    }
                }
            }
            Item {
                id: idSeparator2
                width:2
                height: parent.height
                Rectangle
                {
                    anchors.fill: parent
                    color: "#262626"
                }
            }
            Column{
                id: idModelLibraryContent
                width: idMainPage.width - idSrollViewBtn.width - idSeparator2.width - 10*2
                height: parent.height
                Label{
                    id: idSearchResultTip
                    width: 200
                    height: 50
                    visible: false;
                    font.family: "Source Han Sans CN Normal"
                    font.weight: Font.Normal
                    font.pixelSize: 15
                    color: "black"
                    clip :true                        
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: catalog.i18nc("@info:label", "No results found!")
                }
                ScrollView {
                    id: idModelLibraryScrollView
                    clip : true
                    width: idModelLibraryContent.width
                    height: idModelLibraryContent.height                  
                    property var vSize: idVScroll.size
                    property var vPosition: idVScroll.position
                    property var refreshFlag: false
                    ScrollBar.vertical: ScrollBar {
                        id: idVScroll
                        parent: idModelLibraryScrollView
                        x: idModelLibraryScrollView.mirrored ? 0 : idModelLibraryScrollView.width - width
                        y: idModelLibraryScrollView.topPadding
                        width: 10
                        height: idModelLibraryScrollView.availableHeight
                        policy: ScrollBar.AsNeeded
                        hoverEnabled: true
                    }
                    Flow{
                        id: idModelLibraryList
                        spacing: 5
                        width: idModelLibraryContent.width
                        height: idModelLibraryContent.height
                        //columns: 4
                    }
                    onVPositionChanged:{
                        if((vSize + vPosition) === 1){
                            if(refreshFlag){                                
                                refreshModelLibraryList();
                            }
                            refreshFlag = true;
                        }
                    }
                }                
            }

            Column{
                id: idModelLibraryDetail
                visible: false
                Row{
                    BasicSkinButton{
                        width: 20; height: 22
                        imgW:width; imgH:height;
                        tipText: catalog.i18nc("@Tip:Button", "Return")
                        btnImgUrl: "../res/btn_back.png"
                        anchors.verticalCenter: parent.verticalCenter
                        onClicked:
                        {
                            isDetailPage = false;
                            idModelLibraryDetail.visible = false
                            idModelLibraryContent.visible = true

                            idModelTypeListBtn.enabled = true;
                            idSearch.enabled = true;
                        }
                    }
                }
                Row{
                    spacing:10
                    Column{
                        spacing: 5
                        Image{
                            id: idDetailImage
                            width: idModelLibraryContent.width/2
                            height: idModelLibraryContent.width/2
                            asynchronous: true
                            mipmap: true
                            smooth: true
                            cache: false
                            fillMode: Image.PreserveAspectFit
                            source: ""
                        }
                        ScrollView{
                            width: (idModelLibraryContent.width-10)/2
                            height: 50
                            ScrollBar.horizontal.policy: ScrollBar.AlwaysOn
                            clip : true
                            Row
                            {
                                id: idModelDetailListImage
                                spacing: 5
                            }
                        }
                    }                    
                    Column{
                        spacing: 5
                        Label{
                            id: idModelNameLabel
                            width: (idModelLibraryContent.width-10)/2
                            height: 30
                            text: ""
                            font.family: "Source Han Sans CN Normal"
                            font.weight: Font.Medium
                            font.pixelSize: 18
                            color: "#333333"
                        }
                        Label{
                            id: idModelCountLabel
                            width: (idModelLibraryContent.width-10)/2
                            height: 30
                            text: ""
                        }
                        Row{
                            spacing: 5
                            BasicCircularImage{
                                id: idAvtarImage
                                width: 60
                                height: 60
                                img_src: ""
                            }
                            Label{
                                id: idAuthorName
                                width: (idModelLibraryContent.width-10)/2 - idAvtarImage.width - idImportAllBtn.width- 10
                                height: 30
                                text: ""
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                                clip :true
                                wrapMode: TextEdit.WordWrap
                                elide: Text.ElideRight
                                font.family: "Source Han Sans CN Normal"
                                font.weight: Font.Normal
                                font.pixelSize: 18
                                color: "#333333"
                            }
                            BasicSkinButton{
                                id: idImportAllBtn
                                width: 20; height: 22
                                imgW:width; imgH:height;
                                tipText: catalog.i18nc("@Tip:Button", "Import all")
                                btnImgNormal: "../res/btn_download.png"
                                btnImgHovered: "../res/btn_download_h.png"
                                btnImgPressed: "../res/btn_download_h.png"
                                onClicked:{
                                    downloadModels();
                                }
                            }
                        }
                        Label{
                            id: idModelListLabel
                            width: idModelLibraryContent.width/3
                            height: 60
                            text: catalog.i18nc("@info:label", "Model list:")
                            verticalAlignment: Text.AlignBottom
                            font.family: "Source Han Sans CN Normal"
                            font.weight: Font.Normal
                            font.pixelSize: 16
                            color: "#333333"
                        }
                        ScrollView{
                            width: (idModelLibraryContent.width-10)/2
                            height: idModelLibraryContent.height - 197
                            //ScrollBar.vertical.policy: ScrollBar.AlwaysOn
                            clip : true
                            Column{
                                id: idModelListItem
                            }
                        }
                    }
                }
            }
        }
    }
}