function inputNickNameA(i,thetable )
	--if thetable.actionName=="inputNickName" and ServerMode=="roomMode" then
	if #theRoom.players<theRoom.NUM then
		local theplayerinfo = {socketIndex=i,nickName=thetable.nickName,ishuman=true,name=thetable.nickName,atNet=true}
		
		sendTableToClient(i,{actionName="definePlayer",playerinfo=theplayerinfo})--tell this client to add its player
		for _,v in pairs(theRoom.players) do
			sendTableToClient(i,{actionName="addPlayer",playerinfo=v:getNetworkPublicInfo()})--tell this player to add remained players
		end
		broadCastTheRoomByTable{actionName="addPlayer",playerinfo=theplayerinfo}--tell remained players to add this player

		local thisplayer = Player:new(theplayerinfo)
		thisplayer.isInServer=true
		table.insert(theRoom.players,thisplayer)
		broadCastTheRoom("a player has entered the room")
		if #theRoom.players==theRoom.NUM then
			NetworkStartGame()

		end
			
			
	else
		sendMsgToClient(i,"roomIsFull")
	end
end
table.insert(ServerAnswerTFuncSet,{"inputNickName",inputNickNameA})

function finishXuanjiangA(i,thetable )
	local thisPlayer=getPlayerBySocketIndex(i)
	local thej = getWujiangByPinyin(thetable.chosenWujiangPinyin)
	local remains = {}
	for _,vv in pairs(thetable.remains) do
		local w = getWujiangByPinyin(vv)
		table.insert(remains,w)
	end
	putinJiangs(remains)
	thisPlayer:xuanjiang(thej,true)
	broadCastTheRoomByTableExceptOne({actionName="notifyXuanjiang",playername=thisPlayer.name,wujiangpinyin=thetable.chosenWujiangPinyin},thisPlayer)
	
	if playerWaitingXuanjiangNum and thisPlayer.ishuman then
		playerWaitingXuanjiangNum=playerWaitingXuanjiangNum-1
	end
	if thetable.isZhu then
		
		NetworkNonZhuXuan()
	else
		NetworkMayStartGameloop(  )
	end
end
table.insert(ServerAnswerTFuncSet,{"finishXuanjiang",finishXuanjiangA})

function moNPaiA(i,thetable )
	
	local thisPlayer=getPlayerBySocketIndex(i)
	local idSet = {}
	for j=1,thetable.num do
		local thecard = popACardFromCurPile()
		table.insert(idSet,thecard.id)
		thisPlayer:getCard(thecard,true)
		printForGame(thisPlayer:infoHTML().." mo "..thecard:infoHTML())
	end
	if thisPlayer.ishuman then
		sendTableToClient(i,{actionName="getCard",cardsid=idSet})
		
	end
	
	broadCastTheRoomByTable{actionName="notifyGetCard",num=thetable.num,playername=thisPlayer.name}
end
table.insert(ServerAnswerTFuncSet,{"moNPai",moNPaiA})

function AddZhuangbeiA(i,thetable )
	local thisPlayer=getPlayerBySocketIndex(i)
	local thecard=returnCardById(thetable.cardid)

	if thisPlayer.ishuman then
		thisPlayer:getSkill("zhuangbeiSkill"):strictSkill(thecard)
	end

	--sendTableToClient(i,{actionName="addZhuangbei",cardsid=idSet})
	broadCastTheRoomByTable{actionName="notifyAddZhuangbei",num=thetable.num,playername=thisPlayer.name,cardid=thetable.cardid}
end
table.insert(ServerAnswerTFuncSet,{"AddZhuangbei",AddZhuangbeiA})

function popZhuangbeiA(i,thetable )
	local thisPlayer=getPlayerBySocketIndex(i)
	local theplayer = getRoomPlayerByName(thetable.playername)
	local num=thetable.num

	if thisPlayer.ishuman then
		theplayer:popZhuangbei(num,true)
	end

	broadCastTheRoomByTable{actionName="notifyPopZhuangbei",num=thetable.num,playername=theplayer.name}
end
table.insert(ServerAnswerTFuncSet,{"popZhuangbei",popZhuangbeiA})

function AddPandingCardA(i,thetable )
	local thisPlayer=getPlayerBySocketIndex(i)
	local theplayer=getRoomPlayerByName(thetable.playername)
	local thecard=returnCardById(thetable.cardid)

	--if thisPlayer.ishuman then
		theplayer:AddPandingCard(thecard,true)
	--end
	--sendTableToClient(i,{actionName="addPandingCard",cardid=thetable.cardid})
	broadCastTheRoomByTable{actionName="notifyAddPandingCard",playername=theplayer.name,cardid=thetable.cardid}
end
table.insert(ServerAnswerTFuncSet,{"AddPandingCard",AddPandingCardA})


function DeletePandingCardA(i,thetable )
	local thisPlayer=getPlayerBySocketIndex(i)
	local thecard=returnCardById(thetable.cardid)
	if thisPlayer.ishuman then
		thisPlayer:DeletePandingCard(thecard)
	end
	--sendTableToClient(i,{actionName="addPandingCard",cardid=thetable.cardid})
	broadCastTheRoomByTable{actionName="notifyDeletePandingCard",playername=thisPlayer.name,cardid=thetable.cardid}
end
table.insert(ServerAnswerTFuncSet,{"DeletePandingCard",DeletePandingCardA})


