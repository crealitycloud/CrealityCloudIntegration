import QtQuick 2.6
// import QtQuick.Controls 2.10
// import QtGraphicalEffects 1.0

Rectangle {
    property var img_src: ""
    radius: width / 2
    // color : "transparent"
    Image {
        id: _image
        mipmap: true
        smooth: true
        cache: false
        asynchronous: true
        fillMode: Image.PreserveAspectFit
        // visible: false
        anchors.fill: parent
        source: img_src
        sourceSize: Qt.size(parent.size, parent.size)
        antialiasing: true        
    }
    // Rectangle {
    //     id: _mask
    //     color: "black"
    //     anchors.fill: parent
    //     radius: width / 2
    //     visible: false
    //     antialiasing: true
    //     smooth: true
    // }
    // OpacityMask {
    //     id: mask_image
    //     anchors.fill: _image
    //     source: _image
    //     maskSource: _mask
    //     visible: true
    //     antialiasing: true
    // }
}