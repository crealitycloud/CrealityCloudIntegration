import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1

import UM 1.1 as UM


Item{
    property var detailSelCategory: 1;
    property alias modelDetailImgList: idModelDetailListImage;
    property alias modelDetailItemList: idModelListItem;
    property alias idmodelImg: idDetailImage;
    property var modelName: ""//
    property var modelCount: ""//
    property var modelAImg: ""//
    property var modelAName: ""//

    signal sigReturn();
    signal sigDownloadAll();
    signal sigShareLink();
    signal sigAddModel();
    signal sigDelAll();

    id: idDetailPage
    anchors.fill: parent   

    Row{
        BasicSkinButton{
            width: 22; height: 32
            imgW:width; imgH:height;
            tipText: catalog.i18nc("@Tip:Button", "Return")
            btnImgNormal: "../res/btn_back.png"
            btnImgHovered: "../res/btn_back_h.png"
            btnImgPressed: "../res/btn_back_h.png"
            anchors.verticalCenter: parent.verticalCenter
            onClicked:{
                sigReturn();                
            }
        }
    }
    Row{
        spacing:10
        Column{
            spacing: 5
            Image{
                id: idDetailImage
                width: idDetailPage.width/2
                height: Math.min(idDetailPage.height/2, idDetailPage.width/2)
                asynchronous: true
                mipmap: true
                smooth: true
                cache: false
                fillMode: Image.PreserveAspectFit
                source: ""
            }
            ScrollView{
                width: (idDetailPage.width-10)/2
                height: 70
                ScrollBar.horizontal.policy: ScrollBar.AsNeeded
                clip : true
                Row
                {
                    id: idModelDetailListImage
                    spacing: 5
                }
            }
            Rectangle {
                width: idDetailPage.width/2
                height: idDetailPage.height/2 -70-32-10
                color: "transparent"
                Column {
                    spacing: 5
                    Row {
                        spacing: 5
                        Label {
                            id: idLicenseLabel
                            width: Math.ceil(contentWidth)
                            height: 30
                            text: catalog.i18nc("@title:Label", "Creative Commons License")
                            verticalAlignment: Text.AlignVCenter
                            font: UM.Theme.getFont("medium_bold")
                            renderType: Text.NativeRendering                
                            color: UM.Theme.getColor("text")
                        }

                        BasicCircularButton {
                            id : idLicenseExplain
                            anchors{                       
                                verticalCenter: parent.verticalCenter
                            }
                            btnImgN: "../res/model_license.png"
                            btnImgH: "../res/model_license_h.png"
                            onClicked: {
                                idLicenseDesDlg.visible = true
                            }
                        }
                    }
                    Label {
                        id: idLicenseDesLabel
                        width: 325
                        height: 15
                        text: catalog.i18nc("@title:Label", "Please check the copyright information in the description.")
                        font: UM.Theme.getFont("default")
                        renderType: Text.NativeRendering                
                        color: UM.Theme.getColor("text")
                    }
                }   
            }
        }                    
        Column{
            spacing: 5
            Label{
                id: idModelNameLabel
                width: (idDetailPage.width-10)/2
                height: 30
                text: modelName
                font: UM.Theme.getFont("large_bold")
                renderType: Text.NativeRendering                
                color: UM.Theme.getColor("text")
            }
            Label{
                id: idModelCountLabel
                width: (idDetailPage.width-10)/2
                height: 30
                text: modelCount
                font: UM.Theme.getFont("default")
                color: UM.Theme.getColor("text")
                renderType: Text.NativeRendering
            }
            Row{
                spacing: 10
                BasicCircularImage{
                    id: idAvtarImage
                    width: 60
                    height: 60
                    img_src: modelAImg
                }
                Label{
                    id: idAuthorName
                    width: idDelAllBtn.visible ? 
                            (idDetailPage.width-10)/2 - idAvtarImage.width - idImportAllBtn.width - idDelAllBtn.width - 20 :
                            (idDetailPage.width-10)/2 - idAvtarImage.width - idImportAllBtn.width- 20
                    height: 30
                    text: modelAName
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    clip :true
                    wrapMode: TextEdit.WordWrap
                    elide: Text.ElideRight
                    font: UM.Theme.getFont("large")
                    renderType: Text.NativeRendering
                    color: UM.Theme.getColor("text")
                }
                BasicSkinButton{
                    id: idImportAllBtn
                    width: 20; height: 22
                    imgW:width; imgH:height;
                    tipText: catalog.i18nc("@Tip:Button", "Import all")
                    btnImgNormal: "../res/btn_download.png"
                    btnImgHovered: "../res/btn_download_h.png"
                    btnImgPressed: "../res/btn_download_h.png"
                    onClicked:{
                        sigDownloadAll();
                    }
                }
                BasicSkinButton{
                    id: idSharedBtn
                    width: 20; height: 22
                    imgW:width; imgH:height;
                    tipText: catalog.i18nc("@Tip:Button", "Share link")
                    btnImgNormal: "../res/btn_share.png"
                    btnImgHovered: "../res/btn_share_h.png"
                    btnImgPressed: "../res/btn_share_h.png"
                    visible: detailSelCategory == 2 ? false : true;
                    onClicked:{
                        sigShareLink();
                    }
                }
                BasicSkinButton{
                    id: idAddBtn
                    width: 20; height: 22
                    imgW:width; imgH:height;
                    tipText: catalog.i18nc("@Tip:Button", "Upload models")
                    btnImgNormal: "../res/btn_add.png"
                    btnImgHovered: "../res/btn_add_h.png"
                    btnImgPressed: "../res/btn_add_h.png"
                    visible: detailSelCategory == 2 ? true : false;
                    onClicked:{
                        sigAddModel();
                    }
                }
                BasicSkinButton{
                    id: idDelAllBtn
                    width: 20; height: 22
                    imgW:width; imgH:height;
                    tipText: catalog.i18nc("@Tip:Button", "Delete all")
                    btnImgNormal: "../res/btn_del.png"
                    btnImgHovered: "../res/btn_del_h.png"
                    btnImgPressed: "../res/btn_del_h.png"
                    visible: detailSelCategory == 2 ? true : false;
                    onClicked:{
                        sigDelAll();
                    }
                }
            }
            Label{
                id: idModelListLabel
                width: idDetailPage.width/3
                height: 60
                text: catalog.i18nc("@info:label", "Model list:")
                verticalAlignment: Text.AlignBottom
                font: UM.Theme.getFont("medium")
                renderType: Text.NativeRendering
                color: UM.Theme.getColor("text")
            }
            ScrollView{
                width: (idDetailPage.width-10)/2
                height: idDetailPage.height - 197
                ScrollBar.vertical.policy: ScrollBar.AsNeeded
                clip : true
                Column{
                    id: idModelListItem
                }
            }
        }
    }
    LicenseDescriptionDlg{
        id:idLicenseDesDlg
        visible:false
    }
}