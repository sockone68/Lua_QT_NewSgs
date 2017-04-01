function demandDachuWithoutThink(theplayer,cardType,detail,yesFunc,noFunc)
	local thinkFunc = function () return true end
	demandDachu(theplayer,cardType,detail,thinkFunc,yesFunc,noFunc)
end
function demandDachu(player,cardType,detail,thinkFunc,yesFunc,noFunc)
	if player.ishuman then
		demandHumanDachu(cardType,detail,yesFunc,noFunc)
	else
		Sleep(player,1.3)
		local have,v = player:haveCard(cardType)
		if have and thinkFunc(detail) then
			player:pointAnotherPlayer(detail.from)
			--avl(player.cX,player.cY,detail.from.cX,detail.from.cY)
			player:dachu(v)
			yesFunc()
		else
			noFunc()
			debugPrint("NO!")
		end
	end
end

function clickWhenHumanDachu(responseItem)
	if getmetatable(responseItem)==yaoqiuDachuCard and responseItem.inHumanHand then
		responseItem:responseClick()
		local okF = function ()
			theHumansAnswer={answer="yes",card=responseItem}
		end
		local cF = function ()
			theHumansAnswer={answer="no"} 
			clearPicSelection()

		end
		stdShowButton(okF,cF,true,true)
		preClickState=clickState
		clickstate("wait human click button")
	end
end
table.insert(PressFuncSet,{"wait human dachu",clickWhenHumanDachu})


function demandHumanDachu(cardType,detail,yesFunc,noFunc)
	AddInfoBar("请打出"..cardType.name)
	local alltheCards = {}
	for _,v in pairs(TheHuman.handcards) do
		if getmetatable(v)==cardType then
			table.insert(alltheCards,v)
		end
	end
	fadeT1ExceptT2(TheHuman.handcards,alltheCards)
	yaoqiuDachuCard=cardType
	clickstate("wait human dachu")
	clearPicSelection()
	waitClick()

	restoreAllFade()
	preClickState=""
	if theHumansAnswer then
		if theHumansAnswer.answer=="yes" then
			local c = theHumansAnswer.card
			TheHuman:dachu(c)
			theHumansAnswer=nil
			yesFunc(c)
		else
			--debugPrint("BefOre1")
			noFunc()
			
		end
	else
		noFunc()
	end
end

function askHumanACardToDoSth(cardType,detail,yesFunc,noFunc)
	local alltheCards = {}
	for _,v in pairs(TheHuman.handcards) do
		if getmetatable(v)==cardType then
			table.insert(alltheCards,v)
		end
	end
	fadeT1ExceptT2(TheHuman.handcards,alltheCards)
	yaoqiuDachuCard=cardType
	waitHumanUse()

	restoreAllFade()
	clickState=""
	preClickState=""
	if theHumansAnswer then
		if theHumansAnswer.answer=="yes" then
			local c = theHumansAnswer.card
			theHumansAnswer=nil
			yesFunc(c)
		else
			noFunc()
			
		end
	else
		noFunc()
	end
end

function DemandSthForSth(info,player,detail,humanFunc,thinkFunc,yesFunc,noFunc)
	if player==TheHuman then
		AddInfoBar(info)
		humanFunc(detail)
		if theHumansAnswer then--约定，theHumanAnswer是人类返回的结果，自动被humanFunc添加到detail中
			if theHumansAnswer.answer=="yes" then
				theHumansAnswer=nil
				yesFunc(detail)
			else
				noFunc()
			end
		else
			noFunc()
		end
	else
		Sleep(player,1.3)
		if  thinkFunc(detail) then
			yesFunc()
		else
			noFunc()
		end
	end
end

function zhuangbeiSkill:isChupaiAv()
	local player = self.player
	
	if player:haveCardType("zhuangbei") then
		debugPrint("have zhuangbei")
		return true
	else
		debugPrint("no zhuangbei")
		return false
	end
end
zhuangbeiTypeNameList = {"wuqi","fangju","jia1ma","jian1ma"}
function zhuangbeiSkill:strictSkill(card)
	local player = self.player
	local c = card
	
	local num = c.znum
	local function real()
		printForGame("start put on this "..c.maintype)
		if player.zhuangbeis[num]~=0 then
			local preC =player:popZhuangbei(num)
			qipai(preC,"弃置")
			debugZButton=preC.HumanButton
		end
		
		player.zhuangbeis[num]=player:popCard(c)

		if num==1 then
			local preRSkill = c.skill.removeSelf
			c.skill.removeSelf=function (s)
				s.player.gongjiJuli=1
				if  preRSkill~=Skill.removeSelf then
					preRSkill(s)
				end
				s.player=nil
			end
		end

		c.skill.player=player
		c.skill:addSelf(player)

		c.inZhuangbeis=true
		printForGame(player:info().." 装 "..c.pinyin.."完成")
	end

	real()
	if not player.atNet then
		UIAddZhuangbei(player,c,num)
	elseif notServerHuman(player) then
		player:TellServer{actionName="AddZhuangbei",cardid=c.id,num=num}
	end
	
	if c.znum==1 then
		player.gongjiJuli=c.gongjiJuli
		printForGame(player:info().." gongjiJuli "..player.gongjiJuli)
	end
	
	playSound(c.settleSound)
	
	
end
function zhuangbeiSkill:doSkill(  )
	local _,c=self.player:haveCardType("zhuangbei")

	Sleep(self.player)
	self:strictSkill(c)
	
end
function afterDoHumanSkill()
	restoreAllFade()
	preSetFunc=doNothing
	waitHumanClickForChupai()
end
function zhuangbeiSkill:doHumanSkill(card)
	self:strictSkill(card)
	afterDoHumanSkill()
end

function zhugeSkill:addSelf(player)
	player.shaInfinite=true
end

function zhugeSkill:removeSelf()
	self.player.shaInfinite=false
end

