Qt.include("CalledByLua.js")
var playerFrames=[]
var allOnDeskcards=[]
var theHumanP
var infoBars=[]
var qipaiCards=[]
var humanHandCards=[]
var curPIndex=0

function test1(s){
    printTodetailBar("hahahayes"+num)
}
function createAnimation(detail){
    var ta=caa.createObject(root,{"thesource":detail[0],"thecount":detail[1],"thewidth":detail[2],"theheight":detail[3]})
    ta.x=detail[4]
    ta.y=detail[5]
}
function addCardPic(detail){
    var c
    if(detail[0]==false||detail[0]==-1)
    {
        c = cardComponent.createObject(root, detail[1]);

    }
    else{
        var e=detail[0]
        var suit=detail[1]
        var number=detail[2]

        c = cardComponent.createObject(root, {"isCardBack":false,"english":e,"suit":suit,"number":number,});
        if(detail[3]!=undefined){
             //if(typeof(detail[3]+1)=="number"){
                 c.specialt=detail[3]
             //}

        }
    }
    if(topestz>c.z)
        c.z=++topestz
    return c

}
function movetocenter(c){
    c.cX=centerx;c.xoffset=-0.5;
    c.cY=centery;c.yoffset=-0.5;
    c.updateX(); c.updateY()
}


function qipaicardsMove(){
    for(var i=0;i<qipaiCards.length;i++){
        var c=qipaiCards[i]
        c.targetX=root.centerx
        c.targetY=root.centery
        c.xoffset=i-qipaiCards.length/2
        c.yoffset=-0.5
        if(c.moveAnim.running)
            c.moveAnim.stop()
        c.moveAnim.start()
    }
}
function addHC(c){
     c.inHumanHand=true
    humanHandCards.push(c)
    c.index=humanHandCards.length-1
    arrangeHumanHandcards()
}
function arrangeHumanHandcards(s){
    humanHandCards.forEach(function(c,i){
        if(c!=s){
            c.index=i
            arrangeACard(c,s)
        }
    })

}
function preferX(c,theholdcard){

    var i=c.index
    if(theholdcard){
        return humanHandCards[i-1].x+c.width
    }
    else{
        var x = root.availableWidth*4/5-playerFrames[1].width - humanHandCards.length*c.width
        if(x<0){

            return (i)*c.width+(i)*x/(humanHandCards.length-1)
        }
        else
            return i*c.width
    }
}

function arrangeACard(c,theholdcard){
    if(c.ha.running){c.ha.stop();}
    if(c.index==0)
        c.targetX=0
    else{
        c.targetX=preferX(c,theholdcard)
        if(!theholdcard)
        c.z=humanHandCards[c.index-1].z+1
    }
    c.updateY()

    var trueindex=humanHandCards.indexOf(c)
    c.ha.start()
    if(theholdcard){
        for(var i=trueindex+1;i<humanHandCards.length;i++)
        {
            if(humanHandCards[i]!=theholdcard){
                humanHandCards[i].targetX=preferX(humanHandCards[i],theholdcard)
                humanHandCards[i].ha.start()
            }
        }
    }
}

function arrangeHumanHandcardsWhenHolding(holdcard){

    humanHandCards.sort(function(a,b){
        return a.x-b.x
    })
    humanHandCards.forEach(function(v,i){
        v.index=i
    })
    arrangeHumanHandcards(holdcard)
}
function avl(detail){
    var l=Qt.createQmlObject('import QtQuick 2.0; Rectangle {color: "yellow"; width: 2; height:2}',
                             root, "dynamicSnippet1")
    l.x=detail[0]
    l.y=detail[1]
    var targetx=detail[2]
    var targety=detail[3]
    var dx=l.x-targetx
    var dy=l.y-targety

    var d
    if(dx==0)
        if(dy>0)
            d=-90;
        else
            d=90;
    else
    {
        d=Math.atan(dy/dx)*180/3.14;
        if(dx>0){
                d=180+d
        }
    }
    l.transformOrigin=Item.TopLeft
    l.rotation=d;
    var lac=Qt.createComponent("LineAnim.qml")
    var la=lac.createObject(root,{"thetarget":l,"theto":Math.sqrt(Math.pow(dx,2)+Math.pow(dy,2))})
    la.start()

}
