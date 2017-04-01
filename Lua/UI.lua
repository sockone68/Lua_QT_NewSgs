function AddInfoBar( s )
	if qml then
		callQmlF("addInfoBar",s)
	else

		addInfoBar(s)
		printForGame(s)
	end
end
function stdShowButton( okFunc,cancelFunc,okC,cancelC )
	if qml then
		qmlOkBFunc=okFunc
		qmlCancelBFunc=cancelFunc
		qmlOkBC=okC
		qmlCancelBC=cancelC
		if qmlOkBFunc==doNothing then
			theClickedButton=nil
			qmlOkBFunc=function() 
				theClickedButton={name="okButton"} 
				printForGame("点了确定")
			end
		end
		callQmlF("showBs","")
	else
		addOkB(okFunc,okC)
		curButtonSet[1]=curPIndex
		addCancelB(cancelFunc,cancelC)
		curButtonSet[2]=curPIndex
		theClickedButton=nil
	end
	
end

function clearButtons()
	if qml then
		callQmlF("hideBs","")
	else
		for _,v in pairs(curButtonSet) do
			DeletePic(v)
		end
		curButtonSet={}
	end
	
end
function addCardPileDisplay( ... )
	atp("牌堆牌数",1290,40,100,50);
	afteraddpic( )
	cardNumberPI=curPIndex
end
function addQipaiPileDisplay( ... )
	atp("qipai",1290,90,100,50);
	afteraddpic( )
	qiCardNumberPI=curPIndex
end

function SetCardpileNumDisplay(s)
	currentCardpileDisplayNum=s
	if qml then
		callQmlF("updateMN","剩余"..s)
	else
		ctfp("剩余"..s,AllPicIndexes[cardNumberPI])
	end
	printForGame("剩余"..s)
end

function cardpileNumDisplayChange(num)
	currentCardpileDisplayNum=currentCardpileDisplayNum+num
	SetCardpileNumDisplay(currentCardpileDisplayNum)
end

