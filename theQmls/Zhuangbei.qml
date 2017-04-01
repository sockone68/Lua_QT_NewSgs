import QtQuick 2.0

Image {
    id:im
    property string name
    property string suit
    property string number
    property int pos
    property int pindex
    x:parent.theim.truex;
    y:parent.theim.height-(5-pos)*height;
    source:"../image/equips/"+name+".png";
    width: parent.theim.paintedWidth*3/4
    height:parent.theim.height/10
    fillMode: Image.PreserveAspectFit;
    Text{
        anchors.right: si.left
        text:number
    }

    Image {
        id:si
        x:parent.width-width;
        source: "../image/system/suit/"+suit+".png"
        width: height
        height:parent.height
        fillMode: Image.PreserveAspectFit;
    }
    NumberAnimation { id:za;target: im; property: "x"; duration: 200 }
    MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            o1.qMLCallLua("qmlStdPressedFunc",pindex)
        }
    }

    property var zA:function(isRight,level){
        za.to=im.x+isRight*level*20*parent.parent.xfactor
        za.start()
    }

}