function cixiongAim(theplayer,detail)
	local from = detail.from
	local to = detail.to

	local function askDoWhat()
		detail.from:pointAnotherPlayer(detail.to)
		--avl(detail.from.cX,detail.from.cY,detail.to.cX,detail.to.cY)
		if to==TheHuman then

			AddInfoBar("点确定让对方摸1牌，点取消让自己弃1牌")
			stdShowButton(doNothing,doNothing,true,true)
			simpleWaitClickButton()

			if theClickedButton then
				if theClickedButton.name=="okButton" then
					moNPai(from,1)
				else
					HumanQiN=1
					HumanQiSelection={}
					waitHumanQipai()
					qizhiQiNPai(TheHuman,HumanQiSelection)
					
				end
				theClickedButton=nil
			else
				HumanQiN=1
				HumanQiSelection={}
				waitHumanQipai()
				qizhiQiNPai(TheHuman,HumanQiSelection)
					
			end
		else
			Sleep(to)
			moNPai(from,1)
		end
	end

	if theplayer==from and from.isMale~=to.isMale then
		if from==TheHuman then
			AddInfoBar("是否发动雌雄双股剑技能")
			StdSimpleShowButton(doNothing)
			simpleWaitClickButton()

			if theClickedButton then
				if theClickedButton.name=="okButton" then
					askDoWhat()
				end
				theClickedButton=nil
			end
		else
			Sleep(from)
			askDoWhat()
		end
		
	end
end
function cixiongSkill:addSelf(player)
	printForGame("add cixiongSkill")
	
	table.insert(player.broadcastAnswerList,{"shaAim",cixiongAim})
end
function cixiongSkill:removeSelf()
	self.player:removeAnswerFunc("shaAim",cixiongAim)
end
function qinggangAim(theplayer,detail)
	debugPrint("qinggang1")
	if theplayer==detail.from then

		Sleep(theplayer,1)
		detail.from:pointAnotherPlayer(detail.to)
		
		AddInfoBar("青釭剑无视防具")
		detail.wushiFj=true
	end
end
function qinggangSkill:addSelf(player)
	printForGame("add qinggangSkill")
	table.insert(player.broadcastAnswerList,{"shaAim",qinggangAim})
end

function qinggangSkill:removeSelf()
	self.player:removeAnswerFunc("shaAim",qinggangAim)
end

function baguaResponse(theplayer,detail)
	local aR = false
	if detail.aimDetail then
		if detail.aimDetail.wushiFj then
			aR=true
		end
	end
	if theplayer==detail.to and not detail.alreadyShan and not aR  then
		local function doB()
			AddInfoBar(theplayer.CN.."发动八卦阵")
			
			local pD = Panding(theplayer)
			if pD.pandingCard:color()=="R" then
				AddInfoBar("八卦阵生效")
				detail.alreadyShan=true
			else
				AddInfoBar("八卦阵失效")
			end
		end
		if theplayer==TheHuman then
			AddInfoBar("是否发动八卦阵技能")
			stdShowButton(doNothing,doNothing,true,true)
			simpleWaitClickButton()

			clearButtons()
			if theClickedButton then
				if theClickedButton.name=="okButton" then
					doB()
				end
				theClickedButton=nil
			end
		else
			doB()
		end
	end
end
function baguaSkill:addSelf(player)
	printForGame("add baguaSkill")
	table.insert(player.broadcastAnswerList,
		FindIndexOfAnswerFunc(player,"yaoqiuchuShan",doYaoqiuchuShan)
		,{"yaoqiuchuShan",baguaResponse})
end

function baguaSkill:removeSelf()
		self.player:removeAnswerFunc("yaoqiuchuShan",baguaResponse)
end
function renwangResponse(player,detail)

	if player==detail.to and judgeCardsColor(detail.cards)=="B"  then
		if  detail.wushiFj then
			
		else
			AddInfoBar(player.CN.."发动了仁王盾")
			detail.cancelSha=true
		end
		
	end
end
function renwangSkill:addSelf(player)
	printForGame("add renwangSkill")
	
	table.insert(player.broadcastAnswerList,
		FindIndexOfAnswerFunc(player,"yaoqiuchuShan",doYaoqiuchuShan)
		,{"shaAim",renwangResponse})
end

function renwangSkill:removeSelf()
		self.player:removeAnswerFunc("shaAim",renwangResponse)
end
function clickWhenAskUse(responseItem)
	if getmetatable(responseItem)==yaoqiuDachuCard then
		responseItem:responseClick()
		local okF = function ()
			theHumansAnswer={answer="yes",card=responseItem}
		end
		local cF = function ()
			theHumansAnswer={answer="no"} 
			clearPicSelection()

		end
		stdShowButton(okF,cF,true,true)
		preClickState=clickState
		preSetFunc=doNothing
		clickstate("wait human click button")

	end
end
table.insert(PressFuncSet,{"wait human use",clickWhenAskUse})

function qinglongResponse(player,detail)
	if detail.reason.from==player then
		if player==TheHuman and detail.fromSha==true then
			AddInfoBar("是否再使用一张杀")
			local function yesFunc(c)
				c.skill:strictSkill({detail.reason.to},{c})
			end
			askHumanACardToDoSth(shaCard,detail,yesFunc,doNothing)
		else
			local r,v = player:haveCardType(shaCard)
			if r then
				player:pointAnotherPlayer(detail.reason.to)
				Sleep(player)
				v.skill:strictSkill({detail.reason.to},{v})
			end
		end
		
	end
end
function qinglongSkill:addSelf(player)
	printForGame("add qinglongSkill")
	
	table.insert(player.broadcastAnswerList,{"shanLe",qinglongResponse})
end
function qinglongSkill:removeSelf()
		self.player:removeAnswerFunc("shanLe",qinglongResponse)
end

