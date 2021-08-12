import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Templates 2.2 as T
import QtQuick.Controls.Styles 1.4

import "../js/CloudAPI.js" as CloudAPI
import "../js/CountryCode.js" as CountryCode
import "../js/Validator.js" as Validator

// Scan the login page
Item {
    id: loginItem
    anchors.fill: parent

    Item {
        id: accountLogin
        anchors.leftMargin: 96
        anchors.rightMargin: 95
        anchors.topMargin: 0
        anchors.bottomMargin: 0        
        anchors.fill: parent

        property string loginType: ""
        property string phoneLoginType: "quick";
        property bool showPassWord: false;
        property int verCodeTime: 60


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
                text: qsTr("Email Login")
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
                        accountLogin.switchEmailLogin()                        
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
                text: qsTr("Mobile Phone Login")
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
                        accountLogin.mobilePhoneLogin();                     
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
                text: qsTr("Scan Qrcode Login")
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
                placeholderText: qsTr("Please enter mobile number")
                onTextChanged: accountLogin.fieldValidator()
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
                placeholderText: qsTr("Please enter your email address")
                onTextChanged: accountLogin.fieldValidator()
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
                echoMode: accountLogin.showPassWord ? TextInput.Normal : TextInput.Password
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
                placeholderText: qsTr("Please enter password")
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
                            accountLogin.showPassWord ? 
                            (eyeBtn.hovered ? "../res/login_pwdVisT_h.png" : "../res/login_pwdVisT.png") :
                            (eyeBtn.hovered ? "../res/login_pwdVisF_h.png" : "../res/login_pwdVisF.png")
                        }
                    }
                    onClicked:{
                        accountLogin.showPassWord = !accountLogin.showPassWord;
                    }
                }
                onTextChanged: accountLogin.fieldValidator()
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
                placeholderText: qsTr("Please enter verification code")
                onTextChanged: accountLogin.fieldValidator()
            }

            Label {
                id: mobileSwitchTypeLable
                text: qsTr("Password to login")
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
                        if(accountLogin.phoneLoginType === "quick")
                        {
                            mobileSwitchTypeLable.text = qsTr("Quick login")
                            accountLogin.phoneLoginType = "mobile";
                            accountLogin.switchPhoneLogin();
                        }
                        else if(accountLogin.phoneLoginType === "mobile")
                        {
                            mobileSwitchTypeLable.text = qsTr("Password to login")
                            accountLogin.phoneLoginType = "quick";
                            accountLogin.switchQuickLogin();                            
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
                text: qsTr("Get Code")
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
                text: qsTr("Forget Password?")
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
                text: qsTr("Login In")
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
                    //console.log("onSigButtonClicked loginClicked")
                    var mobile = phoneField.text
                    var countryCode = phoneSelectModel.get(phoneSelect.currentIndex).phone
                    var mobileVerCode = verCode.text
                    var email = emailField.text
                    var password = passwordField.text

                    switch(accountLogin.loginType) {
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
                text: qsTr("Server")
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
                    ListElement{name: "International"}
                    ListElement{name: "China"}
                }
                currentIndex : -1
                onActivated: {
                    //console.log("currentIndex changed --------",currentIndex);
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
            }

            Text {
                id: signUpTip1
                text: "No account? Please click "
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 22//52
                anchors.right: parent.right
                anchors.rightMargin: signUpTip2.width
                color: "#333333"
                font.family: "Source Han Sans CN Normal"
                font.pixelSize: 12
            }

            Text {
                id: signUpTip2
                text: "Sign Up"
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
                console.log(accountLogin.verCodeTime)
                if (accountLogin.verCodeTime < 0) {
                    verButton.enabled = true
                    verButton.text = qsTr("Get Code")
                    verCodeTimer.stop()
                    accountLogin.verCodeTime = 60
                    return
                }
                verButton.text = accountLogin.verCodeTime + "s"
                accountLogin.verCodeTime --
            }
        }

        function cleanField() {
            phoneField.text = ""
            verCode.text = ""
            passwordField.text = ""
        }

        function switchQuickLogin() {
            accountLogin.loginType = "quick"
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
            signUpTip1.anchors.bottomMargin = 22;
        }
        function switchPhoneLogin() {
            accountLogin.loginType = "mobile"
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
            signUpTip1.anchors.bottomMargin = 22;
        }
        function mobilePhoneLogin() {
            if(accountLogin.phoneLoginType === "quick")
            {
                accountLogin.switchQuickLogin();
            }
            else if(accountLogin.phoneLoginType === "mobile")
            {
                accountLogin.switchPhoneLogin();
            }
        }
        function switchEmailLogin() {
            accountLogin.loginType = "email"
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
            signUpTip1.anchors.bottomMargin = 52;
        }
        function fieldValidator() {
            let v = new Validator.Validator()
            let countryCode = phoneSelectModel.get(phoneSelect.currentIndex).phone
            let mobile = phoneField.text
            let code = verCode.text
            let password = passwordField.text
            let email = emailField.text
            switch (accountLogin.loginType) {
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
                    qrItem.refreshItemShow()
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
                    switch (accountLogin.loginType) {
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
                        qrItem.requestQrCode()
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
                    qrItem.refreshItemHiden()
                }else {
                    pluginRootWindow.showMessage("Error: " + JSON.stringify(data))
                }
                pluginRootWindow.hideBusy()
            })
        }

    }

    Component.onCompleted: {
        accountLogin.mobilePhoneLogin()
        var env = CloudUtils.getEnv();
        if (env == "release_local"){
            idServer.currentIndex = 1
        }else{
            idServer.currentIndex = 0
        }
    }

    Component.onDestruction: {
        qrTimer.stop()
    }

    function qrItemShow() {
        qrItem.visible = true
        qrItem.requestQrCode()
    }
    function qrItemHidden() {
        qrItem.visible = false
        qrTimer.stop()
    }
    function loginScuess(token, userId) {
        pluginRootWindow.saveToken(token, userId)
        bodyLoader.source = "Options.qml"
    }

}

