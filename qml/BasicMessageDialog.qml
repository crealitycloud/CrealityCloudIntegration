import QtQuick 2.10
import QtQuick.Controls 2.3
import UM 1.1 as UM
import Cura 1.6 as Cura

BasicDialog
{
    id: base

    signal accept()
    signal cancel()

    property var btnCount : 1
    property var mytitle: catalog.i18nc("@Tip:title", "Tip")
    property var mysource: "../res/warning.png"
    property var myContent: ""
    property var okbtnText: catalog.i18nc("@action:button","OK");
    property var cancelbtnText: catalog.i18nc("@action:button","Cancel");

    width: 221
    height: 114
    visible: false
    title: mytitle
    contentBackground: UM.Theme.getColor("message_background")
    
    Item
    {
        anchors.fill: parent
        UM.I18nCatalog { id: catalog; name: "uranium"}
        Image {
            id: image
            width: 32
            height: 32
            source: mysource
            fillMode: Image.PreserveAspectFit
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter           
        }
        Label
        {
            anchors.left: image.right
            anchors.leftMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter
            horizontalAlignment: Text.AlignHCenter
            text: myContent
            wrapMode: Text.WordWrap
            font: UM.Theme.getFont("default")   
            color: UM.Theme.getColor("text")
            renderType: Text.NativeRendering
        }
        Row {
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 5
            anchors.right: parent.right
            anchors.rightMargin: 5
            width: parent.width/2
            spacing: 5
            Rectangle {
                width: btnCount == 2 ? parent.width - (okbtn.width+cancelbtn.width+5*btnCount) :
                        parent.width - (okbtn.width+5*btnCount)
                height: 1
                color: "transparent"
            }
            Cura.PrimaryButton
            {
                id:okbtn           
                text: okbtnText
                onClicked: { accept()}
                visible: true            
            }
            Cura.PrimaryButton
            {
                id:cancelbtn        
                text: cancelbtnText
                onClicked: { cancel()}
                visible: btnCount == 2 ? true : false
            }
        }
    }
}