function clickWhenSuperQipai(responseItem)
	if getmetatable(responseItem)==Button then
		if responseItem.card then
			if not responseItem.card.inHumanQiSelection then
				table.insert(HumanQiSelection,responseItem.card)	
				responseItem.card.inHumanQiSelection=true
				HumanZButtonLeftAnim(responseItem)
				if #HumanQiSelection==HumanQiN then
					local okF = doNothing
					StdSimpleShowButton(okF)
					preClickState=clickState
					clickstate("wait human click button")
				end
			else
				HumanZButtonRightAnim(responseItem)
				clearButtons()
				table.remove(HumanQiSelection,getIndexInT(HumanQiSelection,responseItem.card))	
				responseItem.card.inHumanQiSelection=false
			end
		end
	elseif getmetatable(getmetatable(responseItem))==Card and responseItem.inHumanHand then
		if not responseItem.inHumanQiSelection then
			table.insert(HumanQiSelection,responseItem)	
			responseItem.inHumanQiSelection=true
			responseItem:raise()
			if #HumanQiSelection==HumanQiN then
				local okF = doNothing
				StdSimpleShowButton(okF)
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
table.insert(PressFuncSet,{"wait human super qipai",clickWhenSuperQipai})
function waitHumanSuperQipai()
	AddInfoBar("请弃"..HumanQiN.."牌")
	HumanZButtonAllLittleLeft()
	clickstate("wait human super qipai")
	clearPicSelection()
	preClickState="wait human super qipai"
	waitClick()

	
end
function guanshiResponse(player,detail)
	if detail.reason.from==player and detail.fromSha==true then
		local function forceHit( )
			player:pointAnotherPlayer(detail.reason.to)
			UICreateAnimation(player,"animationImage/weapon/axe","../animationImage/weapon/axe.png")
			Sleep(player,1)
			broadcast(detail.reason.to,{act="getHurt",
						from=player,reason=detail,to=detail.reason.to})
		end
		if player==TheHuman then
			AddInfoBar("是否发动贯石斧弃两张牌强制命中")
			stdShowButton(doNothing,doNothing,true,true)
			simpleWaitClickButton()

			if theClickedButton then
				if theClickedButton.name=="okButton" then
					AddInfoBar("请弃两张牌强制命中")
					HumanQiN=2
					HumanQiSelection={}
					waitHumanSuperQipai()
					HumanSuperQiNPai(TheHuman,HumanQiSelection)
					forceHit()
				end
				theClickedButton=nil
			end
			
		else
			if #player.handcards>1 then
				AddInfoBar(player.CN.."发动贯石斧")
				
				
				randomQiNPai(player,2)
				forceHit()
			end
		end
		
	end
end
function guanshiSkill:addSelf(player)
	printForGame("add guanshiSkill")
	
	table.insert(player.broadcastAnswerList,{"shanLe",guanshiResponse})
end
function guanshiSkill:removeSelf()
		self.player:removeAnswerFunc("shanLe",guanshiResponse)
end

TheZhangbaSkill=Skill:new{name="TheZhangbaSkill"}
function TheZhangbaSkill:isChupaiAv( )
	local player = self.player
	local sk = shaSkill:new()
	sk.player=self.player

	if player:haveCard(shaCard) then
		debugPrint("already have sha")
	elseif #player.handcards>1 and sk:isChupaiAv() then
		debugPrint("yes i can use zhangba")
		return true
	end
	debugPrint("cant use zhangba")
	return false
end
function TheZhangbaSkill:strictSkill(hp,cards)
	local sk = shaSkill:new()
	sk.player=self.player
	sk:strictSkill({hp},cards)
end
function TheZhangbaSkill:doSkill()
	local player = self.player
	if #player.enemies==0 then
		player.cantSha=true
		debugPrint("enemies=0")
	else
		debugPrint("has enemy")
		local flag = 0
		for i,v in ipairs(player.enemies) do
			if player:juli(v)<=player.gongjiJuli then
				Sleep(player)
				self:strictSkill(v,RandomCombination(player.handcards,2))
				break
			end
		end
	end
end
function zhangbaSkill:addSelf( p )
	if p~=TheHuman then
		TheZhangbaSkill.player=p
		table.insert(self.player.skills,TheZhangbaSkill)
	else
		zhangbaSkill:addForHuman()
	end
end
function zhangbaSkill:addForHuman()
	local theButton=self:addSkillButtonForHuman(TheHuman)
	theButton.func=self.humanButtonFunc
end
function zhangbaSkill:removeSelf()
		if self.player~=TheHuman then
			table.remove(self.player.skills,getIndexInT(self.player.skills,TheZhangbaSkill))
			TheZhangbaSkill.player=nil
		else
			if self.humanButton then
				self:removeSkillButton()
			end
		end
end

function zhangbaSkill.humanButtonFunc(  )
	if clickState=="wait human click for chupai" then
		preSetFunc=function ( ... )
			preSetFunc=doNothing
			HumanQiN=2
			HumanQiSelection={}
			AddInfoBar("请选择2张手牌")

			local function fCancel()
				for _,v in pairs(HumanQiSelection) do
					v:down()
					v.inHumanQiSelection=false
				end
				HumanQiSelection={}
				restoreAllFade()
				AddInfoBar("请出牌")
				clickstate("wait human click for chupai")
			end
			qipaiCancelF=fCancel
			qipaiOkF=function ( ... )
				qipaiOkF=nil
				clickstate("wait human choose a player")
				preInfoForClickPlayer="请单击一个想杀的人"
				AddInfoBar(preInfoForClickPlayer)

				local function Determine()
					local function tOk( )
						
							local sk = shaSkill:new()
							sk.player=TheHuman
							sk:strictSkill({curSelectedPlayers[1]},HumanQiSelection)
							afterDoHumanSkill()
						
					end
					
					stdShowButton( tOk,fCancel,true,false )
					AddInfoBar("请单击确定来杀")
					clickstate("wait human click button")
					preClickStateWithPlayer="wait human choose a player"

					--pause()
				end
				preSetFuncAfterChooseAPlayer=Determine
				waitClick()
			end
			clickstate("wait human qipai")
			clearPicSelection()
			waitClick()
		end
		resume()
	elseif clickState=="wait human use" then
		if yaoqiuDachuCard==shaCard then

		end
	end
	
