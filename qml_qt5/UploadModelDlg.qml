import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.1
import QtGraphicalEffects 1.0
import UM 1.1 as UM
import Cura 1.1 as Cura
import "../js/Validator.js" as Validator

BasicDialog{
    id: idDialog
    width: 600
    height: 428
    titleHeight : 30
    UM.I18nCatalog { id: catalog; name: "uranium"}

    title: catalog.i18nc("@title:window", "Upload Model")

    property var saveWay: 1;
    property var categoryId:0
    property var groupName:""
    property var groupDesc:""
    property var bShare:false
    //property int modelType:1
    property var license:"";
    property var bIsOriginal:false;
    property var progressValue: 0.0
    property bool bRes: true

    onDialogClosed:
    {
        idModelGroupInput.text = ""
        idDescText.text = ""
        progressValue = 0
        idOriginalCheckBox.checked = false
        idLicenseCombobox.currentIndex = 0
        idShareCheckBox.checked = false
        idDialog.height = 428
        idLogoImageColumn.visible = true
        grid_wrapper.visible = true
        idBtnGroup.visible = true
        idprogressBar.visible = false
        idUploadSuccess.visible = false
    }

    function uploadModelSuccess()
    {
        idLogoImageColumn.visible = false
        grid_wrapper.visible = false
        idBtnGroup.visible = false
        idprogressBar.visible = false
        idUploadSuccess.visible = true
        bRes = true;
    }

    function uploadModelFail(info)
    {
        idLogoImageColumn.visible = false
        grid_wrapper.visible = false
        idBtnGroup.visible = false
        idprogressBar.visible = false
        idUploadSuccess.visible = true
        bRes = false;
        idFinishText.text = info
    }

    function insertListModeData(data){
        idGroupTypeModel.clear()
        idGroupTypeCombobox.currentIndex = 0
        var objectArray = JSON.parse(data);
        var objResult = objectArray.result.list;
        for ( var key in objResult ) {
            idGroupTypeModel.append({"key": objResult[key].id, "modelData": objResult[key].name})
        }
    }
    function showMessage(text) {
        msgDialog.myContent = text;
        msgDialog.show()
    }
    function checkFilename(name){
        //console.log("str:--",name,"--")
        var v = new Validator.Validator();
        var fileName = name;
        // File name cannot be empty
        if (!v.required(fileName)) {
            showMessage(catalog.i18nc("@error", "File name cannot be empty"))
            return false
        }
        // File name cannot have special symbols
        if (fileName.indexOf(":") !== -1 || fileName.indexOf('\"') !== -1  || fileName.indexOf("|") !== -1 || fileName.indexOf("*") !== -1) {
            showMessage(catalog.i18nc("@error", "File name can't contain *, | , \", : symbols"))
            return false
        }

        return true
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
    Column{
        id: grid_wrapper
        anchors.top: idLogoImageColumn.bottom
        anchors.topMargin: 25
        anchors.bottomMargin: 25
        anchors.left: parent.left
        anchors.leftMargin: 55
        anchors.rightMargin: 55
        width: idDialog.width - 2
        spacing: 5
        Row{
            Label {
                id: idGroupNameLabel
                width:100
                height:28
                text: catalog.i18nc("@title:Label", "Group Name:")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            TextField {
                id: idModelGroupInput
                selectByMouse: true
                font: UM.Theme.getFont("default")
                placeholderText: catalog.i18nc("@tip:textfield", "Please enter the model group name")
                width: grid_wrapper.width-idGroupNameLabel.width-110
                height : 28
                text: ""
                validator: RegExpValidator { regExp: /^\S{100}$/ }
            }
        }
        Row{
            Label {
                id: idGroupDescLabel
                width:100
                height:28
                text: catalog.i18nc("@title:Label", "Description:")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            ScrollView {
                id: idScrollView
                width: grid_wrapper.width-idGroupNameLabel.width-110
                height: 56
                TextArea {
                    id:idDescText
                    width: idScrollView.width
                    height:idScrollView.height
                    selectByMouse: true
                    wrapMode: TextEdit.Wrap
                    placeholderText: catalog.i18nc("@tip:textfield", "Please enter the model group description")
                    text: ""
                    font.pixelSize: 12
                    font.family: "Source Han Sans CN Normal"
                    font.weight: Font.Normal    
                    background: Rectangle {
                        border.color: "#D7D7D7"
                        color: "white"
                    }               
                }              
            }
        }
        Row{
            Label {
                id: idUploadWay
                width:100
                height:28
                text: catalog.i18nc("@title:Label", "Upload Way:")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            ButtonGroup{id: radioGroup}
            Cura.RadioButton {
                id: wayRadio1
                ButtonGroup.group: radioGroup
                text: catalog.i18nc("@title:Radio", "separate")
                checked: true
                anchors.verticalCenter: parent.verticalCenter
            }
            Cura.RadioButton {
                id: wayRadio2
                ButtonGroup.group: radioGroup
                text: catalog.i18nc("@title:Radio", "combination")
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Row{
            Label {
                id: idGroupType
                width:100
                height:28
                text: catalog.i18nc("@title:Label", "Group Type:")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            Cura.ComboBox {
                id: idGroupTypeCombobox
                height:25
                width: grid_wrapper.width-idGroupNameLabel.width-110
                font.pixelSize : 12
                currentIndex: -1
                model: ListModel {
                    id: idGroupTypeModel
                }
                textRole: "modelData"
            }
        }
        /*Row{
            Label {
                id: idModelType
                width:100
                height:28
                text: catalog.i18nc("@title:Label", "Model Type:")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            Cura.ComboBox {
                id: idModelTypeCombobox
                height:28
                width: grid_wrapper.width-idGroupNameLabel.width-110
                font.pixelSize : 12
                currentIndex: 0
                model: ListModel {
                    id: idModelTypeModel
                }
                textRole: "modelData"
                Component.onCompleted: {
                    idModelTypeModel.append({key: 1, modelData: catalog.i18nc("@title:Label", "Normal Model")})
                    idModelTypeModel.append({key: 2, modelData: catalog.i18nc("@title:Label", "3D Photo Model")})
                }
            }
        }*/
        Row{
            Label {
                width:100
                height:28
                color: "transparent"
            }
            Cura.CheckBox
            {
                id :idOriginalCheckBox
                width: 100
                height: 18
                text: catalog.i18nc("@title:checkbox", "Original")
                visible: true
                checked: false
                anchors.verticalCenter: parent.verticalCenter
                onCheckedChanged:
                {
                    if(idOriginalCheckBox.checked === true)
                    {
                        idDialog.height = 433 + idLicenseLabel.height
                    }
                    else{
                        idDialog.height = 428
                    }
                }
            }
            Cura.CheckBox
            {
                id :idShareCheckBox
                anchors.verticalCenter: parent.verticalCenter
                width: 100
                height: 18
                text: catalog.i18nc("@title:checkbox", "Share")
                visible: true
            }
        }
        Row{
            id: idLicenseRow
            spacing:4
            visible: idOriginalCheckBox.checked
            Label {
                id: idLicenseLabel
                width:100-4
                height:28
                text: catalog.i18nc("@title:Label", "License Type:")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("default")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            Cura.ComboBox{
                id: idLicenseCombobox
                height:28
                width: grid_wrapper.width-idGroupNameLabel.width-110
                font.pixelSize : 12
                currentIndex: 0
                model: ListModel {
                    id: idLicenseModel
                    ListElement{text : "CC BY";}
                    ListElement{text : "CC BY-SA";}
                    ListElement{text : "CC BY-NC";}
                    ListElement{text : "CC BY-NC-SA";}
                    ListElement{text : "CC BY-ND";}
                    ListElement{text : "CC BY-NC-ND";}
                    ListElement{text : "CC0 1.0";}
                }
                textRole: "text"
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
    }
    Row{
        id: idBtnGroup
        anchors{
            horizontalCenter: parent.horizontalCenter
        }
        anchors.top: grid_wrapper.bottom
        anchors.topMargin: 25
        spacing: 10
        BasicButton{
            width: 125
            height: 28
            hoveredBtnBgColor: defaultBtnBgColor
            text: catalog.i18nc("@text:btn", "Upload")
            fontWeight: Font.Bold
            enabled: (idModelGroupInput.text != "")&&(idDescText.text != "")           
            onSigButtonClicked:
            {
                if(!checkFilename(idModelGroupInput.text))
                    return;

                //if(!checkFilename(idDescText.text))
                //    return;
                
                idLogoImageColumn.visible = false
                grid_wrapper.visible = false
                idBtnGroup.visible = false
                idDialog.height = 223
                idprogressBar.visible = true
                idUploadSuccess.visible = false

                if(!idOriginalCheckBox.checked){
                    license = ""
                }
                else{
                    license = idLicenseModel.get(idLicenseCombobox.currentIndex).text
                }
                if(wayRadio1.checked)
                    saveWay = 1;
                else
                    saveWay = 2;

                categoryId= idGroupTypeModel.get(idGroupTypeCombobox.currentIndex).key
                groupName=idModelGroupInput.text
                groupDesc=idDescText.text
                bShare=idShareCheckBox.checked;
                //modelType=idModelTypeModel.get(idModelTypeCombobox.currentIndex).key

                bIsOriginal=idOriginalCheckBox.checked;

                ManageUploadModel.uploadModel();
            }
        }
        BasicButton{
            width: 125
            height: 28
            hoveredBtnBgColor: defaultBtnBgColor
            text: catalog.i18nc("@text:btn", "Cancel")
            fontWeight: Font.Bold
            onSigButtonClicked:
            {
                idDialog.close();
            }
        }
    }
    Column{
        id: idprogressBar
        x: 96
        y: 108
        visible: false
        spacing: 10
        Label{
            anchors{
                horizontalCenter: parent.horizontalCenter
            }
            text: progressValue + "%"
            color: UM.Theme.getColor("text")
            font: UM.Theme.getFont("default")
        }
        ProgressBar{
            id: progressBar
            from: 0
            to:100
            value: progressValue
            width: 408
            height: 3

            background: Rectangle {   
                implicitWidth: progressBar.width
                implicitHeight: progressBar.height
                color: Qt.lighter(UM.Theme.getColor("text"))//"#303030"
            }

            contentItem: Item {  
                Rectangle {
                    width: progressBar.visualPosition * progressBar.width
                    height: progressBar.height
                    color: "#1E9BE2"
                }
            }
        }
    }
    Rectangle{
        id: idUploadSuccess
        visible: false
        x: 1
        y: 35
        width: idDialog.width-2
        height: idDialog.height - titleHeight
        color: "transparent"
        Row{
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
            spacing: 10
            Image{
                id: idFinishImage
                height:sourceSize.height
                width: sourceSize.width
                source: bRes ? "../res/good.gif" : "../res/bad.gif"
                anchors.verticalCenter: parent.verticalCenter
            }
            Label
            {
                id:idFinishText
                height:idFinishImage.height
                text: bRes ? catalog.i18nc("@title:Label", "Uploaded Successfully!") : catalog.i18nc("@title:Label", "Upload failed!")
                color: UM.Theme.getColor("text")
                font: UM.Theme.getFont("medium")
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
        }
    }
    BasicMessageDialog{
        id: msgDialog
        mytitle: catalog.i18nc("@Tip:title", "Error")
        onAccept: {
            msgDialog.close()
        }
    }
    LicenseDescriptionDlg{
        id:idLicenseDesDlg
        visible:false
    }
}