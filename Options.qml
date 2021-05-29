import QtQuick 2.2
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import QtQuick.Dialogs 1.1


import "CloudAPI.js" as CloudAPI

Item {
    id: sendViewRoot
    anchors.fill: parent
    width: 440
    height: 540

    TextField {
        id: fileNameField
        x: 125
        y: 140
        width: 274
        height: 23
        text: CloudUtils.defaultFileName()
    }

    Text {
        id: text_1
        x: 57
        y: 144
        text: qsTr("File Name")
        font.family: "Tahoma"
        font.pixelSize: 12
    }

    Button {
        id: logoutBt
        x: 59
        y: 450
        width: 68
        height: 35
        text: qsTr("Logout")
        onClicked: {
            CloudUtils.clearToken()
            bodyLoader.source = "Login.qml"
        }
    }

    Button {
        id: uploadBt
        x: 331
        y: 450
        width: 68
        height: 35
        text: qsTr("Upload")

        onClicked: {
            disconnectSlot()// Don't work?
            connectSlot()
            var fileName = fileNameField.text
            // File name cannot be empty
            if (fileName === "") {
                pluginRootWindow.showMessage("Error. File name is empty")
                return
            }
            // File name cannot have special symbols
            if (fileName.indexOf(":") !== -1 || fileName.indexOf('"') !== -1  || fileName.indexOf("|") !== -1 || fileName.indexOf("*") !== -1) {
                pluginRootWindow.showMessage("Error. File name can't contain \*, \"\", | , : symbols")
                return
            }
            CloudUtils.saveUploadFile(fileName)
        }
    }

    ProgressBar {
        id: progressBar
        x: 59
        y: 352
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
        x: 81
        y: 321
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
        x: 170
        y: 169
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
                statusImg.source = "res/upload.gif"
                break
            case "good":
                statusImg.source = "res/good.gif"
                progressBar.visible = false

                updateProgressText("File is uploaded !")
                disconnectSlot()  // Disconnecting until onClicked does not take effect.WHY? 
                break
            case "bad":
                updateProgressText("Upload failed !")
                statusImg.source = "res/bad.gif"
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
