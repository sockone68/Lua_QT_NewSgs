--the following functions are for client using to answer the server's msg sent by table ,called ClientAnswerTFunc

function BroadcastCallFunc( name,funcParams )--called by server,funcParams={[1]=..,[2]=..,}
	broadCastTheRoomByTable{actionName="callFunc",funcName=name,funcParams=funcParams}
end

function cccc(thetable)
	translateStringIntoClass(thetable)
	CallFuncByName(thetable.funcName,thetable.funcParams)
end
table.insert(ClientAnswerTFuncSet,{"callFunc",cccc})



function definePlayerA(thetable)
	myPlayer=Player:new(thetable.playerinfo)
	myPlayer.isInClient=true
	table.insert(players,myPlayer)
	printForGame("my player settled")
end
table.insert(ClientAnswerTFuncSet,{"definePlayer",definePlayerA})

function addPlayerA(thetable)
	local p=Player:new(thetable.playerinfo)
	p.isInClient=true--very importante
	table.insert(players,p)
	printForGame("a player added")
end
table.insert(ClientAnswerTFuncSet,{"addPlayer",addPlayerA})

function addZhuA(thetable)--make a player's shenfen being zhu
	local v = getPlayerByName(thetable.playername)
	v.position=1	v.shenfen="zhu"	
	if not Thezhu then
		Thezhu=v
	end
	Thezhu.zhenying="zhuzhong"
end
table.insert(ClientAnswerTFuncSet,{"addZhu",addZhuA})
table.insert(ClientAnswerTFuncSet,{"assignSelfShenfen",function(thetable)	myPlayer.shenfen=thetable.theshenfen	end})

function assignPositionA(thetable)
	local v = getPlayerByName(thetable.playername)
	v.position=thetable.theposition
	if qml and v==myPlayer then
		callQmlF("setthehumanp",v.position)
	end
end
table.insert(ClientAnswerTFuncSet,{"assignPosition",assignPositionA})
table.insert(ClientAnswerTFuncSet,{"xuanjiang",function(thetable)	NetworkHumanXuan(thetable.wujianglist)	end})

function notifyXuanjiangA(thetable)
	local v = getPlayerByName(thetable.playername)
	local thej = getWujiangByPinyin(thetable.wujiangpinyin)
	v:xuanjiang(thej)
end
table.insert(ClientAnswerTFuncSet,{"notifyXuanjiang",notifyXuanjiangA})




function getCardA(thetable)
	for i,v in pairs(thetable.cardsid) do
		local thecard = returnCardById( v )
		printForGame(myPlayer:infoHTML().." mo "..thecard:infoHTML())
		myPlayer:getCard(thecard,true)
	end
end
table.insert(ClientAnswerTFuncSet,{"getCard",getCardA})

function notifyGetCardA(thetable)
	local thep = getPlayerByName(thetable.playername)
	local num = thetable.num
	
	moNpaiAnim(num,thep)
	--cardpileNumDisplayChange(-num)
end
table.insert(ClientAnswerTFuncSet,{"notifyGetCard",notifyGetCardA})


function notifyZhuangbeiAnimA(thetable)
	local from = getPlayerByName(thetable.fromname)
	local to = getPlayerByName(thetable.toname)
	local thecard=returnCardById(thetable.cardid)
	printForGame("THEANSWER")
	zhuangbeiAnim( from,thecard,to,true)
	
end
table.insert(ClientAnswerTFuncSet,{"notifyZhuangbeiAnim",notifyZhuangbeiAnimA})

function notifyQiNPaiAnimA(thetable)--弃手牌
	local player = getPlayerByName(thetable.playername)
	local cards=getCardsFromThetable(thetable)

	if player~=myPlayer or thetable.nothand then
		qiNPaiAnim(player,cards,thetable.spText)

	else
		qiHumanHandcardAnim(cards)
		player:arrangeCardsPos()
	end
	
