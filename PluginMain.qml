import QtQuick 2.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import QtQml 2.2
import UM 1.1 as UM
import "CloudAPI.js" as CloudAPI

Window {
    id: pluginRootWindow
    UM.I18nCatalog { id: catalog; name: "uranium"}
    visible: false
    width: 440
    height: 540
    modality: Qt.ApplicationModal
    minimumWidth: width
    minimumHeight: height
    maximumWidth: width
    maximumHeight: height

    title: catalog.i18nc("@title:window", "Creality Cloud Plugin")

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
            x: 0
            y: 0
            width: 440
            height: 63
            color: "#0f2d79"
            z: 2

            BorderImage {
                id: logo
                x: 20
                y: 17
                width: 34
                height: 34
                transformOrigin: Item.Center
                source: "res/logo.png"
            }

            Text {
                id: logoText
                x: 68
                y: 22
                color: "#ffffff"
                text: catalog.i18nc("@title:window", "Creality Cloud")
                font.family: "Verdana"
                font.pixelSize: 17
            }

            Text {
                id: testLabel
                x: 180
                y: 22
                color: "#ffffff"
                width: 40
                height: 19
                visible: CloudUtils.getEnv() === "test"
                text: qsTr("test")
                font.family: "Verdana"
                font.pixelSize: 12
            }
        }

        Loader {
            id: bodyLoader
            anchors.fill: parent
            // source: "Login.qml"

        }
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
        if (CloudUtils.getEnv() == "release_local") {
            logoBg.color = "#77ACF1"
        }else {
            logoBg.color = "#04009A"
        }

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
