require "gameSystem"
debugPrint("lua loading")

require "BluePants"

sleepTime=2
cardAnimTime=0.5
gameState=""

NUM=0
--guiInput=false


players={}
--players的顺序为静态位置,gamePlayers的顺序为动态位置,初始时，gamePlayers和players相同，随着游戏进行，players元素不会减少，gamePlayers会
gamePlayers={}
Thezhu=nil		Thenei=nil		TheZhongs={}	TheFans={}
TheHuman=nil
shenfenList={"zhu","n","z","f"}
shenfenAssignment={{1,0,0,1},{1,1,0,1},{1,1,1,1},{1,1,1,2},{1,1,1,3},{1,1,2,3},{1,1,2,4}}

jieduans={"Zhunbei","Panding","Mopai","Chupai","Qipai"}



require "Skill"
require "Player"
require "Card" 
require "Wujiangs"
require "Skills"
require "Other"
require "UI"
require "Transmission"
require "Network"
require "Network2"


currentPile=biaozhunPackage

currentPile:shuffle()
qipaiPile=CardPile:new()
otherCards={}
PileCopy={}
for i,v in pairs(currentPile) do
	PileCopy[i]=v
end

curSelectedCards={}
curSelectedPlayers={}


function waitClick( )--for a preset func to call
	pause()
	preSetFunc()
	preSetFunc=doNothing
	clickState=""
end



function waitHumanUse()
	clickstate("wait human use")
	clearPicSelection()
	waitClick()
end

function simpleWaitClickButton()
	clickstate("wait human click button")
	pause()
	clickstate("")
	if qml then
		preSetFunc()
	end
end

preSetFunc=doNothing--for calling from waiting human click sth.


function state( s )
	gameState=s
	printForGame("<font color=red>"..s.."</font> ")
end
function clickstate( s )
	clickState=s
	printForGame("<font color=red>clickState:"..s.."</font> ")
	debugPrint("once")
end

function gameMain()
	--co=coroutine.create(theXiecheng)
	--coroutine.resume(co)

	local theodp=pause
	local theodr=resume
	pause=function ( ... )
		debugPrint 'PAUSEA'
		theodp()
	end
		
	resume=function( ... )
		debugPrint 'RESUME'
		theodr()
	end
	if not isOtherStartState then
		theXiecheng()
	else
		waitClick()
	end
end
function waitHumanInput(  )
	--state("Wait human input")
		--inputState="waiting"
	--coroutine.yield()--pause
	pause()
	getUserCommand(getBarString())
end


function theXiecheng( )--过去曾经用携程来暂停，后来使用了C中的QSemaphore，因此所有的yield都转化成pause
	debugPrint("gameMain called")
	--sleep(3)
		--at()

	if gameState=="" then
		--state("Wait NUM input")
		
		--pause()
		--coroutine.yield()
		--getUserCommand(getBarString())
		startDealBeforeGame()
	end
end

thelastCommandEndPosition=0
function getUserCommand( s )
	--sleep(3)
	local  i,j = 0,thelastCommandEndPosition
	thestring=""
	local ii,jj = 0,0
--user command start with a # and close with a #
--never only write one # but not use another to close
--the loop below is for getting the last command
	while true do
	    i,j = string.find(s, "#[^#]+#", j+1)  
	    if j == nil then 
	    	break 
	    else
	    	ii=i;jj=j
	    end
	   
	end
	if jj ~= 0 then 
		
		 thelastCommandEndPosition=jj
		 thestring=string.sub(s,ii+1,jj-1)
		 if thestring=="demo" then return end
		 debugPrint("thestring is:"..thestring)

		 if thestring=="clear" then
		 	clear()
		 end
		 if gameState=="Wait NUM input" then
		 	startDealBeforeGame()
		 elseif gameState=="Assign wujiang" then
		 	
		 	continueXuanjiang()
		 end

	else
		debugPrint("fuck,you did not use #demo# syntax")
	 end
