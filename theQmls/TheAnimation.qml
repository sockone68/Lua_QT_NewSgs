 import QtQuick 2.7
Item{
    property string thesource
    property int thecount
    property int therate:20
    property int thewidth
    property int theheight

    SpriteSequence {


        id: image
        width: thewidth
        height: theheight
        anchors.left: parent.left
        goalSprite: ""
        Sprite{
            name: "start"
            source: thesource
            frameCount: 1
            frameX:0
            frameY:0
            frameWidth: thewidth
            frameHeight: theheight
            frameRate: 20
            to: {"still":1}
        }
        Sprite{
            name: "still"
            source: thesource
            frameCount: thecount
            frameWidth: thewidth
            frameHeight: theheight
            frameRate: therate
            to: {"end":1}
        }
        Sprite{
            name: "end"
            source: "../animationImage/none.png"
            frameCount: 1
            frameX:0
            frameY:0
            frameWidth: 0
            frameHeight: 0
            frameRate: 0


        }
        property double s:0

    }
    SequentialAnimation {
        id: anim
        //ScriptAction { script: image.goalSprite = "start"; }
        NumberAnimation {  duration: (1000/therate)*thecount; }
        ScriptAction { script: image.destroy(); }
    }
    Component.onCompleted: {
        anim.start()
    }
}