end
table.insert(ClientAnswerTFuncSet,{"notifyQiNPaiAnim",notifyQiNPaiAnimA})


function notifyPlaysoundA(thetable)
	local dir=thetable.dir
	playSound(dir,true)
end
table.insert(ClientAnswerTFuncSet,{"notifyPlaysound",notifyPlaysoundA})


function notifyPointLineA(thetable)
	local from = getPlayerByName(thetable.fromname)
	local to = getPlayerByName(thetable.toname)
	from:pointAnotherPlayer(to,true)
end
table.insert(ClientAnswerTFuncSet,{"notifyPointLine",notifyPointLineA})

function notifyAddZhuangbeiA(thetable)
	local theplayer = getPlayerByName(thetable.playername)
	local thecard = returnCardById(thetable.cardid)
	local  num = thetable.num
	UIAddZhuangbei(theplayer,thecard,num)
	if theplayer~=myPlayer then
		thecard.player=theplayer
		theplayer.zhuangbeis[num]=thecard
	end
end
table.insert(ClientAnswerTFuncSet,{"notifyAddZhuangbei",notifyAddZhuangbeiA})


function notifyPopZhuangbeiA(thetable)
	debugPrint("NOTIFYPOP")
	local theplayer = getPlayerByName(thetable.playername)
	local  num = thetable.num
	UIPopZhuangbei(theplayer,num)
	if theplayer~=myPlayer then
		theplayer.zhuangbeis[num]=0
	end
end
table.insert(ClientAnswerTFuncSet,{"notifyPopZhuangbei",notifyPopZhuangbeiA})

function notifyAddPandingCardA(thetable)
	debugPrint("RECEIVEADDPANDING")
	local theplayer = getPlayerByName(thetable.playername)
	local thecard = returnCardById(thetable.cardid)
	if myPlayer==theplayer then
		myPlayer:AddPandingCard(thecard,true)
	else
		table.insert(theplayer.pandings,thecard)
		UIAddPandingCard( theplayer,thecard)
	end
end
table.insert(ClientAnswerTFuncSet,{"notifyAddPandingCard",notifyAddPandingCardA})


function notifyDeletePandingCardA(thetable)
	local theplayer = getPlayerByName(thetable.playername)
	local thecard = returnCardById(thetable.cardid)
	UIDeletePandingCard( theplayer,thecard)
end
table.insert(ClientAnswerTFuncSet,{"notifyDeletePandingCard",notifyDeletePandingCardA})

function notifyHandChangeA(thetable)
	local theplayer = getPlayerByName(thetable.playername)
	local  num =  thetable.num
	if theplayer~=myPlayer then
		local x = #theplayer.handcards-num
		if x>0 then
			for i=1,x do
				table.remove(theplayer.handcards)
			end
		else
			for i=1,-x do
				table.insert(theplayer.handcards,fakeCard())
			end
		end
	end
	theplayer:updateCardNDisplay( num)
end
table.insert(ClientAnswerTFuncSet,{"notifyHandChange",notifyHandChangeA})


function notifyGetHurtA(thetable)
	local theplayer = getPlayerByName(thetable.playername)
	local  num =  thetable.num
	if theplayer~=myPlayer then
		theplayer.life=theplayer.life-num
	end
	UIGetHurt(theplayer,num)
end
table.insert(ClientAnswerTFuncSet,{"notifyGetHurt",notifyGetHurtA})


function notifyHuiXieA(thetable)
	debugPrint("HUXIE")
	local theplayer = getPlayerByName(thetable.playername)
	if theplayer~=myPlayer then
		theplayer.life=theplayer.life+1
	end
	UIHuixie(theplayer)
end
table.insert(ClientAnswerTFuncSet,{"notifyHuiXie",notifyHuiXieA})


function notifyShunA(thetable)
	translateStringIntoClass(thetable)
	UIShun(thetable.from,thetable.to)