end
function shaSkill:addSelf(player,thecard)

	--self.player=player
	printForGame("assign "..thecard:info().." to "..player:info())
	--self.thecard=thecard
	self.cantSha=false
	--if not allYaoqiuichushanInserted then
	--	for i,v in ipairs(gamePlayers) do
			--table.insert(v.broadcastAnswerList,{"yaoqiuchuShan",doYaoqiuchuShan})
	--	end
	--	allYaoqiuichushanInserted=true
	--end
	if not player.shaDoQipaiInserted then
		table.insert(player.broadcastAnswerList,{"Qipai",self.doInQipai})

		player.shaDoQipaiInserted=true
		player.haventSha=true
	end
	
end

function doYaoqiuchuShan(player,detail)
	if not detail.alreadyShan then
		if detail.to==player then
			if not player.ishuman then
				if not TContainsA(player.enemies,detail.from) then
					table.insert(player.enemies,detail.from)
					debugPrint("你废了")
				end
			end
			local yesF = function ()
				detail.alreadyShan=true
				
			end
			local noF = function ( )
				
			end
			demandDachuWithoutThink(player,shanCard,detail,yesF,noF)
			detail.stop=true
		else
			if TContainsA(player.friends,detail.to) then
				table.insert(player.enemies,detail.from)
			end
			if TContainsA(player.enemies,detail.to) then
				table.insert(player.friends,detail.from)
			end
		end
	end
end
table.insert(otherBroadcastAnswerFuncList,{"yaoqiuchuShan",doYaoqiuchuShan})

function shaSkill.doInQipai(player,detail)
	if player==detail.theplayer then
		debugPrint("doinqipai called")
		player.shaTimes=0
		player.cantSha=false
	end
end
function shaSkill:removeSelf(player)
	--player.skills.sha=nil
	self.player=nil
end
function shaSkill:isChupaiAv( )
	local player = self.player
	if player.cantSha then
		return false
	elseif player.shaTimes<player.shaMax and self:isCanShaEnemy() then
		debugPrint("yes cansha")
		return true
	elseif player.shaInfinite  and self:isCanShaEnemy() then
		return true
	else
		return false
	end
end
function shaSkill:isCanShaEnemy()
	local flag = 0
	local player = self.player
	for i,v in ipairs(player.enemies) do
		if player:juli(v)<=player.gongjiJuli then
			flag=1
			break
		end
	end
	if flag==1 then
		return true
	else
		return false
	end
end
function shaSkill:doSkill()
	
	if self.iscard then debugPrint("sha is card") end
	local player = self.player

	if #player.enemies==0 then
		player.cantSha=true
		debugPrint("enemies=0")
	else
		debugPrint("has enemy")
		local flag = 0
		for i,v in ipairs(player.enemies) do
			if player:juli(v)<=player.gongjiJuli then
				Sleep(player)
				self:strictSkill({v},{self.thecard})
				break
			end
		end
	end
	
end
function shaSkill:strictSkill(hurtPlayers,shacards)
	preSetFunc=doNothing
	local player = self.player
	self:playSound()
	useQiNPai(player,shacards)

	local sADs = {}
	for i,hp in pairs(hurtPlayers) do
		printForGame(player.name.." ".."sha"..hp.name)
		player:pointAnotherPlayer(hp)

		local theaimT ={act="shaAim",to=hp,from=player,cards=shacards}
		broadcast(player,theaimT)
		sADs[i]=theaimT
	end

	debugPrint("sha times +1")
	player.shaTimes=player.shaTimes+1
	
	for i,hp in pairs(hurtPlayers) do
		if not sADs[i].cancelSha then
			player.haventSha=false
			local theT = {act="yaoqiuchuShan",to=hp,from=player}--,aimDetail=sADs[i]
			broadcast(player,theT)

			if theT.alreadyShan==true then
				debugPrint("TRUE")
				broadcast(theT.to,{act="shanLe",reason=theT,fromSha=true})
			else
				debugPrint("FALSE")
				broadcast(hp,{act="getHurt",from=player,to=hp,reason=theT})--
			end
		end
	end 
	
end
function shaSkill:doHumanSkill( )
	local shacard=curSelectedCards[1]
	local shaPlayer=curSelectedPlayers[1]			
	self:strictSkill({shaPlayer},{shacard})
	afterDoHumanSkill()
end
function taoSkill:isChupaiAv(  )
	local player = self.player
	debugPrint("has tao")
	--printForGame(player.life)
	if player.life<player.maxLife  then
		debugPrint("yes can eat Tao")
		return true
	else
		return false
	end
end
function taoSkill:strictSkill()
	self.player:huixie{}--theplayer=self.player
	useQiNPai(self.player,{self.thecard})
end

function taoSkill:doHumanSkill(  )
	self:strictSkill()
	afterDoHumanSkill()
end
function wuzhongshengyouSkill:isChupaiAv( )
	debugPrint("can wuzhong")
	return true
end
function wuzhongshengyouSkill:strictSkill()
	local player = self.player
	local wuzhongT = 
	{act="useJinnang",jinnang=self.thecard,from=player,to=player,
		harm=false,disabled=false}

	function shiyongWuzhong()
		--Sleep(self.player)
		self:playSound()
		useQiNPai(player,{self.thecard})
		
		printForGame("使用无中生有")
		broadcast(player,wuzhongT)
	end
	function getWuzhongBenifit()
		moNPai(player,2)
	end
	shiyongWuzhong()
	if not wuzhongT.disabled then
		getWuzhongBenifit()
	end
end
function wuzhongshengyouSkill:doHumanSkill()
	self:strictSkill()
	afterDoHumanSkill()
end

