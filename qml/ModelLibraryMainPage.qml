import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1

import UM 1.1 as UM
import Cura 1.1 as Cura

Window{
    property var selCategory: 1 //1 model library, 2 my model library, 3 my gcode
    property int sourceType: 1 // 1 model Library List ,2 search result,
    property alias categoryCurIndex: idSelCategory.currentIndex
    property string searchText: ""

    property var modelGroupMap: ({})
    property var imageMap: ({})
    property var modelMap: ({})

    property var curModelCategoryId: -1
    property var nextCursor: ""//model , my model
    property var currentModelLibraryPage: 1//search page
    property var totalPage: 0//search page
    property var pageSize: [28, 18]//0 the count of per model page, 1 count of my gcode page.
    
    property var isDetailPage: false//true: model detail page, false: other page
    property var curSelModelGroupID: ""//details
    property int curSelImgNumber: 1 //details
    
    property alias modelScrollvPos: idVScroll.position
    property alias gcodeScrollvPos: idVScroll2.position

    property var curMyGcodePage: 1
    property var totalPageMyGcode: 1

    property var loginDlg: 0;
    property var userInfoDlg: 0;

    UM.I18nCatalog { id: catalog; name: "uranium"}
    color: UM.Theme.getColor("main_background")
    function setModelTypeComboData(strjson)
    {         
        idModelTypeComboBox_model.clear();
        var objectArray = JSON.parse(strjson);
        var objResult = objectArray.result.list;        
        for( var key in objResult)
        {
            idModelTypeComboBox_model.append({modelCategoryId: objResult[key].id, 
                                        modelCategoryName: objResult[key].name})
        }
        idModelTypeComboBox.currentIndex = 0;
        curModelCategoryId = objResult[0].id;

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

        sourceType = 1

        if(selCategory == 1){
            nextCursor = ""
            ManageModelBrowser.loadPageModelLibraryList("", curModelCategoryId, false)          
        }
        //currentModelLibraryPage = 1;
        
        isDetailPage = false
    }

    function setModelLibraryList(strjson, appendFlag)
    {
        var componentButton = Qt.createComponent("CusModelLibraryItem.qml")
        if (componentButton.status === Component.Ready )
        {
            printMap("before delete");
            if(!appendFlag){//not append
                deleteModelGroupMap();
                console.log("after delete !");
            }else{
                printMap("not delete");
            }
            
            var count = 0;
            var objectArray = JSON.parse(strjson);
            if(objectArray.code === 0)
            {
                var objResult = objectArray.result.list;
                for( var key in objResult){
                    var obj = componentButton.createObject(idModelLibraryList, {"btnNameText": catalog.i18nc("@action:Label", objResult[key].groupName), 
                                                                        "btnModelImage": objResult[key].covers[0].url, 
                                                                        "modelGroupId": objResult[key].id,
                                                                        "btnAuthorText": catalog.i18nc("@action:Label", objResult[key].userInfo.nickName), 
                                                                        "btnAvtarImage": objResult[key].userInfo.avatar,
                                                                        "modelCount": objResult[key].modelCount})
                    if(selCategory == 2)
                        obj.btnDelVis = true;
                    obj.sigButtonDownClicked.connect(onSigButtonDownClicked) 
                    obj.sigButtonClicked.connect(onBrowseDetails)
                    obj.sigBtnDelClicked.connect(slotBtnDelClicked)
                    modelGroupMap[objResult[key].id] = obj;
                    //console.log("key:",key,",objResult[key].id---：",objResult[key].id,",obj---:",obj);
                    count += 1;
                }
                //console.log("modelGroupMap count:",count);
                printMap("current");
            }           
        }
        else{
            CloudUtils.qmlLog("create CusModelLibraryItem fail!")
        }
    }
    function setMyGcodeList(strjson, appendFlag)
    {
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
        for(var i = 0; i < n; i++){
            if(gcodeid == gcode_model.get(i).gcodeID){
                gcode_model.remove(i);
                break;
            }           
        }
    }

    function setModelDetailInfo(strjson)
    {
        var componentButton = Qt.createComponent("BasicImageButton.qml")
        var componentModelItem = Qt.createComponent("CusModelItem.qml")
        if (componentButton.status === Component.Ready )
        {           
            deleteImageMap();
            deleteModelMap();
            
            var objectArray = JSON.parse(strjson);
            if(objectArray.code === 0)
            {
                var objResult = objectArray.result.list;
                for( var key in objResult){
                    var imageNumber = Number(key) +1
                    var obj = componentButton.createObject(idModelLibraryDetail.modelDetailImgList, {
                                                                        "width": 60,
                                                                        "height": 60,
                                                                        "keystr": imageNumber,
                                                                        "modelid": objResult[key].id,
                                                                        "btnImgUrl": objResult[key].coverUrl})  
                    obj.sigBtnClicked.connect(onSigBtnClicked)
                    imageMap[imageNumber] = obj

                    var obj1 = componentModelItem.createObject(idModelLibraryDetail.modelDetailItemList, {"modelname": catalog.i18nc("@action:Button", objResult[key].fileName), 
                                                                        "modeSize": objResult[key].fileSize,
                                                                        "modelid": objResult[key].id,
                                                                        "keystr": imageNumber//,
                                                                        /*"modellink": objResult[key].downloadUrl*/})
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
            CloudUtils.qmlLog("create BasicImageButton fail!")
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

    function onBrowseDetails(id, name, count, author, avtar)//view details
    {
        idMyGcodeContent.visible = false;
        isDetailPage = true;
        idModelLibraryContent.visible = false;
        idModelLibraryDetail.visible = true;
        showNofoundTip(false);
        idTopInfoArea.visible = false;

        curSelModelGroupID = id
        idModelLibraryDetail.modelName =  name;
        idModelLibraryDetail.modelCount = count;
        idModelLibraryDetail.modelAImg = avtar
        idModelLibraryDetail.modelAName = author

        ManageModelBrowser.loadModelGroupDetailInfo(id, count);
    }

    function onSigButtonDownClicked(modelGid, count)//mainPage：download model group
    {       
        if(CloudUtils.getLogin()){
            ManageModelBrowser.importModelGroup(modelGid, count, selCategory);
        }else{
            showMessage(catalog.i18nc("@Tip:content", "please log in first!"));
        }
    }

    function slotBtnDelClicked(id)//1 mainPage and detail: delete my model group;  2 delete mygcode
    {
        deleteDialog.modelGOrGcodeid = id;
        deleteDialog.show()
    }

    function shareLink(modelGid)
    {
        let link = CloudUtils.getWebUrl() + "/model-detail/" + modelGid
        CloudUtils.addToClipboard(link);
        showMessage(catalog.i18nc("@Tip:content", "Link copied to clipboard!"));
    }

    function flushMyMLibAfterDelGroup(modelGid)
    {
        if(isDetailPage)
        {
            deleteImageMap();
            deleteModelMap();
            //back
            curSelModelGroupID = "";
            isDetailPage = false;
            idModelLibraryDetail.visible = false
            idModelLibraryContent.visible = true
            idTopInfoArea.visible = true;
            idSearch.enabled = true
        }

        var strModelGid = "-%1-".arg(modelGid)

        deleteModelGroupMap();
    }
    function flushMyModelAfterAdd()
    {
        ManageModelBrowser.loadPageMyModelList("", false)

        let t_id = "-%1-".arg(curSelModelGroupID);
        let obj;
        let count = 0;
        for(var key in modelGroupMap){
            var strkey = "-%1-".arg(key)           		
            if(strkey == t_id){
                obj = modelGroupMap[key]                
                break;
            }			
        }

        if(obj){
            count = obj.modelCount
            idModelLibraryDetail.modelName = obj.btnNameText
            idModelLibraryDetail.modelCount = count
            idModelLibraryDetail.modelAImg = obj.btnAvtarImage
            idModelLibraryDetail.modelAName = obj.btnAuthorText
        }
        ManageModelBrowser.loadModelGroupDetailInfo(curSelModelGroupID, count);
    }

    function downloadModels()//detailPage：download model group
    {
        var urlList = []; var fileList = []
        var url = ""; var filename = ""       
        for(var key in modelMap)
        {
            url = CloudUtils.modelDownloadUrl(modelMap[key].modelid)//modelMap[key].modellink
            filename = modelMap[key].modelname
            urlList.push(url);
            fileList.push("%1.stl".arg(filename));
        }
        ManageModelBrowser.importModel(urlList, fileList, selCategory)
    }

    function onDownloadModel(name, id)//detailPage：download a single model
    {
        if(!CloudUtils.getLogin()){
            showMessage(catalog.i18nc("@Tip:content", "please log in first!"));
            return;
        }
        
        var urlList = []; var fileList = []
        var url = ""
        url =  CloudUtils.modelDownloadUrl(id); console.log("url:",url)
        urlList.push(url);
        fileList.push("%1.stl".arg(name));
        ManageModelBrowser.importModel(urlList, fileList, selCategory)
    }

    function flushModelLLByScroll()//Scroll to refresh
    {
        if(selCategory == 1){//model
            if(sourceType == 1){//model library
                if(nextCursor != ""){console.log("nextCursor:",nextCursor)
                    ManageModelBrowser.loadPageModelLibraryList(nextCursor, curModelCategoryId, true)
                }
            }
            else if(sourceType == 2){//search result
                if ((searchText != "") && (currentModelLibraryPage+1 <= totalPage)){
                    currentModelLibraryPage++;
                    ManageModelBrowser.loadModelSearchResult(searchText, currentModelLibraryPage, pageSize[0], true)
                }
            }
        }
        else if(sourceType == 2){//my model
            if(nextCursor != ""){console.log("nextCursor:",nextCursor)
                ManageModelBrowser.loadPageMyModelList(nextCursor, curModelCategoryId, true)
            }
        }
    }

    function flushMyGcodeByScroll()//scroll to refresh
    {
        if(curMyGcodePage+1 <= totalPageMyGcode)
        {
            curMyGcodePage++;
            if(selCategory == 3)
            {
                ManageModelBrowser.loadPageMyGcodeList(curMyGcodePage, pageSize[1], true);
            }
        }
    }

    function deleteModelGroupMap()
    {        
        for(var key in modelGroupMap)
        {			
            modelGroupMap[key].destroy()
        }
        modelGroupMap = ({})
    }
    function deleteImageMap()
    {
        for(var key in imageMap)
        {			
            imageMap[key].destroy()
        }
        imageMap = ({})
    }
    function deleteModelMap()
    {
       for(var key in modelMap)
        {			
            modelMap[key].destroy()
        }
        modelMap = ({})
    }

    function printMap(info)
    {
        console.log(info, " ----------print map");
        var count = 0;
        for(var key in modelGroupMap)        
		{
            count += 1; console.log("map key:",key,",    map value:",modelGroupMap[key]);
		}
        console.log(info," map count:  ",count, "----------")
    }

    function showMessage(text) {
        msgDialog.myContent = text;
        msgDialog.show()
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
            loginDlg = CloudUtils.getLoginDlg();
            loginDlg.nextPage = -1;
            loginDlg.show();
            loginDlg.sigLoginRes.connect(slotloginSuccess)
        }
    }

    function slotloginSuccess(img, name, userid)
    {
        idLoginBtn.visible = false;
        spaceRect.visible = true;
        userImg.visible = true;
        userName.visible = true;
      
        switch (idSelCategory.currentIndex){
            case 0:
                initUI();
                ManageModelBrowser.loadCategoryListResult(2)
                break;
            case 1:
                initUI();
                ManageModelBrowser.loadPageMyModelList("",false)
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
        spaceRect.visible = false;
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
        var isLogin = CloudUtils.getLogin();
        if(isLogin){
            userImg.img_src = CloudUtils.getUserImg();
            userName.text = CloudUtils.getUserName();
        }

        idLoginBtn.visible = !isLogin;
        spaceRect.visible = isLogin
        userImg.visible = isLogin;
        userName.visible = isLogin;

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
        }
    }
    function showSearchPage()
    {
        idBackMainPage.visible = false;
        idSelCategory.visible = false;
        idModelTypeComboBox.visible = false;
        idSearch.visible = false;
        idSearchLabel.visible = false;
        //var isLogin = CloudUtils.getLogin();
        idLoginBtn.visible = false//!isLogin;

        idBackMainPage.visible = true
        idSearch.visible = true
        idSearchLabel.visible = true
        spaceRect.visible = false
        userImg.visible = false;
        userName.visible = false;
    }
    function showBusy() {
        busyLayer.visible = true
        idMainPage.enabled = false;
    }

    function hideBusy() {
        busyLayer.visible = false
        idMainPage.enabled = true
    }
//--------------------------------------main page----------------------------------------------
    id: idModelLibraryDlg
    width: 1042
    height: 711
    minimumWidth: 1042
    minimumHeight: 711
    //maximumWidth: 1920
    //maximumHeight: 1080
    title: catalog.i18nc("@title:window", "Creality Cloud Plugin")
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
            BasicSkinButton{
                id: idBackMainPage
                visible: false;
                width: 22; height: 32
                imgW:width; imgH:height;
                tipText: catalog.i18nc("@Tip:Button", "Return to the home page")
                btnImgNormal: "../res/btn_back.png"
                btnImgHovered: "../res/btn_back_h.png"
                btnImgPressed: "../res/btn_back_h.png"
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
                    idLoginBtn.visible = !isLogin;
                    spaceRect.visible = isLogin
                    userImg.visible = isLogin;
                    userName.visible = isLogin;
                }
            }
            Cura.ComboBox {
                id: idSelCategory
                width:200; height: 28
                anchors.verticalCenter: parent.verticalCenter
                model: ListModel{
                    id: idCategory_model
                }
                textRole: "name"
                currentIndex : -1
                onActivated: {
                    if(selCategory != currentIndex+1){
                        if(CloudUtils.getLogin()){
                            selCategory = currentIndex+1;
                            switch (currentIndex){ 
                                case 0:
                                    initUI();
                                    ManageModelBrowser.loadCategoryListResult(2)
                                    break;
                                case 1:
                                    initUI();
                                    ManageModelBrowser.loadPageMyModelList("",false)
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
                Component.onCompleted: {
                    var strlist = ManageModelBrowser.getCategoryText()
                    var n = strlist.length;
                    for(var i=0; i<n; i++){
                        idCategory_model.append({name: strlist[i]});
                    }
                }
            }
            Cura.ComboBox {
                id: idModelTypeComboBox
                width:200; height: 28
                anchors.verticalCenter: parent.verticalCenter
                model: ListModel{
                    id: idModelTypeComboBox_model                   
                }
                textRole: "modelCategoryName"
                currentIndex : -1            
                onActivated: {
                    if(curModelCategoryId != idModelTypeComboBox_model.get(currentIndex).modelCategoryId)
                    {
                        curModelCategoryId = idModelTypeComboBox_model.get(currentIndex).modelCategoryId;
                        console.log("-----------init222:",curModelCategoryId);
                        //currentModelLibraryPage = 1;
                        nextCursor = "";
                        modelScrollvPos = 0;
                        ManageModelBrowser.loadPageModelLibraryList("", curModelCategoryId, false)
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
                font: UM.Theme.getFont("medium")
                renderType: Text.NativeRendering
                color: UM.Theme.getColor("text")
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
                text: catalog.i18nc("@text:btn", "Login")
                hoveredBtnBgColor: defaultBtnBgColor
                anchors.verticalCenter: parent.verticalCenter
                fontWeight: Font.Bold
                onSigButtonClicked: {
                    showLoginDlg();
                }
            }
            Rectangle{
                id: spaceRect
                visible: {
                    if(CloudUtils.getLogin())
                        return false;
                    else
                        return true;
                }
                width: {
                    if(CloudUtils.getLogin()){
                        if((selCategory === 2) || (selCategory === 3)){
                            return idMainPage.width - idSelCategory.width - userImg.width - userName.width - 20*4;
                        }else if(selCategory === 1){
                            return idMainPage.width - idSelCategory.width - idModelTypeComboBox.width - idSearch.width -userImg.width - userName.width - 20*6;
                        }
                        else{
                            return 0;
                        }
                    }else
                        return 0;
                }
                height:46
                color: "transparent"
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
                    cursorShape: Qt.PointingHandCursor
                    hoverEnabled: true
                    onClicked: {
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
                text: ""
                font: UM.Theme.getFont("default")
                renderType: Text.NativeRendering
                color: UM.Theme.getColor("text")
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
                    anchors.verticalCenter: parent.verticalCenter;
                    width: parent.width
                    height: 50
                    horizontalAlignment: Text.AlignHCenter
                    z: 1
                    visible: false;
                    font: UM.Theme.getFont("medium")
                    renderType: Text.NativeRendering
                    color: UM.Theme.getColor("text")
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
                    background: Rectangle {
                        implicitWidth: parent.width;
                        implicitHeight: parent.height;                   
                        color: UM.Theme.getColor("main_background")
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
            onSigReturn:{
                curSelModelGroupID = "";
                isDetailPage = false;
                idModelLibraryDetail.visible = false
                idModelLibraryContent.visible = true
              
                idTopInfoArea.visible = true;
            }
            onSigDownloadAll:{
                if(CloudUtils.getLogin()){
                    downloadModels();
                }else{
                    showMessage(catalog.i18nc("@Tip:content", "please log in first!"));
                }
            }
            onSigShareLink:{
                shareLink(curSelModelGroupID);
            }
            onSigAddModel:{               
                idAddModelDlg.visible = true
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
                ScrollBar.horizontal: ScrollBar {}
                ListView{
                    id: idMyGcodeListV
                    anchors.fill: parent
                    clip : true
                    focus: true
                    model: ListModel{
                        id: gcode_model
                    }
                    delegate: CusMyGcodeItem
                    {
                        width: parent.width;
                        height: 46
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
                            ManageModelBrowser.importModel(urlList, fileList, selCategory)
                        }
                        //onSigBtnPrtClicked():{//url
                        //}
                        onSigBtnDelClicked:{
                            slotBtnDelClicked(gcodeId)
                        }
                    }
                }
                onVPositionChanged: {
                    if((vSize + vPosition) === 1){
                        if(refreshFlag){
                            flushMyGcodeByScroll();
                        }
                        refreshFlag = true;
                    }
                }              
            }
        }       
    }
//-------------------------------------add model-------------------------------------------
    AddModelDlg{
        id: idAddModelDlg
        visible: false
        onSigUploadModel: {
            showBusy();
            ManageModelBrowser.addModels(fileList);
        }
    }
//-------------------------------------messagebox-------------------------------------------
    BasicMessageDialog{
        id: msgDialog
        mytitle: catalog.i18nc("@Tip:title", "Tip")
        onAccept: {
            msgDialog.close()
        }
    }
    BasicMessageDialog{
        id: deleteDialog
        mytitle: catalog.i18nc("@Tip:title", "Tip")
        btnCount: 2
        myContent: catalog.i18nc("@Tip:content", "Are you sure to delete?")       
        property var modelGOrGcodeid: ""
        onAccept:{
            deleteDialog.close()
            if(selCategory == 2)
                ManageModelBrowser.deleteModelGroup(modelGOrGcodeid)
            else if(selCategory ==3)
                ManageModelBrowser.deleteGcode(modelGOrGcodeid)
        }
        onCancel:{
            deleteDialog.close()
        }
    }
    AnimatedImage {
        id: idLoadingImg
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.horizontalCenterOffset: -50
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
    Rectangle {
        id: busyLayer
        anchors.fill: parent
        color: "black"
        opacity: 0.5
        visible: false
        z: 100
        BusyIndicator {
            anchors.centerIn: parent
            width: Math.min(parent.width, parent.height) * 0.25
            height: Math.min(parent.width, parent.height) * 0.25
            running: parent.visible
        }
        MouseArea {
            anchors.fill: parent
        }
    }
    onClosing:{
        if(idLoadingImg.visible)
            close.accepted = false
        else
            close.accepted = true
    }
}
