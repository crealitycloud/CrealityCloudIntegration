import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

import UM 1.1 as UM

Item{
    id: idDelegateItem
    property var headImg: isSelected ? "../res/ellipse_s.png" : "../res/ellipse.png" 

    property var isSelected: idDelegateItem.ListView.isCurrentItem;
    property var isHovered: false

    signal sigBtnDownClicked(var url, var name)
    signal sigBtnPrtClicked(var url)
    signal sigBtnDelClicked(var gcodeId)

    width: 1040
    height: 46
    UM.I18nCatalog { id: catalog; name: "uranium"}

    Rectangle {
        id: backRect
        anchors.fill: parent
        color: isSelected ? "#F1F1F1" : 
                (isHovered ? Qt.lighter(UM.Theme.getColor("main_background")) 
                : UM.Theme.getColor("main_background"))
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: idDelegateItem.ListView.view.currentIndex = index;
            onEntered: isHovered = true
            onExited: isHovered = false
        }
    }

    Rectangle{
        id: idheadImg
        width: 18
        height: width
        anchors.left: parent.left
        anchors.leftMargin: 40
        anchors.verticalCenter: parent.verticalCenter
        border.color: isSelected ? "#42BDD8" : "#D7D7D7"
        radius: width/2
        Image{
            width: 8; height: width
            anchors.centerIn: parent
            source: headImg
        }
    }
    Rectangle{
        id: idGcodeIcon
        width: 36
        height: width 
        anchors.left: idheadImg.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        Image{                       
            anchors.fill: parent
            mipmap: true
            smooth: true
            cache: false
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            sourceSize: Qt.size(parent.size, parent.size)
            antialiasing: true
            source: gcodeIcon
        }
    }
    Label{
        id: idFilename
        width: 300
        height: 36
        clip :true
        anchors.left: idGcodeIcon.right
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        text: gcodeFilename
        elide: Text.ElideRight
        color: isSelected ? "black" : UM.Theme.getColor("text")
        font.family: "Source Han Sans CN Normal"
        font.pixelSize: 12
        font.weight: Font.Normal
    }
    
    Label{
        id: idFilesize
        width: 72
        height: 36
        clip :true
        anchors.left: idFilename.right
        anchors.leftMargin: 100
        anchors.verticalCenter: parent.verticalCenter
        verticalAlignment: Text.AlignVCenter
        text: {
            if(gcodeFileSize > 1024*1024*1024)
            {
                return Math.ceil(gcodeFileSize/(1024*1024*1024))+"GB"
            }
            else if(gcodeFileSize > 1024*1024)
            {
                return Math.ceil(gcodeFileSize/(1024*1024))+"MB"
            }
            else if(gcodeFileSize > 1024)
            {
                return Math.ceil(gcodeFileSize/1024)+"KB"
            }
            else
            {
                return gcodeFileSize+"B"
            }
        }
        color: isSelected ? "#333333" : UM.Theme.getColor("text")
        font.family: "Source Han Sans CN Normal"
        font.pixelSize: 12
        font.weight: Font.ExtraLight
    }

    Rectangle {
        id: btnDownload
        width: 16
        height: 17
        color: "transparent"
        anchors.left: idFilesize.right
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        visible: isSelected ? true : false
        property var btnHovered: false
        Image{
            width: parent.width
            height: parent.height
            visible: parent.visible
            source: parent.btnHovered ? 
                "../res/btn_download_h.png" :"../res/btn_download.png"
            anchors.centerIn: parent
        }
        ToolTip {
            visible: parent.btnHovered && String(text).length
            delay: 500
            text: catalog.i18nc("@Tip:Button", "Export")
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: sigBtnDownClicked(gcodeDownLink, gcodeFilename);
            onEntered: parent.btnHovered = true
            onExited: parent.btnHovered = false
        }
    }
    Rectangle {
        id: btnPrint
        width: 16
        height: 17
        color: "transparent"
        anchors.left: btnDownload.right
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        visible: false//isSelected ? true : false
        property var btnHovered: false
        Image{
            width: parent.width
            height: parent.height
            visible: parent.visible
            source: parent.btnHovered ? 
                "../res/btn_print_h.png" :"../res/btn_print.png"
            anchors.centerIn: parent
        }
        ToolTip {
            visible: parent.btnHovered && String(text).length
            delay: 500
            text: catalog.i18nc("@Tip:Button", "Print")
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: {}//sigBtnPrtClicked(gcodeDownLink);
            onEntered: parent.btnHovered = true
            onExited: parent.btnHovered = false
        }
    }
    Rectangle {
        id: btnDel
        width: 16
        height: 17
        color: "transparent"
        anchors.left: btnPrint.visible ? btnPrint.right : btnDownload.right
        anchors.leftMargin: 30
        anchors.verticalCenter: parent.verticalCenter
        visible: isSelected ? true : false
        property var btnHovered: false
        Image{
            width: parent.width
            height: parent.height
            visible: parent.visible
            source: parent.btnHovered ? 
                "../res/btn_del_h.png" :"../res/btn_del.png"
            anchors.centerIn: parent
        }
        ToolTip {
            visible: parent.btnHovered && String(text).length
            delay: 500
            text: catalog.i18nc("@Tip:Button", "Delete")
        }
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onClicked: sigBtnDelClicked(gcodeID);
            onEntered: parent.btnHovered = true
            onExited: parent.btnHovered = false
        }
    }
}