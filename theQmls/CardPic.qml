import QtQuick 2.0

Item {
    id:self

    property bool isCardBack: true
    property bool moveNow: false
    property bool deleteAfterAnim: false
    property bool inHumanHand: false
    property bool isUp:false
    property double targetX
    property double targetY
    property double cX
    property double cY
    property double xoffset
    property double yoffset
    property int cardMoveTime:700
    property string english
    property string suit
    property string number
    property var moveAnim:theMoveAnim
    property var ha:thehandcardAnim
    property int index
    property int pindex
    property var updateX:function(){
        x=cX+xoffset*width
    }
    property var updateY:function(){
        y=inHumanHand?parent.availableHeight-height:cY+yoffset*height
    }
    //
    //y:inHumanHand?parent.availableHeight-height:cY+yoffset*height
    property double truex:(width-theimage.paintedWidth)/2
    property double truey:(height-theimage.paintedHeight)/2

     property string specialt
    width:theimage.width
    height:theimage.height


    function changeUpdown(){
        self.isUp=!self.isUp
        updownAnim.start()
    }
   Image{
       id:theimage
       visible: false
       width:xfactor*sourceSize.width*4/5*9/5
      // height:yfactor*sourceSize.height*7/5
       fillMode: Image.PreserveAspectFit;
        source:isCardBack?"../image/card/card-back.png":"../image/card/"+english+".png"
        Text{
            id:thenumber
            x:thesuit.x+thesuit.paintedWidth/2-contentWidth/2
            y:self.truey+parent.paintedHeight/28
            //width: thesuit.width
            text:self.number
            color:suit=="Diamonds"||suit=="Hearts"?"red":"black"
        }
        Image{
            id:thesuit
            //anchors.top: thenumber.bottom
            x:self.truex+parent.paintedWidth/20
            y:thenumber.y+thenumber.contentHeight
            opacity: 0.75
            width: theimage.paintedWidth/7
            fillMode: Image.PreserveAspectFit;
            source:suit!=""? "../image/system/suit/"+suit+".png":""
            visible:!isCardBack
        }
        Text{
            anchors.horizontalCenter: parent.horizontalCenter
            y:parent.paintedHeight*2/3
            color:"white"
            text:self.specialt
            style:Text.Outline
        }
   }
   ShaderEffectSource {
       id:theShaderEffectSource
        sourceItem: theimage
    }
    ShaderEffect {
        id:theShaderEffect
        anchors.fill: parent
        property var source:theShaderEffectSource
        property real brightness: 0
        property real contrast: 0
        property real desaturation: 0
        fragmentShader: "
            varying mediump vec2 qt_TexCoord0;
            uniform highp float qt_Opacity;
            uniform lowp sampler2D source;
            uniform highp float brightness;
            uniform highp float contrast;
            uniform highp float desaturation;
            void main() {
                highp vec4 pixelColor = texture2D(source, qt_TexCoord0);
                pixelColor.rgb /= max(1.0/256.0, pixelColor.a);
                highp float c = 1.0 + contrast;
                highp float contrastGainFactor = 1.0 + c * c * c * c * step(0.0, contrast);
                pixelColor.rgb = ((pixelColor.rgb - 0.5) * (contrastGainFactor * contrast + 1.0)) + 0.5;
                pixelColor.rgb = mix(pixelColor.rgb, vec3(step(0.0, brightness)), abs(brightness));


                highp float grayColor = (pixelColor.r + pixelColor.g + pixelColor.b) / 3.0;
                pixelColor = mix(pixelColor, vec4(vec3(grayColor), pixelColor.a), desaturation);
                gl_FragColor = vec4(pixelColor.rgb * pixelColor.a, pixelColor.a) * qt_Opacity;

            }
        "
    }

    state:"notfake"
    states:[
        State{
            name:"notfake"
            PropertyChanges { target: theShaderEffect; brightness: 0 }
        },
        State{
            name:"fake"
            PropertyChanges { target: theShaderEffect; brightness: -0.5 }
        }
    ]
    transitions: [
            Transition {
                to:"notfake"
                NumberAnimation{target:theShaderEffect;property:"brightness";duration:500;easing.type: Easing.InOutQuad}
            },
           Transition {
                to: "fake"
                NumberAnimation{target:theShaderEffect;property:"brightness";duration:500;easing.type: Easing.InOutQuad}
            }
       ]
    property bool isPress:false
    property bool isDraging:false
    MouseArea{
        anchors.fill: parent
        drag.target: self; drag.axis: Drag.XAxis

        cursorShape:inHumanHand?Qt.PointingHandCursor:Qt.ArrowCursor
        onClicked: {
            o1.qMLCallLua("qmlStdPressedFunc",pindex);
            //self.state=(self.state=="notfake")?"fake":"notfake"
        }
        onPressed:{
            isPress=true
            self.z=++self.parent.topestz
        }

        onPositionChanged:{
            if(isPress){
                isDraging=true
            }
            if(inHumanHand){
                self.opacity=0.5
                gameJs.arrangeHumanHandcardsWhenHolding(self)
            }


        }
        onReleased: {
            isPress=false
            if(inHumanHand&&isDraging){
                gameJs.arrangeHumanHandcards()
                self.opacity=1
                isDraging=false
            }
        }
    }

    property var afterMove:function(){}
    ParallelAnimation {
        id:theMoveAnim
        running: false
        NumberAnimation { target: self; property: "x";easing.type: Easing.InOutQuad; to: targetX+xoffset*width; duration: cardMoveTime }
        NumberAnimation { target: self; property: "y";easing.type: Easing.InOutQuad; to: targetY+yoffset*height; duration: cardMoveTime }
        onStopped: {
            if(deleteAfterAnim)
            {
                self.destroy()
            }
            else if(isDelayD)
                delayDestroy.start()
            afterMove()
        }
    }
    property bool isDelayD:false
    property var startDelayDestroy:function(){delayDestroy.start()}
    SequentialAnimation {
        id: delayDestroy
        //ScriptAction { script: image.goalSprite = "start"; }
        PauseAnimation {  duration: 6000; }
        ScriptAction { script: self.state="fake" }
        PauseAnimation {  duration: 1000; }

        ScriptAction { script: self.thedestroy(); }
    }
    function thedestroy(){
        for(var i=0;i<gameJs.qipaiCards.length;i++){
            var c=gameJs.qipaiCards[i]
            if(c.pindex==self.pindex){
                gameJs.qipaiCards.splice(i,1)

                break
            }
        }
        for(var j=0;j<gameJs.allOnDeskcards.length;j++){
            c=gameJs.allOnDeskcards[j]
            if(c.pindex==i){
                gameJs.allOnDeskcards.splice(j,1)
                break
            }
        }
        self.destroy()
        gameJs.qipaicardsMove()
    }

    ParallelAnimation {
        id:thehandcardAnim
        running: false
        NumberAnimation { target: self; property: "x"; to: targetX; duration: 200 }
         onStopped: {

        }
    }
    ParallelAnimation {
        id:updownAnim
        running: false
        NumberAnimation { target: self; property: "y";easing.type: Easing.InOutQuad; to: isUp?self.y-30*yfactor:self.y+30*yfactor; duration: 150 }

         onStarted: {
            //console.log("y is "+self.y)
         }
    }
    Component.onCompleted: {
        theMoveAnim.running=moveNow
        gameJs.allOnDeskcards.push(self)
    }
}

