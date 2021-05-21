import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

import "CloudAPI.js" as CloudAPI

// Scan the login page
Item {
    id: loginItem
    anchors.fill: parent
    width: 440
    height: 540

    property int expireTime: 0
    property bool requestSwitch: false

    QRCode {
        id: qrcode
        x: 132
        y: 229
        width: 176
        height: 170
        transformOrigin: Item.Center
        Behavior on x {PropertyAnimation {duration: 300} }

        Rectangle {
            id: refreshMask
            color: "#000000"
            anchors.fill: parent
            z: 1
            opacity: 0

        }

        MouseArea {
            anchors.leftMargin: -39
            anchors.rightMargin: -208
            hoverEnabled: true
            anchors.fill: parent
            onEntered: {qrcode.x = 50; example.opacity = 1}
            onExited: {qrcode.x = 132; example.opacity = 0}
        }

        Item {
            id: refreshItem
            visible: false
            z: 2

            Button {
                id: refreshBt
                x: 47
                y: 59
                width: 77
                height: 27
                text: qsTr("Refresh")
                onClicked: {
                    requestQrCode()
                }
            }

            Text {
                id: expireText
                x: 15
                y: 106
                color: "#ffffff"
                text: qsTr("QR code has expired")
                font.family: "Tahoma"
                font.bold: true
                font.pixelSize: 14
            }
        }
    }

    Rectangle {
        id: example
        opacity: 0
        Behavior on opacity {PropertyAnimation {duration: 300} }
        Image {
            x: 236
            y: 225
            width: 208
            height: 187
            source: "res/example.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    Timer {
        id: qrTimer
        interval: 2000
        repeat: true
        onTriggered: {
            console.log("expired: ", loginItem.expireTime-CloudAPI.timestamp())
            if (CloudAPI.timestamp() > loginItem.expireTime) {
                // Qr code expired, display refresh button
                refreshItemShow()
                qrTimer.stop()
                return
            }
            // Poll to check whether the qr code is scanned
            if (loginItem.requestSwitch === false) {
                loginItem.requestSwitch = true
                CloudAPI.qrQuery(function(data) {
                    if (data["code"] === 0) {
                        if (data["result"]["state"] === 3) {
                            console.log(JSON.stringify(data))
                            pluginRootWindow.showMessage("login success:" + data["result"]["token"])
                            pluginRootWindow.saveToken(data["result"]["token"], data["result"]["userId"])
                            qrTimer.stop()
                        }
                    }else {
                        CloudUtils.qmlLog(JSON.stringify(data))
                    }
                    loginItem.requestSwitch = false
                })
            }

        }
    }

    Text {
        id: qrText_1
        x: 81
        y: 107
        width: 278
        height: 33
        text: qsTr("Scan the code to log in")
        font.family: "Tahoma"
        font.bold: true
        font.pixelSize: 24
    }

    Text {
        id: qrText_2
        x: 94
        y: 153
        text: qsTr("Me section in app > Scan icon on top")
        font.pixelSize: 13
    }

    Text {
        id: qrLink
        x: 140
        y: 456
        width: 160
        height: 16
        color: "#1987ea"
        text: 'Download Creality Cloud APP'
        font.underline: true
        lineHeight: 1.4
        font.family: "Tahoma"
        font.pixelSize: 12
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: Qt.openUrlExternally("https://model.creality.com/")
        }
    }

    BorderImage {
        id: logo
        x: 20
        y: 17
        width: 34
        height: 34
        transformOrigin: Item.Center
        source: "res/logo.png"
    }

    Rectangle {
        id: logoBg
        x: 0
        y: 0
        width: 440
        height: 63
        color: "#0f2d79"
        z: -3
    }

    Text {
        id: logoText
        x: 68
        y: 22
        color: "#ffffff"
        text: qsTr("Creality Cloud")
        font.family: "Tahoma"
        font.pixelSize: 17
    }


    Component.onCompleted: {
        requestQrCode()

    }
    Component.onDestruction: {
        qrTimer.stop()
    }

    function requestQrCode() {
        pluginRootWindow.showBusy()
        CloudAPI.qrLogin(function(data) {
            if (data["code"] === 0) {
                CloudAPI.identical = data["result"]["identical"]
                loginItem.expireTime = data["result"]["expireTime"]
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

    function refreshItemShow() {
        refreshItem.visible = true
        refreshMask.opacity = 0.4
    }
    function refreshItemHiden() {
        refreshItem.visible = false
        refreshMask.opacity = 0
    }

}

