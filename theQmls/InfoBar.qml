
import QtQuick 2.7
Rectangle{
    property string t
    color: "#9c1313"
    x:parent.centerx-width/2
    anchors.verticalCenter: parent.verticalCenter
    width:thet.contentWidth
    height:thet.contentHeight
    Text{
        id:thet
        color:"white"
       text:t
    }

}
