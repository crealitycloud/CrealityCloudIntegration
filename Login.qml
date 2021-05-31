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
                text: catalog.i18nc("@action:button", "Click the refresh")
                onClicked: {
                    requestQrCode()
                }
            }

            Text {
                id: expireText
                x: 15
                y: 106
                color: "#ffffff"
                text: catalog.i18nc("@info:warning", "QR code has expired")
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
                            pluginRootWindow.saveToken(data["result"]["token"], data["result"]["userId"])
                            qrTimer.stop()
                            bodyLoader.source = "Options.qml"
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
        width: 742
        height: 33
        text: catalog.i18nc("@text:window", "Scan the code to log in")
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
        font.family: "Tahoma"
        font.bold: true
        font.pixelSize: 24
    }

    Text {
        id: qrText_2
        x: 94
        y: 153
        text: catalog.i18nc("@text:window", "Me section in app > Scan icon on top")
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 13
    }

    Text {
        id: qrLink
        x: 140
        y: 456
        width: 368
        height: 16
        color: "#1987ea"
        text: catalog.i18nc("@text:window", 'Download Creality Cloud APP')
        horizontalAlignment: Text.AlignHCenter
        anchors.horizontalCenter: parent.horizontalCenter
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

