import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.1
import QtQuick.Controls.Styles 1.4
import UM 1.1 as UM
import "../js/CloudAPI.js" as CloudAPI
import "../js/CountryCode.js" as CountryCode
import "../js/Validator.js" as Validator

BasicDialog {
    id: pluginRootWindow
    UM.I18nCatalog { id: catalog; name: "uranium"}
    visible: false
    width: 600
    height: 443  
    titleHeight: 30
    title: catalog.i18nc("@title:window", "Login")

    property string token: ""
    property string userId: ""

    property string userImg: ""
    property string userName: ""
    property int nextPage: -1;//---0:modelLib,1:"myModel",2:"myGcode",3:"uploadModel",  ---4:"uploadGcode",

    property string loginType: ""
    property string phoneLoginType: "quick";
    property bool showPassWord: false;
    property int verCodeTime: 60

    signal sigLoginSuccess(var retPageType, var userImg, var userName, var userId);
    signal sigLoginRes(var userImg, var userName, var userId);

    function switchEmailLogin() {
        loginType = "email"
        phoneSelect.visible = false
        phoneField.visible = false
        mobileSwitchTypeLable.visible = false;
        emailField.visible = true
        passwordField.visible = true
        verCode.visible = false
        verButton.visible = false
        resetLink.visible = true
        cleanField()           
        passwordField.anchors.topMargin = 10;
        resetLink.anchors.topMargin = 6;
        loginButton.anchors.bottomMargin = 73;
        serverSetting.anchors.bottomMargin = 35;
        signUpTip1.anchors.bottomMargin = 45;
    }
    function showBusy() {
        busyLayer.visible = true
    }

    function hideBusy() {
        busyLayer.visible = false
    }

    function showMessage(text) {
        msgDialog.text = text;
        msgDialog.visible = true
    }

    function saveToken(token, userId, userImg, userName) {
        CloudUtils.saveToken(token, userId, userImg, userName)
        pluginRootWindow.token = token
        pluginRootWindow.userId = userId
    }

    function cleanField() {
        phoneField.text = ""
        verCode.text = ""
        passwordField.text = ""
    }

    function switchQuickLogin() {
        loginType = "quick"
        phoneSelect.visible = true
        phoneField.visible = true
        mobileSwitchTypeLable.visible = true;
        emailField.visible = false
        passwordField.visible = false
        verCode.visible = true
        verButton.visible = true           
        resetLink.visible = false
        cleanField()
        passwordField.anchors.topMargin = 40;
        resetLink.anchors.topMargin = 10;
        loginButton.anchors.bottomMargin = 43;
        serverSetting.anchors.bottomMargin = 5;
        signUpTip1.anchors.bottomMargin = 15;
    }
    function switchPhoneLogin() {
        loginType = "mobile"
        phoneSelect.visible = true
        phoneField.visible = true
        mobileSwitchTypeLable.visible = true;
        emailField.visible = false
        passwordField.visible = true
        verCode.visible = false
        verButton.visible = false
        resetLink.visible = true
        cleanField()
        passwordField.anchors.topMargin = 40;
        resetLink.anchors.topMargin = 10;
        loginButton.anchors.bottomMargin = 43;
        serverSetting.anchors.bottomMargin = 5;
        signUpTip1.anchors.bottomMargin = 15;
    }
    function mobilePhoneLogin() {
        if(phoneLoginType === "quick")
        {
            switchQuickLogin();
        }
        else if(phoneLoginType === "mobile")
        {
            switchPhoneLogin();
        }
    }
    
    function fieldValidator() {
        let v = new Validator.Validator()
        let countryCode = phoneSelectModel.get(phoneSelect.currentIndex).phone
        let mobile = phoneField.text
        let code = verCode.text
        let password = passwordField.text
        let email = emailField.text
        switch (loginType) {
            case "quick":
                if (v.required(countryCode) && v.required(mobile) && v.isInternationphone(mobile)) {
                    verButton.enabled = true
                    if(v.required(code)) {
                        loginButton.enabled = true
                    }else {
                        loginButton.enabled = false
                    }
                }else {
                    loginButton.enabled = false
                    verButton.enabled = false
                }
                break
            case "mobile":
                if (v.required(countryCode) && v.required(mobile) && v.required(password) && v.isInternationphone(mobile)) {
                    loginButton.enabled = true
                }else {
                    loginButton.enabled = false
                }
                break
            case "email":
                if (v.required(email) && v.required(password)) {
                    loginButton.enabled = true
                }else {
                    loginButton.enabled = false
                }
        }
    }

    function refreshItemShow() {
        refreshItem.visible = true
        refreshMask.opacity = 0.4
    }
    function refreshItemHiden() {
        refreshItem.visible = false
        refreshMask.opacity = 0
    }
    function requestQrCode() {
        pluginRootWindow.showBusy()
        CloudAPI.qrLogin(function(data) {
            if (data["code"] === 0) {
                CloudAPI.identical = data["result"]["identical"]
                qrItem.expireTime = data["result"]["expireTime"]
                // Generate qr code link
                qrcode.value = "https://share.creality.com/scan-code?i=" + CloudAPI.identical
                qrTimer.running = true
                refreshItemHiden()
            }else {
                pluginRootWindow.showMessage("Error: " + JSON.stringify(data))
            }
            pluginRootWindow.hideBusy()
        })
    }

    function qrItemShow() {
        qrItem.visible = true
        requestQrCode()
    }

    function qrItemHidden() {
        qrItem.visible = false
        qrTimer.stop()
    }

    function loginScuess(token, userId) {
        
        CloudUtils.setLogin(true);
        CloudAPI.getUserInfo(token, userId, function(data) {              
            if (data["code"] === 0) {
                userImg = data["result"]["userInfo"]["base"]["avatar"]
                userName = data["result"]["userInfo"]["base"]["nickName"]
                //var userid = data["result"]["userInfo"]["base"]["userId"]                
                pluginRootWindow.hide()
                pluginRootWindow.saveToken(token, userId, userImg, userName)

                sigLoginSuccess(nextPage, userImg, userName, userId);
                sigLoginRes(userImg, userName, userId)                      
            }
        })

    }

    MessageDialog {
        id: msgDialog
        title: catalog.i18nc("@Tip:title", "Error")
        icon: StandardIcon.Warning
        modality: Qt.ApplicationModal
        onAccepted: {
            msgDialog.visible = false
        }
    }
       
    Rectangle {
        id: rootRect
        anchors.fill: parent
        anchors.topMargin:titleHeight
        //head logo
        Rectangle {
            id: logoBg           
            width: parent.width
            height: 73
            color: "white"
            z: 2

            BorderImage {
                id: logo
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -width
                width: 36
                height: 34
                transformOrigin: Item.Center
                source: "../res/logo.png"
            }

            Text {
                id: logoText
                anchors.left: logo.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: "#333333"
                text: catalog.i18nc("@title:window", "Creality Cloud")
                font.family: "Source Han Sans CN Normal"
                font.pixelSize: 20
                font.weight: Font.Bold
            }
        }
        //Separator
        Item {
            id: idSeparator
            anchors.top: logoBg.bottom;
            width:parent.width
            height: 1
            Rectangle
            {
                anchors.fill: parent
                color: "#42BDD8"
                opacity: 0.5
            }
        }  
        //login page
        Item {
            id: loginItem
            anchors.fill: parent
            anchors.topMargin: 74
            
            Item {
                id: accountLogin
                anchors.leftMargin: 96
                anchors.rightMargin: 95
                anchors.topMargin: 0
                anchors.bottomMargin: 0        
                anchors.fill: parent
                Row {
                    height: 24
                    anchors.top: parent.top
                    anchors.topMargin: 42
                    anchors.left: parent.left
                    anchors.leftMargin: -20
                    anchors.right: parent.right
                    anchors.rightMargin: -60
                    spacing: 3
                    BasicButton {
                        id: emailLoginLabel
                        width: 120; height: 24
                        text: catalog.i18nc("@title:Label", "Email Login")
                        btnTextColor: btnSelected ? "#42BDD8": (hovered ? "#42BDD8" : "#C7C7C7")
                        btnSelected: false
                        defaultBtnBgColor : "transparent"
                        hoveredBtnBgColor: "transparent"
                        selectedBtnBgColor: "transparent"
                        pixSize: 18
                        fontWeight: Font.Bold
                        btnRadius: 0
                        btnBorderW: 0
                        onSigButtonClicked: {
                                pluginRootWindow.switchEmailLogin()                        
                                emailLoginLabel.btnSelected = false
                                mobilephoneLoginLabel.btnSelected = false
                                scanQrcodeLoginLabel.btnSelected = false
                                btnSelected = true;
                        }
                    }

                    Rectangle
                    {
                        width: 1; height: 17
                        color: "#E8E8E8"
                        anchors.verticalCenter: parent.verticalCenter
                    }       

                    BasicButton {
                        id: mobilephoneLoginLabel
                        width: 166; height: 24
                        text: catalog.i18nc("@title:Label", "Mobile Phone Login")
                        btnTextColor: btnSelected ? "#42BDD8": (hovered ? "#42BDD8" : "#C7C7C7")
                        btnSelected: true
                        defaultBtnBgColor : "transparent"
                        hoveredBtnBgColor: "transparent"
                        selectedBtnBgColor: "transparent"
                        pixSize: 18
                        fontWeight: Font.Bold
                        btnRadius: 0
                        btnBorderW: 0
                        onSigButtonClicked: {
                                mobilePhoneLogin();                     
                                emailLoginLabel.btnSelected = false
                                mobilephoneLoginLabel.btnSelected = false
                                scanQrcodeLoginLabel.btnSelected = false
                                btnSelected = true;
                        }
                    }

                    Rectangle
                    {
                        width: 1; height: 17
                        color: "#E8E8E8"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    
                    BasicButton {
                        id: scanQrcodeLoginLabel
                        width: 166; height: 24
                        text: catalog.i18nc("@title:Label", "Scan Qrcode Login")
                        btnTextColor: btnSelected ? "#42BDD8": (hovered ? "#42BDD8" : "#C7C7C7")
                        btnSelected: false
                        defaultBtnBgColor : "transparent"
                        hoveredBtnBgColor: "transparent"
                        selectedBtnBgColor: "transparent"
                        pixSize: 18
                        fontWeight: Font.Bold
                        btnRadius: 0
                        btnBorderW: 0
                        onSigButtonClicked: {
                                qrItemShow()
                                emailLoginLabel.btnSelected = false
                                mobilephoneLoginLabel.btnSelected = false
                                scanQrcodeLoginLabel.btnSelected = false
                                btnSelected = true;
                        }
                    }
                }

                Item {
                    id: element1
                    height: 243
                    anchors.top: parent.top
                    anchors.topMargin: 95
                    anchors.right: parent.right
                    anchors.rightMargin: 0           
                    anchors.left: parent.left
                    anchors.leftMargin: 0
            
                    ComboBox {
                        id: phoneSelect
                        width: 106
                        height: 36
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        down: true
                        model: ListModel { id: phoneSelectModel }
                        delegate: ItemDelegate{
                            width: 170
                            height : 25
                            contentItem: Rectangle
                            {
                                anchors.fill: parent
                                Text {
                                    id:myText
                                    height: 25
                                    text: nameEn + " " +phone
                                    color: "#333333"
                                    font: phoneSelect.font
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                                color: (phoneSelect.highlightedIndex === index) ? "#42BDD8" : "white"
                            }
                            hoverEnabled: phoneSelect.hoverEnabled
                        }

                        indicator: Rectangle
                        {
                            anchors.right: phoneSelect.right
                            anchors.rightMargin: 16
                            anchors.verticalCenter: phoneSelect.verticalCenter
                            width: phoneSelect.height - 1
                            height: phoneSelect.height - 2                   
                            color: "transparent"
                            Image {
                                width: 11
                                height: 6
                                anchors.centerIn: parent
                                source: idListViewPhone.visible ? "../res/up.png" : "../res/down.png"
                            }
                        }

                        contentItem: Item{
                            Image {
                                id : headImagePhone
                                x: 13; y: 8
                                height: 20
                                width: 12
                                source: "../res/login_phone.png"
                            }
                            Label {
                                id: idText
                                x: headImagePhone.width + 18; y: 8
                                height: headImagePhone.height
                                width: phoneSelect.width - headImagePhone.width - phoneSelect.indicator.width - 29
                                text: "+ " + phoneSelect.model.get(phoneSelect.currentIndex).phone
                                font: phoneSelect.font
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                        background: Rectangle {
                                color: "white"
                                border.width: 1
                                border.color: "#C7C7C7"
                        }

                        popup: Popup {
                            y: phoneSelect.height - 1
                            background: Rectangle {
                                border.width: 1
                                border.color: "#42BDD8"
                            }
                            width: 200
                            implicitHeight: contentItem.implicitHeight
                            contentItem: ListView {
                                id: idListViewPhone
                                clip: true
                                implicitHeight: contentHeight
                                model: phoneSelect.popup.visible ? phoneSelect.delegateModel : null
                                currentIndex: phoneSelect.highlightedIndex
                                ScrollBar.vertical: ScrollBar { }
                            }
                        }
                        Component.onCompleted: {
                            var dict = CountryCode.dict.allCountries
                            for (var i in dict) {
                                if(dict[i].phone_number != ""){
                                    model.append({"nameCn": dict[i].name_CN, "nameEn": dict[i].name_EN, "phone": dict[i].phone_number})
                                }
                            }
                            phoneSelect.currentIndex = 36
                        }
                    }

                    TextField {
                        id: phoneField
                        height: 36
                        width: 301
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: phoneSelect.right
                        anchors.leftMargin: 0
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        color: "#333333"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 14
                        font.weight: Font.Normal
                        selectByMouse: true
                        placeholderText: catalog.i18nc("@tip:textfield", "Please enter mobile number")
                        onTextChanged: fieldValidator()
                    }

                    TextField {
                        id: emailField
                        height: 36
                        width: 408
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.top: parent.top
                        anchors.topMargin: 0
                        color: "#333333"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 14
                        font.weight: Font.Normal
                        selectByMouse: true
                        leftPadding: 10 + headImageAccount.width + 13
                        Image {
                            id : headImageAccount
                            x: 10
                            y: (emailField.height - sourceSize.height)/2
                            height:sourceSize.height
                            width: sourceSize.width
                            source: "../res/login_email.png"
                        }
                        placeholderText: catalog.i18nc("@tip:textfield", "Please enter your email address")
                        onTextChanged: fieldValidator()
                    }

                    TextField {
                        id: passwordField
                        height: emailField.height
                        width: emailField.width
                        anchors.top: phoneSelect.bottom
                        anchors.topMargin: 40//10
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        echoMode: showPassWord ? TextInput.Normal : TextInput.Password
                        color: "#333333"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 14
                        font.weight: Font.Normal
                        selectByMouse: true
                        leftPadding: 10 + headImagePwd.width + 13
                        rightPadding: 11 + endImageEye.width + 13
                        Image {
                            id : headImagePwd
                            x: 10
                            y: (passwordField.height - sourceSize.height)/2
                            height: sourceSize.height
                            width: sourceSize.width
                            source: "../res/login_passwd.png"
                        }
                        placeholderText: catalog.i18nc("@tip:textfield", "Please enter password")
                        Button{
                            id: eyeBtn
                            height:endImageEye.sourceSize.height
                            width: endImageEye.sourceSize.width
                            anchors.right: passwordField.right
                            anchors.rightMargin: 11
                            anchors.bottom: passwordField.bottom
                            anchors.bottomMargin: (passwordField.height - eyeBtn.height)/2
                            background: Rectangle {
                                implicitWidth: parent.width
                                implicitHeight: parent.height
                                color: "transparent"
                            }
                            Image{
                                id: endImageEye
                                anchors.centerIn: parent
                                fillMode: Image.Pad
                                source: {
                                    showPassWord ? 
                                    (eyeBtn.hovered ? "../res/login_pwdVisT_h.png" : "../res/login_pwdVisT.png") :
                                    (eyeBtn.hovered ? "../res/login_pwdVisF_h.png" : "../res/login_pwdVisF.png")
                                }
                            }
                            onClicked:{
                                showPassWord = !showPassWord;
                            }
                        }
                        onTextChanged: fieldValidator()
                    }

                    TextField {
                        id: verCode
                        width: 289
                        height: 36
                        anchors.top: phoneSelect.bottom
                        anchors.topMargin: 40
                        color: "#333333"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 14
                        font.weight: Font.Normal
                        selectByMouse: true
                        leftPadding: 10 + headImageVercode.width + 13
                        Image {
                            id : headImageVercode
                            x: 10
                            y: (verCode.height - sourceSize.height)/2
                            height: sourceSize.height
                            width: sourceSize.width
                            source: "../res/login_passwd.png"
                        }
                        placeholderText: catalog.i18nc("@tip:textfield", "Please enter verification code")
                        onTextChanged: fieldValidator()
                    }

                    Label {
                        id: mobileSwitchTypeLable
                        text: catalog.i18nc("@title:Label", "Password to login")
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.bottom: verButton.top
                        anchors.bottomMargin: 18
                        font.wordSpacing: -0.5
                        font.letterSpacing: -1
                        font.capitalization: Font.MixedCase
                        color: "#42BDD8"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if(phoneLoginType === "quick")
                                {
                                    mobileSwitchTypeLable.text = catalog.i18nc("@title:Label", "Quick login")
                                    phoneLoginType = "mobile";
                                    switchPhoneLogin();
                                }
                                else if(phoneLoginType === "mobile")
                                {
                                    mobileSwitchTypeLable.text = catalog.i18nc("@title:Label", "Password to login")
                                    phoneLoginType = "quick";
                                    switchQuickLogin();                            
                                }
                            }
                            onEntered: {
                                parent.font.underline = true
                            }
                            onExited: {
                                parent.font.underline = false
                            }
                        }
                    }

                    BasicButton
                    {
                        id: verButton
                        height: 36
                        text: catalog.i18nc("@text:btn", "Get Code")
                        anchors.left: verCode.right
                        anchors.leftMargin: 20
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.top: phoneSelect.bottom
                        anchors.topMargin: 40
                        enabled: false
                        defaultBtnBgColor : "#42BDD8"
                        hoveredBtnBgColor: "#42BDD8"
                        btnRadius: 3
                        btnBorderW: 0
                        btnTextColor: enabled ? "white" : "#333333"
                        onSigButtonClicked: {
                            var phone = phoneSelectModel.get(phoneSelect.currentIndex).phone + phoneField.text
                            CloudAPI.getVerCode(phone, function(data) {
                                if (data["code"] == 0) {
                                    verCodeTimer.start()
                                }else {
                                    pluginRootWindow.showMessage("Error: " + JSON.stringify(data))
                                }
                            })
                        }
                    }

                    Label {
                        id: resetLink
                        color: "#42BDD8"
                        text: catalog.i18nc("@title:Label", "Forget Password?")
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.top: passwordField.bottom
                        anchors.topMargin: 10//6
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                        visible: false
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: Qt.openUrlExternally(CloudUtils.getWebUrl() + "/?resetpassword = 0")
                            hoverEnabled: true
                            onEntered: {
                                parent.font.underline = true
                            }
                            onExited: {
                                parent.font.underline = false
                            }
                        }
                    }

                    BasicButton
                    {
                        id: loginButton
                        height: 48
                        width: 408
                        text: catalog.i18nc("@text:btn", "Login In")
                        anchors.right: parent.right
                        anchors.rightMargin: 0
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 43//73
                        enabled: false
                        defaultBtnBgColor : "#42BDD8"
                        hoveredBtnBgColor: "#42BDD8"
                        btnRadius: 3
                        btnBorderW: 0
                        btnTextColor: enabled ? "white" : "#333333"
                        onSigButtonClicked:
                        {
                            var mobile = phoneField.text
                            var countryCode = phoneSelectModel.get(phoneSelect.currentIndex).phone
                            var mobileVerCode = verCode.text
                            var email = emailField.text
                            var password = passwordField.text

                            switch(loginType) {
                                case "quick":
                                    CloudAPI.quickLogin(countryCode+mobile, countryCode, mobileVerCode, function(data) {
                                        if (data["code"] == 0) {
                                            loginScuess(data["result"]["token"], data["result"]["userId"])                                           
                                        }else {
                                            pluginRootWindow.showMessage("Error: " + data["msg"])
                                        }
                                    })
                                break
                                case "mobile":
                                    CloudAPI.accountLogin(1, countryCode+mobile, password, function(data) {
                                        if (data["code"] == 0) {
                                            loginScuess(data["result"]["token"], data["result"]["userId"])
                                        }else {
                                            pluginRootWindow.showMessage("Error: " + data["msg"])
                                        }
                                    })
                                break
                                case "email":
                                    CloudAPI.accountLogin(2, email, password, function(data) {
                                        if (data["code"] == 0) {
                                            loginScuess(data["result"]["token"], data["result"]["userId"])
                                        }else {
                                            pluginRootWindow.showMessage("Error: " + data["msg"])
                                        }
                                    })
                            }
                        }                       
                    }

                    Text {
                        id: serverSetting
                        text: catalog.i18nc("@title:Label", "Server")
                        width: 50; height: 30
                        clip: true;
                        elide: Text.ElideRight
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 5//35
                        anchors.left: parent.left
                        anchors.leftMargin: 0
                        font.wordSpacing: -0.5
                        font.letterSpacing: -1
                        font.pixelSize: 13
                        verticalAlignment: Text.AlignVCenter
                    }
                    ComboBox {
                        id: idServer
                        width:130; height: 30
                        anchors.bottom: serverSetting.bottom
                        anchors.bottomMargin: 0
                        anchors.left: serverSetting.right
                        anchors.leftMargin: 3
                        model: ListModel{
                            id: idServerModel
                        }
                        currentIndex : -1
                        onActivated: {
                            var env = ""
                            if (textAt(currentIndex) === idServerModel.get(0).name){
                                env = "release_oversea"
                            }else {
                                env = "release_local"
                            }
                            CloudUtils.saveUrl(env)
                            CloudUtils.autoSetUrl()
                            CloudAPI.api_url = CloudUtils.getCloudUrl()
                        }
                        Component.onCompleted: {                           
                            idServerModel.append({"name": catalog.i18nc("@text:ComboBox", "International")})
                            idServerModel.append({"name": catalog.i18nc("@text:ComboBox", "China")})
                        }
                    }

                    Text {
                        id: signUpTip1
                        text: catalog.i18nc("@title:Label", "No account? Please click ")
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 15//45
                        anchors.right: parent.right
                        anchors.rightMargin: signUpTip2.width
                        color: "#333333"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 12
                    }

                    Text {
                        id: signUpTip2
                        text: catalog.i18nc("@title:Label", "Sign Up")
                        height: 12
                        width: 50
                        anchors.top: signUpTip1.top
                        anchors.topMargin: 0
                        anchors.left: signUpTip1.right
                        anchors.leftMargin: 0
                        color: "#42BDD8"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 12
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            hoverEnabled: true
                            onClicked: Qt.openUrlExternally(CloudUtils.getWebUrl() + "/?signup=1")
                            onEntered: parent.font.underline = true
                            onExited: parent.font.underline = false
                        }
                    }
                }
                
                Timer {
                    id: verCodeTimer
                    interval: 1000
                    repeat: true
                    onTriggered: {
                        verButton.enabled = false
                        console.log(verCodeTime)
                        if (verCodeTime < 0) {
                            verButton.enabled = true
                            verButton.text = catalog.i18nc("@text:btn", "Get Code")
                            verCodeTimer.stop()
                            verCodeTime = 60
                            return
                        }
                        verButton.text = verCodeTime + "s"
                        verCodeTime --
                    }
                }
            }

            Item {
                id: qrItem
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: 10
                z: 2
                visible: false

                property int expireTime: 0
                property bool requestSwitch: false

                Rectangle {
                    color: "white"
                    anchors.fill: parent
                }

                Timer {
                    id: qrTimer
                    interval: 2000
                    repeat: true
                    onTriggered: {
                        console.log("expired: ", qrItem.expireTime-CloudAPI.timestamp())
                        if (CloudAPI.timestamp() > qrItem.expireTime) {
                            // Qr code expired, display refresh button
                            refreshItemShow()
                            qrTimer.stop()
                            return
                        }
                        // Poll to check whether the qr code is scanned
                        if (qrItem.requestSwitch === false) {
                            qrItem.requestSwitch = true
                            CloudAPI.qrQuery(function(data) {
                                if (data["code"] === 0) {
                                    if (data["result"]["state"] === 3) {
                                        qrTimer.stop()
                                        loginScuess(data["result"]["token"], data["result"]["userId"])                                      
                                    }
                                }else {
                                    CloudUtils.qmlLog(JSON.stringify(data))
                                }
                                qrItem.requestSwitch = false
                            })
                        }
                    }
                }

                Image {
                    source: "../res/back.png"
                    anchors.left: parent.left
                    anchors.leftMargin: 0
                    anchors.top: parent.top
                    anchors.topMargin: 30
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            qrItemHidden()
                            scanQrcodeLoginLabel.btnSelected = false
                            switch (loginType) {
                                case "quick":
                                case "mobile":
                                    mobilephoneLoginLabel.btnSelected = true
                                    break
                                case "email":
                                    emailLoginLabel.btnSelected = true
                                    break;
                            }
                        }
                    }
                }

                Text {
                    id: qrLink
                    color: "#1987ea"
                    text: catalog.i18nc("@text:window", 'Download Creality Cloud APP')
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 25
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.underline: true
                    lineHeight: 1.4
                    font.family: "Tahoma"
                    font.pixelSize: 12
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Qt.openUrlExternally(CloudUtils.getWebUrl())
                    }
                }

                Text {
                    id: qrText_1
                    text: catalog.i18nc("@text:window", "Scan the code to log in")
                    anchors.top: parent.top
                    anchors.topMargin: 10
                    horizontalAlignment: Text.AlignHCenter
                    anchors.horizontalCenter: parent.horizontalCenter
                    font.family: "Tahoma"
                    font.bold: true
                    font.pixelSize: 24
                }

                Text {
                    id: qrText_2
                    text: catalog.i18nc("@text:window", "Me section in app > Scan icon on top")
                    anchors.top: qrText_1.bottom
                    anchors.topMargin: 10
                    anchors.horizontalCenter: parent.horizontalCenter
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 13
                }

                Rectangle {
                    id: example
                    opacity: 0
                    width: 208
                    height: 187
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 95
                    anchors.right: parent.right
                    anchors.rightMargin: -20
                    Behavior on opacity {PropertyAnimation {duration: 300} }
                    Image {
                        anchors.fill: parent
                        source: "../res/example.png"
                        fillMode: Image.PreserveAspectFit
                    }
                }

                QRCode {
                    id: qrcode
                    width: 170
                    height: 170
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 80
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.horizontalCenterOffset: 0
                    Behavior on anchors.horizontalCenterOffset {PropertyAnimation {duration: 300} }

                    Rectangle {
                        id: refreshMask
                        color: "#000000"
                        anchors.fill: parent
                        z: 1
                        opacity: 0
                    }

                    MouseArea {
                        width: 170
                        anchors.leftMargin: -125
                        anchors.rightMargin: -133
                        hoverEnabled: true
                        anchors.fill: parent
                        onEntered: {qrcode.anchors.horizontalCenterOffset = -80; example.opacity = 1}
                        onExited: {qrcode.anchors.horizontalCenterOffset = 0; example.opacity = 0}
                    }

                    Item {
                        id: refreshItem
                        anchors.fill: parent
                        visible: true
                        z: 10

                        Button {
                            id: refreshBt
                            width: 77
                            height: 27
                            text: catalog.i18nc("@action:button", "Click the refresh")
                            anchors.bottom: parent.bottom
                            anchors.bottomMargin: 50
                            anchors.horizontalCenter: parent.horizontalCenter
                            onClicked: {
                                requestQrCode()
                            }
                        }

                        Text {
                            id: expireText
                            color: "#ffffff"
                            text: catalog.i18nc("@info:warning", "QR code has expired")
                            anchors.top: refreshBt.bottom
                            anchors.topMargin: 10
                            anchors.horizontalCenter: parent.horizontalCenter
                            font.family: "Tahoma"
                            font.bold: true
                            font.pixelSize: 14
                        }
                    }
                }
            }
        //busyLayer
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
    }


    Component.onCompleted: {
        console.log("login page init completed...")
        sigLoginSuccess.connect(CloudUtils.loginSuccess);
        mobilePhoneLogin()
        CloudAPI.os_version = CloudUtils.getOsVersion()
        CloudAPI.duid = CloudUtils.getDUID()
        CloudAPI.api_url = CloudUtils.getCloudUrl()
        var token = CloudUtils.loadToken()
        var userId = CloudUtils.getUserId()

        var env = CloudUtils.getEnv();
        if (env == "release_local"){
            idServer.currentIndex = 1
        }else{
            idServer.currentIndex = 0
        }

        if (token === "") {           
            CloudUtils.setLogin(false);
        }else {
            showBusy()
            CloudAPI.getUserInfo(token, userId, function(data) {
                hideBusy()
                if (data["code"] === 0) {
                    CloudUtils.setLogin(true);
                    pluginRootWindow.hide()
                    userImg = data["result"]["userInfo"]["base"]["avatar"]
                    userName = data["result"]["userInfo"]["base"]["nickName"]
                    //var userid = data["result"]["userInfo"]["base"]["userId"]

                    sigLoginSuccess(nextPage, userImg, userName, userId);
                    sigLoginRes(userImg, userName, userId)
                }else {                   
                    CloudUtils.setLogin(false);
                }
            })
        }
    }

    Component.onDestruction: {
        qrTimer.stop()
    }
}
}