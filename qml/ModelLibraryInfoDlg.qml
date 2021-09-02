import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1

import UM 1.1 as UM

Window{
    property var selCategory: 1 //1 model library, 2 my model library, 3 my gcode
    property int sourceType: 1 // 1 model Library List ,2 search result,
    property alias categoryCurIndex: idSelCategory.currentIndex
    property string searchText: ""

    property var modelGroupMap: {0:0}
    property var imageMap: {0:0}
    property var modelMap: {0:0}

    property var curModelCategoryId: 0
    property var currentModelLibraryPage: 1
    property var totalPage: 0
    property var pageSize: [28, 18]//0 the count of per model page, 1 count of my gcode page.
    
    property var isDetailPage: false//true: model detail page, false: other page
    property var curSelModelGroupID: ""//details
    property int curSelImgNumber: 1 //details
    
    property alias modelScrollvPos: idVScroll.position
    property alias gcodeScrollvPos: idVScroll2.position

    property var curMyGcodePage: 1
    property var totalPageMyGcode: 0

    property var loginDlg: 0;
    property var userInfoDlg: 0;

    UM.I18nCatalog { id: catalog; name: "uranium"}

    function setModelTypeComboData(strjson)
    {         
        idModelTypeComboBox_model.clear();//先清空
        var objectArray = JSON.parse(strjson);
        var objResult = objectArray.result.list;        
        for( var key in objResult)
        {
            idModelTypeComboBox_model.append({modelCategoryId: objResult[key].id, 
                                        modelCategoryName: objResult[key].name})//添加数据
            //点击模型分类，刷新界面
        }
        idModelTypeComboBox.currentIndex = 0;
        curModelCategoryId = objResult[0].id;
        //---initialize the mainPage
        if(sourceType == 2){
            idSearch.text = "" 
            showNofoundTip(false)
        }
        if(isDetailPage){
            isDetailPage = false;
            idModelLibraryDetail.visible = false
            idModelLibraryContent.visible = true

            idSearch.enabled = true;
        }
        //---

        sourceType = 1

        if(selCategory == 1){
            ManageModelBrowser.loadPageModelLibraryList(1, curModelCategoryId, false)
            totalPage = ManageModelBrowser.getTotalPage(selCategory, curModelCategoryId, pageSize[0])
        }
        currentModelLibraryPage = 1;
        isDetailPage = false
        console.log("current page: %1".arg(currentModelLibraryPage))
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
                    if(selCategory == 2)
                        obj.btnDelVis = true;
                    obj.sigButtonDownClicked.connect(onSigButtonDownClicked) 
                    obj.sigButtonClicked.connect(onSigButtonClicked)
                    obj.sigBtnDelClicked.connect(slotBtnDelClicked)
                    modelGroupMap[objResult[key].id] = obj
                }
            }           
        }
        else{
            console.log("create CusModelLibraryItem fail!")
        }
    }
    function setMyGcodeList(strjson, appendFlag)
    {
        //idContentArea.visible = false;
        //idMyGcodeContent.visible = true;
        if(!appendFlag){
            gcode_model.clear();
        }
        var objectArray = JSON.parse(strjson);
        var objResult = objectArray.result.list;
        for( var key in objResult){
            gcode_model.append({gcodeID: objResult[key].id,
                                gcodeDownLink: objResult[key].downloadLink,
                                gcodeIcon: objResult[key].thumbnail,
                                gcodeFilename: objResult[key].name,
                                gcodeFileSize: objResult[key].size})
        }
    }

    function flushMyGcodeList(gcodeid)
    {
        var n = gcode_model.count; 
        //console.log("before gcode_model:",n)
        for(var i = 0; i < n; i++){
            if(gcodeid == gcode_model.get(i).gcodeID){
                gcode_model.remove(i);
                break;
            }           
        }
        //console.log("after gcode_model:", gcode_model.count)
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
                    var obj = componentButton.createObject(idModelLibraryDetail.modelDetailImgList, {
                                                                        "width": 30,
                                                                        "height": 30,
                                                                        "keystr": imageNumber,
                                                                        "modelid": objResult[key].id,
                                                                        "btnImgUrl": objResult[key].coverUrl})  
                    obj.sigBtnClicked.connect(onSigBtnClicked)
                    imageMap[imageNumber] = obj

                    var obj1 = componentModelItem.createObject(idModelLibraryDetail.modelDetailItemList, {"modelname": catalog.i18nc("@action:Button", objResult[key].fileName), 
                                                                        "modeSize": objResult[key].fileSize,
                                                                        "modelid": objResult[key].id,
                                                                        "keystr": imageNumber,
                                                                        "modellink": objResult[key].downloadUrl})
                    obj1.sigBtnDetailClicked.connect(onSigBtnDetailItemClicked)
                    obj1.sigDownModel.connect(onDownloadModel)
                    modelMap[objResult[key].id] = obj1
                }
                curSelImgNumber = 1;
                idModelLibraryDetail.idmodelImg.source = imageMap[curSelImgNumber].btnImgUrl
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
            idModelLibraryDetail.idmodelImg.source = imageMap[key].btnImgUrl
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
            idModelLibraryDetail.idmodelImg.source = imageMap[curSelImgNumber].btnImgUrl
            imageMap[curSelImgNumber].btnSelect = true
            modelMap[keyValue].btnIsSelected = true
        }
    }

    function onSigButtonClicked(id, name, count, author, avtar)//view details
    {
        idMyGcodeContent.visible = false;
        isDetailPage = true;
        idModelLibraryContent.visible = false;
        idModelLibraryDetail.visible = true;
        showNofoundTip(false);
        idTopInfoArea.visible = false;

        curSelModelGroupID = id
        idModelLibraryDetail.modelName =  name;//
        idModelLibraryDetail.modelCount = count;//
        idModelLibraryDetail.modelAImg = avtar//
        idModelLibraryDetail.modelAName = author//

        ManageModelBrowser.loadModelGroupDetailInfo(id, count);//
    }

    function onSigButtonDownClicked(modelGid, count)//mainPage：download model group /////
    {       
        ManageModelBrowser.importModelGroup(modelGid, count);
    }

    function slotBtnDelClicked(id)//1 mainPage and detail: delete my model group;  2 delete mygcode
    {
        deleteDialog.modelGOrGcodeid = id;
        deleteDialog.visible = true;
    }
    function flushMyModelLibrary(modelGid)
    {
        if(isDetailPage)
        {
            //console.log("after delete, flush detail")
            deleteCompent("imageMap");
            deleteCompent("modelMap");           
            //back
            curSelModelGroupID = "";
            isDetailPage = false;
            idModelLibraryDetail.visible = false
            idModelLibraryContent.visible = true

            idSearch.enabled = true
        }

        //console.log("after delete, flush model page")
        var strModelGid = "-%1-".arg(modelGid)

        for(var key in modelGroupMap){
            var strkey = "-%1-".arg(key)           		
            if(strkey == strModelGid){
                modelGroupMap[key].destroy()
                delete modelGroupMap[key]
                break;
            }			
        }
    }
    function downloadModels()//detailPage：download model group /////
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

    function onDownloadModel(name, url)//detailPage：download a single model /////
    {
        var urlList = []; var fileList = []
        urlList.push(url);
        fileList.push("%1.stl".arg(name));
        ManageModelBrowser.importModel(urlList, fileList)
    }

    function flushModelLLByScroll()//Scroll to refresh
    {
        if (currentModelLibraryPage+1 <= totalPage)
        {
            currentModelLibraryPage++;
            console.log("current page--%1".arg(currentModelLibraryPage))
            if(selCategory == 1){//model lib
                if(sourceType == 1)//model 
                    ManageModelBrowser.loadPageModelLibraryList(currentModelLibraryPage, curModelCategoryId, true)
                else if(sourceType == 2)//search result
                    if(searchText != "")
                        ManageModelBrowser.loadModelSearchResult(searchText, currentModelLibraryPage, pageSize[0], true)
            }
            else if(selCategory == 2){//my model
                ManageModelBrowser.loadPageMyModelList(currentModelLibraryPage, curModelCategoryId, true)
            }
        }
    }

    function flushMyGcodeByScroll()//scroll to refresh
    {
        if(curMyGcodePage+1 <= totalPageMyGcode)
        {
            curMyGcodePage++;
            console.log("current gocde page--%1".arg(curMyGcodePage))
            if(selCategory == 3)
            {
                ManageModelBrowser.loadPageMyGcodeList(curMyGcodePage, pageSize[1], true);
            }
        }
    }

    function deleteCompent(compentMap)
    {
        var tMap = {}

        if(compentMap === "modelGroupMap")
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
    function showLoginDlg()
    {
        if(loginDlg){
            loginDlg.show()
        }
        else{
            var componentLogin = Qt.createComponent("Login.qml")
            if (componentLogin.status === Component.Ready )
            {
                var obj = componentLogin.createObject(idModelLibraryDlg)
                loginDlg = obj;
                obj.nextPage = -1;
                obj.show();
                obj.sigLoginRes.connect(slotloginSuccess)
            }
        }
    }

    function slotloginSuccess(img, name, userid)
    {
        console.log("login success in Model Page.")
        idLoginBtn.visible = false;
        userImg.visible = true;
        userName.visible = true;
        userImg.img_src = img; 
        userName.text = name;
      
        switch (idSelCategory.currentIndex){
            case 0:
                initUI();
                ManageModelBrowser.loadCategoryListResult(2)
                break;
            case 1:
                initUI();
                ManageModelBrowser.loadPageMyModelList(1,false)
                break;
            case 2:
                initUI();
                ManageModelBrowser.loadPageMyGcodeList(1, pageSize[1], false)
                break;
        }

    }
    function logout()
    {
        idLoginBtn.visible = true;
        userImg.visible = false;
        userName.visible = false;
        userImg.img_src = "";
        userName.text = "";
        CloudUtils.clearToken()
        CloudUtils.setLogin(false);
        idSelCategory.currentIndex = 0;
        selCategory = 1;
        initUI();
        ManageModelBrowser.loadCategoryListResult(2)
    }

    function showuserInfo(img, name)
    {
        userImg.img_src = img;
        userName.text = name;
    }
    function initUI()
    {
        /*idBackMainPage.visible = true;
        idSelCategory.visible = true;
        idModelTypeComboBox.visible = true;
        idSearch.visible = true;
        idSearch.text = "";
        idSearchLabel.visible = true;
        idLoginBtn.visible = true;
        userImg.visible = true;
        userName.visible = true;*/
        if(selCategory == 1)
        {
            idMyGcodeContent.visible = false;
            sourceType = 1;
            isDetailPage = false;
            idModelLibraryContent.visible = true
            idModelLibraryDetail.visible = false;
            showNofoundTip(false);
            idBackMainPage.visible = false;
            idSelCategory.visible = true;
            idModelTypeComboBox.visible = true;
            idSearch.visible = true;
            idSearch.text = "";
            idSearchLabel.visible = false;
            var isLogin = CloudUtils.getLogin();
            idLoginBtn.visible = !isLogin;//没有登录显示
            userImg.visible = isLogin;//登录显示
            userName.visible = isLogin;//登录显示
            
            
        }
        else if(selCategory == 2)
        {
            idMyGcodeContent.visible = false;
            isDetailPage = false;
            idModelLibraryContent.visible = true
            idModelLibraryDetail.visible = false;
            showNofoundTip(false);
            idBackMainPage.visible = false;
            idSelCategory.visible = true;
            idModelTypeComboBox.visible = false;
            idSearch.visible = false;
            idSearch.text = "";
            idSearchLabel.visible = false;
            var isLogin = CloudUtils.getLogin();
            idLoginBtn.visible = !isLogin;//没有登录显示
            userImg.visible = isLogin;//登录显示
            userName.visible = isLogin;//登录显示
        }
        else if(selCategory == 3)
        {
            idMyGcodeContent.visible = true;
            idModelLibraryContent.visible = false;
            idModelLibraryDetail.visible = false;
            showNofoundTip(false);
            idBackMainPage.visible = false;
            idSelCategory.visible = true;
            idModelTypeComboBox.visible = false;
            idSearch.visible = false;
            idSearch.text = "";
            idSearchLabel.visible = false;
            var isLogin = CloudUtils.getLogin();
            idLoginBtn.visible = !isLogin;//没有登录显示
            userImg.visible = isLogin;//登录显示
            userName.visible = isLogin;//登录显示
        }
    }
    function showSearchPage()
    {
        idBackMainPage.visible = false;
        idSelCategory.visible = false;
        idModelTypeComboBox.visible = false;
        idSearch.visible = false;
        idSearchLabel.visible = false;
        var isLogin = CloudUtils.getLogin();
        idLoginBtn.visible = !isLogin;//没有登录显示
        userImg.visible = isLogin;//登录显示
        userName.visible = isLogin;//登录显示

        idBackMainPage.visible = true
        idSearch.visible = true
        idSearchLabel.visible = true
    }
 
//--------------------------------------main page----------------------------------------------
    id: idModelLibraryDlg
    width: 1042
    height: 711
    minimumWidth: 1042
    minimumHeight: 711
    //maximumWidth: 1920
    //maximumHeight: 1080
    title: catalog.i18nc("@window:title", "Model Library")
    MouseArea {
        anchors.fill: parent
        focus: true
        onClicked: {
            focus = true
        }
    }

    Item{
        id: idMainPage
        anchors.fill: parent
        anchors.leftMargin: 41
        anchors.rightMargin: 41
        Row
        {
            id: idTopInfoArea           
            height: 68
            spacing: 20
            BasicSkinButton{//从搜索页返回（返回模型库）
                id: idBackMainPage
                visible: false;
                width: 20; height: 22
                imgW:width; imgH:height;
                tipText: catalog.i18nc("@Tip:Button", "Return to the home page")
                btnImgUrl: "../res/btn_back.png"
                anchors.verticalCenter: parent.verticalCenter
                onClicked:{
                    ManageModelBrowser.loadCategoryListResult(2)
                    idSearch.text = "" 
                    showNofoundTip(false)

                    idBackMainPage.visible = false;
                    idSelCategory.visible = true;
                    idModelTypeComboBox.visible = true;
                    idSearch.visible = true;
                    idSearchLabel.visible = false;
                    var isLogin = CloudUtils.getLogin();
                    idLoginBtn.visible = !isLogin;//没有登录显示
                    userImg.visible = isLogin;//登录显示
                    userName.visible = isLogin;//登录显示
                }
            }
            ComboBox {
                id: idSelCategory
                width:200; height: 28
                anchors.verticalCenter: parent.verticalCenter
                model: ListModel{
                    id: idCategory_model
                    ListElement{name: "模型库"}
                    ListElement{name: "我的模型"}
                    ListElement{name: "我的切片"}
                }
                currentIndex : -1
                onActivated: {
                    if(selCategory != currentIndex+1){
                        console.log("Switch classification")
                        if(CloudUtils.getLogin()){
                            selCategory = currentIndex+1;
                            switch (currentIndex){ 
                                case 0:
                                    initUI();
                                    ManageModelBrowser.loadCategoryListResult(2)
                                    break;
                                case 1:
                                    initUI();
                                    ManageModelBrowser.loadPageMyModelList(1,false)
                                    break;
                                case 2:
                                    initUI();
                                    ManageModelBrowser.loadPageMyGcodeList(1, pageSize[1], false)
                                    break;
                            }
                        }
                        else{   
                            selCategory = idSelCategory.currentIndex+1;
                            if(selCategory === 1)
                                return
                            showLoginDlg()
                        }
                    }                             
                }
            }
            ComboBox {
                id: idModelTypeComboBox
                width:200; height: 28
                anchors.verticalCenter: parent.verticalCenter
                model: ListModel{
                    id: idModelTypeComboBox_model                   
                }
                textRole: "modelCategoryName"
                currentIndex : -1
                popup: Popup {
                    y: idModelTypeComboBox.height - 1
                    background: Rectangle {
                        border.width: 1
                        border.color: "#BDBDBD"
                    }
                    width: idModelTypeComboBox.width
                    implicitHeight: 310
                    contentItem: ListView {
                        clip: true
                        implicitHeight: contentHeight
                        model: idModelTypeComboBox.popup.visible ? idModelTypeComboBox.delegateModel : null
                        currentIndex: idModelTypeComboBox.highlightedIndex
                        ScrollBar.vertical: ScrollBar { }
                    }
                }
                onActivated: {
                    if(curModelCategoryId != idModelTypeComboBox_model.get(currentIndex).modelCategoryId)
                    {
                        curModelCategoryId = idModelTypeComboBox_model.get(currentIndex).modelCategoryId;
                        //再刷新界面
                        currentModelLibraryPage = 1;
                        modelScrollvPos = 0;
                        ManageModelBrowser.loadPageModelLibraryList(1, curModelCategoryId, false)
                        totalPage = ManageModelBrowser.getTotalPage(selCategory, curModelCategoryId, pageSize[0])
                        console.log("current page: %1".arg(currentModelLibraryPage))
                    }
                }
            }
            TextField
            {
                id : idSearch
                height: 28
                width: 260
                selectByMouse: true
                text: ""
                font.family: "Source Han Sans CN Normal"
                font.weight: Font.Normal
                font.pixelSize: 12
                color: "black"
                anchors.verticalCenter: parent.verticalCenter
                padding: 5
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
                            ManageModelBrowser.loadModelSearchResult(searchText, 1, pageSize[0], false);//deal with things in python
                        }
                    }
                }
            }
            Label{
                id: idSearchLabel
                width: 130; height: 28
                anchors.verticalCenter: parent.verticalCenter
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
            BasicButton{
                id: idLoginBtn
                width: 125; height: 28
                visible: {
                    if(CloudUtils.getLogin())
                        return false;
                    else
                        return true;
                }
                text: "登录"
                btnTextColor: "white"
                defaultBtnBgColor : "#B4B4B4"
                anchors.verticalCenter: parent.verticalCenter
                pixSize: 14
                fontWeight: Font.Bold
                btnRadius: 3
                btnBorderW: 0
                onSigButtonClicked: {
                    console.log("click the login btn")
                    showLoginDlg();
                }
            }
            BasicCircularImage{
                id: userImg
                visible: {
                    if(CloudUtils.getLogin())
                        return false;
                    else
                        return true;
                }
                width: 46; height: 46
                img_src: ""
                anchors.verticalCenter: parent.verticalCenter
                MouseArea {
                    anchors.fill: parent
                    focus: true
                    onClicked: {
                        console.log("click the userImg")
                        if(userInfoDlg){
                            userInfoDlg.showPersonInfo(userImg.img_src, userName.text, "ID: "+CloudUtils.getUserId());
                        }
                        else{
                            var componentUser = Qt.createComponent("UserInfo.qml")
                            if (componentUser.status === Component.Ready )
                            {
                                var obj = componentUser.createObject(idModelLibraryDlg)
                                userInfoDlg = obj;
                                obj.showPersonInfo(userImg.img_src, userName.text, "ID: "+CloudUtils.getUserId());
                                obj.sigLogout.connect(logout)
                            }
                        }                        
                    }
                }
            }
            Label{
                id: userName
                visible: {
                    if(CloudUtils.getLogin())
                        return false;
                    else
                        return true;
                }
                width: 27; height: 14
                text: "小李"
                color: "black"
                anchors.verticalCenter: parent.verticalCenter
            }
        }        
        Row{
            id: idContentArea
            anchors.top: idTopInfoArea.bottom           
            height: idMainPage.height-idTopInfoArea.height-53;
            Rectangle{
                id: idModelLibraryContent
                anchors.verticalCenter: parent.verticalCenter
                width: idMainPage.width; 
                height: idMainPage.height-idTopInfoArea.height-53;
                Label{
                    id: idSearchResultTip
                    anchors.verticalCenter: parent.verticalCenter;//anchors.centerIn: parent;
                    width: parent.width
                    height: 50
                    horizontalAlignment: Text.AlignHCenter
                    visible: false;
                    font.family: "Source Han Sans CN Normal"
                    font.weight: Font.Normal
                    font.pixelSize: 15
                    color: "black"
                    clip :true                                           
                    text: catalog.i18nc("@info:label", "No results found!")
                }
                ScrollView {
                    id: idModelLibraryScrollView;
                    clip : true                    
                    width: parent.width;
                    height: parent.height;
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
                        z: 1
                    }
                    Flow{
                        id: idModelLibraryList
                        spacing: 20
                        width: idMainPage.width;
                        height: idMainPage.height-idTopInfoArea.height-53;
                        //columns: 4 or 7
                    }
                    onVPositionChanged:{
                        if((vSize + vPosition) === 1){
                            if(refreshFlag){                                
                                flushModelLLByScroll();
                            }
                            refreshFlag = true;
                        }
                    }
                }                
            }                
        }
