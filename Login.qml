import QtQuick 2.2
import QtQuick.Controls 2.3
import QtQuick.Controls.Styles 1.4

import "CloudAPI.js" as CloudAPI
import "CountryCode.js" as CountryCode
import "Validator.js" as Validator

// Scan the login page
Item {
    id: loginItem
    anchors.fill: parent
    width: 440
    height: 540

    Item {
        id: accountLogin
        anchors.rightMargin: 35
        anchors.leftMargin: 35
        anchors.bottomMargin: 35
        anchors.topMargin: 98
        anchors.fill: parent

        property string loginType: ""
        property int verCodeTime: 60

        Item {
            height: 260
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 75
            anchors.left: parent.left
            anchors.leftMargin: 0

            ComboBox {
                id: phoneSelect
                width: 150
                height: 40
                anchors.top: parent.top
                anchors.topMargin: 0
                down: true
                displayText: "+" + model.get(currentIndex).phone
                model: ListModel {id: "phoneSelectModel"}
                delegate: ItemDelegate{
                    text:  nameEn + " " +phone
                    font.letterSpacing: -1
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
                height: 40
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: phoneSelect.right
                anchors.leftMargin: 20
                anchors.top: parent.top
                anchors.topMargin: 0
                placeholderText: qsTr("Please enter mobile number")
                onTextChanged: accountLogin.fieldValidator()
            }

            TextField {
                id: emailField
                height: 40
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                placeholderText: qsTr("Please enter your email address")
                onTextChanged: accountLogin.fieldValidator()
            }

            TextField {
                id: passwordField
                height: 40
                anchors.top: phoneSelect.bottom
                anchors.topMargin: 24
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.right: parent.right
                anchors.rightMargin: 0
                echoMode: TextInput.Password
                placeholderText: qsTr("Please enter password")
                onTextChanged: accountLogin.fieldValidator()
            }

            TextField {
                id: verCode
                width: 250
                height: 40
                anchors.top: phoneSelect.bottom
                anchors.topMargin: 24
                placeholderText: qsTr("Please enter verification code")
                onTextChanged: accountLogin.fieldValidator()
            }


            Button {
                id: verButton
                height: 40
                text: qsTr("Get Code")
                anchors.left: verCode.right
                anchors.leftMargin: 20
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.top: phoneSelect.bottom
                anchors.topMargin: 24
                enabled: false
                onClicked: {
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


            Button {
                id: loginButton
                height: 40
                text: qsTr("Login In")
                anchors.right: parent.right
                anchors.rightMargin: 0
                anchors.left: parent.left
                anchors.leftMargin: 0
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 80
                enabled: false
                onClicked: {
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
        }

        Text {
            id: loginText1
            height: 24
            text: qsTr("Log In")
            font.bold: true
            font.family: "Tahoma"
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.left: parent.left
            anchors.leftMargin: 0
            font.pixelSize: 22
        }

        Text {
            id: loginText2
            text: "No account? Please click "
            anchors.left: parent.left
            anchors.leftMargin: 0
            font.family: "Verdana"
            anchors.top: loginText1.bottom
            anchors.topMargin: 24
            font.pixelSize: 16
        }

        Text {
            text: "Sign Up"
            anchors.left: loginText2.right
            anchors.leftMargin: 0
            anchors.top: loginText1.bottom
            anchors.topMargin: 24
            font.family: "Verdana"
            font.pixelSize: 16
            color: "#1987ea"
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: Qt.openUrlExternally(CloudUtils.getWebUrl() + "/?signup=1")
            }
        }

        Flow {
            height: 15
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 0
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 0

            Text {
                id: mobileLoginLable
                text: qsTr("Mobile Login")
                font.wordSpacing: -0.5
                font.letterSpacing: -1
                font.capitalization: Font.MixedCase
                font.pixelSize: 13
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: accountLogin.switchPhoneLogin()
                    onEntered: {
                        parent.color = "#1987ea"
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.color = "black"
                        parent.font.underline = false
                    }
                }
            }

            Text {
                text: qsTr(" | ")
                font.pixelSize: 13
            }

            Text {
                id: mobileQuickLoginLabel
                text: qsTr("Mobile Quick Login")
                font.wordSpacing: -0.5
                font.letterSpacing: -1
                font.pixelSize: 13
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: accountLogin.switchQuickLogin()
                    onEntered: {
                        parent.color = "#1987ea"
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.color = "black"
                        parent.font.underline = false
                    }
                }
            }

            Text {
                text: qsTr(" | ")
                font.pixelSize: 13
            }

            Text {
                id: emailLoginLabel
                text: qsTr("Email Login")
                font.wordSpacing: -0.5
                font.letterSpacing: -1
                font.pixelSize: 13
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: accountLogin.switchEmailLogin()
                    onEntered: {
                        parent.color = "#1987ea"
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.color = "black"
                        parent.font.underline = false
                    }
                }
            }

            Text {
                text: qsTr(" | ")
                font.pixelSize: 13
            }

            Text {
                text: qsTr("Scan Qrcode Login")
                font.wordSpacing: -0.5
                font.letterSpacing: -1
                font.pixelSize: 13
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: qrItemShow()
                    onEntered: {
                        parent.color = "#1987ea"
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.color = "black"
                        parent.font.underline = false
                    }
                }
            }

            Text {
                text: qsTr(" | ")
                font.pixelSize: 13
            }

            Text {
                text: qsTr("Setting")
                font.wordSpacing: -0.5
                font.letterSpacing: -1
                font.pixelSize: 13
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if(!pluginRootWindow.settingWindow){
                            var component = Qt.createComponent("Setting.qml")
                            pluginRootWindow.settingWindow = component.createObject(pluginRootWindow)
                        }
                        pluginRootWindow.settingWindow.show()
                    }
                    onEntered: {
                        parent.color = "#1987ea"
                        parent.font.underline = true
                    }
                    onExited: {
                        parent.color = "black"
                        parent.font.underline = false
                    }
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
            emailField.visible = false
            passwordField.visible = false
            verCode.visible = true
            verButton.visible = true
            mobileQuickLoginLabel.font.bold = true
            mobileLoginLable.font.bold = false
            emailLoginLabel.font.bold = false
            cleanField()
        }
        function switchPhoneLogin() {
            accountLogin.loginType = "mobile"
            phoneSelect.visible = true
            phoneField.visible = true
            emailField.visible = false
            passwordField.visible = true
            verCode.visible = false
            verButton.visible = false
            mobileLoginLable.font.bold = true
            mobileQuickLoginLabel.font.bold = false
            emailLoginLabel.font.bold = false
            cleanField()
        }
        function switchEmailLogin() {
            accountLogin.loginType = "email"
            phoneSelect.visible = false
            phoneField.visible = false
            emailField.visible = true
            passwordField.visible = true
            verCode.visible = false
            verButton.visible = false
            emailLoginLabel.font.bold = true
            mobileLoginLable.font.bold = false
            mobileQuickLoginLabel.font.bold = false
            cleanField()
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
                    if (v.required(countryCode) && v.required(mobile)) {
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
                    if (v.required(countryCode) && v.required(mobile) && v.required(password)) {
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
        anchors.rightMargin: 30
        anchors.leftMargin: 30
        anchors.topMargin: 63
        anchors.fill: parent
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
            source: "res/back.png"
            anchors.left: parent.left
            anchors.leftMargin: 0
            anchors.top: parent.top
            anchors.topMargin: 30
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    qrItemHidden()
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
            anchors.topMargin: 80
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
                source: "res/example.png"
                fillMode: Image.PreserveAspectFit
            }
        }

        QRCode {
            id: qrcode
            width: 170
            height: 170
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100
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
        accountLogin.switchQuickLogin()
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

