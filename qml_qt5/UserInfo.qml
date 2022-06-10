import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1
import UM 1.1 as UM

BasicDialog {
    id: dialog
    UM.I18nCatalog { id: catalog; name: "uranium"}
    visible: false
    width: 340
    height: 238  
    titleHeight: 30
    title: catalog.i18nc("@title:window", "userinfo")
    property var userImg: ""
    property var userName: "unknow"
    property var userId: "ID: 0000011111"

    signal sigLogout();
    function showPersonInfo(tuserImg, tuserName, tuserId)
    {
        userImg = tuserImg
        userName = tuserName
        userId = tuserId
        dialog.show();
    }
    Item{
        anchors.fill: parent
        anchors.topMargin: titleHeight
        anchors.bottomMargin: 1
        anchors.leftMargin: 1
        anchors.rightMargin: 1
        
        BasicCircularImage{
            id: iduserImg
            width: 70; height: 70
            img_src: userImg
            anchors.top: parent.top
            anchors.topMargin: 20
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label{
            id: iduserName
            width: 27; height: 14
            text: userName
            color: UM.Theme.getColor("text")
            font: UM.Theme.getFont("default")
            anchors.top: iduserImg.bottom
            anchors.topMargin: 10
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }
        Label{
            id: id_userid
            width: 88; height: 10
            text: userId
            color: UM.Theme.getColor("text")
            font: UM.Theme.getFont("default")
            anchors.top: iduserName.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignHCenter
        }
        BasicButton{
            id: idLoginBtn
            width: 140; height: 36
            text: catalog.i18nc("@text:btn", "Log out")
            hoveredBtnBgColor: defaultBtnBgColor
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 24
            anchors.horizontalCenter: parent.horizontalCenter
            onSigButtonClicked: {
                dialog.close();
                sigLogout();
            }
        }       
    }
}