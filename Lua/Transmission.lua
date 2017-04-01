


theRoom={players={},NUM=2}--for Client or for server's room mode
myPlayer=nil--for client player
--Rooms={}--for server
--accounts={test={password=""}}
--publicLobbyInfo=function ()--for server

theClients={}--AllIndexesClient={}
curClientIndex=0

ServerMode="roomMode"
isClient=false
isServer=false

function broadCastTheRoom(s)
	broadCastRoom(theRoom,s)
end

function broadCastTheRoomByTable(t)
	broadCastRoomByTable(theRoom,t)
end

function broadCastTheRoomByTableExceptOne(t,p)
	broadCastRoomByTableExceptOne(theRoom,t,p)
end

function clientTellEveryOneInRoom(t)--called by client
	if isServer then
		broadCastTheRoomByTable(t)
	else
		sendTableToServer{actionName="tellEveryOne",content=t}
	end
end

function clientTellEveryOneInRoomExceptOne(t,p)
	if isServer then
		broadCastTheRoomByTableExceptOne(t,p)
	else
		sendTableToServer{actionName="tellEveryOneExceptOne",content=t,exception=p.name}
	end
end



ServerKnowAConnect=function ()
	printForGame("server know a connect ,name it with "..curClientIndex)
	table.insert(theClients,{id=curClientIndex})
	curClientIndex=curClientIndex+1
	if ServerMode=="lobbyMode" then
		sendMsgToClient(#theClients-1,"plz input uname")
	elseif ServerMode=="roomMode" then
		sendMsgToClient(#theClients-1,"plz input nickname")
	end
end

ServerKnowADisconnect=function (i)
	printForGame("server know disconnect func called")
	table.remove(theClients,i+1)

end
ClientKnowSelfDisconnect=function (fakeParameter)
	printForGame("client know disconnect func called")
end


function ServerAnswerFunc(i,s)--貌似一次最好只发一次，否则会接受不到
	printForGame("theServerAFunc called,string is "..s.." And theClient is "..i)
	thetable=nil
	local f = loadstring("thetable="..s)
	if type(f)=="function" then	f()	end
	if	type(thetable)=="table" then
		ServerAnswerTable(i,thetable)
	else
		--printForGame(type(thetable))
		if s=="fillRobot" then
			local diff = theRoom.NUM-#theRoom.players
			if diff>0 then
				for i=1,diff do
					local thisr = Player:new{name="robot"..i,atNet=true,isInServer=true}
					table.insert(theRoom.players,thisr)
					broadCastTheRoomByTable{actionName="addPlayer",playerinfo=thisr:getNetworkPublicInfo()}
				end
				NetworkStartGame()
			end
		end
	end
end

ClientAnswerFunc=function (s)
	printForGame("theClientAFunc called,string is "..s)
	thetable=nil
	local f = loadstring("thetable="..s)
	if type(f)=="function" then 	f()	end
	if	type(thetable)=="table" then
		ClientAnswerTable( thetable)
		
	else
		printForGame("not table,is "..type(thetable))
		if s=="plz input nickname" then
			preSetFunc=function ()
				preSetFunc=doNothing
				inputDialog("你昵称","昵称：","nick")
				pause()
				local theNN = stringFromInputDialog
				
				sendTableToServer{actionName="inputNickName",nickName=theNN}
				waitClick()
			end
			resume()
		--[[
		elseif s=="plz input uname" then
			preSetFunc=function ()
				inputDialog("你账号名","账号：","test")
				pause()
				local theLN = stringFromInputDialog
				stringFromInputDialog=""
				inputDialog("你密码","密码：","")
				pause()
				local thePs = stringFromInputDialog

				sendTableToServer{actionName="inputLogName",logName=theLN,password=thePs}
			end
			resume()
			--]]
		elseif s=="Start" then
			NUM=#players
			for _,v in pairs(players) do
				table.insert(gamePlayers,v)
			end

			isClient=true
			UIBeforeGameStartSetting()
			SetCardpileNumDisplay(#currentPile)
			TheHuman=myPlayer

			table.insert(myPlayer.broadcastAnswerList,{"panding",NetworkNotifyPanding})

			oldPlaysound=playSound
			playSound=function(dir,Strict)
				if not Strict then
					if isAtNet() then
						clientTellEveryOneInRoom{actionName="notifyPlaysound",dir=dir}
					else
						oldPlaysound(dir)
					end
				else
					oldPlaysound(dir)
				end
			end
			--清理屏幕
			--等待服务器传回位置，身份信息

		elseif s=="simpleResume" then
			preSetFunc=doNothing
			resume()
						--[[
		elseif s=="ShouldResume" then
			printForGame("Called")
			if shouldResume then
				preSetFunc=doNothing
				shouldResume=false
				resume()
			else
				printForGame("But not resume")
			end
			--]]
		end
	end
	
end


cliButton=cliButton or AddTextButton("qike",700,480,100,50)
cliButton.func=function ()
	startClient()
end

serButton=serButton or AddTextButton("qifu",600,480,100,50)
serButton.func=function ()
	startServer()
	isServer=true
end


frButton=frButton or AddTextButton("fillRobot",500,480,100,50)
function NetworkFillRobot(  )
	sendMsgToServer "fillRobot"
end
frButton.func=function ()

	NetworkFillRobot()
end

senButton=senButton or AddTextButton("sendToServer",700,580,100,50)
senButton.func=function ()
	
	sendMsgToServer([[{
 ["detail"] = {
 ["ttt"] = {
 ["jinnang"] = "card",
 ["from"] = "player",
}
,
 ["disabled"] = false,
 ["act"] = "useAoeJinnang",
 ["aoe"] = true,
 ["harm"] = true,
 ["jinnang"] = 73,
 ["from"] = "nick",
}
,
 ["actionName"] = "broadcast",
}]])
end

sencButton=sencButton or AddTextButton("sendToClient",500,580,100,50)
sencButton.func=function ()
	sendMsgToClient(0,"哈哈")
	sendMsgToClient(0,"哈哈")
	sendMsgToClient(0,"哈哈")
end