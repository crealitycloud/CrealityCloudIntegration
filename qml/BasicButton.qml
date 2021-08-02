import QtQuick 2.0
import QtQuick.Controls 2.3

Item {
    id: basicButton
    implicitWidth: 32
    implicitHeight: 32
    property var keyStr: ""
    property alias text: propertyButton.text
    property alias btnText: btnTxt
    property alias hovered: propertyButton.hovered
    property alias down: propertyButton.down

    property bool btnEnabled:true
    property bool btnSelected:false
    property color defaultBtnBgColor: "#F5F5F5"
    property color hoveredBtnBgColor: "#1E9BE2"
    property color selectedBtnBgColor: "#1E9BE2"
    property color btnTextColor:"black"
    property var btnRadius: 14
    property var btnBorderW: 1
    property var pixSize: 14

    signal sigButtonClicked()
    signal sigButtonClickedWithKey(string str)

    Button {
        id : propertyButton
        width: parent.width
        height: parent.height
        font.family: "Source Han Sans CN Normal"
        font.weight: Font.Normal
        font.pixelSize: pixSize
        contentItem: Item {
            Text {
                  id: btnTxt
                  color:  btnTextColor
                  anchors.centerIn: parent
                  elide: Text.ElideRight
                  text: propertyButton.text
                  font: propertyButton.font
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
            sigButtonClicked()
            sigButtonClickedWithKey(keyStr)
        }
    }
}

