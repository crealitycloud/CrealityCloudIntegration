import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1
import UM 1.1 as UM
import Cura 1.1 as Cura

BasicDialog{
    id: idDialog
    width: 600
    height: 428
    titleHeight : 30
    UM.I18nCatalog { id: catalog; name: "uranium"}

    title: catalog.i18nc("@title:window", "Add Model")

    signal sigUploadModel(var fileList);

    function showMessage(text) {
        msgDialog.myContent = text;
        msgDialog.show()
    }

    function clearUI() {
        file_model.clear();
        idNumberLabel.text = "0/10"
    }

    onDialogClosed:
    {
        clearUI()
    }

    Item{
        id: idLogoImageColumn
        x: 1
        y: titleHeight
        width: parent.width-2
        height: 74
        CusHeadItem{
            id: headLogo
            anchors.fill: parent
        }
    }

    Item{
        id: grid_wrapper
        anchors.top: idLogoImageColumn.bottom  
        anchors.bottom: parent.bottom      
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 5
        anchors.bottomMargin: 5
        anchors.leftMargin: 1
        anchors.rightMargin:1
        Item{
            id: idHead
            width: parent.width
            height: 50
            Label {
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                width:100
                height:28
                text: catalog.i18nc("@title:Label", "select file")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            Label {
                id: idNumberLabel
                anchors.right: idAddBtn.left
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                text: "0/10"
            }
            BasicButton{
                id: idAddBtn
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                width: 125
                height: 28
                hoveredBtnBgColor: defaultBtnBgColor
                text: catalog.i18nc("@title:btn", "open")
                enabled: true
                onSigButtonClicked:{                    
                    openfileDialog.open()
                }
                FileDialog
                {
                    id: openfileDialog
                    title: catalog.i18nc("@title:window","Open file(s)")
                    modality: Qt.WindowModal
                    selectMultiple: true
                    nameFilters: [catalog.i18nc("@text:fileDialog", "stl files ")+"(*.stl *.STL)"]
                    folder: shortcuts.documents
                    onAccepted:
                    {
                        var fCount = fileUrls.length;
                        //Remove the prefix
                        var fList = [];
                        var filepath = ""
                        var prefix = "file:///"
                        for(var index=0; index < fCount; index++)
                        {
                            filepath = fileUrls[index]
                            filepath = filepath.substr(prefix.length)
                            fList.push(filepath)
                        }

                        //The number of uploaded files is less than 10
                        if(fCount > 10)
                        {
                            var info = catalog.i18nc("@Tip:content", "A maximum of 10 models can be uploaded at one time.");
                            showMessage(info)
                        }
                        else
                        {
                            file_model.clear();
                            var fileCount = 0;
                            //Remove files larger than 500 M
                            for(var index=0; index < fCount; index++)
                            {                         
                                var filesize = CloudUtils.getFileSize(fList[index]);
                                var newsize = Math.ceil(filesize/(1024*1024))
                                if(newsize <= 500){
                                    var file = CloudUtils.getFileName(fList[index]);
                                    fileCount++;
                                    file_model.append({filename: file, filesize: filesize, filepath: fList[index]})
                                }
                            }
                            idNumberLabel.text = "%1/10".arg(fileCount)
                        }
                    }                   
                }               
            }
        }
        Item{
            id: idFileList
            anchors.top: idHead.bottom
            anchors.topMargin: 5
            width: parent.width
            height: parent.height - idHead.height - idBtnGroup.height - 5
            ScrollView {
                id: idScrollView
                anchors.fill: parent
                ListView{
                    id: idFileListView
                    anchors.fill: parent
                    clip : true
                    focus: true
                    model: file_model
                    delegate: idViewDelegate
                }
                background: Rectangle{
                    color: "transparent"
                }             
            }
        }
        Row{
            id: idBtnGroup
            width: parent.width/2
            height: 50
            anchors.top: idFileList.bottom
            anchors.topMargin: 0
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 5
            BasicButton{
                width: 125
                height: 28
                hoveredBtnBgColor: defaultBtnBgColor
                anchors{
                    verticalCenter: parent.verticalCenter
                }
                text: catalog.i18nc("@text:btn", "Upload")
                fontWeight: Font.Bold
                enabled: file_model.count > 0
                onSigButtonClicked:{
                    var files = []
                    var n = file_model.count; 
                    for(var i = 0; i < n; i++){
                        files.push(file_model.get(i).filepath);
                    }
                    idDialog.close()
                    sigUploadModel(files);                    
                    clearUI()
                }            
            }
            BasicButton{
                width: 125
                height: 28
                hoveredBtnBgColor: defaultBtnBgColor
                anchors{
                    verticalCenter: parent.verticalCenter
                }
                text: catalog.i18nc("@text:btn", "Cancel")
                fontWeight: Font.Bold
                enabled: true
                onSigButtonClicked:{
                    idDialog.close()
                    clearUI();
                }            
            }
        }       
    }

    ListModel{
        id: file_model
    }
    Component{
        id: idViewDelegate
        Item{
            width: idFileListView.width
            height: 54
            Label{
                width: 200; height: 30
                text: filename
                anchors.left: parent.left
                anchors.leftMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                font: UM.Theme.getFont("default")
                renderType: Text.NativeRendering
                color: UM.Theme.getColor("text")
                
            }
            Label{
                width: 80; height: 30
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: idDelbtn.left
                anchors.rightMargin: 20
                text: {
                    if(filesize > 1024*1024*1024)
                    {
                        return Math.ceil(filesize/(1024*1024*1024))+"GB"
                    }
                    else if(filesize > 1024*1024)
                    {
                        return Math.ceil(filesize/(1024*1024))+"MB"
                    }
                    else if(filesize > 1024)
                    {
                        return Math.ceil(filesize/1024)+"KB"
                    }
                    else
                    {
                        return filesize+"B"
                    }
                }
                font: UM.Theme.getFont("default")
                renderType: Text.NativeRendering
                color: UM.Theme.getColor("text")
                
            }
            BasicSkinButton{
                id: idDelbtn
                anchors.verticalCenter: parent.verticalCenter
                anchors.right: parent.right
                anchors.rightMargin: 20
                width:14; height:17
                imgW:width; imgH:height;
                tipText: catalog.i18nc("@Tip:Button", "Delete")
                btnImgNormal: "../res/btn_del.png"
                btnImgHovered: "../res/btn_del_h.png"
                btnImgPressed: "../res/btn_del_h.png"
                onClicked:
                {
                    file_model.remove(index)
                    idNumberLabel.text = "%1/10".arg(file_model.count)
                }
            }
        }

    }
    BasicMessageDialog{
        id: msgDialog
        mytitle: catalog.i18nc("@Tip:title", "Tip")
        onAccept: {
            msgDialog.close()
        }
    }
}