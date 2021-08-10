import QtQuick 2.2
//import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import QtQml 2.2
import UM 1.1 as UM
import "../js/CloudAPI.js" as CloudAPI

BasicDialog {
    id: pluginRootWindow
    UM.I18nCatalog { id: catalog; name: "uranium"}
    visible: false
    width: 600
    height: 443  
    titleHeight: 30
    title: catalog.i18nc("@title:window", "Creality Cloud Plugin")
    closeIcon: "../res/btn_close_n.png"

    property string token: ""
    property string userId: ""
    property var settingWindow

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

    function saveToken(token, userId) {
        CloudUtils.saveToken(token, userId)
        pluginRootWindow.token = token
        pluginRootWindow.userId = userId
    }

    MessageDialog {
        id: msgDialog
        title: "Error"
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

            Text {
                id: testLabel
                anchors.left: logoText.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                color: "#ffffff"
                width: 40
                height: 19
                visible: CloudUtils.getEnv() === "test"
                text: qsTr("test")
                font.family: "Tahoma"
                font.pixelSize: 12
            }
        }

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

        Loader {
            id: bodyLoader
            anchors.fill: parent
            anchors.topMargin: 74
        }
    }
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border.width: 1
        border.color: "#42BDD8"
    }
    Component.onCompleted: {
        init()
    }
    onClosing: {
        bodyLoader.source = ""
    }
    function init() {
        CloudAPI.os_version = CloudUtils.getOsVersion()
        CloudAPI.duid = CloudUtils.getDUID()
        CloudAPI.api_url = CloudUtils.getCloudUrl()
        var token = CloudUtils.loadToken()
        var userId = CloudUtils.getUserId()

        if (token === "") {
            bodyLoader.source = "Login.qml"
        }else {
            showBusy()
            CloudAPI.getUserInfo(token, userId, function(data) {
                hideBusy()
                if (data["code"] === 0) {
                    bodyLoader.source = "Options.qml"
                }else {
                    bodyLoader.source = "Login.qml"
                }
            })
        }
    }
}
