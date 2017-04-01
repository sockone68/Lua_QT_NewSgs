
import QtQuick.Window 2.2
import QtQuick 2.6
import QtQuick.Controls 2.0
 import QtQuick.Layouts 1.3
import try1 1.0

 ApplicationWindow {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")
    id:window
    property var theArray: myModel

    Page {
        id: root
            anchors.fill: parent
            header: ToolBar {
                Label {
                             text: qsTr("Contacts")
                             font.pixelSize: 20
                             anchors.centerIn: parent
                         }

            }
            ListView {
                         id: listView
                         anchors.fill: parent
                         topMargin: 48

                         spacing: 20
                         model: theArray
                         orientation:Qt.Horizontal
                         delegate: ItemDelegate {
                             text: modelData
                             //width: listView.width - listView.leftMargin - listView.rightMargin
                             height: avatar.implicitHeight
                             leftPadding: avatar.implicitWidth + 32

                             Image {
                                 id: avatar
                                 source:"../image/general/"+ modelData + ".png"
                             }
                              onClicked: {
                                  o1.qMLCallLua("DIYWindowEvent",index)

                                  window.close()
                              }
                         }
                     }
        }


}

