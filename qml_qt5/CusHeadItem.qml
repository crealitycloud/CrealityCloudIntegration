import QtQuick 2.10
import QtQuick.Controls 2.3
import UM 1.1 as UM
import Cura 1.1 as Cura
import "../js/CloudAPI.js" as CloudAPI
import "../js/CountryCode.js" as CountryCode
import "../js/Validator.js" as Validator

Item{
    property alias currentIndex: idServer.currentIndex
    anchors.top: parent.top
    anchors.left: parent.left
    anchors.right: parent.right
    height: 74
    UM.I18nCatalog { id: catalog; name: "uranium"}
    //logo
    Rectangle {
        id: logoBg           
        width: parent.width
        height: 73
        color: UM.Theme.getColor("main_background")
        z: 2
        Rectangle{
            width: 400
            height: 73
            color: "transparent"
            anchors.horizontalCenter: parent.horizontalCenter
            BorderImage {
                id: logo
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
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
                text: catalog.i18nc("@title:window", "Creality Cloud")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("huge")
                renderType: Text.NativeRendering            
                Component.onCompleted: {
                    font.bold = true
                }
            }
            
            Text {
                id: serverText
                anchors.right: idServer.left
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                text: catalog.i18nc("@title:window", "Server")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                renderType: Text.NativeRendering            
                Component.onCompleted: {
                    font.bold = true
                }
            }

            Cura.ComboBox {
                id: idServer
                anchors.right: parent.right
                anchors.leftMargin: 8
                anchors.verticalCenter: parent.verticalCenter
                width:100

                model: ListModel{
                    id: idServerModel
                }
                textRole: "name"
                currentIndex : -1
                onActivated: {
                    var env = ""
                    if (textAt(currentIndex) === idServerModel.get(0).name){
                        env = "release_oversea"
                    }else {
                        env = "release_local"
                    }
                    CloudUtils.saveUrl(env)
                    CloudUtils.autoSetUrl()
                    CloudAPI.api_url = CloudUtils.getCloudUrl()
                }
                Component.onCompleted: {
                    idServerModel.append({"name": catalog.i18nc("@text:ComboBox", "International Server")})
                    idServerModel.append({"name": catalog.i18nc("@text:ComboBox", "China Server")})
                }
            }
        }       
    }
    //Separator
    Item {
        id: idSeparator
        anchors.top: logoBg.bottom;
        width:parent.width
        height: 1
        Rectangle
        {
            anchors.fill: parent
            color: "#ACACAC"
            opacity: 0.5
        }
    }
}