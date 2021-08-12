import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import UM 1.1 as UM

import "../js/CloudAPI.js" as CloudAPI
import "../js/Validator.js" as Validator

Item {
    id: sendViewRoot
    anchors.fill: parent

    property var v: new Validator.Validator()

    TextField {
        id: fileNameField
        x: 205
        y: 39
        width: 274
        height: 23
        text: CloudUtils.defaultFileName()
    }

    Text {
        id: text_1
        x: 137
        y: 43
        text: catalog.i18nc("@label", "File Name")
        font.family: "Tahoma"
        font.pixelSize: 12
    }

    Button {
        id: logoutBt
        x: 139
        y: 248
        width: 68
        height: 35
        text: catalog.i18nc("@action:button", "Logout")
        onClicked: {
            CloudUtils.clearToken()
            bodyLoader.source = "Login.qml"
        }
    }

    Button {
        id: uploadBt
        x: 411
        y: 248
        width: 68
        height: 35
        text: catalog.i18nc("@action:button", "Upload")

        onClicked: {
            disconnectSlot()// Don't work?
            connectSlot()
            var fileName = fileNameField.text
            // File name cannot be empty
            if (!v.required(fileName) || fileName.indexOf(' ') !== -1) {
                pluginRootWindow.showMessage(catalog.i18nc("@error", "File name cannot be empty"))
                return
            }
            // File name cannot have special symbols
            if (fileName.indexOf(":") !== -1 || fileName.indexOf('"') !== -1  || fileName.indexOf("|") !== -1 || fileName.indexOf("*") !== -1) {
                pluginRootWindow.showMessage(catalog.i18nc("@error", "File name can't contain \*, \"\", | , : symbols"))
                return
            }
            CloudUtils.saveUploadFile(fileName)
        }
    }

    ProgressBar {
        id: progressBar
        x: 139
        y: 251
        width: 340
        height: 15
        minimumValue: 0
        maximumValue: 100
        visible: false
        style: ProgressBarStyle {
            background: Rectangle {
                radius: 2
                color: "white"
                border.color: "gray"
                border.width: 1
            }

            progress: Rectangle {
                color: "#0f2d79"
                border.color: "gray"
                border.width: 1
            }
        }
    }

    Text {
        id: progressText
        x: 161
        y: 220
        width: 297
        height: 25
        visible: false
        font.bold: false
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pixelSize: 15
    }

    AnimatedImage {
        id: statusImg
        x: 250
        y: 68
        width: 100
        height: 100
        fillMode: Image.PreserveAspectFit
        visible: false
    }

    //upload,good,bad. Information display for switching between different states
    function updateStatus(status) {
        switch (status) {
            case "upload":
                statusImg.visible = true
                progressText.visible = true
                progressBar.visible = true
                fileNameField.visible = false
                text_1.visible = false
                logoutBt.visible = false
                uploadBt.visible = false
                statusImg.source = "../res/upload.gif"
                break
            case "good":
                statusImg.source = "../res/good.gif"
                progressBar.visible = false

                updateProgressText(catalog.i18nc("@info:status", "File is uploaded !"))
                disconnectSlot()  // Disconnecting until onClicked does not take effect.WHY? 
                break
            case "bad":
                updateProgressText(catalog.i18nc("@info:status", "Upload failed !"))
                statusImg.source = "../res/bad.gif"
                progressBar.visible = false
                disconnectSlot()
                break
        }
    }

    function progress(per) {
        console.log("progress bar", per)
        if(per >= 0) {
            progressBar.value = per * 100
        }

    }

    function updateProgressText(message) {
        progressText.text = message
    }

    function connectSlot() {
        CloudUtils.updateProgressText.connect(updateProgressText)
        CloudUtils.updateProgress.connect(progress)
        CloudUtils.updateStatus.connect(updateStatus)
    }

    function disconnectSlot() {
        CloudUtils.updateProgressText.disconnect(updateProgressText)
        CloudUtils.updateProgress.disconnect(progress)
        CloudUtils.updateStatus.disconnect(updateStatus)
    }

    Component.onCompleted: {
        fileNameField.text = CloudUtils.defaultFileName()
        CloudUtils.qmlLog("defaultFileName: " + fileNameField.text)

    }
}
