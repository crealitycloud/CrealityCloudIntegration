import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

import UM 1.1 as UM

Item{
    //property var modelimage: ""
    property var modelname: ""
    property var modelid: ""
    property var keystr: 0// number starts with 1
    property var modelcount: 0
    property var modellink: ""
    property var modeSize: ""
    property var btnIsSelected: false

    signal sigBtnDetailClicked(var key)
    signal sigDownModel(var name, var url)

    implicitWidth: 280
    implicitHeight: 36

    UM.I18nCatalog { id: catalog; name: "uranium"}

    Row{
        spacing: 20
        BasicButton{
            width: 160
            height: 36
            btnRadius: 0
            btnBorderW: 0
            pixSize: 12
            btnTextColor: btnIsSelected? "white" : "#666666"
            btnText.width: width-10
            defaultBtnBgColor: "#FFFFFF"
            hoveredBtnBgColor: "#E1E1E1"
            selectedBtnBgColor: "#1E9BE2"
            btnSelected: btnIsSelected
            text: modelname
            onSigButtonClicked:{
                sigBtnDetailClicked(modelid)
            }
        }
        Label{
            width: 80
            height: 36
            font.pixelSize: 12
            color: "#999999"
            clip :true
            verticalAlignment: Qt.AlignVCenter
            text: {
                if(modeSize > 1024*1024*1024)
                {
                    return Math.ceil(modeSize/(1024*1024*1024))+"GB"
                }
                else if(modeSize > 1024*1024)
                {
                    return Math.ceil(modeSize/(1024*1024))+"MB"
                }
                else if(modeSize > 1024)
                {
                    return Math.ceil(modeSize/1024)+"KB"
                }
                else
                {
                    return modeSize+"B"
                }
            }    
        }
        BasicSkinButton{
            anchors.verticalCenter: parent.verticalCenter
            width:14; height:17
            imgW:width; imgH:height;
            tipText: catalog.i18nc("@Tip:Button", "Import")
            visible: btnIsSelected
            btnImgNormal: "../res/btn_download.png"
            btnImgHovered: "../res/btn_download_h.png"
            btnImgPressed: "../res/btn_download_h.png"
            onClicked:
            {
                sigDownModel(modelname, modellink)
            }
        }
    }
}