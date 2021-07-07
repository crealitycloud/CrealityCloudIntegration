import QtQuick 2.2
import QtQuick.Window 2.2
import QtQuick.Controls 1.4

Window {
    id: settingWindow
    title: "Setting"
    modality: Qt.ApplicationModal
    width: 300
    height: 400

    Item {
        id: column
        anchors.rightMargin: 30
        anchors.leftMargin: 30
        anchors.bottomMargin: 40
        anchors.topMargin: 40
        anchors.fill: parent

        Text {
            id: title
            text: qsTr("Setting")
            font.family: "Verdana"
            font.bold: true
            font.pixelSize: 23
        }

        Item {
            id: row
            height: 40
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.left: parent.left
            anchors.leftMargin: 0

            Text {
                id: set1
                text: qsTr("Server")
                font.family: "Tahoma"
                verticalAlignment: Text.AlignVCenter
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 0
                anchors.top: parent.top
                anchors.topMargin: 0
                font.pixelSize: 15
            }

            ComboBox {
                id: serverSet
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.top: parent.top
                model: ["International server", "China server"]
            }

        }

    }

    Button {
        id: okBtn
        width: 80
        text: "OK"
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        onClicked: {
            var env = ""
            if (serverSet.currentIndex === 0) {
                env = "release_oversea"
            }else {
                env = "release_local"
            }

            CloudUtils.saveUrl(env)
            CloudUtils.autoSetUrl()
            pluginRootWindow.init()
            pluginRootWindow.settingWindow.close()
        }
    }

    onVisibleChanged: {
        if (CloudUtils.getEnv() === "release_local") {
            serverSet.currentIndex = 1
        }else {
            serverSet.currentIndex = 0
        }
    }

}

