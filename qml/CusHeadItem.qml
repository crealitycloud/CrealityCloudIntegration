import QtQuick 2.10
import QtQuick.Controls 2.3
import UM 1.1 as UM

Item{
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
            width: logo.width+8+logoText.contentWidth
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