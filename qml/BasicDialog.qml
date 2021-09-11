import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Window 2.2
import QtGraphicalEffects 1.0
import UM 1.3 as UM

Window {
    id: base
    width: 300
    height: 200
    property string title: ""
    property var titleBackground:  UM.Theme.getColor("main_window_header_background")
    property var contentBackground: "transparent"
    property var borderColor: UM.Theme.getColor("border")
    property var titleIcon: ""
    property var closeIcon: "../res/btn_close_n.png"
    property var titleHeight: 30
    property alias btnEnabled: closeButton.enabled

    flags: Qt.Dialog | Qt.FramelessWindowHint
    modality: Qt.ApplicationModal
    color: UM.Theme.getColor("main_background")

	signal dialogClosed()
    MouseArea {
        anchors.fill: parent
        focus: true
        onClicked: {
            focus = true
        }
    }
    
    Rectangle
    {
    	id: mainLayout
        anchors.fill: parent
		color: contentBackground
        opacity: 1
        border.color: borderColor
        border.width: 1
    }

    //The title bar
    Rectangle{
        id: titleBar
        x: 1
        y: 1
        width: mainLayout.width-2
        implicitHeight: titleHeight-1
        color: titleBackground
       
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
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("medium")
                anchors.left: parent.left
                anchors.leftMargin: 10 + idTitleImg.width
                anchors.verticalCenter: parent.verticalCenter
            }
            onPressed: {
                clickPos = Qt.point(mouse.x,mouse.y)
            }
            onPositionChanged: {
                var delta = Qt.point(mouse.x-clickPos.x, mouse.y-clickPos.y)
                //if mainwindow inherit QWidget, use setPos
                base.setX(base.x+delta.x)
                base.setY(base.y+delta.y)
            }
        }
        //close button
        Button{
            id: closeButton
            height: parent.height
            implicitWidth: 30
            anchors.right: parent.right
            onClicked: {
                base.visible = false;
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
}
