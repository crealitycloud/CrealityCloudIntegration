import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0


Item {
    property var btnBorderW: 2
    property var keystr: 0
    property var modelid: ""
    property var btnImgUrl: ""
    property var btnSelect: false
    signal sigBtnClicked(var key)

    id: basicButton
    implicitWidth: 60
    implicitHeight: 60

    Button {
        id : propertyButton
        width: parent.width
        height: parent.height
        Rectangle {
            anchors{
                horizontalCenter: parent.horizontalCenter
                verticalCenter: parent.verticalCenter
            }
                width: parent.width - btnBorderW*2
                height: parent.height - btnBorderW*2
                opacity: 1
                color: (propertyButton.hovered || btnSelect) ? "#E9E9E9" : "#DBDBDB"
            Image{
                width: parent.width
                height: parent.height  
                opacity: (propertyButton.hovered || btnSelect) ? 1 : 0.3 
                mipmap: true
                smooth: true
                cache: false
                asynchronous: true
                fillMode: Image.PreserveAspectFit
                source: btnImgUrl
            }
        }


        background: Rectangle {
            width: parent.width
            height: parent.height
            color: "transparent"
            border.width: btnBorderW
            border.color: (propertyButton.hovered || btnSelect)? "#1E9BE2" : "#DBDBDB"
        }

        onClicked:
        {
            sigBtnClicked(keystr)
        }
    }
}