function wuxiekejiSkill:addSelf( player,thecard )
	if not player.AnsDoWhenUseJinnangInserted then
		printForGame("添加无懈可击响应")
		table.insert(player.broadcastAnswerList,{"useJinnang",wuxiekejiSkill.doWhenUseJinnang})
		player.AnsDoWhenUseJinnangInserted=true
	end
end
function wuxiekejiSkill:isChupaiAv(  )
	return false
end
--[=[
function wuxieSkill:cancelAns( )
	if not self.player:haveCard(wuxieCard) then
		self.player:popFuncInBList(wuxieSkill.doWhenUseJinnang)
	end
end
-]=]
function wuxiekejiSkill.doWhenUseJinnang( player,detail )
	debugPrint(player:info().."无邪answer")
	local have,thecard = player:haveCard(wuxieCard)
	
	function dachuWuxie(card)
		preSetFunc=doNothing
		if player~=TheHuman then
			Sleep(player)
			player:dachu(card)
		end
		
		detail.stop=true
		if detail.WuxieSourceDetail then
			
			detail.WuxieSourceDetail.disabled=not detail.WuxieSourceDetail.disabled
			broadcast(player,
				{act="useJinnang",jinnang=card,from=player,to=detail.from,
				harm=true,WuxieSourceDetail=detail.WuxieSourceDetail})
		else
			detail.disabled=not detail.disabled
			broadcast(player,
				{act="useJinnang",jinnang=card,from=player,to=detail.from,harm=true,
				WuxieSourceDetail=detail,disabled= detail.disabled})
		end

	end
	if have then
		if not player.ishuman then
			if TContainsA(player.enemies,detail.from) 
				and TContainsA(player.enemies,detail.to) and detail.harm==false then
				debugPrint("first wuxieReason")
				dachuWuxie(thecard)
			elseif TContainsA(player.friends,detail.to) and detail.harm==true then
				debugPrint("second wuxieReason")
				dachuWuxie(thecard)
				
			end
		else
			AddInfoBar("是否打出无懈可击")
			
			demandDachuWithoutThink(TheHuman,wuxieCard,detail,dachuWuxie,doNothing)
			
		end
		
	end
end

function clickWuguCard(responseItem)
	if responseItem.isWuguCard then
		debugPrint("chose wugucard")
		theChosenWugucard=responseItem
		preSetFunc=doNothing
		RGFPBWHI()
	end
end
table.insert(PressFuncSet,{"wait human choose wugucard",clickWuguCard})


function wugufengdengSkill:isChupaiAv() 
	return true

end

function MoWhenWugu(player,Detail) 
	local wuguDetail = Detail.aoeDetail
	local WT = {act="useJinnang",jinnang=Detail.thecard,from=Detail.from,to=player,aoe=true
			,harm=false,disabled= false,aoeDetail=wuguDetail}
	broadcast(player,WT)

	--these 2 lines are for network
	wuguDetail=WT.aoeDetail
	Detail.aoeDetail=WT.aoeDetail

	if not WT.disabled then
		if not player.ishuman then
			
			if wuguDetail.cards[1] then
				if #wuguDetail.cards==1 then
					Sleep(player,0.8)
				else
					Sleep(player)
				end
				AddInfoBar(player.CN.."摸了"..wuguDetail.cards[1].name)

				if not isAtNet() then
					mo1PaiOnDesk(player,wuguDetail.cards[1])
				else
					clientTellEveryOneInRoom{actionName="mo1PaiOnDesk",card=wuguDetail.cards[1],getplayer=player}
				end

				
				wuguDetail.cards[1].OnDesk=false
				table.remove(wuguDetail.cards,1)
			end
		else
			AddInfoBar("请摸一张五谷牌")
			clickstate("wait human choose wugucard")
			clearPicSelection()
			waitClick()
			
			if not isAtNet() then
				mo1PaiOnDesk(TheHuman,theChosenWugucard)
			else
				clientTellEveryOneInRoom{actionName="mo1PaiOnDesk",card=theChosenWugucard,getplayer=TheHuman}
			end
			--mo1PaiOnDesk(TheHuman,theChosenWugucard)
			theChosenWugucard.isWuguCard=false
			table.remove(wuguDetail.cards,getIndexInT(wuguDetail.cards,theChosenWugucard))
			theChosenWugucard=nil
		end
	end
end
function afterWugu(detail)
	if detail.from ==TheHuman then
		clickstate(preClickState)
		restoreAllFade()
	end
end

function wugufengdengSkill:strictSkill()
	self:playSound()
	local player = self.player
	allPointLine(player)
	useQiNPai(player,{self.thecard})
	local wuguCards = {}
	
	local n = #gamePlayers
	local np = player
	for i = 1,n do
		local c = popACardFromCurPile()
		c.isWuguCard=true
		c.WuguIndex=i
		table.insert(wuguCards,c)
		player:pointAnotherPlayer(np)

		np=xiajia(np)
	end

	UIAddWuguCards( wuguCards )

	
	broadcast(player,
				{act="useAoeJinnang",jinnang=self.thecard,from=player,aoe=true,harm=false,
				disabled= false,aoeFunc=MoWhenWugu,aoeDetail={cards=wuguCards,
				cardsDetail={},curIndex=1},afterBroFunc=afterWugu})

end

function wugufengdengSkill:doHumanSkill()
	self:strictSkill()
	preSetFunc=doNothing
	waitHumanClickForChupai()
	--afterDoHumanSkill()
end


function allPointLine(player)
	local np = player
	local n = #gamePlayers
	for i = 1,n do
		player:pointAnotherPlayer(np)
		--avl(player.cX,player.cY,np.cX,np.cY)
		np=xiajia(np)
	end
end

function nanmanruqinSkill:isChupaiAv()
	return true
end

