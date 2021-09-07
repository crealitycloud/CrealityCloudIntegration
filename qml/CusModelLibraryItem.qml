import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0

import UM 1.1 as UM

Item {
    id: basicButton
    width: 225
    height: 285

    UM.I18nCatalog { id: catalog; name: "uranium"}

    property var btnNameText: "name"
    property var btnAuthorText: "author"
    property var btnModelImage: ""
    property var btnAvtarImage: ""
    property var modelGroupId: ""
    property var modelCount: 0
    property alias btnDelVis: idBtnDel.visible

    property alias text: propertyButton.text
    property bool btnEnabled:true
    property bool btnSelected:false
    property color defaultBtnBgColor: "white"
    property color hoveredBtnBgColor: "#F0E1C9"
    property color selectedBtnBgColor: "blue"
    property color btnTextColor: "black"

    property var btnRadius: 0
    property var btnBorderW: 1
    property var pixSize: 14
    property alias hovered: propertyButton.hovered
    property alias down: propertyButton.down

    signal sigButtonClicked(var id, var name, var count, var author, var avtar)
    signal sigButtonDownClicked(var groupid, var count)
    signal sigBtnDelClicked(var groupid)

    Button {
        id : propertyButton
        width: parent.width
        height: parent.height
        font.family: "Source Han Sans CN Normal"
        font.weight: Font.Normal
        font.pixelSize: pixSize
        contentItem: Item {
                Column{
                    spacing: 5
                    width: propertyButton.width
                    Image{
                        id: idModelImage
                        width: propertyButton.width-15
                        height: width
                        asynchronous: true
                        mipmap: true
                        smooth: true
                        cache: false
                        fillMode: Image.PreserveAspectFit
                        source: btnModelImage
                    }
                    
                    Label{
                        width: 147
                        height: 12
                        clip :true
                        text: btnNameText                      
                        font.pixelSize: 12
                        color: "#333333"
                    }
                    
                    Row{
                        spacing: 5
                        BasicCircularImage{
                            id: idAvtarImage
                            width: 24
                            height: 24
                            img_src: btnAvtarImage
                        }
                        Label{
                            width: idBtnDel.visible == true ? 
                                    propertyButton.width - idAvtarImage.width - idBtnImport.width - idBtnDel.width - 30 :
                                    propertyButton.width - idAvtarImage.width - idBtnImport.width - 30
                            height: 11
                            clip :true
                            verticalAlignment: Text.AlignVCenter
                            anchors.verticalCenter: parent.verticalCenter
                            text: btnAuthorText                      
                            font.pixelSize: 14
                            color: "#333333"
                        }

                        BasicSkinButton{
                            id: idBtnImport
                            width: 20; height: 22
                            imgW:width-2; imgH:height-2;
                            tipText: catalog.i18nc("@Tip:Button", "Import all")
                            btnImgUrl: "../res/btn_download.png"
                            onClicked:
                            {	
                                sigButtonDownClicked(modelGroupId, modelCount)
                            }
                        }
                        BasicSkinButton{
                            id: idBtnDel
                            width: 20; height: 22
                            imgW:width-2; imgH:height-2;
                            tipText: catalog.i18nc("@Tip:Button", "Delete all")
                            btnImgUrl: "../res/btn_del.png"
                            visible: false
                            onClicked:
                            {	
                                sigBtnDelClicked(modelGroupId);
                            }
                        }
                    }
                }
        }

        background: Rectangle {
            implicitWidth: parent.width
            implicitHeight: parent.height
            radius: btnRadius
            opacity: enabled ? 1 : 0.3
            color: {
                if(btnSelected)
                {
                  return selectedBtnBgColor
                }
               return propertyButton.hovered ?hoveredBtnBgColor:defaultBtnBgColor
            }
            border.width: btnBorderW
            border.color: propertyButton.hovered? hoveredBtnBgColor : "#757575"
        }
        onClicked:
        {
            sigButtonClicked(modelGroupId, btnNameText, modelCount, btnAuthorText, btnAvtarImage)
        }
    }
}

