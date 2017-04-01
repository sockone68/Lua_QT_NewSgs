
Player=AbstractPlayer:new{gongjiJuli=1,ishuman=false,alive=true,ppcurIndex=0,}

--position,shenfen,wujiang,skills,handcards,zhuangbeis,friends,enemies,ppIndexs,WjPIndex
function getPlayerByName(name)--for client,or server's special use
	for i,v in pairs(players) do
		if v.name==name then
			return v
		end
	end
	return getRoomPlayerByName(name)
end
ttClassRegister{Player,"name","player",getPlayerByName}
--ppcurIndex：玩家图片子图片当前最大序号,目前没找到原因，但是需要从0开始
--ppIndexs:用于确保删除后序号依然有效，因此访问子图片均需要通过self.ppIndexs[theIndex]的形式
zhuangbeiSkill=Skill:new{name="zhuangbeiSkill"}
otherBroadcastAnswerFuncList={}
function Player:new( o )
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	o.ppIndexs={}
	o.handcards={}
	o.zhuangbeis={0,0,0,0}
	o.pandings={}
	o.skills={zhuangbeiSkill:new{player=o}} 
	o.enemies={} o.friends={o}
	o.skillButtons={}
	--broadcastAnswerList可以满足一个输入，多个响应，如果想让某个同名的响应先被触发，
	--只需将其调到最前面,想要覆盖，直接覆盖即可
	o.broadcastAnswerList={
	
		{"gameStart",Player.gameStart},
		{"Panding",Player.pandingJieduan},
		{"Mopai",Player.mopaiJieduan},
		{"Chupai",Player.chupaiJieduan},
		{"Qipai",Player.qipaiJieduan},
		{"getHurt",Player.getHurt},
		{"judgeQipai",Player.judgeQipai},
		
		{"useAoeJinnang",Player.resposeAoe},
		{"goingDie",Player.resposeQiutao},
		{"demandDachu",Player.responseDachu},
		{"beiChai",Player.responseBeiChai},
	}
	for _,v in pairs(otherBroadcastAnswerFuncList) do
		table.insert(o.broadcastAnswerList,v)
	end
	o.resetStateTable={}
	return o
end

function Player:getNetworkPublicInfo()
	return {socketIndex=self.socketIndex,nickName=self.name,ishuman=self.ishuman,name=self.name,atNet=self.atNet}
end

WjImgDir="image/general/"
function Player:xuanjiang( thewujiang)

	self.wujiang=thewujiang
	if NUM>4 and self.shenfen=="zhu" then
		self.life=thewujiang.life+1
	else
		self.life=thewujiang.life
	end
	
	self.maxLife=self.life
	self.isMale=thewujiang.isMale
	self.CN=thewujiang.CN
	printForGame("position:"..self.position.." name:"..self.name.." pinyin:"..self.wujiang.pinyin)
	---[[
	if not self.isInServer then
		debugPrint("setpic")
		UISetWjPic( self,thewujiang )
	else
		debugPrint("not setpic")
	end
	--]]

	for _,v in pairs(thewujiang.skills) do
		local  vv = v:new()
		vv:addSelf(self)
		
	end
end


