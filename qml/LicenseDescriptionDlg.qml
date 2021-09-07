import QtQuick 2.10
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.0
import QtQuick.Window 2.2
import QtQuick.Dialogs 1.1
import UM 1.1 as UM

BasicDialog{
    id: idLicenseDlg
    UM.I18nCatalog { id: catalog; name: "uranium"}
    width: 760
    height: 520
    title: catalog.i18nc("@title:window", "Creality Cloud protect designer's copyrighted works")

    ScrollView{
        anchors.top: parent.top
        anchors.topMargin: 30+30+5
        anchors.left: parent.left
        anchors.leftMargin: 5+21
        width: parent.width-10 - 21
        height: parent.height-titleHeight-10-30-30
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        clip : true
        Column{
            width: 708
            spacing: 30
            Label{
                width:parent.width
                height:40
                wrapMode: Text.WordWrap
                color: "#333333"
                text: catalog.i18nc("@title:Label", "In Creality Cloud, your original work (inc 3D prints & articles) is restrictedly protected under Creative Commons Licenses 4.0. If you find any breach of agreement, please contact us to discuss further action.")
                font.pixelSize:14
            }
            Row{
                width: parent.width
                spacing: 20
                Column{
                    width: parent.width - 172 - 20
                    height: 60
                    spacing: 5
                    Label{
                        width: parent.width
                        height: 14
                        wrapMode: Text.WordWrap
                        color: "#333333"
                        text: qsTr("CC BY")
                        font.pixelSize:18
                        font.weight: "Bold"
                    }
                    Label{
                        width: parent.width
                        height: parent.height-14-5
                        wrapMode: Text.WordWrap
                        color: "#666666"
                        text: catalog.i18nc("@title:Label","This license allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, so long as attribution is given to the creator. The license allows for commercial use.")
                        font.pixelSize:12
                    }
                }
                Image{
                    width: 172
                    height: 60   
                    mipmap: true
                    smooth: true
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: "../res/license_by.png"
                }
            }
            Row{
                width: parent.width
                spacing: 20
                Column{
                    width: parent.width - 172 - 20
                    height: 60
                    spacing: 5
                    Label{
                        width: parent.width
                        height: 14
                        wrapMode: Text.WordWrap
                        color: "#333333"
                        text: qsTr("CC BY-SA")
                        font.pixelSize:18
                        font.weight: "Bold"
                    }
                    Label{
                        width: parent.width
                        height: parent.height-14-5
                        wrapMode: Text.WordWrap
                        color: "#666666"
                        text: catalog.i18nc("@title:Label","This license allows reusers to distribute, remix, adapt, and build upon the material in any medium or format, so long as attribution is given to the creator. The license allows for commercial use. If you remix, adapt, or build upon the material, you must license the modified material under identical terms.")
                        font.pixelSize:12
                    }
                }
                Image{
                    width: 172
                    height: 60   
                    mipmap: true
                    smooth: true
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: "../res/license_by_sa.png"
                }
            }
            Row{
                width: parent.width
                spacing: 20
                Column{
                    width: parent.width - 172 - 20
                    height: 60
                    spacing: 5
                    Label{
                        width: parent.width
                        height: 14
                        wrapMode: Text.WordWrap
                        color: "#333333"
                        text: qsTr("CC BY-NC")
                        font.pixelSize:18
                        font.weight: "Bold"
                    }
                    Label{
                        width: parent.width
                        height: parent.height-14-5
                        wrapMode: Text.WordWrap
                        color: "#666666"
                        text: catalog.i18nc("@title:Label","This license allows reusers to distribute, remix, adapt, and build upon the material in any medium or format for noncommercial purposes only, and only so long as attribution is given to the creator.")
                        font.pixelSize:12
                    }
                }
                Image{
                    width: 172
                    height: 60   
                    mipmap: true
                    smooth: true
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: "../res/license_by_nc.png"
                }
            }
            Row{
                width: parent.width
                spacing: 20
                Column{
                    width: parent.width - 172 - 20
                    height: 60
                    spacing: 5
                    Label{
                        width: parent.width
                        height: 14
                        wrapMode: Text.WordWrap
                        color: "#333333"
                        text: qsTr("CC BY-NC-SA")
                        font.pixelSize:18
                        font.weight: "Bold"
                    }
                    Label{
                        width: parent.width
                        height: parent.height-14-5
                        wrapMode: Text.WordWrap
                        color: "#666666"
                        text: catalog.i18nc("@title:Label","This license allows reusers to distribute, remix, adapt, and build upon the material in any medium or format for noncommercial purposes only, and only so long as attribution is given to the creator. If you remix, adapt, or build upon the material, you must license the modified material under identical terms.")
                        font.pixelSize:12
                    }
                }
                Image{
                    width: 172
                    height: 60   
                    mipmap: true
                    smooth: true
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: "../res/license_by_nc_sa.png"
                }
            }
            Row{
                width: parent.width
                spacing: 20
                Column{
                    width: parent.width - 172 - 20
                    height: 60
                    spacing: 5
                    Label{
                        width: parent.width
                        height: 14
                        wrapMode: Text.WordWrap
                        color: "#333333"
                        text: qsTr("CC BY-ND")
                        font.pixelSize:18
                        font.weight: "Bold"
                    }
                    Label{
                        width: parent.width
                        height: parent.height-14-5
                        wrapMode: Text.WordWrap
                        color: "#666666"
                        text: catalog.i18nc("@title:Label","This license allows reusers to copy and distribute the material in any medium or format in unadapted form only, and only so long as attribution is given to the creator. The license allows for commercial use.")
                        font.pixelSize:12
                    }
                }
                Image{
                    width: 172
                    height: 60   
                    mipmap: true
                    smooth: true
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: "../res/license_by_nd.png"
                }
            }
            Row{
                width: parent.width
                spacing: 20
                Column{
                    width: parent.width - 172 - 20
                    height: 60
                    spacing: 5
                    Label{
                        width: parent.width
                        height: 14
                        wrapMode: Text.WordWrap
                        color: "#333333"
                        text: qsTr("CC BY-NC-ND")
                        font.pixelSize:18
                        font.weight: "Bold"
                    }
                    Label{
                        width: parent.width
                        height: parent.height-14-5
                        wrapMode: Text.WordWrap
                        color: "#666666"
                        text: catalog.i18nc("@title:Label","This license allows reusers to copy and distribute the material in any medium or format in unadapted form only, for noncommercial purposes only, and only so long as attribution is given to the creator.")
                        font.pixelSize:12
                    }
                }
                Image{
                    width: 172
                    height: 60   
                    mipmap: true
                    smooth: true
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: "../res/license_by_nc_nd.png"
                }
            }
            Row{
                width: parent.width
                spacing: 20
                Column{
                    width: parent.width - 172 - 20
                    height: 60
                    spacing: 5
                    Label{
                        width: parent.width
                        height: 14
                        wrapMode: Text.WordWrap
                        color: "#333333"
                        text: qsTr("CC0")
                        font.pixelSize:18
                        font.weight: "Bold"
                    }
                    Label{
                        width: parent.width
                        height: parent.height-14-5
                        wrapMode: Text.WordWrap
                        color: "#666666"
                        text: catalog.i18nc("@title:Label","(aka CC Zero) is a public dedication tool, which allows creators to give up their copyright and put their works into the worldwide public domain.")
                        font.pixelSize:12
                    }
                }
                Image{
                    width: 172
                    height: 60   
                    mipmap: true
                    smooth: true
                    cache: false
                    asynchronous: true
                    fillMode: Image.PreserveAspectFit
                    source: "../res/license_cc0.png"
                }
            }
        }
    }
}
