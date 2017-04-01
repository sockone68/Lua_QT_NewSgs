//callQmlF
function log(s){
    console.log(s)
}
function printTodetailBar(s){

    detailBar.append(s)
    detailBarScroll.position=1
}
function addInfoBar(s){
    if(infoBars.length>0)infoBars.pop().destroy()
    var b=infoBarComponent.createObject(root,{"t":s})
    if(b.z<topestz)
        b.z=++topestz
    infoBars.push(b)
}

function gameStart(s){
    mopaiduiN.visible=true
    qipaiduiN.visible=true
}

function setthehumanp(s){theHumanP=s}

function showBs(s){
    okB.visible=true;cancelB.visible=true
}
function hideBs(s){
    okB.visible=false;cancelB.visible=false
}
function updateMN(s){
    mopaiduiN.s=s
}
function updateQN(s){
    qipaiduiN.s=s
}

function removeFromHandcards(i){
    console.log("callingremove")
    for(var j=0;j<humanHandCards.length;j++){
        var c=humanHandCards[j]
        if(c.pindex==i)
        {
            //c.cY=c.y-c.height/2
            c.inHumanHand=false

            humanHandCards.splice(j,1)
            console.log("removefromhand")
            break
        }
    }
    arrangeHumanHandcards()
}

function gethurt(p){
    playerFrames[p].getHurt()
}
function huixie(p){
    playerFrames[p].huixie()
}

function removePandingIcon(p){
    playerFrames[p].removePandingIcon()
}

function deleteCard(i){
    for(var j=0;j<allOnDeskcards.length;j++){
        var c=allOnDeskcards[j]
        if(c.pindex==i){
            allOnDeskcards.splice(j,1)
            c.destroy()
            console.log("remove")
            break
        }
    }
}

function removeHumanSkill(j){
    for(var i=0;i<skModel.count;i++){
        if(skModel.get(i).pindex==j){
            skModel.remove(i)
            break
        }
    }
}

function changeCardUpdown(i){
    for(var j=0;j<humanHandCards.length;j++){
        if(humanHandCards[j].pindex==i){
            humanHandCards[j].changeUpdown()
            break
        }
    }
}

//callQmlFTable
function getXuanList(s){
    xuanlist=s
    xuanPop.open()

}

function setWjPic(list){
    var positionAfterHuman=list[0]
    var pinyin=list[1]
    var shili=list[2]
    var life=list[3]
    var position=list[4]
    var theW=list[5]
    var theH=list[6]
    var theX=list[7]
    var theY=list[8]

    var sprite = wujiangFrameComponent.createObject(root, {"pinyin":pinyin,"shili":shili,"maxlife":life,"life":life,"theW":theW,"theH":theH,"theX":theX,"theY":theY});
    playerFrames[position]=sprite
    sprite.pindex=curPIndex
    curPIndex++
}

function thePlayerMoNPai(detail){
    var n=detail[0]
    var p=detail[1]
    //console.log("thep is "+p)
    for(var i=0;i<n;i++)
    {
        //console.log(root.centerx)
        var c = cardComponent.createObject(root, {"cX":root.centerx,"cY":root.centery,"xoffset":i-n/2,"yoffset":-0.5,"targetX":playerFrames[p].centerx,"targetY":playerFrames[p].centery,"deleteAfterAnim":true});
        c.z=++topestz
        c.updateX()
        c.updateY()
        c.moveAnim.start()
    }


}

function addPandingCard(detail){
    var c=addCardPic(detail)
    //movetocenter(c)
    c.cX=centerx;c.cY=centery;c.yoffset=-0.5;c.updateX();c.updateY()
    c.isDelayD=true
    c.pindex=curPIndex
    curPIndex++
    qipaiCards.push(c)
    qipaicardsMove()
}