end
function continueXuanjiang( )
	local theindex = thestring+0
	if theindex>0 and theindex<=#humanXuanjiangs then
		TheHuman:xuanjiang(humanXuanjiangs[theindex])
		table.remove(humanXuanjiangs,theindex)
		putinJiangs(humanXuanjiangs)
	end
end
function clearGameRestoreOriginalCondition( ... )
	broadcastStack={}
	players={}
	
	for i=1,#currentPile do
		table.insert(qipaiPile,table.remove(currentPile))	

	end
	for _,v in pairs(gamePlayers) do
		table.insert(Wujiangs,v.wujiang)
		---[[
		for i=1,#v.handcards do
			table.insert(qipaiPile,table.remove(v.handcards,1))
		end
		for i=1,#v.zhuangbeis do
			if v.zhuangbeis[i]~=0 then
				table.insert(qipaiPile,v.zhuangbeis[i])
			end
		end
		for i=1,#v.pandings do
			table.insert(qipaiPile,table.remove(v.pandings,1))
		end 

	end
	
	ReplaceCardPile(true)
	---[[
	for i,v in pairs(currentPile) do
		v.OnDesk=false
	end
	--]]
	gamePlayers={}	TheZhongs={}	TheFans={}
	allYaoqiuichushanInserted=false
	rl.func( )

end
function oldGetNumFunc()
	state("Wait NUM input")
	pause()
	local s=getBarString()
	local  i,j = 0,thelastCommandEndPosition
	thestring=""
	local ii,jj = 0,0
	while true do
	    i,j = string.find(s, "#[^#]+#", j+1)  
	    if j == nil then 
	    	break 
	    else
	    	ii=i;jj=j
	    end
	   
	end
	if jj ~= 0 then 
		
	 thelastCommandEndPosition=jj
	 thestring=string.sub(s,ii+1,jj-1)
	end
	return tonumber(thestring)
end

function stdDealPreGame(playerAssignment,humanXuanFunc)
	if #playerAssignment<=8 and #playerAssignment>=2 then
		NUM=#playerAssignment
 		printForGame("NUM:"..NUM)
		players=playerAssignment
		local shenfenAssignTable={}
 		for var=1,4 do
 			for _=1,shenfenAssignment[NUM-1][var] do
 				table.insert(shenfenAssignTable,shenfenList[var])
 			end
 			
 		end
 		
 		for i,player in ipairs(players) do
 			player.shenfen=table.remove(shenfenAssignTable,math.random(#shenfenAssignTable))
 			if player.shenfen=="zhu" then 
 				Thezhu=player 
 				Thezhu.position=1
 				Thezhu.zhenying="zhuzhong"
 			elseif player.shenfen=="f" then
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
 		state("Assign position")
 		local positionAssignTable = {}
 		for var=2,NUM do
 			table.insert(positionAssignTable,var)
 		end
 		for i,player in ipairs(players) do
 			if player.shenfen=="f" then
 				player.enemies[1]=Thezhu
 			end
 			if player.shenfen~="zhu" then
 				local var=math.random(#positionAssignTable)

 				player.position=table.remove(positionAssignTable,var)
 			end
 			if player.shenfen=="z" then
 				player.friends[1]=Thezhu
 			end
 		end
 		if qml then
 			callQmlF("setthehumanp",TheHuman.position)
 		end
 		table.sort( players, cmpP )

 		for i,player in ipairs(players) do
 			table.insert(gamePlayers,player)
 			printForGame(gamePlayers[i]:info())
 		end
 		state("Assign wujiang")
 		local zhugongs = {}
 		for i,v in ipairs(Wujiangs) do
 			if v["isZhugong"] then
 				
 				table.insert(zhugongs,table.remove(Wujiangs,i))
 			end
 		end

 		for i=1,3 do
 			table.insert(zhugongs,table.remove(Wujiangs,math.random(#Wujiangs)))
 		end

 		
 		if Thezhu.ishuman then
 			humanXuanFunc(zhugongs)
 		else
 			Xuanjiang(Thezhu,zhugongs)
 		end
 		--other people choose wujiang
 		for i=2,NUM do
 			local thejiangs={}
 			if players[i].shenfen=="n" then
 				for i=1,5 do
 					table.insert(thejiangs,table.remove(Wujiangs,math.random(#Wujiangs)))
 				end
 			else
 				for i=1,3 do
 					table.insert(thejiangs,table.remove(Wujiangs,math.random(#Wujiangs)))
 				end
 			end
 			if players[i].ishuman==true then
 				humanXuanFunc(thejiangs)
 			
 			else

 				Xuanjiang(players[i],thejiangs)
 			end
 		end

 		startGameLoop()
	end
end

function stdDealBeforeAlphaLocalSgs(getNumFunc,humanXuanFunc)
	local thenum

	if type(getNumFunc)=="number" then
		thenum=getNumFunc
	elseif type(getNumFunc)=="string" then
		thenum=tonumber(getNumFunc)
	else
		thenum=getNumFunc()--thestring
	end
	
	if thenum>=2 and thenum<=8 then
 		
 		state("Load players")
 		local playerAssignment={}
 		TheHuman=Player:new{ishuman=true,index=1,name="Human"}
 		table.insert(playerAssignment, TheHuman)

 		printForGame("player "..playerAssignment[1].name.." created")
 		for  var=2,thenum do
 			table.insert(playerAssignment, Player:new{index=var,name="player"..var})
 			printForGame("player "..playerAssignment[var].name.." created")
 		end
 		stdDealPreGame(playerAssignment,humanXuanFunc)
 		

 	end
end
function  startDealBeforeGame(  )
	stdDealBeforeAlphaLocalSgs(oldGetNumFunc,humanXuan)

end

function humanXuan( thejiangs )
	humanXuanjiangs=thejiangs
	for i,v in ipairs(thejiangs) do
		printForGame(i.." "..v.pinyin)
	end
	printForGame("Wait wujiang index input")
	--coroutine.yield()
	pause()
	getUserCommand(getBarString())
	
end



function Xuanjiang( player,thejiangs)
	local var = math.random(#thejiangs)
	local w = thejiangs[var]
	player:xuanjiang(w)
	--player.name=thejiangs[var].pinyin
	table.remove(thejiangs,var)
	putinJiangs(thejiangs)
	return w
end
function putinJiangs( wujiangs)
	for i=1,#wujiangs do
		table.insert(Wujiangs,table.remove(wujiangs,#wujiangs))
	end
end
function  startGameLoop( )
	UIBeforeGameStartSetting()

	state("gameStart")
	broadcast(Thezhu,{act="gameStart"})
	printForGame("----------------")
	state("gameLoop")

	--require "Other"

	
	local nextPlayer = Thezhu
	repeat
		jieduansBroadcast(nextPlayer)
		nextPlayer=xiajia(nextPlayer)
	until gameState=="End"
	
	--broadcast(Thezhu,{act="Zhunbei",1})
	--gamePlayers[3]:answerBroadcast("Demo fdff")
end
function canBroadcastJieduan( player,jieduan )
	
	if not player["forbid"..jieduan] and  player.alive and  gameState~="End" then
		return true
	else
		return false
	end

end
function jieduansBroadcast( player )
	printForGame("----------------------")
    printForGame(player:infoHTML().." start huihe</font> ")
	for i=1,#jieduans do

		if canBroadcastJieduan(player,jieduans[i]) then
			broadcast(player,{act=jieduans[i],theplayer=player})
			

		end
	end
	player:resetState()
end

function popACardFromCurPile()
	if not isAtNet() or isServer then
		local thecard = currentPile:deal()

		if not isAtNet() then
			cardpileNumDisplayChange(-1)
		else
			BroadcastCallFunc( "cardpileNumDisplayChange",{-1} )
		end
		
		if not thecard then
			ReplaceCardPile()
			thecard = currentPile:deal()
		end
		return thecard
	else
		return GetSthFromServer{getType="popCurentCardPile"}
	end
	
end

function pushCardIntoQipaiPile( c )
	table.insert(qipaiPile,c)
	if qml then
		callQmlF("updateQN","弃牌数"..#qipaiPile)
	else
		ctfp(""..#qipaiPile,AllPicIndexes[qiCardNumberPI])
	end
end
function ReplaceCardPile(DontDelete)
	AddInfoBar("洗牌")
	qipaiPile:shuffle()
	if not DontDelete then
		for _,v in pairs(qipaiPile) do
			v.OnDesk=false
			DeletePic(v.pindex)
		end
	end
	currentPile=qipaiPile
	qipaiPile=CardPile:new()
end

function afterDealCard(thecard)
	-- body
end
function mo1Pai( player )
	
	local thecard = popACardFromCurPile()
	printForGame(player:infoHTML().." mo "..thecard:infoHTML())

	player:getCard(thecard)
	return thecard
end

function moNPai( player,n )
	printForGame(player:infoHTML().." mo "..n.." pai")
	

	if not player.atNet then
		for i=1,n do
			mo1Pai(player)
		end
		moNpaiAnim( n,player )
	elseif notServerHuman(player) then
		player:TellServer{actionName="moNPai",num=n}
	end
end

function mo1PaiOnDesk(player,thecard)
	if not player.ishuman then
		notHumanmo1PaiOnDeskAnimain(player,thecard)
	end


	player:getCard(thecard)
end
function qipai( thecard,spText)--一个小约定，弃单个不在玩家手牌里的牌用此函数
	pushCardIntoQipaiPile(thecard)
	
	if not isServer and not isClient then
		if thecard.player then
			qiNPaiAnim(thecard.player,{thecard},spText)
			thecard.player:updateCardNDisplay()
		end
		
	else
		if  thecard.player then
			if 	notServerHuman(thecard.player)  then
				clientTellEveryOneInRoom{actionName="notifyQiNPaiAnim",playername=thecard.player.name,cardsid={thecard.id},nothand=true,spText=spText}
			end
		else

		end
	end
	thecard.inHumanHand=false

	
end

function moveCardToQipaipileFromCards(cards ,thecard)
	local thecard = popCard(cards,thecard)
	pushCardIntoQipaiPile(thecard)
	qiNPaiAnim(thecard.player,{thecard})
end
function qi1Pai( player ,c,isN)--用于弃手牌
	local thecard = player:popCard(c,isN)
	printForGame(player:infoHTML().." qi "..thecard:infoHTML())
	pushCardIntoQipaiPile(thecard)
	if thecard.skill then
		--thecard.skill.player=player
		if thecard.skill.removeSelf then 
			thecard.skill:removeSelf() 
			--printForGame(thecard.skill.player:info())
		end
	end
	if thecard.inHumanHand then thecard.inHumanHand=false end
	--player:updateCardNDisplay()
end
function qiNPai( player,thecards,spText)
	local n = #thecards
	printForGame(player:infoHTML().." qi "..n.." pai")
	for i=1,#thecards do
		qi1Pai(player,thecards[1],true)
		
	end
	
	if not player.atNet then
		if not player.ishuman then
			qiNPaiAnim(player,thecards,spText)
		else
			qiHumanHandcardAnim(thecards)
			player:arrangeCardsPos()
		end
	elseif notServerHuman(player) then
		debugPrint("BROADCASTCLIETNQIPAI")
		clientTellEveryOneInRoom{actionName="notifyQiNPaiAnim",playername=player.name,cardsid=getCardsIds( thecards ),spText=spText}
	end
	
end
function useQiNPai( player,thecards )
	qiNPai( player,thecards,"使用")
end
function qizhiQiNPai( player,thecards )
	qiNPai( player,thecards,"弃置")
end
function dachuQiNPai( player,thecards )
	qiNPai( player,thecards,"打出")
end
function HumanSuperQiNPai(player,thecards )
	local n = #thecards
	printForGame(player:infoHTML().." qi "..n.." pai")

	local handcards = {}
	for i,v in ipairs(thecards) do
		if v.inZhuangbeis then
			player:popZhuangbei(v.znum)
			qipai(v)
		else
			v.flag=1
			qi1Pai(player,v,true)
			table.insert(handcards,v)
		end
	end

	HumanRestoreZButtons()
	qiHumanHandcardAnim(handcards)

	
	player:arrangeCardsPos()
end

function randomQi1Pai( player )
	qi1Pai(player,math.random(#player.handcards))
end
function randomQiNPai( player,N )
	local indexs = {}
	for i=1,#player.handcards do
		indexs[i]=i
	end

	local thecards = {}
	for i=1,N do
		thecards[i]=player.handcards[table.remove(indexs,math.random(#indexs))]
		--randomQi1Pai(player)
	end

	qizhiQiNPai(player,thecards)
	return thecards
end



function xiajia( p)--返回下一个活着的player,isNetRobot indicates whether the caller is a robot
	if p.position==NUM then
		return Thezhu
	else
		
		local theplayers = (p.isInServer and theRoom.players) or players
		local pn = theplayers[p.position+1]
		if pn.alive then
			return pn
		else
			return xiajia(pn)
		end
	end

end


function Panding(player)
	Sleep(player,1.3)
			
	local thecard=popACardFromCurPile()
	local detail = {act="panding",pandingCard=thecard}

	if not isAtNet() then
		UIPanding(player,thecard)
	end
		
	broadcast(player,detail)

	return detail
end

function judgeWin()
	local function fanAlldie( ... )
		for i,v in pairs(TheFans) do
			if  v.alive then
				return false
			end
		end
		return true
	end
	local function zhongAlldie( ... )
		for i,v in pairs(TheZhongs) do
			if  v.alive then
				return false
			end
		end
		return true
	end
	if Thenei then
		if Thezhu.alive==false then
			if Thenei.alive and fanAlldie() and zhongAlldie() then
				return true,"n"
			else
				return true,"f"
			end
		else
			if not Thenei.alive and fanAlldie() then
				return true,"zhuzhong"
			else
				return false
			end
		end
	else
		if Thezhu.alive==false then
			return true,"f"
		else
			if fanAlldie() then
				return true,"zhuzhong"
			else
				return false
			end
		end
	end
end


function THaveCard( t,thecard)
	for i,v in ipairs(t) do
		if getmetatable(v)==thecard  then
			return true,v
		end
	end
	return false
end



function GetSelectionTable(selection)--called by c
	if #selection~=0 then
		if clickState=="wait human qipai" and #selection==HumanQiN then
			local flag = 0
			local t = {}
			for i,v in pairs(selection) do
				vv=AllIndexesPic[v]
				if  getmetatable(getmetatable(vv))==Card and vv.inHumanHand then
					table.insert(t,vv)
				else
					flag=1
					break
				end
			end
			if flag==0 then
				HumanQiSelection=t
				local okF = doNothing
				StdSimpleShowButton(okF)
				preClickState=clickState
				clickstate("wait human click button")
			end
		end
		--[[
		printForGame("printing selection change")
		for i,v in pairs(selection) do
			printForGame(v)
		end
		printForGame("print end")
		--]]
	else
		--[[
		if clickState=="wait human dachu" then

		elseif clickState=="wait human use" then

		elseif clickState=="wait human click button" then
			
		elseif clickState=="wait human choose a player" then
			preSetFunc=doNothing
			clickstate(preClickState)
		elseif clickState=="wait human choose wugucard" then
			
		elseif clickState=="" then

		else
			restoreAllFade()
			curSelectedCards={}
			clickstate(preClickState)
		end
		]]
		
		
	end
end



print "loaded once"

debugPrint("<font color=gold>game.lua loaded</font> ")
debugPrint("<h3>Game Start</h3> ")
