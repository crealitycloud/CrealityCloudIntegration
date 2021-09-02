import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1
import UM 1.1 as UM

import "../js/CloudAPI.js" as CloudAPI
import "../js/Validator.js" as Validator

BasicDialog {
    id: sendViewRoot
    UM.I18nCatalog { id: catalog; name: "uranium"}
    visible: false
    width: 600
    height: 443  
    titleHeight: 30
    title: catalog.i18nc("@title:window", "Creality Cloud Plugin")
    property var v: new Validator.Validator()
    //upload,good,bad. Information display for switching between different states
    function updateStatus(status) {
        switch (status) {
            case "upload":
                statusImg.visible = true
                progressText.visible = true
                progressBar.visible = true
                fileNameField.visible = false
                text_1.visible = false
                uploadBt.visible = false
                logoutBt.visible = false
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

    function showMessage(text) {
        msgDialog.text = text;
        msgDialog.visible = true
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

    Rectangle {
        id: rootRect
        anchors.fill: parent
        anchors.topMargin:titleHeight

        visible: false;
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

        Item {
            id: bodyLoader
            anchors.fill: parent
            anchors.topMargin: 74
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
                    //退出登录，返回
                    CloudUtils.setLogin(false);
                    close();
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
                        showMessage(catalog.i18nc("@error", "File name cannot be empty"))
                        return
                    }
                    // File name cannot have special symbols
                    if (fileName.indexOf(":") !== -1 || fileName.indexOf('"') !== -1  || fileName.indexOf("|") !== -1 || fileName.indexOf("*") !== -1) {
                        showMessage(catalog.i18nc("@error", "File name can't contain \*, \"\", | , : symbols"))
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

            MessageDialog {
                id: msgDialog
                title: "Error"
                icon: StandardIcon.Warning
                modality: Qt.ApplicationModal
                onAccepted: {
                    msgDialog.visible = false
                }
            }
        }
    }

    Component.onCompleted: {
        console.log("uploadgcode init completed-------")
        rootRect.visible = true;
        fileNameField.text = CloudUtils.defaultFileName()
        CloudUtils.qmlLog("defaultFileName: " + fileNameField.text)       
    }
}
