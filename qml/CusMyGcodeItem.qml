import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

import UM 1.1 as UM

Item{
    id: idDelegateItem
    property var headImg: isSelected ? "../res/ellipse_s.png" : "../res/ellipse.png" 

    property var isSelected: idDelegateItem.ListView.isCurrentItem;
    property var isHovered: idBtn.hovered;

    signal sigBtnDownClicked(var url, var name)
    signal sigBtnPrtClicked(var url)
    signal sigBtnDelClicked(var gcodeId)

    implicitWidth: 1040
    implicitHeight: 46

    UM.I18nCatalog { id: catalog; name: "uranium"}

    Button{
        id: idBtn
        anchors.fill: parent
        onClicked:{
            idDelegateItem.ListView.view.currentIndex = index;
        }
        contentItem: Rectangle{
            anchors.fill: parent
            color: isSelected ? "#F1F1F1" : 
                    (idBtn.hovered ? "#F1F1F1" : "white")
            Flow{
                x: 40; y: 5;
                height: parent.height-10;
                spacing: 100
                Row{
                    spacing: 10
                    Rectangle{
                        id: idheadImg
                        width: 18; height: width
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
                        width: 36; height: width                   
                        anchors.verticalCenter: parent.verticalCenter
                        opacity: isSelected ? 0.5 : 1
                        Image{                       
                            anchors.fill: parent
                            mipmap: true
                            smooth: true
                            cache: false
                            asynchronous: true
                            fillMode: Image.PreserveAspectFit
                            sourceSize: Qt.size(parent.size, parent.size)
                            antialiasing: true
                            source: model.gcodeIcon
                        }
                    }
                    Label{
                        width: 300//72
                        height: 36
                        clip :true
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Qt.AlignVCenter
                        text: model.gcodeFilename
                        elide: Text.ElideRight
                        color: "#333333"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 12
                        font.weight: Font.Normal
                    }
                }
                Row{
                    spacing: 30
                    Label{
                        width: 72
                        height: 36
                        clip :true
                        anchors.verticalCenter: parent.verticalCenter
                        verticalAlignment: Qt.AlignVCenter
                        text: {
                            if(model.gcodeFileSize > 1024*1024*1024)
                            {
                                return Math.ceil(model.gcodeFileSize/(1024*1024*1024))+"GB"
                            }
                            else if(model.gcodeFileSize > 1024*1024)
                            {
                                return Math.ceil(model.gcodeFileSize/(1024*1024))+"MB"
                            }
                            else if(model.gcodeFileSize > 1024)
                            {
                                return Math.ceil(model.gcodeFileSize/1024)+"KB"
                            }
                            else
                            {
                                return model.gcodeFileSize+"B"
                            }
                        }
                        color: "#999999"
                        font.family: "Source Han Sans CN Normal"
                        font.pixelSize: 12
                        font.weight: Font.ExtraLight
                    }
                    BasicSkinButton{
                        anchors.verticalCenter: parent.verticalCenter
                        width:16; height:17
                        imgW:width; imgH:height;
                        visible: isSelected ? true : false
                        tipText: catalog.i18nc("@Tip:Button", "export")//导出Gcode
                        btnImgNormal: "../res/btn_download.png"
                        btnImgHovered: "../res/btn_download_h.png"
                        btnImgPressed: "../res/btn_download_h.png"
                        onClicked:{
                            console.log("export to platform")
                            sigBtnDownClicked(model.gcodeDownLink, model.gcodeFilename);
                        }
                    }
                    BasicSkinButton{
                        anchors.verticalCenter: parent.verticalCenter
                        width:16; height:17
                        imgW:width; imgH:height;
                        visible: false//isSelected ? true : false
                        tipText: catalog.i18nc("@Tip:Button", "print")//打印
                        btnImgNormal: "../res/btn_print.png"
                        btnImgHovered: "../res/btn_print_h.png"
                        btnImgPressed: "../res/btn_print_h.png"
                        onClicked:{
                            console.log("print")
                            sigBtnPrtClicked(model.gcodeDownLink);
                        }
                    }
                    BasicSkinButton{
                        anchors.verticalCenter: parent.verticalCenter
                        width:16; height:17
                        imgW:width; imgH:height;
                        visible: isSelected ? true : false
                        tipText: catalog.i18nc("@Tip:Button", "delete")//删除
                        btnImgNormal: "../res/btn_del.png"
                        btnImgHovered: "../res/btn_del_h.png"
                        btnImgPressed: "../res/btn_del_h.png"
                        onClicked:{
                            console.log("delete")
                            sigBtnDelClicked(model.gcodeID);
                        }
                    }
                }                                        
            }
        }
    }
}