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
    property var userName: "小李"
    property var userId: "ID: 7356441234"

    signal sigLogout();
    function showPersonInfo(tuserImg, tuserName, tuserId)
    {
        userImg = tuserImg
        userName = tuserName
        userId = tuserId
        dialog.show();
    }
    Column{
        anchors.fill: parent
        anchors.topMargin: titleHeight
        spacing: 10
        BasicCircularImage{
            id: iduserImg
            width: 70; height: 70
            img_src: userImg
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label{
            id: iduserName
            width: 27; height: 14
            text: userName
            color: "black"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        Label{
            id: id_userid
            width: 88; height: 10
            text: userId
            color: "black"
            anchors.horizontalCenter: parent.horizontalCenter
        }
        BasicButton{
            id: idLoginBtn
            width: 140; height: 36
            text: "退出登录"
            btnTextColor: "white"
            defaultBtnBgColor : "#B4B4B4"
            anchors.horizontalCenter: parent.horizontalCenter
            pixSize: 14
            fontWeight: Font.Bold
            btnRadius: 3
            btnBorderW: 0
            onSigButtonClicked: {
                console.log("login out")
                close();
                sigLogout();
                
            }
        }
    }
    
}