end
table.insert(ClientAnswerTFuncSet,{"notifyShun",notifyShunA})

function mo1PaiOnDeskA(thetable)
	translateStringIntoClass(thetable)
	mo1PaiOnDesk(thetable.getplayer,thetable.card)
end
table.insert(ClientAnswerTFuncSet,{"mo1PaiOnDesk",mo1PaiOnDeskA})

function EndAndResumeA(thetable)
	translateStringIntoClass(thetable)
	for k,v in pairs(thetable.detail) do
		TheNetBroadcastTable[k]=v
	end
	preSetFunc=doNothing
	resume()
end
table.insert(ClientAnswerTFuncSet,{"EndAndResume",EndAndResumeA})

function NetworkNotifyPanding(player,detail)--for clienthuman
	UIPanding(player,detail.pandingCard)
end

function ClientAnsWins( thetable )
	if TheHuman.zhenying==thetable.role then
		printForGame("你赢啦")
	else
		printForGame("你输啦")
	end
	 --FinishGame()
	 ClientGameOver()
end
table.insert(ClientAnswerTFuncSet,{"Wins",ClientAnsWins})

function ClientGameOver( ... )
	sleep(1000)
	quit()
end

--ClientAnswerTFunc finished
--[[
function doWhenNet( ... )
	oldPrintForGame=printForGame
	oldEmitCallQmlFWithTable=emitCallQmlFWithTable
	if ServerMode=="roomMode"	then

		
		printForGame=broadCastTheRoomByTable 
		
	else

	end
end
]]




function NetworkJieduansBroadcast( player )
	printForGame("----------------------")
    printForGame(player:infoHTML().." start huihe</font> ")
	for i=1,#jieduans do
		debugPrint 'BROADCAStJD'
		if canBroadcastJieduan(player,jieduans[i]) then
			NetworkBroadcast(player,{act=jieduans[i],theplayername=player.name,isJB=true})
			--waitClick()
			debugPrint 'YESYES'
		else
			debugPrint 'CANt'
		end
	end
	player:resetState()
	debugPrint("NETX0")
end



function NetworkGame()
	local nextPlayer = Thezhu
	repeat
		NetworkJieduansBroadcast(nextPlayer)
		debugPrint("NETX")
		nextPlayer=xiajia(nextPlayer)
		--coroutine.yield()
	until gameState=="End"

	--NetworkJieduansBroadcast( Thezhu )
	
end

