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

        Row {
            id: row
            height: 40
            anchors.top: title.bottom
            anchors.topMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.left: parent.left
            anchors.leftMargin: 0
            spacing: 10

            Text {
                id: set1
                text: qsTr("Server")
                font.family: "Tahoma"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                font.pixelSize: 15
            }

            ExclusiveGroup{id: mos}
            RadioButton {
                id: serverRadio1
                exclusiveGroup: mos
                text: "International"
                height: parent.height
            }
            RadioButton {
                id: serverRadio2
                exclusiveGroup: mos
                text: "China"
                height: parent.height
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
            if (mos.current.text === "International") {
                env = "release_oversea"
            }else {
                env = "release_local"
            }

            CloudUtils.saveUrl(env)
            CloudUtils.autoSetUrl()
            //pluginRootWindow.init()
            close();//pluginRootWindow.settingWindow.close()
        }
    }

    onVisibleChanged: {
        if (CloudUtils.getEnv() === "release_local") {
            serverRadio2.checked = true
        }else {
            serverRadio1.checked = true
        }
    }

}