function ansNan(player,Detail) 
	local nanDetail = Detail.aoeDetail
	if Detail.from==player then

	else
		if Detail.from==nil then
			debugPrint("SUPERFUCK")
		end
		local WT = {act="useJinnang",jinnang=Detail.jinnang,from=Detail.from,to=player
		,aoe=true,harm=true,disabled= false,aoeDetail=nanDetail}
		broadcast(player,WT)

		if not WT.disabled then
			local yesF = function ()
				broadcast(player,{act="dachushaLe",reason=Detail})
			end
			local noF = function ( )
				broadcast(player,{act="getHurt",from=Detail.from,to=player,reason=Detail})--
			end
			demandDachuWithoutThink(player,shaCard,Detail,yesF,noF)
			
		end
	end
	
end

function nanmanruqinSkill:strictSkill()
	self:playSound()
	local player = self.player
	useQiNPai(player,{self.thecard})
	allPointLine(player)
	
	
	broadcast(player,
				{act="useAoeJinnang",jinnang=self.thecard,from=player,aoe=true,harm=true,
				disabled= false,aoeFunc=ansNan,aoeDetail={cardsDetail={},},})
end

function nanmanruqinSkill:doHumanSkill( ... )
	self:strictSkill()
	afterDoHumanSkill()
end

function wanjianqifaSkill:isChupaiAv()
	return true
end

function ansWan(player,Detail) 
	local wanDetail = Detail.aoeDetail
	if Detail.from==player then

	else
		local WT = {act="useJinnang",jinnang=Detail.jinnang,from=Detail.from,to=player
		,aoe=true,harm=true,disabled= false,aoeDetail=Detail.aoeDetail}
		broadcast(player,WT)

		if not WT.disabled then
			--[[
				local yesF = function ()
					broadcast(player,{act="dachushanLe",reason=Detail})
				end
				local noF = function ( )
					broadcast(player,{act="getHurt",from=Detail.from,reason=Detail,to=player})
				end
				demandDachuWithoutThink(player,shanCard,Detail,yesF,noF)
			
			]]
			
			local theT = {act="yaoqiuchuShan",to=player,from=Detail.from}
			broadcast(player,theT)

			if theT.alreadyShan==true then
				broadcast(player,{act="shanLe",reason=theT})--
			else
			--	debugPrint("HAHAHAHAHA")
				broadcast(player,{act="getHurt",from=theT.from,to=player,reason=theT})--
			--	debugPrint("afterBGH")
			end
		end
	end
	
end

function wanjianqifaSkill:strictSkill()
	self:playSound()
	local player = self.player
	useQiNPai(player,{self.thecard})
	allPointLine(player)
	
	
	broadcast(player,
				{act="useAoeJinnang",jinnang=self.thecard,from=player,aoe=true,harm=true,
				disabled= false,aoeFunc=ansWan,aoeDetail={cardsDetail={},},})
end

function wanjianqifaSkill:doHumanSkill( ... )
	self:strictSkill()
	afterDoHumanSkill()
end
function taoyuanjieyiSkill:isChupaiAv()
	return true
end

function ansTao(player,Detail) 
		
	local WT = {act="useJinnang",jinnang=Detail.jinnang,from=Detail.from,to=player
	,aoe=true,harm=false,disabled= false,}
	broadcast(player,WT)

	if not WT.disabled then
		player:huixie(Detail)
	end
end
function taoyuanjieyiSkill:strictSkill()
	self:playSound()
	local player = self.player
	useQiNPai(player,{self.thecard})
	allPointLine(player)
	
	
	broadcast(player,
				{act="useAoeJinnang",jinnang=self.thecard,from=player,aoe=true,harm=true,
				disabled= false,aoeFunc=ansTao,aoeDetail={cardsDetail={},},})
end

function taoyuanjieyiSkill:doHumanSkill( ... )
	self:strictSkill()
	afterDoHumanSkill()
end
function juedouSkill:isChupaiAv()
	if not self.cant then
		debugPrint("can jd")
		return true
	else
		return false
	end
end

function ansJ(player,Detail,thefrom) 
	local noF = function ( )
		broadcast(player,{act="getHurt",from=thefrom,to=player})
	end
	local yesF = function ()
		if not isAtNet() then
			ansJ(thefrom,Detail,player) 
		else
			broadcast(player,{act="demandDachu",from=player,to=thefrom,dachuFunc=ansJ})
		end
	end
	demandDachuWithoutThink(player,shaCard,{from=thefrom},yesF,noF)
end

function juedouSkill:strictSkill(from,to)
	self:playSound()
	--local player = self.player
	from:pointAnotherPlayer(to)
	--avl(from.cX,from.cY,to.cX,to.cY)
	useQiNPai(from,{self.thecard})

	local JT = {act="useJinnang",jinnang=self.thecard,from=from,to=to,harm=true,
				disabled= false,}
	for _,v in pairs(gamePlayers) do
		v:judgeEnemy(JT)
	end
	broadcast(from,JT)
	if not JT.disabled then
		if not isAtNet() then
			
			ansJ(to,{},from) 
		else
			broadcast(from,{act="demandDachu",from=from,to=to,dachuFunc=ansJ})
		end
	end
end
function juedouSkill:doSkill()
	local player = self.player

	if #player.enemies==0 then
		self.cant=true
		debugPrint("enemies=0")
	else
		debugPrint("has enemy")
		
		for i,v in ipairs(player.enemies) do
			Sleep(player)
			self:strictSkill(player,v)
			break
		end
		
	end
end
function juedouSkill:doHumanSkill()
	local jcard=curSelectedCards[1]
	local jPlayer=curSelectedPlayers[1]		
	preSetFunc=doNothing
	self:strictSkill(self.player,jPlayer)
	afterDoHumanSkill()
end


function shunshouqianyangSkill:isChupaiAv()
	self.cant=false
	local player = self.player
	local flag = 0
	for i,v in ipairs(player.enemies) do
		if player:juli(v)<=1 and #v.handcards~=0 then
			flag=1
			break
		end
	end
	if flag==0 then
		self.cant=true
	end

	if not self.cant then
		debugPrint("can shun")
		return true
	else
		return false
	end
