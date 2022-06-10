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
    property color defaultBtnBgColor: "#F3F3F3"
    property color hoveredBtnBgColor: "#0078D7"
    property color selectedBtnBgColor: "#0078D7"
    property color btnTextColor: "black"
    property var btnRadius: 3
    property var btnBorderW: 1
    property var pixSize: 14
    property var fontWeight: Font.Normal

    signal sigButtonClicked()
    signal sigButtonClickedWithKey(string str)

    Button {
        id : propertyButton
        width: parent.width
        height: parent.height
        font: UM.Theme.getFont("default")

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
            border.color: propertyButton.hovered? hoveredBtnBgColor : "#ABABAB"
        }
        onClicked:
        {
            sigButtonClicked()
            sigButtonClickedWithKey(keyStr)
        }
        Component.onCompleted: {
            propertyButton.font.weight = fontWeight
            propertyButton.font.pixelSize = pixSize
        }
    }
}

