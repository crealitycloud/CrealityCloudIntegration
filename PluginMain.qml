import QtQuick 2.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.1
import QtQml 2.2

import "CloudAPI.js" as CloudAPI

Window {
    id: pluginRootWindow
    visible: false
    width: 440
    height: 540
    modality: Qt.ApplicationModal
    minimumWidth: width
    minimumHeight: height
    maximumWidth: width
    maximumHeight: height

    title: qsTr("Creality Cloud Plugin")

    property string token: ""
    property string userId: ""

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
        
        Loader {
            id: bodyLoader
            anchors.fill: parent
           // source: "Login.qml"
            
        }
    }
    Component.onCompleted: {
        CloudAPI.os_version = CloudUtils.getOsVersion()
        CloudAPI.duid = CloudUtils.getDUID()
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
    onClosing: {
        bodyLoader.source = ""
    }
}