end
function clickWhenShunChai(responseItem)
	if getmetatable(getmetatable(responseItem))==Card then
		local function continueS()
			TheChosenShunCard=responseItem
			resume()
		end
		if responseItem.inHumanShunSCards then
			theHumanShunRegion="shoupai"
			continueS()
		elseif responseItem.inHumanShunZs then
			theHumanShunRegion="certainZ"
			continueS()
		elseif responseItem.inHumanShunPDs then
			theHumanShunRegion="certainPD"
			continueS()
		end
	end
end
table.insert(PressFuncSet,{"wait human choose shuncard",clickWhenShunChai})
table.insert(PressFuncSet,{"wait human choose chaicard",clickWhenShunChai})


function shunshouqianyangSkill:strictSkill(from,to,region,c)
	self:playSound()
	--local player = self.player
	from:pointAnotherPlayer(to)
	useQiNPai(from,{self.thecard})

	local JT = {act="useJinnang",jinnang=self.thecard,from=from,to=to,harm=true,
				disabled= false,}
	for _,v in pairs(gamePlayers) do
		v:judgeEnemy(JT)
	end
	broadcast(from,JT)

	local function doShun()
		local thecard=0
		local function ds()
			
			if region=="shoupai" and to.ishuman and from~=to then
				if not isAtNet() then
					mo1PaiOnDesk(from,thecard)
				else
					PlayerTellAPlayer(from,to,{actionName="mo1PaiOnDesk",card=thecard,getplayer=from})
				end
			else
				getCardDebug=true
				from:getCard(thecard)
				getCardDebug=false
			end
			if  region=="shoupai" then
				
				if not isAtNet() then
					UIShun( from,to )
				else
					clientTellEveryOneInRoom{actionName="notifyShun",from=from,to=to}
				end
				
			end
			printForGame(from:info().." 顺了"..to:info().."的"..thecard:info())
			
		end
		if region=="shoupai" then
			local thesindex = 0
			if not c then
				thecardindex = math.random(#to.handcards)
				
			else
				thecardindex = c.ShunSIndex
			end
			local T = {act="beiChai",region="shoupai",index=thecardindex,to=to,ispop=true}
			broadcast(to,T)
			thecard=T.thecard
--[[
			if not c then
				thecard = to:popCard(to.handcards[math.random(#to.handcards)])
				
			else
				thecard = to:popCard(c)
			end
			--]]
		elseif region=="certainZ" then
			thecard=to:popZhuangbei(c.znum)
		elseif region=="certainPD" then
			thecard=to:DeletePandingCard(c)
		end
		ds()
	end

	if not JT.disabled then
		if from==TheHuman then
			addPicsForHumanShunChai(to)


			clickstate("wait human choose shuncard")
			pause()
			clickstate("")

			region=theHumanShunRegion
			c=TheChosenShunCard
			deletePicsForHumanShunChai(c)
			doShun()
			--一样的，delete放在后面就没问题，放在doshun前边就不行,位置会错误(解决了，在getCard函数中延时50ms)
			
			debugPrint(getPicY(AllPicIndexes[c.pindex]))
			

		else
			Sleep(from)
			doShun()
		end
	end
end
function shunshouqianyangSkill:doSkill()
	local player = self.player
	local flag = 0
	for i,v in ipairs(player.enemies) do
		if player:juli(v)<=1 and #v.handcards~=0 then
			flag=1
			Sleep(player)
			self:strictSkill(player,v,"shoupai")
			break
		end
	end
	if flag==0 then
		self.cant=true
	end
end
function shunshouqianyangSkill:doHumanSkill()
	local card=curSelectedCards[1]
	local sPlayer=curSelectedPlayers[1]		
	preSetFunc=doNothing

	self:strictSkill(self.player,sPlayer)
	afterDoHumanSkill()
end
function guohechaiqiaoSkill:isChupaiAv()
	if not self.cant then
		debugPrint("can chai")
		return true
	else
		return false
	end
end

function guohechaiqiaoSkill:strictSkill(from,to,region,c)
	self:playSound()
	from:pointAnotherPlayer(to)
	useQiNPai(from,{self.thecard})

	local JT = {act="useJinnang",jinnang=self.thecard,from=from,to=to,harm=true,
				disabled= false,}
	--[[
	for _,v in pairs(gamePlayers) do
		v:judgeEnemy(JT)
	end
	]]
	broadcast(from,JT)

	local function doC()
		debugPrint("DOCHAI")
		local thecard=0
		local function ds()
			
			printForGame(from:info().." 拆了"..to:info().."的"..thecard:info())
			if to==TheHuman then
				if region=="shoupai" then 
					TheHuman:arrangeCardsPos()
					DeletePic(thecard.pindex)--不知道为什么这个要放在上一行的下面
				end
			end
		end
		if region=="shoupai" then
			local thesindex = 0
			if not c then
				thecardindex = math.random(#to.handcards)
				
			else
				thecardindex = c.ShunSIndex
			end
			local T = {act="beiChai",region="shoupai",index=thecardindex,to=to}
			broadcast(to,T)
			thecard=T.thecard

			qizhiQiNPai(to,{thecard})
			printForGame(from:info().." 拆了"..to:info().."的"..thecard:info())
			
		elseif region=="certainZ" then
			thecard=c
			to:popZhuangbei(c.znum)
			qipai(c,"弃置")
			ds()
		elseif region=="certainPD" then
			thecard=to:DeletePandingCard(c)
			qipai(c,"弃置")
			ds()
		end
	end

	if not JT.disabled then
		if from.ishuman then
			addPicsForHumanShunChai(to)

			clickstate("wait human choose chaicard")
			waitClick()

			region=theHumanShunRegion
			c=TheChosenShunCard
			deletePicsForHumanShunChai(c)
			doC()
			
		else
			Sleep(from)
			doC()
		end
	end
end
function guohechaiqiaoSkill:doSkill()
	local player = self.player
	local flag = 0
	for i,v in ipairs(player.enemies) do
		if  #v.handcards~=0 then
			flag=1
			Sleep(player)
			self:strictSkill(player,v,"shoupai")
			break
		end
	end
	if flag==0 then
		self.cant=true
	end
end
function guohechaiqiaoSkill:doHumanSkill()
	local card=curSelectedCards[1]
	local sPlayer=curSelectedPlayers[1]		
	preSetFunc=doNothing

	self:strictSkill(self.player,sPlayer)
	afterDoHumanSkill()
end

function shandianSkill:isChupaiAv()
	return true
end
function judgeShandian(ysCard,detail )
	local card = detail.pandingCard
	qipai(card,"判定")
	if card.suit=="Spades" and card.number>1 and card.number<10 then
		AddInfoBar("闪电生效")
		sleep(1000)
		playSound("system/CarMus_Act05.mp3")
		ysCard.funcP:DeletePandingCard(ysCard)
		qipai(ysCard,"弃置")
		broadcast(ysCard.funcP,{act="getHurt",hurtN=3,reason=detail,to=ysCard.funcP})
	else
		shandianCancel(ysCard)
	end
end 
function shandianCancel(c)
	AddInfoBar("闪电失效")
	sleep(1000)
	c.funcP:DeletePandingCard(c)
	--c.funcP=xiajia(c.funcP)
	--c.player=c.funcP
	xiajia(c.funcP):AddPandingCard(c)
end

shandianCard.iconDir="image/icon/lei.png"
shandianCard.judgePDFunc=judgeShandian
shandianCard.ysCancelFunc=shandianCancel

function shandianSkill:strictSkill()
	self:playSound()
	local card=self.thecard
	zhuangbeiAnim(self.player,card)
	self.player:popCard(card)
	
	
	--card.funcP=self.player
	
	self.player:AddPandingCard(card)
	
end

function shandianSkill:doSkill()
	Sleep(self.player)
	self:strictSkill()
end

function shandianSkill:doHumanSkill()
	self:strictSkill()
	afterDoHumanSkill()
end

function lebusishuSkill:isChupaiAv()
	return true
end
function judgeLe(ysCard,detail )
	local card = detail.pandingCard
	qipai(card,"判定")
	if card.suit~="Hearts" then
		AddInfoBar("乐不思蜀生效")

		ysCard.funcP.forbidChupai=true
		if ysCard.funcP.atNet and ysCard.funcP.ishuman then
			sendTableToServer{actionName="setNetplayerAttr",name=ysCard.funcP.name,attr="forbidChupai",content=true}
		end
	else
		AddInfoBar("乐不思蜀失效")
		
		
	end
	sleep(1000)
	LeCancel(ysCard)
	
end 
function LeCancel(c)
	c.funcP:DeletePandingCard(c)
	qipai(c,"弃置")
end

lebuCard.judgePDFunc=judgeLe
lebuCard.ysCancelFunc=LeCancel
function lebusishuSkill:strictSkill(to)
	self:playSound()
	local from = self.player
	
	local card=self.thecard
	zhuangbeiAnim(self.player,card,to)
	self.player:popCard(card)
		
	to:AddPandingCard(card)
	if not TContainsA(to.resetStateTable,"forbidChupai") then
		table.insert(to.resetStateTable,"forbidChupai")
	end
	--pause()
end

function lebusishuSkill:doSkill()
	local player = self.player
	Sleep(player)
	local flag = 0
	for i,v in ipairs(player.enemies) do
		flag=1
		self:strictSkill(v)
		break
	end
	if flag==0 then
		self:strictSkill(xiajia(player))
	end
end

function lebusishuSkill:doHumanSkill()
	local card=curSelectedCards[1]
	local sPlayer=curSelectedPlayers[1]		
	preSetFunc=doNothing
	self:strictSkill(sPlayer)
	afterDoHumanSkill()
end

function jiedaosharenSkill:isChupaiAv( ... )
	return false
end

function jiedaosharenSkill:strictSkill(p1,p2)
	self:playSound()
	local player = self.player
	
	player:pointAnotherPlayer(p1)
	--sleep(0.35)
	p1:pointAnotherPlayer(p2)

	useQiNPai(player,{self.thecard})

	local JT = {act="useJinnang",jinnang=self.thecard,from=player,to=p1,harm=true,
				disabled= false,}
	
	broadcast(player,JT)

	if not JT.disabled then
		local thewuqi = 1
		local function AgreeFunc()
			local r,v = p1:haveCardType(shaCard)
			if r then
				Sleep(p1)
				v.skill:strictSkill({p2},{v})
			else
				DenyFunc()
			end
		end
		local function DenyFunc()
			thewuqi=p1:popZhuangbei(1)
			if player==TheHuman then
				thewuqi:AddCardPic(p1.cX-cardWidth/2,p1.cY-cardHeight/2)
			end
			player:getCard(thewuqi)
		end
		
		if p1==TheHuman then

			AddInfoBar("是否对"..p2.CN.."出杀")
			stdShowButton(doNothing,doNothing,true,true)
			simpleWaitClickButton()
			if theClickedButton then
				if theClickedButton.name=="okButton" then
					
					AddInfoBar("请对"..p2.CN.."使用一张杀")
					local function yesFunc(c)
						c.skill:strictSkill({p2},{c})
					end
					askHumanACardToDoSth(shaCard,{},yesFunc,DenyFunc)
					
				else
					DenyFunc()
				end
				theClickedButton=nil
			else
				DenyFunc()
			end
		else
			Sleep(p1)
			DenyFunc()
		end
	end

end

function jiedaosharenSkill:doHumanSkill()
	local card=curSelectedCards[1]
	local p1=curSelectedPlayers[1]		
	local p2=curSelectedPlayers[2]

	preSetFunc=doNothing
	if p1.zhuangbeis[1]~=0 then		
		self:strictSkill(p1,p2)
		afterDoHumanSkill()
	end
end
debugPrint("Skills.lua loaded")