function NetworkStartGame()
	HumanNum=0
	for _,v in pairs(theRoom.players) do
		if v.ishuman then
			HumanNum=HumanNum+1
		end
	end
	playerWaitingXuanjiangNum=HumanNum
	broadCastTheRoom("Start")
	printForGame("num of theroomp is "..#theRoom.players)
	stdNetworkDealPreGame()
end

function NetworkMayStartGameloop()
	if playerWaitingXuanjiangNum then
		if playerWaitingXuanjiangNum==0 then
			NetworkStartGameLoop()
		else
			--printForGame("NOTFINISH"..playerWaitingXuanjiangNum)
		end
	end
end

function  NetworkStartGameLoop( )--for server
	--players=theRoom.players--after this the server can use the member playerss
	--Thezhu=getPlayerByName(Thezhu.name)
	printForGame "NetworkStartGameLoop"
	state("gameStart")
	gameLoopIsRunning=true
	NetworkBroadcast(Thezhu,{act="gameStart"})
end

function stdNetworkDealPreGame()
	if #theRoom.players<=8 and #theRoom.players>=2 then
		NUM=#theRoom.players
 		printForGame("NUM:"..NUM)
 		local ps = theRoom.players
 		
		local shenfenAssignTable={}
 		for var=1,4 do
 			for _=1,shenfenAssignment[NUM-1][var] do
 				table.insert(shenfenAssignTable,shenfenList[var])
 			end
 			
 		end
 		state("assignShenfen")
	 	for i,player in ipairs(ps) do
			player.shenfen=table.remove(shenfenAssignTable,math.random(#shenfenAssignTable))

			if player.shenfen=="zhu" then 
				Thezhu=player 
				Thezhu.position=1
				Thezhu.zhenying="zhuzhong"
				broadCastTheRoomByTable{actionName="addZhu",playername=player.name}
			else
				if player.ishuman then
					sendTableToClient(player.socketIndex,{actionName="assignSelfShenfen",theshenfen=player.shenfen})
				end
				if player.shenfen=="f" then
					player.zhenying="f"
					table.insert(TheFans,player)
				elseif player.shenfen=="z" then
					table.insert(TheZhongs,player)
					player.zhenying="zhuzhong"
				elseif player.shenfen=="n" then
					Thenei=player
					player.zhenying="n"
					player.zs={} player.fs={}
				end
			end
		end

		state("Assign position")
		local positionAssignTable = {}
		for var=2,NUM do
			table.insert(positionAssignTable,var)
		end
		for i,player in ipairs(ps) do
			if player.shenfen=="f" then
				player.enemies[1]=Thezhu
			end
			if player.shenfen~="zhu" then
				local var=math.random(#positionAssignTable)

				player.position=table.remove(positionAssignTable,var)
				broadCastTheRoomByTable{actionName="assignPosition",playername=player.name,theposition=player.position}
			end
			if player.shenfen=="z" then
				player.friends[1]=Thezhu
			end
		end

		table.sort( ps, cmpP )

 		for i,player in ipairs(ps) do
 			table.insert(gamePlayers,player)
 			printForGame(gamePlayers[i]:info())
 		end

 		state("Assign wujiang")
 		local zhugongs = {}
 		local zhugongpinyins = {}
 		for i,v in ipairs(Wujiangs) do
 			if v["isZhugong"] then
 				local w = table.remove(Wujiangs,i)
 				table.insert(zhugongs,w)
 				table.insert(zhugongpinyins,w.pinyin)
 			end
 		end

 		for i=1,3 do
 			local w = table.remove(Wujiangs,math.random(#Wujiangs))
 			table.insert(zhugongs,w)
 			table.insert(zhugongpinyins,w.pinyin)
 		end

 		
 		if Thezhu.ishuman then
 			sendTableToClient(Thezhu.socketIndex,{actionName="xuanjiang",wujianglist=zhugongpinyins})
 		else
 			NetworkRobotXuanjiang(Thezhu,zhugongs)
 		end
 	end


end

function NetworkNonZhuXuan()
	local ps = theRoom.players
	

	for i=2,NUM do
		local thejiangs={}
		local thejiangspinyins = {}
		if ps[i].shenfen=="n" then
			for i=1,5 do
				local w = table.remove(Wujiangs,math.random(#Wujiangs))
				table.insert(thejiangs,w)
				table.insert(thejiangspinyins,w.pinyin)
			end
		else
			for i=1,3 do
				local w = table.remove(Wujiangs,math.random(#Wujiangs))
				table.insert(thejiangs,w)
				table.insert(thejiangspinyins,w.pinyin)
			end
		end
		if ps[i].ishuman then
			sendTableToClient(ps[i].socketIndex,{actionName="xuanjiang",wujianglist=thejiangspinyins})
			
		else
			NetworkRobotXuanjiang(ps[i],thejiangs)
		end
	end
end

function NetworkHumanXuan( thejiangs )--called by client,thejiangs is a string array
	if qml then

	else
		humanXuanjiangs=thejiangs
		theTable1={}
		for i,v in ipairs(thejiangs) do
			theTable1[i]=v
		end
		addQml("xuanjiang.qml",#theTable1)
		
		DIYWindowEvent=function (s)
			thestring= (s+1)..""
			NetworkContinueXuanjiang()
		end
		
	end
end

function NetworkContinueXuanjiang( )
	local theindex = thestring+0
	if theindex>0 and theindex<=#humanXuanjiangs then
		printForGame(humanXuanjiangs[theindex])
		local thej=getWujiangByPinyin(humanXuanjiangs[theindex])
		
		myPlayer:xuanjiang(thej)
		table.remove(humanXuanjiangs,theindex)
		local isz=false
		if myPlayer.shenfen=="zhu" then
			isz=true
		end
		sendTableToServer{actionName="finishXuanjiang",chosenWujiangPinyin=thej.pinyin,remains=humanXuanjiangs,isZhu=isz}
	end
end

function NetworkRobotXuanjiang( player,thejiangs)--it's in the server

	local w=Xuanjiang( player,thejiangs)
	local isz = false
	if player.shenfen=='zhu' then
		isz=true
	end
	broadCastTheRoomByTable{actionName="notifyXuanjiang",playername=player.name,wujiangpinyin=w.pinyin,isZhu=isz}
	if isz then
		NetworkNonZhuXuan()
	else
		
		NetworkMayStartGameloop(  )
	end
	
end



function resumeXc( ... )
	NetworkGame()
end




function getRoomPlayerByName(name)--for server
	for i,v in pairs(theRoom.players) do
		if v.name==name then
			return v
		end
	end
end

function getPlayerBySocketIndex(i)--for server
	
	if type(i)=="number" then
		for _,v in pairs(theRoom.players) do
			if v.socketIndex==i then
				return v
			end
		end
	elseif type(i)=="string" then
		return getRoomPlayerByName(i)
	end
end

function getWujiangByPinyin( pinyin )
	for i,v in pairs(WujiangsCopy) do
		if v.pinyin==pinyin then
			return v
		end
	end
end

function getCardsFromThetable(thetable)
	local result = {}
	for i,v in pairs(thetable.cardsid) do
		--printForGame 'GEtCARD'
		local thecard = returnCardById( v )
		result[i]=thecard
	end
	return result
end
function isAtNet()
	if TheHuman then
		if TheHuman.atNet then
			return true
		else
			return false
		end
	else
		return true
	end
end
function isNetRobot(p)
	if not p.ishuman  and p.isInServer then
		return true
	else
		return false
	end
end

function isClientHuman(p)
	if p.ishuman and not p.isInServer then
		return true
	else
		return false
	end
end

function isServerHuman(p)--not a serverhuman but atnet means its a net robot or a player using client
	if p.ishuman and p.isInServer then
		return true
	else
		return false
	end
end

function notServerHuman(p)
	if isServerHuman(p) then
		return false
	else
		return true
	end
end


function playerTellServer(player,t)--t is table
	--t.MsgFrom=player.name
	if player.isInClient then
		sendTableToServer(t)
	elseif player.isInServer then
		ServerAnswerTable(player.name,t)
	end
end

function Player:TellServer(t)--t is table
	playerTellServer(self,t)
end

function setNetplayerAttr( name,attr,content )
	local player = getRoomPlayerByName(name)
	player[attr]=content
end

function GetSthFromServer( detail )
	detail.actionName="GetSthFromServer"
	sendTableToServer(detail)
	TheWaitingServerAnswer=detail
	pause()
	local theresult = detail.result
	TheWaitingServerAnswer=nil
	return theresult
end
function AnsReturnGetSth(thetable)
	translateStringIntoClass(thetable)
	TheWaitingServerAnswer.result=thetable.result
	resume()
end
table.insert(ClientAnswerTFuncSet,{"returnGetSth",AnsReturnGetSth})



function getCardsIds( cards )
	local result = {}
	for i,v in pairs(cards) do
		result[i]=v.id
	end
	return result
end



function broadcastPrintForGame(s)
	if not roomModeOn then
		printForGame(s)
	else
		broadCastTheRoomByTable{actionName="callfunc",funcName="printForGame",funcParams={s}}
	end
end
