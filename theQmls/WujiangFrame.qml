import QtQuick 2.0
import QtGraphicalEffects 1.0
Rectangle{
    id:theborder
    property string pinyin
    property string shili
    property int maxlife
    property int life
    property int pindex
    property double theW
    property double theH
    property double theX
    property double theY
    property double centerx:x+wj.width/2
    property double centery:y+wj.height/2
    property var theBModel:bModel
    property int handcardnum:0
    property var theim:wj
    x: theX*xfactor*4/5-width/5*(theX/1400)
    y: theY*yfactor
    width:wj.paintedWidth+6
    height:wj.paintedHeight+6
    property int thesleeptime
    property var zBs:[]
    property string borderColor:"black"
    border.color: borderColor
    border.width: 3
    state: "notChosen"

       states: [
           State {
               name: "normal"
               PropertyChanges { target: shaderItem; brightness: 0 }
               PropertyChanges { target: shaderItem; desaturation: 0 }
               PropertyChanges { target: theborder; borderColor: "black" }
           },
           State {
               name: "Chosen"
               PropertyChanges { target: theborder; borderColor: "yellow" }
           },
           State {
               name: "notChosen"
               PropertyChanges { target: theborder; borderColor: "black" }
           },
           State {
               name: "canChosen"
               PropertyChanges { target: shaderItem; brightness: 0 }
           },
           State {
               name: "cantChosen"
               PropertyChanges { target: shaderItem; brightness: -0.4 }
           },
           State {
               name: "fanmian"
               PropertyChanges { target: shaderItem; brightness: 0.5 }
           },
           State {
               name: "notFanmian"
               PropertyChanges { target: shaderItem; brightness: 0 }
           },
           State {
               name: "die"
               PropertyChanges { target: shaderItem; desaturation: 1 }
           }
       ]
   transitions: [
          Transition {
              to: "normal"
              NumberAnimation{target:shaderItem;property:"brightness";duration:500}
              NumberAnimation{target:shaderItem;property:"desaturation";duration:500}
          },
           Transition {
               to:"cantChosen"
               NumberAnimation{target:shaderItem;property:"brightness";duration:500;easing.type: Easing.InOutQuad}
           },
          Transition {
               to: "die"
               NumberAnimation{target:shaderItem;property:"desaturation";duration:500;easing.type: Easing.InOutQuad}
           }
      ]

    Image {

        anchors.margins: 3
        visible: false
        property double sizeratio:sourceSize.width/sourceSize.height
        property double x1:height*sizeratio
        property double y1: width/sizeratio
        x:3
        y:3
        id:wj
        width:xfactor>yfactor?x1:xfactor*theW
        height:xfactor>yfactor?yfactor*theH:y1
        property double truex:(wj.width-wj.paintedWidth)/2
        property double truey:(wj.height-wj.paintedHeight)/2


        //fillMode: Image.PreserveAspectFit;
        source:"../image/general/"+ pinyin + ".png"
    }
    ShaderEffect {
        id: shaderItem
        x:wj.x
        y:wj.y
        width:wj.width
        height:wj.height
        property variant source: wj
        property real brightness: 0
        property real contrast: 0
        property real desaturation: 0.0

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

    Image{
        x:wj.truex
        y:wj.truey
        fillMode: Image.PreserveAspectFit;
        width:parent.paintedWidth/5
        source:"../image/kingdom/icon/"+theborder.shili+".png"
    }
   MouseArea{
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
           console.log("clickWj")
            o1.qMLCallLua("qmlStdPressedFunc",pindex);
            //shaderItem.state=(shaderItem.state=="notChosen"?"cantChosen":"notChosen")
        }

    }


    LinearGradient {

        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        width:parent.width/5
        height:parent.height/10
        Text{
            color:"white"
            style:Text.Outline
            anchors.centerIn: parent
            text:theborder.handcardnum
        }

        gradient: Gradient{
            GradientStop{position: 0;color:shili=="wei"?"blue":shili=="shu"?"MediumVioletRed":shili=="wu"?"Aqua":shili=="qun"?"lightsteelblue":"black"}
            GradientStop{position: 1;color:shili=="wei"?"Indigo":shili=="shu"?"Red":shili=="wu"?"Green":shili=="qun"?"slategray":"black"}
        }
        start: Qt.point(0, 0);
        end: Qt.point(width, 0);
    }


    ListModel {
         id: bModel

     }
    Rectangle{
        id:br
        color:"transparent"
        width:shaderItem.width/7
        height:maxlife*width
        x:wj.truex+shaderItem.width-width
        y:wj.truey+shaderItem.height-height
        ListView {
             anchors.fill:parent
             model: bModel
             delegate: Image{
                 width:br.width
                 height:width
                 source:!good?"../image/system/magatamas/0.png":(life>maxlife*2/3)?"../image/system/magatamas/3.png":(life>maxlife/3)?"../image/system/magatamas/2.png":"../image/system/magatamas/1.png"
             }

         }
    }
    Component.onCompleted: {
        for(var i=0;i<life;i++){
            bModel.append({"good":true})
        }
    }


    ListModel {
         id: sfModel
         ListElement{name:"tunknown";thevisible:true}
         ListElement{name:"tzhu";thevisible:false}
         ListElement{name:"tz";thevisible:false}
         ListElement{name:"tf";thevisible:false}
         ListElement{name:"tn";thevisible:false}
     }
    property bool spread:false
    Rectangle{
        id:sfs
        color:"transparent"
        width:shaderItem.width/6
        height:l.count*width
        x:wj.truex+shaderItem.width-width
        y:wj.truey
        ListView {
            id:l
             anchors.fill:parent
             model: sfModel
             delegate: Image{
                 visible: thevisible
                 width:sfs.width
                 fillMode: Image.PreserveAspectFit;
                 source:"../image/system/roles/"+name+".png"
                 MouseArea{
                     cursorShape: Qt.PointingHandCursor
                     anchors.fill: parent
                     onClicked: function(){
                         if(shaderItem.spread){
                             sfModel.get(1).thevisible=false
                             sfModel.get(2).thevisible=false
                             sfModel.get(3).thevisible=false
                             sfModel.get(4).thevisible=false
                         }else{
                             sfModel.get(1).thevisible=true
                             sfModel.get(2).thevisible=true
                             sfModel.get(3).thevisible=true
                             sfModel.get(4).thevisible=true
                         }
                         shaderItem.spread=!shaderItem.spread
                         sfModel.get(0).name=sfModel.get(index).name
                     }
                 }
             }

         }
    }



    Rectangle{
        id:tb
        x:wj.truex
        y:wj.truey+parent.height
        width:parent.width
        height:parent.height/14
        color:"red"
        visible:false
        transformOrigin: Item.TopLeft
    }

    NumberAnimation {id:tba; target: tb; property: "width";from:tb.width; to:0; duration: thesleeptime;running:false }

}
property var getHurt:function(){
    life--
    bModel.get(maxlife-life-1).good=false
}
property var huixie:function(){
    bModel.get(maxlife-life-1).good=true
    life++

}
property var pDs:[]
property var addPandingIcon:function(s){
    var pd=Qt.createQmlObject('import QtQuick 2.0; Image {fillMode: Image.PreserveAspectFit;anchors.top:parent.top}',
                             shaderItem, "dynamicSnippet1")
    pd.source="../"+s
    pd.width=shaderItem.width/7
    pDs.push(pd)
    pd.x=pDs.length*pd.width

}
property var removePandingIcon:function(){

    var pd=pDs.pop()
    pd.destroy()

}
property var zA:function(detail){
    var direction=detail[0]
    var level=detail[1]
    var po=detail[2]
    zBs[po].zA(direction,level)
}

property var firstshenfenChooseButton:function (s){
    sfModel.get(0).name="t"+s
}
function sleep(s){
    tb.width=wj.paintedWidth
    tb.visible=true
    thesleeptime=s
    tba.start()
}
}
