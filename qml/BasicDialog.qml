import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0

Window {
    id: eo_askDialog
    width: 300
    height: 200
    property string title: ""
    property string titleBackground:  "#42BDD8"
    property var titleIcon: ""
    property var closeIcon: "../res/btn_close_n.png"
    property var titleHeight: 30
    property alias btnEnabled: closeButton.enabled

    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: "transparent"

	signal dialogClosed()
    MouseArea {
        anchors.fill: parent
        focus: true
        onClicked: {
            focus = true
        }
    }
    
    Rectangle{//The title bar
        id: titleBar
        width: mainLayout.width
        implicitHeight: 30
        color: titleBackground
        z:mainLayout.z + 1
       
        MouseArea{
            id: mouseControler
            property point clickPos: "0,0"
            height: parent.height
            width: parent.width
            //title
            Image {
                id: idTitleImg
                anchors.left: parent.left
                anchors.leftMargin: 5
                source: titleIcon
                anchors.verticalCenter: parent.verticalCenter
            }
            Text{
                text: title
				font.family: "Source Han Sans CN Normal"
				font.weight: Font.Bold
				font.pixelSize: 14
                anchors.left: parent.left
                anchors.leftMargin: 10 + idTitleImg.width
                anchors.verticalCenter: parent.verticalCenter
                color: "#333333"
            }

            onPressed: {
                clickPos = Qt.point(mouse.x,mouse.y)
            }

            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                //if mainwindow inherit QWidget, use setPos
                eo_askDialog.setX(eo_askDialog.x+delta.x)
                eo_askDialog.setY(eo_askDialog.y+delta.y)
            }
        }

        //close button
        Button{
            id: closeButton
            height: parent.height
            implicitWidth: 30
            anchors.right: parent.right
            onClicked: {
                eo_askDialog.visible = false;
                //eo_askDialog.close();
				dialogClosed()
            }
            contentItem: Item
            {
                anchors.fill: parent
                Image
                {
                    anchors.centerIn: parent
                    width: 10
                    height: 10
                    source:  closeIcon
                }
            }

            background: Rectangle
            {
                anchors.fill: parent
                color: closeButton.hovered? "#E81123" : "transparent"
            }
        }    
    }

    Rectangle
    {
    	id: mainLayout
        anchors.fill: parent
		color: "white"
        opacity: 1      
    }
    DropShadow {
        anchors.fill: mainLayout
        radius: 8
        samples: 17
        source: mainLayout
        color:  "#42BDD8"
    }
}
