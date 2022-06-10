import QtQuick 2.0
import QtQuick.Controls 2.3

Button {
    id : idLicenseExplain
    property string btnImgN;
    property string btnImgH;
    implicitWidth: 16
    implicitHeight: 16
    width: implicitWidth
    height: implicitHeight

    background: Rectangle {
        width: parent.width
        height: parent.height
        radius: parent.width/2
        color: "transparent"
        Image{
            id: _image                      
            anchors.fill: parent
            source: idLicenseExplain.hovered ? btnImgH : btnImgN
        }                   
    }   
}