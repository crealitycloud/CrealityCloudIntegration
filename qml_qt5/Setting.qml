import QtQuick 2.2
import QtQuick.Controls 1.4
import UM 1.1 as UM
import Cura 1.1 as Cura

BasicDialog
{
    id: settingWindow
    UM.I18nCatalog { id: catalog; name: "uranium"}
    title: catalog.i18nc("@title:window", "Setting")
    width: 300
    height: 400

    Item {
        id: column
        anchors.rightMargin: 30
        anchors.leftMargin: 30
        anchors.bottomMargin: 40
        anchors.topMargin: 40
        anchors.fill: parent

        Row {
            id: row
            height: 40
            anchors.top: parent.top
            anchors.topMargin: 0
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.left: parent.left
            anchors.leftMargin: 0
            spacing: 10

            Text {
                id: set1
                text: catalog.i18nc("@title:Label", "Server")            
                font.family: "Tahoma"
                verticalAlignment: Text.AlignVCenter
                height: parent.height
                font.pixelSize: 15
                color: UM.Theme.getColor("text")
            }

            Cura.RadioButton {
                id: serverRadio1
                text: catalog.i18nc("@text:ComboBox", "International")
                height: parent.height
            }
            Cura.RadioButton {
                id: serverRadio2
                text: catalog.i18nc("@text:ComboBox", "China")
                height: parent.height
            }

        }
		Text
		{
			anchors.centerIn : parent
			text:catalog.i18nc("@title:Label", "Warning:\n The switch takes effect only\n after the software is restarted")   
			
		}

    }

    Button {
        id: okBtn
        width: 80
        text: catalog.i18nc("@text:btn", "OK")
        anchors.right: parent.right
        anchors.rightMargin: 40
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 20
        onClicked: {
            var env = ""
            if(serverRadio1.checked){
                env = "release_oversea"
            }else {
                env = "release_local"
            }

            CloudUtils.saveUrl(env)
            //CloudUtils.autoSetUrl()
            //CloudUtils.clearToken()
            //CloudUtils.setLogin(false)
            settingWindow.close();
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