function UIBeforeGameStartSetting()
	if qml then
		callQmlF("gameStart","")
	else
		addCardPileDisplay()
		addQipaiPileDisplay()
	end
	SetCardpileNumDisplay(#currentPile)
end

function waitHumanClickForChupai( ... )
	AddInfoBar("请出牌")
	clickstate("wait human click for chupai")
	clearPicSelection()--会导致selection事件
	preClickState="wait human click for chupai"
	curSelectedCards={}
	curSelectedPlayers={}

	waitClick()
end

function waitHumanQipai()
	AddInfoBar("请弃"..HumanQiN.."张手牌")
	clickstate("wait human qipai")
	clearPicSelection()
	preClickState="wait human qipai"
	waitClick()
end

function UISetWjPic( player,thewujiang )
	if qml then 
		local theSetFunc=function (pin,count)
			local t = WjPPosAssignment[NUM][count]
			
			theTable1={count,pin,thewujiang.shili,player.maxLife,player.position,Ww,Wh,t[1],t[2]}
			callQmlFTable("setWjPic",theTable1)
			addQp(player)
			if player~=Thezhu and not player.ishuman then
				callQmlFTable("addshenfenChooseButton",{player.position,"unknown"})
			
			else
				
				callQmlFTable("addshenfenChooseButton",{player.position,player.shenfen})
			end
		end
		
		player:SetWjPic(thewujiang.pinyin,theSetFunc)
	else
		player:SetWjPic(thewujiang.pinyin,player.setWjPic)
	end
end

function HumanZButtonLeftAnim(b)
	if qml then
		callQmlFTable("zA",{-1,2,b.card.znum,TheHuman.position})
	else
		PMA(AllPicIndexes[b.pindex],-50,0,cardAnimTime*500)
	end
end
function HumanZButtonRightAnim(b)
	if qml then
		callQmlFTable("zA",{1,2,b.card.znum,TheHuman.position})
	else
		PMA(AllPicIndexes[b.pindex],50,0,cardAnimTime*500)
	end
end

function HumanZButtonLittleLeftAnim(b)
	if qml then
		callQmlFTable("zA",{-1,1,b,TheHuman.position})
	else
		PMA(AllPicIndexes[b.pindex],-10,0,cardAnimTime*500)
		b.littleL=true
	end
end
function HumanZButtonLittleRightAnim(b)
	if qml then
		callQmlFTable("zA",{1,1,b,TheHuman.position})
	else
		if b.littleL then
			PMA(AllPicIndexes[b.pindex],10,0,cardAnimTime*500)
			b.littleL=false
		end
	end
end

function HumanZButtonAllLittleLeft()
	for i,v in pairs(TheHuman.zhuangbeis) do
		if v~=0 then
			if qml then
				HumanZButtonLittleLeftAnim(i)
			else
				HumanZButtonLittleLeftAnim(v.HumanButton)
			end
		end
	end
end

function HumanRestoreZButtons()
	--printForGame("test")
	for i,v in pairs(TheHuman.zhuangbeis) do
		if v~=0  then
			if qml then
				HumanZButtonLittleRightAnim(i)
			else
				HumanZButtonLittleRightAnim(v.HumanButton)
			end
		end
	end
end

function clickWhenButton(responseItem)
	if getmetatable(responseItem)==Button then
		--AddInfoBar("你单击了按钮")
		playSound("button/menu.mp3",true)
		
		clearButtons()
		clickState=""
		
		theClickedButton=responseItem
		if responseItem.Continue then
			preSetFunc=responseItem.answerFunc
			RGFPBWHI()--resumeGameFromPauseByWatingHumanInput
		else
			responseItem.answerFunc()
		end
	elseif TContainsA(curSelectedCards,responseItem) then
		responseItem:responseClick()
		curSelectedCards={}
		clearPicSelection()
		restoreAllFade()
		clearButtons()
		clickstate(preClickStateWithCard)
		AddInfoBar(preInfo)
	elseif TContainsA(curSelectedPlayers,responseItem) then
		curSelectedPlayers={}
		clearPicSelection()
		restoreAllFade()
		clearButtons()
		clickstate(preClickStateWithPlayer)
		AddInfoBar(preInfoForClickPlayer)
	elseif getmetatable(responseItem)==Player then
		if playerHumanChosen==true then

		else

		end
	end
end
table.insert(PressFuncSet,{"wait human click button",clickWhenButton})



function qiNPaiAnim( player,thecards,text)
	--[[
	local function NetworkQiNPaiAnim()
		printForGame("NEtworKQPAI")
		local ct = {}
		for i,v in pairs(thecards) do
			ct[i]=v.id
		end
		clientTellEveryOneInRoom{actionName="notifyQiNPaiAnim",playername=player.name,cardsid=ct}
	end
	--]]
	--local function realAnim()
		if qml then
			local notOndesk = {}
			local theOndesk = {}
			for i,v in ipairs(thecards) do
				if not v.OnDesk then
					table.insert(notOndesk,v)
				else
					table.insert(theOndesk,v)
				end
			end
			if #notOndesk>0 then
				theTable1={#notOndesk,player.position}
				for i=1,#notOndesk do
					table.insert(theTable1,notOndesk[i].english)
					table.insert(theTable1,notOndesk[i].suit)
					table.insert(theTable1,NumberToText(notOndesk[i].number))
					table.insert(theTable1,player.CN..(text or ""))--卡牌上的特殊文字"弃牌"
				end
				callQmlFTable("thePlayerQiNPai",theTable1)
			end
			if #theOndesk>0 then
				theTable1={}
				table.insert(theTable1,#theOndesk)
				for i=1,#theOndesk do
					table.insert(theTable1,theOndesk[i].qpindex)
				end
				table.insert(theTable1,"center")

				callQmlFTable("onDeskCardsAnim",theTable1)
			end
		else

			local n = #thecards

			local cardPT = {}
			local noti = {}
			local zX,y =player.cX- n*cardWidth/2,player.cY-cardHeight/2
			for i,v in ipairs(thecards) do
				if not v.OnDesk then
					cardPT[i]=v:AddCardPic(zX+(i-1)*cardWidth,y)
				else
					cardPT[i]=v.pindex
					table.insert(noti,i)
				end
			end

			for i=1,n do
				local ti = AllPicIndexes[cardPT[i]]
				if not TContainsA(noti,i) then
					PMA(ti,700-player.cX,480-player.cY,cardAnimTime*1000)
				else
					PMA(ti,700-cardWidth/2-thecards[i].x,480-cardHeight/2-thecards[i].y,cardAnimTime*1000)
				end
			end
		end
	--end
	--realAnim()
--[[
	if not Strict then
		if isAtNet() then
			NetworkQiNPaiAnim()
		else
			realAnim()
		end
	else
		realAnim()
	end
	]]
end
function qiHumanHandcardAnim( thecards)
	local n = #thecards
	if qml then
		for i=1,n do
			callQmlF("removeFromHandcards",thecards[i].qpindex)
			
		end
		theTable1={}
		table.insert(theTable1,n)
		for i=1,n do
			table.insert(theTable1,thecards[i].qpindex)
			
		end
		table.insert(theTable1,"center")

		callQmlFTable("onDeskCardsAnim",theTable1)
		
	else
		
		for i=1,n do
			local theindex = AllPicIndexes[thecards[i].pindex]
			--printForGame(getPicX(theindex))

			PMA(theindex,700-getPicX(theindex)-(n/2-(i-1))*cardWidth,480-(getPicY(theindex)+cardHeight/2),cardAnimTime*1000)
		end
	end
	
	
		
	
end
function zhuangbeiAnim( from,thecard,to,Strict)
	if not to then
		to=from
	end
	local function NetworkZhuangbeiAnim()
		printForGame("THEANSWER")
		clientTellEveryOneInRoom{actionName="notifyZhuangbeiAnim",fromname=from.name,toname=to.name,cardid=thecard.id}
	end
	local function realAnim( ... )
		from:pointAnotherPlayer(to,Strict)
		if qml then 
			
			if from.ishuman then
				callQmlFTable("onDeskCardsAnim",{1,thecard.qpindex,"playercenter",to.position})
				callQmlF("removeFromHandcards",thecard.qpindex)
			else
				callQmlFTable("thePlayerZbAnim",{thecard.english,thecard.suit,NumberToText(thecard.number),from.position,to.position})
			end
			
		else
			
			--avl(from.cX,from.cY,to.cX,to.cY)
			if from.ishuman then

				local theindex = AllPicIndexes[thecard.pindex]
				--local tx,ty =(getIndexInT(from.cards,thecard)-1)*cardWidth,960-cardWidth
				local tx,ty =getPicX(theindex),getPicY(theindex)
				PMATD(thecard.pindex,theindex,to.cX- cardWidth/2-tx,to.cY-cardHeight/2-(ty),cardAnimTime*1000)
				--PMA(theindex,player.cX- cardWidth/2-tx,player.cY-cardHeight/2-(ty),cardAnimTime*500)
			else
				local x,y =from.cX- cardWidth/2,from.cY-cardHeight/2
				local tx,ty = to.cX- cardWidth/2,to.cY-cardHeight/2
				local theindex = thecard:AddCardPic(x,y)
				PMATD(theindex,AllPicIndexes[theindex],tx-x,ty-y,cardAnimTime*1000)
			end
			thecard.OnDesk=false
		end
	end
	if not Strict then
		if isAtNet() then
			NetworkZhuangbeiAnim()
		else
			realAnim()
		end
	else
		realAnim()
	end
end

function UIAddZhuangbei(player,c,num)
		zhuangbeiAnim( player,c,nil,true)
		if qml then
			callQmlFTable("addZb",{c.equipImageName,c.suit,NumberToText(c.number),num,player.position})
			local b = Button:new{name=c.text,card=c}
			c.HumanButton=b
			addQp(b)
		else
			local pw,py = 180,30
			--[[
			if player~=TheHuman then
				player:Apfp(0,Wh-py*(5-num),pw,py,"image/equips/"..c.equipImageName..".png")
				player:Apfp(pw-24,Wh-py*(5-num),24,24,imageDirForASuit(c.suit))
				--player:Apfp(pw-48,Wh-py*(5-num),24,24,imageDirForASuit(c.suit))
				atfp(c.text,AllPicIndexes[player.pindex],pw-48,Wh-py*(5-num),24,24,0x0)
				player[zhuangbeiTypeNameList[num].."PIndex"]=player.ppcurIndex
			else
		--]]
		debugPrint("UIAddZhuangbeiSSB")
			local zb=AddButton(player.x+0,player.y+Wh-py*(5-num),pw,py,"image/equips/"..c.equipImageName..".png","zhuangbeiButton")
			apfp(pw-24,0,24,24,imageDirForASuit(c.suit),AllPicIndexes[zb.pindex])
			atfp(c.text,AllPicIndexes[zb.pindex],pw-48,0,24,24,0x0)
			c.HumanButton=zb
			zb.card=c
			--end
		end
	
end

function UIPopZhuangbei(player,num)
	if qml then
		callQmlFTable("deleteZb",{num,player.position})
	else
		local result = player.zhuangbeis[num]
		if getmetatable(getmetatable(result))==Card then
			debugPrint("isCard")
		end
		debugPrint(type(result))
		if not result.HumanButton then
			debugPrint("NOBUTTON")
			result.HumanButton=debugZButton
		end
		clearButton(result.HumanButton)
		debugZButton=nil
	end
end

function moNpaiAnim( n,player )
	--if player.ishuman then
		if qml then 
			callQmlFTable("thePlayerMoNPai",{n,player.position})
		else
			local zX,y =700- n*cardWidth/2,480-cardHeight
			local p = player
			if not player.cX then
				p=getPlayerByName(player.name)
			end
			for i=1,n do
				local ti = AddCardBackPic(zX+(i-1)*cardWidth,y)
				PMATD(ti,AllPicIndexes[ti],p.cX-700,p.cY-380,cardAnimTime*1000)
			end
		end
	--end
end

function notHumanmo1PaiOnDeskAnimain(player,thecard)
	if qml then 
		callQmlF("removeFromHandcards",thecard.qpindex)
		callQmlFTable("onDeskCardsAnim",{1,thecard.qpindex,"playercenter",player.position})
	else
		local ti = thecard.pindex
		local tti = AllPicIndexes[ti]
		local tx = getPicX(tti)
		local ty = getPicY(tti)
		PMATD(ti,tti,player.cX-cardWidth/2-tx,player.cY-cardHeight/2-ty,cardAnimTime*1000)
		thecard.OnDesk=false
		thecard.pindex=-1
	end
end

function UIAddPandingCard( player,card)
	if qml then
		callQmlFTable("addPandingIcon",{player.position,card.iconDir})
	else
		card.iconX=player.x+Ww-30*#player.pandings
		card.iconY=player.y+Wh
		AddPicCantSelectAndMove(card.iconX,card.iconY,28,28,card.iconDir)
		card.iconIndex=curPIndex
	end
end

function UIDeletePandingCard( player,card)
	if qml then
		callQmlF("removePandingIcon",player.position)
	else
		DeletePic(card.iconIndex)
		player:arrangePandingCardsPos()
		
	end
end

function UIGetHurt(player,hurtN)
	if qml then
		for i=1,hurtN do
			callQmlF("gethurt",player.position)
		end
	else
		for j=1,hurtN do
			local lifeBefore = player.life+hurtN
			local i = lifeBefore-j+1
			if i>0 then
				player:Dpfp(player.lifeBarIndexs[i])
				
				player:Apfp(Ww-33,Wh-33*i,33,33,"image/system/magatamas/0.png")
				player.lifeBarIndexs[i]=player.ppcurIndex
			end
			--sleep(1)
		end
	end
end

function UIHuixie(player)
	if qml then
		callQmlF("huixie",player.position)
	else
		local i = player.life
		printForGame("血"..i)

		if i>0 then
			player:Dpfp(player.lifeBarIndexs[i])
			
			player:Apfp(Ww-33,Wh-33*i,33,33,"image/system/magatamas/3.png")
			player.lifeBarIndexs[i]=player.ppcurIndex
		end
	end
end

function UIPanding(player,thecard)
	if qml then
		callQmlFTable("addPandingCard",{thecard.english,thecard.suit,NumberToText(thecard.number),player.CN.."判定"})
		addQp(thecard)
	else
		thecard:AddCardPic(700-cardWidth/2,480)
		ctfp(thecard.text.."\n判定",AllPicIndexes[thecard.pindex])
	end
end


function addPicsForHumanShunChai(to)
	local n = #to.handcards
	HumanShunSCards={}
	for i=1,n do
		table.insert(HumanShunSCards,to.handcards[i])
		to.handcards[i].inHumanShunSCards=true
		to.handcards[i].ShunSIndex=i
	end
	HumanShunZs={}
	for i,v in pairs(to.zhuangbeis) do
		if v~=0 then
			table.insert(HumanShunZs,v)
			v.inHumanShunZs=true
		end
	end
	HumanShunPDs={}
	for i,v in pairs(to.pandings) do
		table.insert(HumanShunPDs,v)
		v.inHumanShunPDs=true
	end

	if qml then
		theTable1={#HumanShunSCards,#HumanShunZs,#HumanShunPDs}
		for i,v in pairs(HumanShunSCards) do
			addQp(v)
		end
		for i,v in pairs(HumanShunZs) do
			table.insert(theTable1,v.english)
			table.insert(theTable1,v.suit)
			table.insert(theTable1,NumberToText(v.number) )
			addQp(v)
			v.OnDesk=true
		end
		for i,v in pairs(HumanShunPDs) do
			table.insert(theTable1,v.english)
			table.insert(theTable1,v.suit)
			table.insert(theTable1,NumberToText(v.number))
			addQp(v)
			v.OnDesk=true
		end

		callQmlFTable("addShunChaiCards",theTable1)
	else
		local zX,y =700- n*cardWidth/2,480-cardHeight
		for i=1,n do
			to.handcards[i]:AddCardBackPic(zX+(i-1)*cardWidth,y)
			AllIndexesPic[curPIndex]=to.handcards[i]
		end
		y=y+cardHeight
		zX=700- 4*cardWidth/2
		for i,v in pairs(HumanShunZs) do
				local zz = zX+(i-1)*cardWidth
				v:AddCardPic(zz,y)
			
		end
		y=y+cardHeight
		for i,v in pairs(HumanShunPDs) do
			v:AddCardPic(zX+(i-1)*cardWidth,y)
		end
	end
end
function deletePicsForHumanShunChai(c)
	if qml then
		for i,v in pairs(HumanShunSCards) do
			callQmlF("deleteCard",v.qpindex)	
		end
		for i,v in pairs(HumanShunZs) do
			if v~=c then
				callQmlF("deleteCard",v.qpindex)	
			end
		end
		for i,v in pairs(HumanShunPDs) do
			if v~=c then
				callQmlF("deleteCard",v.qpindex)	
			end
		end
		if c.player==TheHuman then
			for i,v in pairs(HumanShunSCards) do
					
				v.OnDesk=true
			end
		end
	else
		for i,v in pairs(HumanShunSCards) do
					
			DeletePic(v.cardbackIndex)
		end
		for i,v in pairs(HumanShunZs) do
			if v~=c then
				DeletePic(v.pindex)
			end
		end
		for i,v in pairs(HumanShunPDs) do
			if v~=c then
				DeletePic(v.pindex)
			end
		end
		if c.player==TheHuman then
			for i,v in pairs(HumanShunSCards) do
					
				v.OnDesk=true
			end
		end
	end
end

function UIShun( from,to )
	if to~=TheHuman then
		if qml then
			callQmlFTable("thePlayerZbAnim",{-1,0,0,to.position,from.position})
		else
			local ti = AddCardBackPic(to.cX-cardWidth/2,to.cY-cardHeight/2)
			PMATD(ti,AllPicIndexes[ti],from.cX-to.cX,from.cY-to.cY,cardAnimTime*1000)
		end
	end
end

function UIAddHumanHandcard(player,card )
	if qml then 
		if not card.OnDesk then
			callQmlFTable("addHumanHandCard",{card.english,card.suit,NumberToText(card.number)})
			addQp(card)
		else
			callQmlFTable("onDeskCardsAnim",{1,card.qpindex,"humanhand"})
		end
	else
		local n = #player.handcards
		local x = curHumanWjp[1] - n*cardWidth 
		local tx =1
		local ty = 960-cardHeight
		
		if x>0 then
			tx=(n-1)*cardWidth
		else
			
			tx=curHumanWjp[1]-cardWidth
		end
		if not card.OnDesk then
			card:AddCardPic(tx,ty)
		else
			sleep(50)

			local ii = AllPicIndexes[card.pindex]
			if not getCardDebug then
				
				PMA(ii,tx-getPicX(ii),ty-getPicY(ii),cardAnimTime*1000)
			else
				PMA(ii,tx-card.x,ty-card.y,cardAnimTime*1000)
			end
		end
	end
end

function UIAddWuguCards( wuguCards )
	local n = #wuguCards
	if qml then
		theTable1={n}
		for i=1,#wuguCards do
			table.insert(theTable1,wuguCards[i].english)
			table.insert(theTable1,wuguCards[i].suit)
			table.insert(theTable1,NumberToText(wuguCards[i].number))
			addQp(wuguCards[i])
			wuguCards[i].OnDesk=true
		end
		callQmlFTable("addWuguCards",theTable1)
	else
		local tn = (n>4 and 4) or n
		for i = 1,tn do
			wuguCards[i]:AddCardPic(700-tn*cardWidth/2+(i-1)*cardWidth,380)
		end
		for i = 5,n do
			wuguCards[i]:AddCardPic(700-4*cardWidth/2+(i-5)*cardWidth,380+cardHeight)
		end
		
	end
end

function UIDie( player )
	if qml then

	else
		setGray(AllPicIndexes[player.pindex])
		--setColorize(AllPicIndexes[self.pindex],0x000000)
		player:Apfp(0,Wh/2,Ww,Ww/172*112,"image/system/death/"..player.shenfen..".png")
	end
end

function UICreateAnimation(player,dir,qmldir)
	if qml then
		theTable1={player.position,qmldir,26,229,177}
		callQmlFTable("createAnimationAtPlayer",theTable1)
	else
		if player==TheHuman then
			AAM(700-229/2,player.y,25,229,177,dir)
		else
			AAM(player.cX-229/2,player.y+Wh,25,229,177,"animationImage/weapon/axe")
		end
	end
end

function Card:raise()
	if qml then
		callQmlF("changeCardUpdown",self.qpindex)
	else
		PMA(AllPicIndexes[self.pindex],0,-30,cardAnimTime*200)
	end
end
function Card:down()
	if qml then
		callQmlF("changeCardUpdown",self.qpindex)
	else
		PMA(AllPicIndexes[self.pindex],0,30,cardAnimTime*200)
	end
end

function  Player:updateCardNDisplay(number)
	if qml then
		
		callQmlFTable("updateHCN",{self.position,number or #self.handcards})
	else
		ctfp(""..(number or #self.handcards).."c",AllPicIndexes[self.WjPIndex])
	end
end
function  Player:arrangeCardsPos(  )
	if self==TheHuman then
		if qml then 
			--emitCallQmlFunction("arrangeHumanHandcards","")
		else
			
			sleep(50)
			local x = curHumanWjp[1] - #self.handcards*cardWidth 
			if x>0 then
				for i,v in pairs(self.handcards) do
					local theindex = AllPicIndexes[v.pindex]
					PMA(theindex,(i-1)*cardWidth-getPicX(theindex),0,cardAnimTime*500)
				end
			else
				for i,v in pairs(self.handcards) do
					local theindex = AllPicIndexes[v.pindex]
					if i==1 then
						PMA(theindex,0-getPicX(theindex),0,cardAnimTime*500)
					else
						PMA(theindex,(i-1)*cardWidth+(i-1)*x/(#self.handcards-1)-getPicX(theindex),0,cardAnimTime*500)
					end
					
				end
			end	
			
		end
	end
end

function Player:pointAnotherPlayer(p,Strict)
	local function realp()

		if qml then
			
			callQmlFTable("pointPlayerAnim",{self.position,p.position})
		else
			avl(self.cX,self.cY,p.cX,p.cY)
		end
	end

	if not Strict then
		if isAtNet() then
			clientTellEveryOneInRoom{actionName="notifyPointLine",fromname=self.name,toname=p.name}
		else
			realp()
		end
	else
		realp()
	end
end

function AddshenfenChooseButton(x,y,n)
	n=n or "unknown"
	local b=AddButton(x,y,100,30,"image/system/roles/"..n..".png","shenfenChooseButton")
	b.isStaticButton=true
	b.n=n
	b.list={}
	local  function addChildren(theb)
		theb.list={}
		for i,v in pairs(shenfenList) do
			local bb=AddshenfenChooseButton(x,y+30*i,v)
			bb.mother=theb
			table.insert(theb.list,bb)
		end
		theb.spread=true
	end 
	local function deleteChildren(theb)
		for i,v in pairs(theb.list) do
			DeletePic(v.pindex)
			v=nil
		end
		theb.spread=false
	end 
	b.func=function ()
		if b.n=="unknown" then
			if not b.spread then
				b.list={}
				addChildren(b)
			else
				deleteChildren(b)
				
			end
		else
			if b.mother then
				deleteChildren(b.mother)
				local xx,yy = b.mother.x,b.mother.y
				DeletePic(b.mother.pindex)
				b.mother=nil
				AddshenfenChooseButton(xx,yy,b.n)
			elseif b.spread then
				deleteChildren(b)
			else
				addChildren(b)
			end
		end
	end
	return b
end


function qmlLog( s )
	callQmlF("log",s)
end

function qmlgetstring( s )
	callQmlF("log","index is "..s)
	thestring=(s+1)
	resume()
end

curQPIndex=0
qmlSpecialPicByIndex={}
function addQp( p )
	qmlSpecialPicByIndex[curQPIndex]=p
	p.qpindex=curQPIndex
	curQPIndex=curQPIndex+1
end
function qmlStdPressedFunc(param )
	param=tonumber(param)
	printForGame("click:"..param)
	local responseItem = qmlSpecialPicByIndex[param]
	if responseItem then
		printForGame(responseItem:info())
		if  responseItem.isStaticButton==true then
			responseItem.func()
		else
			local flag = 1
			for _,v in pairs(PressFuncSet) do
				if clickState==v[1] then
					flag=0
					v[2](responseItem)
					break
				end
			end
			if flag==1 then
				printForGame("BigWrong!state="..gameState)
				printForGame("clickState="..clickState)
			end
		end
	end
end

function clickWhenQMLButton(bname )--called by qml
	playSound("button/menu.mp3",true)
		
	clearButtons()
	clickState=""
	local func = _G["qml"..bname.."BFunc"]
	--theClickedButton=responseItem
	if _G["qml"..bname.."BC"] then
		preSetFunc=func
		resume()
	else
		func()
	end
end

fadePics={}
function fadeT1ExceptT2( t1,t2 )
	--restoreAllFade()
	
	for _,v in pairs(t1) do
		if qml then
			if getmetatable(v)==Player then
				callQmlFTable("setPicFade",{"player",v.position})
			else
				callQmlFTable("setPicFade",{"card",v.qpindex})
			end
		else
			setFade(AllPicIndexes[v.pindex])
			
		end
		table.insert(fadePics,v)
	end

	for _,v in pairs(t2) do
		
		local flag,_,i = TContainsA(fadePics,v)
		if flag then 
			if qml then
				if getmetatable(v)==Player then
					callQmlFTable("restoreFade",{"player",v.position})
				else
					callQmlFTable("restoreFade",{"card",v.qpindex})
				end
			else
				restoreFade(AllPicIndexes[v.pindex]) 
				
			end
		end
		table.remove(fadePics,i)
	end
	
end

function restoreAllFade()
	for _,v in pairs(fadePics) do
		if qml then
			if getmetatable(v)==Player then
				callQmlFTable("restoreFade",{"player",v.position})
			else
				callQmlFTable("restoreFade",{"card",v.qpindex})
			end
		else 
			restoreFade(AllPicIndexes[v.pindex])
		end
	end
	fadePics={}
end