function GetHurtA(i,thetable )
	local thisPlayer=getPlayerBySocketIndex(i)
	local num=thetable.hurtN
	if thisPlayer.ishuman then
		thisPlayer:getHurt(thetable)
	end

	broadCastTheRoomByTable{actionName="notifyGetHurt",playername=thisPlayer.name,num=num}
end
table.insert(ServerAnswerTFuncSet,{"GetHurt",GetHurtA})

function HuiXieA(i,thetable )
	local thisPlayer=getPlayerBySocketIndex(i)
	if thisPlayer.ishuman then
		thisPlayer:huixie{}
	end

	broadCastTheRoomByTable{actionName="notifyHuiXie",playername=thisPlayer.name}
end
table.insert(ServerAnswerTFuncSet,{"Huixie",HuiXieA})

function ClientBroadCastA(i,thetable )
	preSetFunc=function (  )
		preSetFunc=doNothing
		printForGame("BEFORECB")
		thetable.detail.fromClient=true
		NetworkBroadcast(getPlayerBySocketIndex(i),thetable.detail )
		printForGame("AFTERCB")
		waitClick()
	end
	resume()
end
table.insert(ServerAnswerTFuncSet,{"broadcast",ClientBroadCastA})


function finishBroadcastA(i,thetable )
	translateStringIntoClass(thetable.detail)
	for k,v in pairs(thetable.detail) do
		CurBC().detail[k]=v
	end
	--CurBC().detail=thetable.detail
	finishAnsBroadcast(true)
end
table.insert(ServerAnswerTFuncSet,{"finishBroadcast",finishBroadcastA})

table.insert(ServerAnswerTFuncSet,{"tellEveryOne",function(i,thetable )	broadCastTheRoomByTable(thetable.content)	end})

table.insert(ServerAnswerTFuncSet,{"tellEveryOneExceptOne",function(i,thetable )	broadCastTheRoomByTableExceptOne(thetable.content,getPlayerBySocketIndex(thetable.exception))	end})


function cheatA(i,thetable )
	local f = loadstring("cheatcard="..thetable.name)
	f()
	for _,v in pairs(theRoom.players) do
		if not v.ishuman then
			v:getCard(popCertainCardInCurrentPile(cheatcard),true)
		end
	end
end
table.insert(ServerAnswerTFuncSet,{"cheat",cheatA})

function PlayerTellAPlayer(from,to,content)--called by client
	if from.isInServer then
		sendTableToPlayer(to,content)
	else
		sendTableToServer{actionName="tellAPlayer",content=content,to=to}
	end
end

function TellAPlayer(i,t)--called by client
	translateStringIntoClass(t)
	sendTableToPlayer(t.to,t.content)
	
end
table.insert(ServerAnswerTFuncSet,{"tellAPlayer",TellAPlayer})


function popcardA(i,t)--called by client
	translateStringIntoClass(t)
	local thisPlayer=getPlayerBySocketIndex(i)
	thisPlayer:popCard( t.card)
end
table.insert(ServerAnswerTFuncSet,{"popcard",popcardA})

function ServerGetCardA(i,t)--called by client
	--translateStringIntoClass(t)
	--local thisPlayer=getPlayerBySocketIndex(i)
	local getcardPlayer = getPlayerBySocketIndex(t.player)
	local thecard =returnCardById(t.card) 
debugPrint("TTTTTTTTTTServerGetCardA")
	getcardPlayer:getCard(thecard,true)

	if getcardPlayer.ishuman then
		sendTableToPlayer(getcardPlayer,{actionName="getCard",cardsid={thecard.id}})
	end
--	clientTellEveryOneInRoom{actionName="notifyHandChange",playername=getcardPlayer.name,num=#getcardPlayer.handcards}
end
table.insert(ServerAnswerTFuncSet,{"getCard",ServerGetCardA})

function ServerSetNetplayerAttr( i,t )
	debugPrint("setNetplayerAttrCALLED")
	translateStringIntoClass(t)
	setNetplayerAttr( t.name,t.attr,t.content )
end
table.insert(ServerAnswerTFuncSet,{"setNetplayerAttr",ServerSetNetplayerAttr})

function ServerGetSthFromServer( i,t )
	if t.getType=="popCurentCardPile" then
		t.result=popACardFromCurPile()
	end
	t.actionName="returnGetSth"
	sendTableToClient(i,t)
end
table.insert(ServerAnswerTFuncSet,{"GetSthFromServer",ServerGetSthFromServer})

function ServerWins( i,t )
	broadCastTheRoomByTable(t)
end
table.insert(ServerAnswerTFuncSet,{"Wins",ServerWins})

		--[[
		elseif thetable.actionName=="inputLogName" and ServerMode=="lobbyMode" then
			printForGame("the client's log name is "..thetable.logName.." and the client's password is "..thetable.password)
			if accounts[thetable.logName] then
				if accounts[thetable.logName].password==thetable.password then
					--sendMsgToClient(i,"yesyes")
					sendTableToClient(i,{actionName="LetClientEnterLobby",publicLobbyInfo=publicLobbyInfo()})
				else
					sendMsgToClient(i,"wrongPassword")
				end
			else
				sendMsgToClient(i,"wrongName")
			end
			--sendMsgToClient(i,"plz input password")
		--	]]
		