//-------------------------------------Model Library Detail-------------------------------------------          
        ModelLibraryDetail{
            id: idModelLibraryDetail
            anchors.fill: parent  
            anchors.leftMargin: 21
            anchors.rightMargin: 21
            anchors.topMargin: 20
            anchors.bottomMargin: 21
            visible: false
            detailSelCategory: selCategory
            onSigReturn:{//从详情页返回(返回模型库、返回搜索页、返回我的模型)
                curSelModelGroupID = "";
                isDetailPage = false;
                idModelLibraryDetail.visible = false
                idModelLibraryContent.visible = true
              
                idTopInfoArea.visible = true;
            }
            onSigDownloadAll:{
                downloadModels();
            }
            onSigDelAll:{
                slotBtnDelClicked(curSelModelGroupID);
            }
        }
        
//-------------------------------------my gcode list-------------------------------------------
        Item{
            id: idMyGcodeContent
            anchors.top: idTopInfoArea.bottom
            width: idMainPage.width;
            height: idModelLibraryContent.height;
            visible: false;
            ScrollView {
                id: idGcodeScrollView;
                clip : true                    
                width: parent.width;
                height: parent.height;
                property var vSize: idVScroll2.size
                property var vPosition: idVScroll2.position
                property var refreshFlag: false
                ScrollBar.vertical: ScrollBar {
                    id: idVScroll2
                    parent: idGcodeScrollView
                    x: idGcodeScrollView.mirrored ? 0 : idGcodeScrollView.width - width
                    y: idGcodeScrollView.topPadding
                    width: 10
                    height: idGcodeScrollView.availableHeight
                    policy: ScrollBar.AsNeeded
                    hoverEnabled: true
                    z: 1
                }
                ListView{
                    id: idMyGcodeListV
                    anchors.fill: parent
                    clip : true
                    focus: true
                    model: ListModel{
                        id: gcode_model
                    }
                    delegate: CusMyGcodeItem{
                        onSigBtnDownClicked:{//url name
                            var urlList = []; var fileList = []
                            urlList.push(url);
                            //Remove the suffix
                            while(1){
                                var pos = name.length-6;
                                if(pos<=0)
                                    break;
                                var count = pos;
                                if(name.indexOf(".gcode", pos) != -1){
                                    name = name.substr(0, count)
                                }
                                else{
                                    break;
                                }
                            }
                            
                            fileList.push("%1.gz".arg(name));
                            ManageModelBrowser.importModel(urlList, fileList)//download gcode /////
                        }
                        /*onSigBtnPrtClicked():{//url

                        }*/
                        onSigBtnDelClicked:{
                            slotBtnDelClicked(gcodeId)
                        }
                    }
                }
                onVPositionChanged:{
                        if((vSize + vPosition) === 1){
                            if(refreshFlag){
                                //console.log("scroll to refresh gcode...");
                                flushMyGcodeByScroll();
                            }
                            refreshFlag = true;
                        }
                    }
            }
        }
    }
//-------------------------------------messagebox-------------------------------------------
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
    MessageDialog{
        id: deleteDialog
        title: catalog.i18nc("@Tip:title", "Tip")
        icon: StandardIcon.Question
        text: "Are you sure to delete?"//确定要删除吗？
        standardButtons: StandardButton.Ok | StandardButton.Cancel
        modality: Qt.ApplicationModal
        visible: false
        property var modelGOrGcodeid: ""
        onAccepted:{
            msgDialog.visible = false
            if(selCategory == 2)
                ManageModelBrowser.deleteModelGroup(modelGOrGcodeid)
            else if(selCategory ==3)
                ManageModelBrowser.deleteGcode(modelGOrGcodeid)
        }
        onRejected:{
            msgDialog.visible = false
        }
    }
    AnimatedImage {
        id: idLoadingImg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top;
        anchors.topMargin: 12;
        visible: {
            if(CloudUtils.getDownloadState){
                idMainPage.enabled = false;
                return true;
            }
            else{
                idMainPage.enabled = true;
                return false;
            } 
        }
        source: "../res/loading.gif"
    } 
    onClosing:{
        if(idLoadingImg.visible)
            close.accepted = false
        else
            close.accepted = true
    }
}