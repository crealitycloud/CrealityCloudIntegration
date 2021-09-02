import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Controls 1.4 as T
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1

BasicDialog{
    id: idDialog
    width: 600
    height: 428
    titleHeight : 30
    title: qsTr("Upload Model")
    property var saveWay: 1;

    property var categoryId:0
    property var groupName:""
    property var groupDesc:""
    property var bShare:false
    property int modelType:1
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
    Column{
        id: idLogoImageColumn
        y: 30
        Rectangle {
            id:logoRect
            width: idDialog.width
            height: 74
            color: "transparent"
            Row
            {
                width: logoImage.width + idText.contentWidth
                anchors{
                    horizontalCenter: parent.horizontalCenter
                    verticalCenter: parent.verticalCenter
                }
                spacing: 10
                Image {
                    id : logoImage
                    width: 36
                    height: 34
                    source: "../res/logo.png"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Label
                {
                    id:idText
                    height:logoImage.height
                    text: qsTr("Creality Cloud")
                    font.pixelSize:20 
                    verticalAlignment: Qt.AlignVCenter
                    horizontalAlignment: Qt.AlignLeft
                }
            }
        }
        Item {
            id: name           
            width:idDialog.width
            height: 1
            Rectangle
            {
                anchors.fill: parent
                color: "#42BDD8"
                opacity: 0.5
            }
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
        width: idDialog.width
        spacing: 5
        Row{
            Label {
                id: idGroupNameLabel
                width:100
                height:28
                text: qsTr("Group Name:")
                font.pixelSize: 12
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            TextField {
                id: idModelGroupInput
                font.pixelSize:12
                placeholderText: qsTr("Please enter the model group name")
                //baseValidator:RegExpValidator { regExp: /^\S{100}$/ }
                width: grid_wrapper.width-idGroupNameLabel.width-110
                height : 28
                text: ""
            }
        }
        Row{
            Label {
                id: idGroupDescLabel
                width:100
                height:28
                text: qsTr("Description:")
                font.pixelSize: 12
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
                    wrapMode: TextEdit.Wrap
                    placeholderText: qsTr("Please enter the model group description")
                    text: ""
                    font.pixelSize: 12
                    font.family: "Source Han Sans CN Normal"
                    font.weight: Font.Normal
                }
                background: Rectangle {
                    border.color: "#D7D7D7"
                    color: "transparent"
                }
            }
        }
        Row{
            Label {
                id: idUploadWay
                width:100
                height:28
                text: qsTr("Upload Way:")
                font.pixelSize: 12
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            ButtonGroup{id: radioGroup}
            RadioButton {
                id: wayRadio1
                ButtonGroup.group: radioGroup
                text: "separate"
                checked: true
                anchors.verticalCenter: parent.verticalCenter
            }
            RadioButton {
                id: wayRadio2
                ButtonGroup.group: radioGroup
                text: "combination"
                anchors.verticalCenter: parent.verticalCenter
            }
        }
        Row{
            Label {
                id: idGroupType
                width:100
                height:28
                text: qsTr("Group Type:")
                font.pixelSize: 12
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            ComboBox {
                id: idGroupTypeCombobox
                height:25
                width: grid_wrapper.width-idGroupNameLabel.width-110
                font.pixelSize : 12
                currentIndex: -1
                model: ListModel {
                    id: idGroupTypeModel
                }
            }
        }
        Row{
            Label {
                id: idModelType
                width:100
                height:28
                text: qsTr("Model Type:")
                font.pixelSize: 12
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            ComboBox {
                id: idModelTypeCombobox
                height:28
                width: grid_wrapper.width-idGroupNameLabel.width-110
                font.pixelSize : 12
                currentIndex: 0
                model: ListModel {
                    id: idModelTypeModel
                    ListElement{key: 1; modelData: qsTr("Normal Model")}
                    ListElement{key: 2; modelData: qsTr("3D Photo Model")}
                }
            }
        }
        Row{
            Label {
                width:100
                height:28
            }
            CheckBox
            {
                id :idOriginalCheckBox
                width: 100
                height: 18
                text: qsTr("Original")
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
            CheckBox
            {
                id :idShareCheckBox
                anchors.verticalCenter: parent.verticalCenter
                width: 100
                height: 18
                text: qsTr("Share")
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
                text: qsTr("License Type:")
                font.pixelSize: 12
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
            ComboBox{
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
            }   
            Button {
                id : idLicenseExplain
                width: 16
                height: 16
                anchors{                       
                    verticalCenter: parent.verticalCenter
                }
                Rectangle {
                    width: parent.width
                    height: parent.height
                    Image{
                        width: parent.width
                        height: parent.height  
                        mipmap: true
                        smooth: true
                        cache: false
                        asynchronous: true
                        fillMode: Image.PreserveAspectFit
                        source: idLicenseExplain.hovered ? "../res/model_license_h.png" : 
                                    "../res/model_license.png"
                    }                  
                }
                background: Rectangle {
                    implicitWidth: parent.width
                    implicitHeight: parent.height
                    radius: parent.width/2
                    color: "transparent"
                }
                onClicked:{
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
            btnRadius:3
            btnBorderW:0
            defaultBtnBgColor: "#B4B4B4"
            text: qsTr("Upload")
            enabled: (idModelGroupInput.text != "")&&(idDescText.text != "")
            onSigButtonClicked:
            {
                idLogoImageColumn.visible = false
                grid_wrapper.visible = false
                idBtnGroup.visible = false
                idDialog.height = 223
                idprogressBar.visible = true
                idUploadSuccess.visible = false

                var license = "";
                if(idLicenseRow.visible){
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
                modelType=idModelTypeModel.get(idModelTypeCombobox.currentIndex).key
                license=license
                bIsOriginal=idOriginalCheckBox.checked;

                ManageUploadModel.uploadModel();
            }
        }
        BasicButton{
            width: 125
            height: 28
            btnRadius:3
            btnBorderW:0
            defaultBtnBgColor: "#B4B4B4"
            text: qsTr("Cancel")
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
            font.pixelSize: 12
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
                color: "#303030"
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
        y: 35
        width: idDialog.width
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
                height:logoImage.sourceSize.height
                text: bRes ? qsTr("Uploaded Successfully") : ""
                font.pixelSize:14
                verticalAlignment: Qt.AlignVCenter
                horizontalAlignment: Qt.AlignLeft
            }
        }
    }

    LicenseDescriptionDlg{
        id:idLicenseDesDlg
        visible:false
    }
}