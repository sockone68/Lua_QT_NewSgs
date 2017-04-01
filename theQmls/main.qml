import QtQuick 2.7
import QtQuick.Controls 2.0
import QtQuick.Layouts 1.3
import try1 1.0
import QtGraphicalEffects 1.0
import "main.js" as GameJs
//there is a object named "o1" for calling the lua,used like this:o1.qMLCallLua("updateLua","")
Page {
    id: root
    property var gameJs:GameJs
    Image {
        id:background
        source: "../image/wallpaper.jpg"
        anchors.fill: parent
    }

    //font.family: "微软正黑体"
    property int num
    property int topestz:z
    property double xfactor:availableWidth/1400
    property double yfactor:availableHeight/960
    property double centerx:availableWidth/2*4/5
    property double centery:availableHeight/2

    property var wujiangFrameComponent:Qt.createComponent("WujiangFrame.qml");
    property var cardComponent:Qt.createComponent("CardPic.qml");
    property var infoBarComponent : Qt.createComponent("InfoBar.qml");
    property var caa:Qt.createComponent("TheAnimation.qml")

    property var xuanlist

    function callFunc(t){
        GameJs[t[1]](t[0])
    }
    function callFuncByTable(t){
        var name=t.pop()
        GameJs[name](t)
    }

    ToolButton {
        contentItem: Rectangle{
            id:otherButton
            color: "#7a4949"
            width:100
            height:100
            Text{
                anchors.centerIn: parent
                text:"..."
            }
        }
        onClicked: optionsMenu.open()

        Menu {
            id: optionsMenu
            y:otherButton.y+otherButton.height
            transformOrigin: Menu.TopRight
            MenuItem {
                text: "更新lua"
                onTriggered: o1.qMLCallLua("updateLua","")
            }
            MenuItem {
                text: "作弊"
                onTriggered: o1.qMLCallLua("qmlCheatFunc","")
            }

        }
    }

     Flickable {
          x:root.availableWidth*4/5
          width:root.availableWidth/5
          height:root.availableHeight*3/4
          TextArea.flickable: TextArea {
              id:detailBar
              color:"white"
              text: "<b>InfoBar</b>"
              wrapMode: TextArea.Wrap
              textFormat: TextEdit.RichText
          }

          ScrollBar.vertical: ScrollBar {id: detailBarScroll }
      }


    Button{
        id:startButton
        text: qsTr("开始")
        font.pixelSize: 20
        anchors.centerIn: parent

        onClicked: {//addInfoBar("s")
            startButton.visible=false
            howManyPopup.open()
            GameJs.createAnimation(["../animationImage/weapon/axe.png",26,229,177,100,100])
        }
     }
    Popup {
              id: howManyPopup
              x: (root.width - width) / 2
              y: root.height / 6
              width: 200
              height: 300

              focus: true
              Text {
                  id: tp
                  text: qsTr("几个人？")
              }
              SpinBox {
                  y:40
                  id:numSlider
                  from:2
                  to:8
                  stepSize: 1
                  value: 2
                  width: parent.width
                  anchors.horizontalCenter: parent.horizontalCenter
                }
              Text {
                  id:renT
                  anchors.top:numSlider.bottom
                  text: numSlider.value+"人"
              }
              Button{
                  text:"确定"
                  anchors.top:renT.bottom
                  onClicked:{
                      num=numSlider.value
                      o1.qMLCallLua("qmlStartGame",num);
                      howManyPopup.close();startButton.visible=false
                  }
              }

              onClosed:{
                  startButton.visible=true
              }
          }

    Popup{
        id:xuanPop
        x: (root.width - width) / 2
        y: root.height / 6
        width: root.availableWidth
        height: root.availableHeight/2;
        dim:true
        closePolicy: Popup.NoAutoClose
        ListView {
                 id: listView
                 anchors.fill: parent
                 topMargin: 48
                 spacing: 20
                 model: xuanlist
                 orientation:Qt.Horizontal
                 delegate: ItemDelegate {
                     text: modelData
                     //width: listView.width - listView.leftMargin - listView.rightMargin
                     height:xuanPop.availableHeight
                     leftPadding: avatar.implicitWidth + 32

                     Image {
                        height:xuanPop.availableHeight
                        fillMode: Image.PreserveAspectFit;
                         id: avatar
                         source:"../image/general/"+ modelData + ".png"
                     }
                      onClicked: {
                          o1.qMLCallLua("qmlgetstring",index);
                          xuanPop.close()
                      }
                 }
         }
    }
    Button{
        id:okB
        text: "确定"
        font.pixelSize: 20
        x:(root.availableWidth/2-90)*xfactor*5/6
        y:root.availableHeight*2/3
        width:100*xfactor
        height:50*yfactor
        visible: false
        onClicked: {
            o1.qMLCallLua("clickWhenQMLButton","Ok");
        }
     }
    Button{
        id:cancelB
        text: "取消"
        font.pixelSize: 20
        x:(root.availableWidth/2+90)*xfactor*5/6
        y:root.availableHeight*2/3
        width:100*xfactor
        height:50*yfactor
        visible: false
        onClicked: {
            o1.qMLCallLua("clickWhenQMLButton","Cancel");
        }
     }

    Rectangle{
        id:mopaiduiN
        color:"transparent"
        x:root.availableWidth*4/5-width
        y:0;visible: false
        width:root.availableWidth/20
        height:root.availableHeight/20
        property string s:"摸牌堆"
        Text{
            color:"white"
            text:parent.s
        }
    }
    Rectangle{
        id:qipaiduiN
        color:"transparent";visible: false
        x:root.availableWidth*4/5-width
        anchors.top: mopaiduiN.bottom
        width:root.availableWidth/20
        height:root.availableHeight/20
        property string s:"弃牌堆"
        Text{
            color:"white"
            text:parent.s
        }
    }

    Rectangle{//it's a horizontal center line for test
        visible:false
        anchors.centerIn: parent
        width: 1000
        height:1
    }


    ListModel {id: skModel}

    Rectangle{//human Skill region
        id:sl
        color:"transparent"
        width:root.availableWidth/5
        height:root.availableHeight/3
        x:root.availableWidth/5*4
        y:root.availableHeight/4*3

        ListView {
             anchors.fill:parent
             model: skModel
             delegate: Image{
                 width:sl.width
                 fillMode: Image.PreserveAspectFit

                 source:"../image/system/skill/1-normal.png"
                 Text{
                     anchors.centerIn: parent
                     text:name
                 }
                 MouseArea{
                     anchors.fill: parent
                     hoverEnabled: true
                     cursorShape: Qt.PointingHandCursor
                     onEntered: parent.source="../image/system/skill/1-hover.png"
                     onPressed:  parent.source="../image/system/skill/1-down.png"
                     onReleased: parent.source="../image/system/skill/1-down-hover.png"
                     onClicked:{ o1.qMLCallLua("qmlStdPressedFunc",pindex);

                     }
                     onExited: parent.source="../image/system/skill/1-normal.png"
                 }
             }
             ScrollBar.vertical: ScrollBar { }
         }
    }

    Component.onCompleted: {
        //GameJs.addCardPic([false,{"cX":0,"cY":0}])
    }
}