function thePlayerQiNPai(detail){
    var n=detail[0]
    var p=detail[1]
    p=playerFrames[p]

    for(var i=0;i<n;i++)
    {
        var e=detail[2+i*4]
        var suit=detail[3+i*4]
        var number=detail[4+i*4]
        var specialt=detail[5+i*4]
        var c = cardComponent.createObject(root, {"specialt":specialt,"isCardBack":false,"english":e,"suit":suit,"number":number,"cX":p.centerx,"cY":p.centery,"xoffset":i-n/2,"yoffset":-0.5});//"targetY":root.centery,"deleteAfterAnim":false});


        if(topestz>c.z)
            c.z=++topestz
        c.updateX()
        //if(detail[1]!=theHumanP)
            c.updateY()
        c.isDelayD=true
        //c.moveAnim.start()
        qipaiCards.push(c)
    }
    qipaicardsMove()
}

function onDeskCardsAnim(detail){
    var cards=[]
    var i=1
    for(;i<=detail[0];i++){
        for(var j=0;j<allOnDeskcards.length;j++){
            var c=allOnDeskcards[j]
            if(c.pindex==detail[i])
            {
                if(topestz>c.z)
                    c.z=++topestz
                cards.push(c)
                break
            }
        }
    }
    if(detail[i]=="center"){
        for(var j=0;j<cards.length;j++){
            console.log("QIhumanpai")
             c=cards[j]
            c.isDelayD=true
            qipaiCards.push(c)
            /*
            c.targetX=centerx
            c.targetY=centery
            c.xoffset=j-cards.length/2
            c.yoffset=-0.5

            c.moveAnim.start()*/
        }
        qipaicardsMove()
    }
    else if(detail[i]=="playercenter"){
        var toP=playerFrames[detail[i+1]]
        for(var j=0;j<cards.length;j++){
            c=cards[j]
            c.targetX=toP.centerx;c.targetY=toP.centery;c.xoffset=j-cards.length/2;c.yoffset=-0.5
            c.deleteAfterAnim=true
            c.moveAnim.start()
        }
    }
    else if(detail[i]=="humanhand"){
        toP=playerFrames[detail[i+1]]
        for(var j=0;j<cards.length;j++){
            c=cards[j]
            c.targetX=(humanHandCards.length+j)*c.width;c.targetY=root.availableHeight-c.height;c.xoffset=0;c.y=c.y;c.yoffset=0
            c.deleteAfterAnim=false
            c.afterMove=function(){
                addHC(c)
                c.afterMove=function(){}
            }

            c.moveAnim.start()
        }
    }
}

function addZb(detail){
    var name=detail[0];var suit=detail[1];var number=detail[2];var pos=detail[3];var p=detail[4]
    p=playerFrames[p]
     var zComponent=Qt.createComponent("Zhuangbei.qml");
    var z = zComponent.createObject(p,{"name":name,"pos":pos,"suit":suit,"number":number})
    p.zBs[pos]=z
    console.log("zbn:"+pos)
    z.pindex=curPIndex++
}
function deleteZb(detail){
    var pos=detail[0]
    var p=detail[1]
    p=playerFrames[p]
    p.zBs[pos].destroy()
}

function thePlayerZbAnim(detail){
    var c
    if(detail[0]==false||detail[0]==-1)
        c=addCardPic([-1,{}])
    else
        c=addCardPic(detail)
    var p=detail[3]
    p=playerFrames[p]
    var tp=playerFrames[detail[4]]
    c.cX=p.centerx;c.cY=p.centery;c.xoffset=-0.5;c.yoffset=-0.5
    c.updateX();c.updateY()
    c.targetX=tp.centerx;c.targetY=tp.centery
    c.deleteAfterAnim=true
    c.moveAnim.running=true
}

function addHumanHandCard(detail){
    var c=addCardPic(detail)
    c.pindex=curPIndex++
    addHC(c)
}

