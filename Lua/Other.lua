function mousePressEvent(x,y )
	--PMA(1,x-getPicX(1),y-getPicY(1),300)
	debugPrint("Press")
	
end
function mouseMoveEvent(i,x,y )
	--printForGame(x.." "..y)
end
function HoverEnterEvent(i,x,y )
	--printForGame("hover enter")
	--printForGame(x.." "..y)
	--[[
	if getmetatable(getmetatable(AllIndexesPic[i]))==Card then
		if AllIndexesPic[i].inHumanHand then
			PicScaleAnimation(AllPicIndexes[i],1,0.3,200)
		end
	end
	--]]
end
function HoverMoveEvent( i,x,y )
	--printForGame(x.." "..y)
end

function HoverLeaveEvent( i,x,y )
	--printForGame("hover leave")

	--printForGame(x.." "..y)
	--[[
	if getmetatable(getmetatable(AllIndexesPic[i]))==Card then
		if AllIndexesPic[i].inHumanHand then
			PicScaleAnimation(AllPicIndexes[i],1.3,-0.3,200)
		end
	end
	--]]
end
function DIYWindowEvent( s )
	printForGame(s)
end

if not isWpSet then
	setWp("image/w.png")
	isWpSet=true
end
---[[
isOtherStartState=true
require "Settings"
settingButton=settingButton or AddTextButton("设置",600,380,100,50)
settingButton.func=function ()
	inputDialog("默认人数","人数：",settings.defaultNum)
	pause()
	thestring=stringFromInputDialog
	local n = tonumber(thestring)
	settings.defaultNum=n or settings.defaultNum
	io.output("Settings.lua")
	io.write("settings=")
	serialize(settings)
	--waitClick()
end
sButton=sButton or AddTextButton("开始",700,380,100,50)
sButton.func=function ()
	preSetFunc=function ( ... )
		preSetFunc=doNothing
		local function idN( ... )
			inputDialog("选择人数","人数",settings.defaultNum)
			pause()
			printForGame("you inputed "..(stringFromInputDialog or ""))
			local n = tonumber(stringFromInputDialog);
			if n then 
				sButton:destruct()	
				settingButton:destruct()
				return n
			else
				waitClick()
			end
			
		end 
		function alpha1HumanXuan( thejiangs )
			humanXuanjiangs=thejiangs
			for i,v in ipairs(thejiangs) do
				printForGame(i.." "..v.pinyin)
			end
			theTable1={}
			for i,v in ipairs(thejiangs) do
				theTable1[i]=v.pinyin
			end
			addQml("xuanjiang.qml",#theTable1)
			--inputDialog("你要选的武将的序号","序号：","1")
			DIYWindowEvent=function (s)
				thestring= (s+1)..""
				resume()
				--emitS1("dieNow")
			end
			pause()
			--thestring=stringFromInputDialog
			continueXuanjiang()
		end
		stdDealBeforeAlphaLocalSgs(idN,alpha1HumanXuan)
	end
	resume()
end
function qmlStartGame(n)
	preSetFunc=function ( ... )
		preSetFunc=doNothing
		function alpha2HumanXuan( thejiangs )
			humanXuanjiangs=thejiangs
			for i,v in ipairs(thejiangs) do
				printForGame(i.." "..v.pinyin)
			end
			theTable1={}
			for i,v in ipairs(thejiangs) do
				theTable1[i]=v.pinyin
			end
			callQmlFTable("getXuanList",theTable1)
			pause()
			
			continueXuanjiang()
		end
		stdDealBeforeAlphaLocalSgs(n,alpha2HumanXuan)
	end
	resume()
	--emitCallQmlFunction("log",s)
end


uqButton=uqButton or AddTextButton("qml",800,480,100,50)
uqButton.func=function ()
	qml=true
	useqml()
	printForGame=function ( s )
		callQmlF("printTodetailBar",s)
	end
	tM=function ( ... )
		-- body
	end
end

--]]

CheatButton=AddTextButton("作弊键",1150,40,100,50)
CheatButton.func=function ()
--AddPicCantSelectAndMove( 0,0,2000,2000,"QQ20170107-0.jpg")
	--theTable1={"Albert Einstein","itme","Ernest Hemingway", "Hans Gude"}

	addQml("test.qml",0)
	--setColorize(AllPicIndexes[TheHuman.pindex],0x000000)
	--restoreColorize(AllPicIndexes[TheHuman.pindex])
	--[[
	if not isV then
		vanishPic(AllPicIndexes[TheHuman.pindex],1,-1)
		isV=true
	else
		vanishPic(AllPicIndexes[TheHuman.pindex],0,1)
		isV=false
	end
	--]]
	--TheHuman:getCard(getCertainCardInCurrentPile(shaCard))
	--TheHuman:getCard(getCertainCardInCurrentPile(lebuCard))
	--sendTableToServer{actionName="cheat",name="lebuCard"}
	--sendTableToServer{actionName="cheat",name="guanshiCard"}
	--TheHuman:getCard(popCertainCardInCurrentPile(shandianCard))
	--TheHuman:getCard(popCertainCardInCurrentPile(zhugeCard))

	--[[将杀视为八卦
	TheHuman:getCard(popCertainCardInCurrentPile(shaCard))
	for i,v in pairs(TheHuman.handcards) do
		if getmetatable(v)==shaCard then
			setmetatable(v,baguaCard)
			v.skill=newCard(baguaCard,0,0).skill
		end
	end
	--]]
	--TheHuman:getCard(popCertainCardInCurrentPile(shunshouCard))
	--xiajia(TheHuman):getCard(popCertainCardInCurrentPile(wuxieCard))
	
	--xiajia(TheHuman):getCard(popCertainCardInCurrentPile(shaCard))
	--xiajia(TheHuman):getCard(popCertainCardInCurrentPile(shandianCard))
--AAM(700,380,25,229,177,"animationImage/weapon/axe")

	--xiajia(TheHuman):getCard(popCertainCardInCurrentPile(guanshiCard))
	--[[
	preSetFunc=immediatelyWin
	RGFPBWHI()
	--]]
end
function qmlCheatFunc( ... )
	--callQmlFTable("callFuncByTable",{"test1"})
	TheHuman:getCard(popCertainCardInCurrentPile(lebuCard))
	--TheHuman:getCard(popCertainCardInCurrentPile(zhugeCard))
	--xiajia(TheHuman):getCard(popCertainCardInCurrentPile(shanCard))
end
function callQmlFTable(name,t)
	table.insert(t,name)
	theTable1=t
	emitCallQmlFWithTable("callFuncByTable",#theTable1)
end
function callQmlF(name,s)
	--emitCallQmlFunction(name,s)
	--qtLog("callQmlF"..name)
	theTable1={s,name}
	emitCallQmlFWithTable("callFunc",#theTable1)
end
function immediatelyWin()
	printForGame("你赢啦")
	sleep(1000)
	quit()
	sleep(1000)
	clearGameRestoreOriginalCondition()
	clear()
	gameState=""
	preSetFunc=doNothing
	theXiecheng()

end

rl=AddTextButton("更新自定义代码",0,40,220,50);
function updateLua(...)
	package.loaded["Other"]=nil
	require("Other")
end
rl.func=updateLua
op=AddTextButton("打开自定义文件",0,100,220,50)
op.func=function ()
	openFileInApp("Other.lua")
end

function popCertainCardInCurrentPile(card)
	local thecard = 1
	for i,v in pairs(currentPile) do 
		if getmetatable(v)==card then
			thecard=table.remove(currentPile,i)
			break
		end
	end
	
	ctfp(""..#currentPile,AllPicIndexes[cardNumberPI])
	if not thecard then
		ReplaceCardPile()
		thecard = currentPile:deal()
	end
	return thecard
end

function getCertainCardInCurrentPile(card)--undone
	local thecard = 1
	for i,v in pairs(currentPile) do 
		if getmetatable(v)==card then
			thecard=v
			break
		end
	end
	
	
	return thecard
end

debugPrint("Other.lua loaded")