Wjw=250 
Wjh=199/158*Wjw
Wjws=200 
Wjhs=199/158*Wjws
HumanWjp={1400-Wjw,960-Wjh}
HumanWjps={1400-Wjws,960-Wjhs}
WjPPosAssignment={
	{},
	{HumanWjp,{(1400-Wjw)/2,0}},
	{HumanWjp,{850,0},{200,0}},
	{HumanWjp,{1400-Wjw,960-2*Wjh-100},{(1400-Wjw)/2,0},{0,960-2*Wjh-100}},
	{HumanWjp,{1400-Wjw,960-2*Wjh-100},{(1400-Wjw)/2+200,0},{(1400-Wjw)/2-200,0},{0,960-2*Wjh-100}},
	{HumanWjps,{1400-Wjws,960-2*Wjhs-100},{(1400-Wjws)/2+300,0},{(1400-Wjws)/2,0},{(1400-Wjws)/2-300,0},{0,960-2*Wjhs-100}},
	{HumanWjps,{1400-Wjws,960-2*Wjhs-100},{(1400-Wjws)/2+400,0},{(1400-Wjws)/2+130,0},{(1400-Wjws)/2-130,0},{(1400-Wjws)/2-400,0},{0,960-2*Wjhs-100}},
	{HumanWjps,{1400-Wjws,960-2*Wjhs-50},{1400-Wjws,960-3*Wjhs-100},{(1400-Wjws)/2+300,0},{(1400-Wjws)/2,0},{(1400-Wjws)/2-300,0},{0,960-3*Wjhs-100},{0,960-2*Wjhs-50}},
}
Ww,Wh = 1,1
function Player:Apfp( x,y,w,h,dir )
	--给图片添加子图片，此子图片不可移动
	apfp( x,y,w,h,dir,AllPicIndexes[self.WjPIndex])
	self.ppcurIndex=self.ppcurIndex+1
	if self.ppcurIndex~=1 then
		table.insert(self.ppIndexs,self.ppIndexs[#self.ppIndexs]+1)
	else
		table.insert(self.ppIndexs,1)
	end
end
function Player:Dpfp(theppIndex)
	local theindex = self.ppIndexs[theppIndex]
	dpfp(AllPicIndexes[self.WjPIndex],theindex)
	for i=theppIndex,#self.ppIndexs do
		self.ppIndexs[i]=self.ppIndexs[i]-1
	end
	--self.ppcurIndex=self.ppcurIndex-1
	
end
function Player:SetWjPic(pinyin,func)
	local nextP=TheHuman or myPlayer
	
	local count=1
	repeat
		
		if nextP==self then
			if NUM<6 then 
				Ww,Wh=Wjw,Wjh
				curHumanWjp=HumanWjp
			else
				Ww,Wh=Wjws,Wjhs
				curHumanWjp=HumanWjps

			end
			if func==self.setWjPic then
				
				func(self,pinyin,count)
			else
				
				func(pinyin,count)
			end
			break
		else
			count=count+1
			nextP=xiajia(nextP)
		end
		
	until nextP==(TheHuman or myPlayer)
end

function Player:setWjPic(pinyin,count)
	local t = WjPPosAssignment[NUM][count]
	self.x,self.y,self.w,self.h=t[1],t[2],Ww,Wh
	self.cX=self.x+self.w/2
	self.cY=self.y+self.h/2

--addColorPic(t[1],t[2],Ww,Wh,0x000000,false,false,"")
--afteraddpic()
	AddPicCantMove(t[1],t[2],Ww,Wh,WjImgDir..pinyin..".png")
	self.WjPIndex=curPIndex
	self.pindex=self.WjPIndex
	
	--printForGame(AllPicIndexes[self.WjPIndex])
	AllIndexesPic[curPIndex]=self--let self(a player ) be the element who is in charge
	
	atfp("",AllPicIndexes[self.WjPIndex],0,Wh/2,100,100,0x005500)
	self:updateCardNDisplay()

	AddPicCantSelectAndMove(t[1],t[2]+Wh,Ww,10,"image/timeBar.png")
	self.timeBarIndex=curPIndex
	self:Apfp(Ww-30,0,30,30,"image/po/po"..self.position..".png")
	
	--self:Apfp(0,0,100,30,"image/system/roles/"..self.shenfen..".png")
	--AddshenfenChooseButton(self.x,self.y,self.shenfen)
	if self~=Thezhu and self~=(TheHuman or myPlayer) then
		AddshenfenChooseButton(self.x,self.y,"unknown")
	else
		AddshenfenChooseButton(self.x,self.y,self.shenfen)
	end

	self.lifeBarIndexs={}
	for i=1,self.life do
		self:Apfp(Ww-33,Wh-33*i,33,33,"image/system/magatamas/3.png")
		self.lifeBarIndexs[i]=self.ppcurIndex
	end
	if self==(TheHuman or myPlayer) then
		mP(AllPicIndexes[self.timeBarIndex],600,620)
		--PMA(self.timeBarIndex,-200,-200)
		--printForGame(self.timeBarIndex)
	end
	--printForGame("hey")
			
	
end

function Player:info(  )
	if self.wujiang then
		return self.position.." "..self.name.." "..self.wujiang.pinyin.." "..(self.shenfen or "")
	else
		return self.position.." "..self.name.." "..(self.shenfen or "")
	end
end
function Player:infoHTML(  )
	return "<font color=Green>"..self:info().."</font> "
end

--[[
function Player:answerBroadcast(detail)
	local flag = 0
	if not self:cantResponse(detail)  then
	--sleep(1)
		debugPrint("BEFORE"..detail["act"])
		for i=1,#self.broadcastAnswerList do
			if self.broadcastAnswerList[i] then
				if self.broadcastAnswerList[i][1]==detail["act"] then
					debugPrint("CAtCH")
					 self.broadcastAnswerList[i][2](self,detail)
					 debugPrint 'AFtERANSWER'
					 flag=1
				end
			end
		end
	else
		debugPrint("CANtreSPONE")
	end
	debugPrint("FLAG is"..flag)
	--死亡或者没有相应的响应函数则返回默认响应，后来改为直接完成广播回应
	if self.isInClient then
		sendTableToServer{actionName="finishBroadcast",detail=detail}
		debugPrint("AfterClientfinish")
	else
		debugPrint("NOTCLIENTFINISH")
		finishAnsBroadcast(self.isInServer)
	end
end
--]]
function FindIndexOfAnswerFunc(player,act,func)
	for i,v in pairs(player.broadcastAnswerList) do
		if v[1]==act and v[2]==func then
			return i
		end
	end
	return 1
end

function Player:removeAnswerFunc(act,func)
	local index =FindIndexOfAnswerFunc(self,act,func)
	if index then
		debugPrint("remove theAnswerFunc")
		table.remove(self.broadcastAnswerList,index)
	end
end

function Player:cantResponse( detail )
	
	if self.alive==false or gameState=="End" then
		return true
	else
		
		return false
	end
end

function Player:cardMax( )
	return self.life
end
function Player:getCard(card,Strict)
	if getmetatable(getmetatable(card))==Card then

		if not self.atNet or Strict then
			table.insert(self.handcards,card)
			
			card.player=self
			card.skill.player=self
			if TheHuman then
				self:updateCardNDisplay()
			end
			if isClientHuman(self) then
				
				UIAddHumanHandcard(self,card )
				
				card.inHumanHand=true
				--self:arrangeCardsPos()
				--table.insert(player.handcardPics,curPIndex)
		
			end
			if card.skill and card.type~="zhuangbei" then
				--card.skill.player=self
				if card.skill.addSelf then 
					card.skill:addSelf(self,card) 
				end
			end
			if self.atNet then
				clientTellEveryOneInRoom{actionName="notifyHandChange",playername=self.name,num=#self.handcards}
			end
		elseif notServerHuman(self) then
		
			self:TellServer{actionName="getCard",card=card,player=self}

			
		end
	
	end
end

function Player:popCard( thecard,isN)--isN related to arangeCardPos
	local result =table.remove(self.handcards,getIndexInT(self.handcards,thecard))

	if not self.atNet then
		self:updateCardNDisplay()
	elseif notServerHuman(self) then
		if self.isInClient then
			sendTableToServer{actionName="popcard",card=thecard}
		end
		clientTellEveryOneInRoom{actionName="notifyHandChange",playername=self.name,num=#self.handcards}
	end

	if self.ishuman then
		result.inHumanHand=false
		result.clicked=false
		--DeletePic(thecard.pindex)
		if not isN and self.ishuman then
			if qml then

			else
				self:arrangeCardsPos()
			end
		end
	end
	return result
end

function Player:dachu(thecard)
	thecard:playSound()
	dachuQiNPai(self,{thecard},"打出")
end
function Player:popZhuangbei(num,Strict)
	debugPrint("BB")
	local result = self.zhuangbeis[num]
	local function real()
		debugPrint("AA")
		result.inZhuangbeis=false
		self.zhuangbeis[num]=0

		result.skill:removeSelf()
	end
	local function tellS()
		if not Strict then
			self:TellServer{actionName="popZhuangbei",num=num,playername=self.name}
		end
	end
	if not self.atNet then
		UIPopZhuangbei(self,num)
		real()
	elseif notServerHuman(self) then
		
		if myPlayer then
			tellS()
		else
			tellS()
			real()
		end
	end
	
	
	return result
end

function Player:AddPandingCard(card,Strict)
	
	if not self.atNet or Strict then
		table.insert(self.pandings,card)
		card.funcP=self
		card.player=self

		if not self.atNet then
			UIAddPandingCard( self,card)
		else
			if isClientHuman(self) then
				UIAddPandingCard( self,card)
			end
		end
	elseif not TheHuman or notServerHuman(self)  then
		self:TellServer{actionName="AddPandingCard",cardid=card.id,playername=self.name}
	end
	
	
end

function Player:DeletePandingCard(card,Strict)
	
	table.remove(self.pandings,getIndexInT(self.pandings,card))

	if not self.atNet then
		UIDeletePandingCard( self,card)
	elseif notServerHuman(self)  then
		self:TellServer{actionName="DeletePandingCard",cardid=card.id}
	end

	return card
end

function Player:arrangePandingCardsPos()
	local n = #self.pandings
	for i,v in pairs(self.pandings) do
		local theindex = AllPicIndexes[v.iconIndex]
		PMA(theindex,self.x+Ww-30*i-v.iconX,0,cardAnimTime*500)
		v.iconX=self.x+Ww-30*i
		v.iconY=self.y+Wh
	end
end



function Player:resetState( )
	for i ,v in pairs(self.resetStateTable) do
		self[v]=false
	end
end

function Player:gameStart( detail )
	--Sleep(self)
	moNPai(self,4)
	
end

--各种阶段可以被重写
function Player:pandingJieduan( detail )
	if self==detail.theplayer or self.name==detail.theplayername then
		while #self.pandings~=0 do
			local thecard = self.pandings[1]

			local JT = {act="useJinnang",jinnang=thecard,to=self,harm=true,disabled= false,}
	
			broadcast(self,JT)

			if not JT.disabled then
				AddInfoBar(self.CN.."进行判定"..thecard.name)
				sleep(0.5)
				local pdetail=Panding(self)
				debugPrint("NOTCANCEL")
				thecard.judgePDFunc(thecard,pdetail)
			else

				thecard.ysCancelFunc(thecard)
			end
		end
	end
end

function Player:mopaiJieduan(detail )
	
	if self==detail.theplayer or self.name==detail.theplayername then
		AddInfoBar(self.CN.."摸牌阶段")
		Sleep(self,1)
		self.haventSha=true
		printForGame("mopai")
		
		moNPai(self,2)

		

	end
end
chupaiInfo="请出牌"
chupaiClickState="wait human click for chupai"

function clickWhenChupai(responseItem)
	if getmetatable(getmetatable(responseItem))==Card and responseItem.inHumanHand then
		fadeT1ExceptT2(TheHuman.handcards,{responseItem})
		responseItem:responseClick()
		if responseItem.type=="zhuangbei" then
			preInfo="请出牌"
			preClickStateWithCard="wait human click for chupai"
			curSelectedCards[1]=responseItem
			printForGame("你单击了装备")
			AddInfoBar("请单击确定来装备")
			preClickState=clickState
			clickstate("wait human click button")
			function zOk()
				local _,s = findTByAttrs(TheHuman.skills,"name","zhuangbeiSkill")
				s:doHumanSkill(curSelectedCards[1])
			end
			StdSimpleShowButton(zOk)
		else
			if not curSelectedCards[1] then
				printForGame("你单击了卡牌")
				curSelectedCards[1]=responseItem
				preClickState=clickState
				responseItem.FuncForHumanChupai()
			else
				curSelectedCards={}
				clearPicSelection()
				restoreAllFade()
			end
		end
	else
		debugPrint("Wrong click place!!")
	end
end
table.insert(PressFuncSet,{"wait human click for chupai",clickWhenChupai})

function Player:chupaiJieduan( detail )
	--state("Chupai")
	
	if self==detail.theplayer  or self.name==detail.theplayername then
		AddInfoBar(self.CN.."出牌阶段")
		debugPrint("this player is "..self:info())
		if not self.ishuman then
			
			self:arrangeEF()
			local t = self:haveActInChupai()
			local theFlag=#t

			debugPrint("available act num "..theFlag)

			while theFlag~=0 do
				debugPrint("chupai")
				t[1]:doSkill()

				t = self:haveActInChupai()
			 	theFlag=#t
			end 
			debugPrint("no act")

		else
			--self:arrangeCardsPos()
			preInfo=chupaiInfo
			preClickStateWithCard=chupaiClickState

			if  isClient then
				debugPrint 'ISCLIET'
				--preSetFunc=function ( ... )
					debugPrint 'AFTERISCLIENTBEFOREPAUSE'
					--qtLog("SNALLTEEST")
					waitHumanClickForChupai()

					clickState=""
					preClickState=""
					restoreAllFade()
					clearPicSelection()
					clearButtons()
				--end
				--resume()

			else
				debugPrint 'NOTCLIENTNOTCLIENT'
				waitHumanClickForChupai()

				clickState=""
				preClickState=""
				restoreAllFade()
				clearPicSelection()
				clearButtons()
			end
			
		end
		
	end

end
function Player:arrangeEF( )
	if self.shenfen=="n" then
		
	end
end

function Player:haveActInChupai(  )
	local actList = {}

	for _,v in pairs(self.skills) do
		if v:isChupaiAv() then
			table.insert(actList,v)
		
		end
	end

	for _,v in pairs(self.handcards) do
		if v.skill:isChupaiAv() then
			table.insert(actList,v.skill)
		end
	end
	return actList
end

function clickWhenQipai(responseItem)
	if getmetatable(getmetatable(responseItem))==Card and responseItem.inHumanHand then
		if not responseItem.inHumanQiSelection then
			table.insert(HumanQiSelection,responseItem)	
			responseItem.inHumanQiSelection=true
			responseItem:raise()
			if #HumanQiSelection==HumanQiN then
				if qipaiOkF  then
					local okF = qipaiOkF
					stdShowButton( okF,qipaiCancelF,true,false )
				else
					local okF = doNothing
					StdSimpleShowButton(okF)
				end
				
				preClickState=clickState
				clickstate("wait human click button")
			end
		else
			responseItem:down()
			clearButtons()
			table.remove(HumanQiSelection,getIndexInT(HumanQiSelection,responseItem))	
			responseItem.inHumanQiSelection=false
		end
	end
end
table.insert(PressFuncSet,{"wait human qipai",clickWhenQipai})

function Player:qipaiJieduan( detail )
	if self==detail.theplayer  or self.name==detail.theplayername then
		AddInfoBar(self.CN.."弃牌阶段")
		if not self.ishuman then
			local n = #self.handcards-self.cardMax(self)
			if n>0 then
				Sleep(self)
				printForGame("qipai")
				debugPrint("sum before:"..#self.handcards)
				local thecards=randomQiNPai(self,n)
				debugPrint("sum after:"..#self.handcards)
				--broadcast(self,{act="judgeQipai",cards=thecards,from=self})
			else
				Sleep(self,1)
			end
		else
			HumanQiN=#self.handcards-self.cardMax(self)
			if HumanQiN>0 then
				HumanQiSelection={}
				waitHumanQipai()
				qizhiQiNPai(self,HumanQiSelection)
				--broadcast(self,{act="judgeQipai",cards=HumanQiSelection,from=self})
			else
				--deleteInfoBar()
			end
		end
		

		
	end
end
function Player:judgeQipai( detail )
	local theplayer = detail.from
	local thecards = detail.cards
	local nextP = xiajia(theplayer)

	local theCanShaList = theplayer:canShaList()
	
	repeat
		if theplayer.haventSha and THaveCard(thecards,shaCard) and TContainsT(theCanShaList,nextP.enemies) then
			if not TContainsA(nextP.enemies,theplayer) then
				Sleep(nextP,1)
				table.insert(nextP.enemies,theplayer)
				debugPrint(nextP:info()..":你废了,"..theplayer:info())
			end
		end

		nextP=xiajia(nextP)
	until nextP==theplayer
end
hurtSkill=Skill:new{name="Hit"}
function Player:getHurt( detail )
	if self==detail.to then
		--Sleep(self,1)
		debugPrint(self:info().."fuck,i'm hurt")
		detail.hurtN = detail.hurtN or 1
		local hurtN = detail.hurtN
		local lifeBefore = self.life
		self.life=self.life-hurtN
		printForGame(self:info().." life is "..self.life)
		hurtSkill.player=self
		hurtSkill:playSound()
		playSound("system/hurt_normal.mp3")

		if not self.atNet then
			UIGetHurt(self,hurtN)
		elseif notServerHuman(self) then
			detail.actionName="GetHurt"
			self:TellServer(detail)
		end
		

		if self.life<=0 then
			self:goingDie(detail)
		end
	end
end

function checkDie(DT)
	if not DT.beAlive then
		DT.theplayer:die()
		DT.stop=true
		DT.stop=true
	end
end
function Player:goingDie(thehurtdetail)
	AddInfoBar(self.CN.."濒死")
	local DT = {act="goingDie",theplayer=self,detail=thehurtdetail,beAlive=false,afterBroFunc=checkDie}
	
	if thehurtdetail.from then
		broadcast(thehurtdetail.from,DT)
	else
		broadcast(thehurtdetail.to,DT)
	end
end
function Player:resposeQiutao(detail)
	local illPlayer = detail.theplayer
	function afterSave(notEnoughFunc)
		illPlayer:huixie(detail)
		if illPlayer.life<1 then
			notEnoughFunc()
		else
			detail.beAlive=true
			detail.stop=true
		end
	end
	if self.ishuman then
		function nEF()
			local yesF = function (thecard)
				afterSave(nEF)
			end
			local noF = doNothing
			demandHumanDachu(taoCard,detail,yesF,noF)
		end
		nEF()
	else
		Sleep(self)
		if TContainsA(self.friends,illPlayer) then
			function findTAndSave()
				local haveT,v = self:haveCard(taoCard)
				if haveT then
					self:dachu(v)
					afterSave(findTAndSave)
				else
				end
			end
			findTAndSave()
		end
	end
	
end
--local ShenshaDeathPicNames = {zhu="lord",z="zhongchen",f="rebel",n="neijian"}
function Player:die(detail)
	printForGame(self:info().." die")
	table.remove(gamePlayers,getIndexInT(gamePlayers,self))
	for i,v in pairs(gamePlayers) do
		local thei=getIndexInT(v.friends,self) 
		if thei then
			table.remove(v.friends,thei)
		end
		thei=getIndexInT(v.enemies,self) 
		if thei then
			table.remove(v.enemies,thei)
		end
	end
	
	--local name = ShenshaDeathPicNames[self.shenfen]
	UIDie(self)
	self.alive=false

	qiNPai(self,self.handcards)
	sleep(50)
	for i,v in pairs(self.zhuangbeis) do
		if v~=0 then
			local zc = self:popZhuangbei(i)
			qipai(zc)
			sleep(550)
		end
	end
	for i=1,#self.pandings do
		local pc =self.pandings[1]
		self:DeletePandingCard(pc)
		qipai(pc)
		sleep(550)
		--table.insert(qipaiPile,table.remove(self.pandings,1))
	end 
	

	table.insert(Wujiangs,self.wujiang)
	local r,role = judgeWin()
	if r then
		printForGame("the group of "..role.." Wins")

		if not isAtNet() then
			if TheHuman.zhenying==role then
				printForGame("你赢啦")
			else
				printForGame("你输啦")
			end
			 --FinishGame()
			immediatelyWin()
		else
			self:TellServer{actionName="Wins",role=role}
		end
	end
end
function Player:huixie(detail )
	--if self==detail.theplayer then
		--Sleep(self)
		if self.maxLife>self.life then
			debugPrint(self:info().."yeah,i'm healthy")
			self.life=self.life+1
			printForGame(self:info().." life is "..self.life)
			
			playSound("system/CarMus_Act04.mp3")
			
			
			if not self.atNet then
				UIHuixie(self)
			elseif notServerHuman(self) then
				detail.actionName="Huixie"
				self:TellServer(detail)
			end
		end
	--end
end
function Player:judgeEnemy( detail )
	debugPrint("jE"..self:infoHTML())
	if detail.harm==true then
		if TContainsA(self.friends,detail.to) then
			debugPrint("first")
			table.insert(self.enemies,detail.from)
		end
		if TContainsA(self.enemies,detail.to) then
			debugPrint("second")
			table.insert(self.friends,detail.from)
		end
	end
	
end
function Player:resposeAoe( detail )
	if detail.aoe==true and not detail.disabled then
		
		detail.aoeFunc(self,detail)
	end
end

function Player:responseDachu( detail )
	if detail.to ==self then
		detail.dachuFunc(self,{},detail.from)
	end
end
function Player:responseBeiChai( detail )
	if detail.to ==self then
		if detail.region=="shoupai" then

			detail.thecard=self.handcards[detail.index]
			if detail.ispop then
				self:popCard(detail.thecard)
			end
		end
	end
end
function Player:juli(p )
	local juli = 0
	
	if self~=p then 
		function weizhijuli(p1,p2 )
			juli=juli+1
			if juli>NUM then 
				return
			end
			if xiajia(p1)~=p2 then
				weizhijuli(xiajia(p1),p2)
			end
		end

		weizhijuli(self,p)
	end
	if juli>#gamePlayers/2 then 
		juli=#gamePlayers-juli 
	end
	if self.zhuangbeis[4]~=0 then
		juli=juli-1
	end
	if p.zhuangbeis[3]~=0 then
		juli=juli+1
	end
	return juli 
end

function Player:canShaList(  )
	local nextP = xiajia(self)
	local theList = {}
	repeat
		
		if self:juli(nextP)<=self.gongjiJuli then
			table.insert(theList,nextP)
		end
		nextP = xiajia(nextP)
	until nextP==self
	return theList
end


function Player:popFuncInBList(func )
	for i,v in ipairs(self.broadcastAnswerList) do
		if v[2]==func then
			return table.remove(self.broadcastAnswerList,i)
		end
	end
	return nil
end
function Player:haveCard(thecard )
	for i,v in ipairs(self.handcards) do
		if getmetatable(v)==thecard then
			return true,v
		end
	end
	return false
end



function Player:haveCardType(thetype )
	for i,v in ipairs(self.handcards) do

		if v.type==thetype then
			return true,v
		end
	end
	return false
end
function Player:getSkill( name )
	for _,v in pairs(self.skills) do
		if v.name==name then
			return v
		end
	end
end
function Sleep(player,st)
	local s = st or sleepTime
	--tM:time Bar move 时间条动画
	if qml then
		
		callQmlFTable("sleepPlayer",{player.position,s*1000})
	else
		tM(AllPicIndexes[player.timeBarIndex],s)
	end
	sleep((s+0.1)*1000)
end

function  cmpP( p1,p2 )
	if(p1.position<p2.position) then
		return true
	else
		return false
	end
end




debugPrint("Player.lua loaded")