function pointPlayerAnim(detail){
    var p1=playerFrames[detail[0]]
    var p2=playerFrames[detail[1]]
    avl([p1.centerx,p1.centery,p2.centerx,p2.centery])
}
function addPandingIcon(detail){
    console.log("pandingpos:"+detail[0])
    var p=playerFrames[detail[0]]
    p.addPandingIcon(detail[1])
}

function addShunChaiCards(detail){
    var sN=detail[0]
    var zN=detail[1];var pN=detail[2]

    for(var i=0;i<sN;i++){
        var sC=addCardPic([false,{"cX":centerx,"cY":centery,"xoffset":i-sN/2,"yoffset":-0.5}])
        sC.updateX();sC.updateY()
        sC.pindex=curPIndex
        curPIndex++

    }
    for(var j=0;j<zN;j++){
        console.log("addZ")
        var zC=addCardPic([detail[3+j*3],detail[4+j*3],detail[5+j*3]])
        zC.cX=centerx;zC.yoffset=0.5;zC.xoffset=j-zN/2;zC.cY=centery
        zC.updateX();zC.updateY()
        zC.pindex=curPIndex
        curPIndex++

    }
    for(var k=0;k<pN;k++){
        console.log("addp")
        var pC=addCardPic([detail[3+pN*3+k*3],detail[4+pN*3+k*3],detail[5+pN*3+k*3]])
        pC.cX=centerx;pC.cY=centery;pC.xoffset=j-pN/2;pC.yoffset=1.5
        pC.updateX();pC.updateY()
        pC.pindex=curPIndex
        curPIndex++

    }
}
function addWuguCards(detail){
    var n=detail[0]
    var tn =n>4? 4: n
    for (var i = 0;i<tn;i++ )
    {

        var zC=addCardPic([detail[1+i*3],detail[2+i*3],detail[3+i*3]])
        zC.cX=centerx;zC.yoffset=-0.5;zC.xoffset=i-tn/2;zC.cY=centery
        zC.updateX();zC.updateY()
        zC.pindex=curPIndex
        curPIndex++
    }
    for(i=4;i<n;i++){
        zC=addCardPic([detail[1+i*3],detail[2+i*3],detail[3+i*3]])
        zC.cX=centerx;zC.yoffset=0.5;zC.xoffset=(i-4)-(n-4)/2;zC.cY=centery
        zC.updateX();zC.updateY()
        zC.pindex=curPIndex
        curPIndex++
    }


}

function zA(detail){//zhuangbei little animation

    var p=playerFrames[detail[3]]
    p.zA(detail)
}

function createAnimationAtPlayer(detail){
    var p=playerFrames[detail[0]]
    var thed=detail.slice(1,5)
    //console.log(thed)
    thed.push(p.centerx-thed[2]/2)
    thed.push(p.centery-thed[3]/2)
    createAnimation(thed)
}

function updateHCN(detail){
    var p=playerFrames[detail[0]]
    p.handcardnum=detail[1]
}

function addshenfenChooseButton(detail){
    var p=playerFrames[detail[0]]
    p.firstshenfenChooseButton(detail[1])
}
function sleepPlayer(detail){
    playerFrames[detail[0]].sleep(detail[1])
}
function addHumanSkill(detail){
    var s={"name":detail[0],"pindex":curPIndex++}
    skModel.append(s)

}

function setPicFade(detail){
    if(detail[0]=="card"){
        for(var j=0;j<allOnDeskcards.length;j++){
            var c=allOnDeskcards[j]
            if(c.pindex==detail[1]){
                c.state="fake"
                break
            }
        }
    }
    else if(detail[0]=="player"){
        var p=playerFrames[detail[1]]
        p.state="cantChosen"
    }
}

function restoreFade(detail){
    if(detail[0]=="card"){
        for(var j=0;j<allOnDeskcards.length;j++){
            var c=allOnDeskcards[j]
            if(c.pindex==detail[1]){
                c.state="cantChosen"
                break
            }
        }
    }
    else if(detail[0]=="player"){
        var p=playerFrames[detail[1]]
        p.state="canChosen"
    }
}
