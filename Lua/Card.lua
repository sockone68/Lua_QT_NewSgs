
Card={type,package,pinyin,english,subtype,FuncForHumanChupai=doNothing,pindex}
function returnCardById( id )
	for _,v in pairs(currentPile) do
		if v.id==id then
			debugPrint("FIRStRETURN")
			return v
		end
	end
	for _,v in pairs(PileCopy) do
		if v.id==id then
			debugPrint("SECONDRETURN")
			return v
		end
	end
end
ttClassRegister{2,Card,"id","card",returnCardById}

Card.__index=Card
CardTypes={}
Suits={"Hearts","Diamonds","Clubs","Spades"}
cardWidth=120
cardHeight=125/3*4

function Card:new(thename,thetype,thepinyin,theenglish,thesubtype)
	local o={name=thename,type=thetype,pinyin=thepinyin,english=theenglish,
subtype=thesubtype}
	if thetype=="zhuangbei" then
		o.equipImageName=theenglish
	end
	setmetatable(o,self)
	table.insert(CardTypes,o)
	self.__index=self

	if thesubtype then
		local _,_,maintype,zDetail=string.find(thesubtype,"^(%a+)_?(%w*)$")
		o.maintype=maintype
		if thesubtype=="fangju" then
			o.znum=2
			o.settleSound="system/CarMus_Equ001.mp3"
		elseif maintype=="ma" and zDetail=="plus1" then
			o.znum=3
			o.settleSound="horse.mp3"
		elseif maintype=="ma" and zDetail=="minus1" then
			o.znum=4
			o.settleSound="horse.mp3"
		elseif maintype=="wuqi"  then
			o.znum=1
			o.settleSound="system/CarMus_Equ001.mp3"
			o.gongjiJuli=zDetail+0
			
		else
			--debugPrint("fuckyou")
		end
	end
	--o.skill={}
	return o
end
function Card:getSubtype(  )
	if self.subtype then
		local i,j,st,ex = string.find(self.subtype,"^(%w+)(_%w+)?$")
		return string.sub(self.subtype,i,j),st,ex
	else
		return self.type
	end
end
function Card:getIndexInCards( cards )
	for i,v in ipairs(cards) do
		if v==self then 
			return i
		end
	end
	return 0
end
function Card:info( )
	if self.id then
		return self.id..self.name
	elseif self.pinyin then
		return self.pinyin
	else 
		return ""
	end
end
function Card:infoHTML( )
	return "<font color=Orange>"..self:info().."</font> "
end
function Card:color()
	if self.suit=="Diamonds" or self.suit=="Hearts" then
		return "R"
	else
		return "B"
	end
end


function judgeCardsColor(t)
	local RcolorCount,BcolorCount = 0,0
	for _,v in pairs(t) do
		if v:color()=="R" then
			RcolorCount=RcolorCount+1
		else
			BcolorCount=BcolorCount+1
		end
	end
	if RcolorCount==0 and BcolorCount~=0 then
		return "B"
	elseif RcolorCount~=0 and BcolorCount==0 then
		return "R"
	end
	return "none"
end
function judgeCardsNumber(t)
	local sum = 0
	for _,v in pairs(t) do
		sum=sum+v.number
	end
	return sum
end
function Card:playSound()

	local dir = "playcard/"
	if self.player.isMale then
		dir=dir.."male/"
	else
		dir=dir.."female/"
	end
	playSound(dir..self.pinyin..".mp3")
end
count=0
function newCard(thecard,thenumber,thesuit)
	count=count+1
	local o={number=thenumber,suit=thesuit,id=count}
	o.english=thecard.english
	setmetatable(o,thecard)
	thecard.__index=thecard
	
	
	local theskill = _G[thecard.pinyin.."Skill"]
	if theskill then
		o.skill=theskill:new{iscard=true}
	else
		o.skill=Skill:new{name="none"}
	end
	o.skill.thecard=o
	--printForGame(o:info())
	return o
end

CardsCard={}
function CardsCard:new(cards,cardType,selfDefinition)
	local o =selfDefinition or {}
	setmetatable(o,cardType)
	self.__index=self
	if o~=selfDefinition then
		o.number=judgeCardsNumber(cards)
		o.color=judgeCardsColor(cards)
	end
	o.cards=cards
	return o
end

function NumberToText(n)
	if n==1 then
		return "A"
	elseif n<11 then
		return ""..n
	elseif n==11 then
		return "J"
	elseif n==12 then
		return "Q"
	elseif n==13 then
		return "K"
	end
end
function imageDirForASuit( suit )
	return "image/system/suit/"..suit..".png"
end
function Card:AddCardPic(x,y)
	AddPic(x,y,cardWidth,cardHeight,"image/card/"..self.english..".png",self:info())
	self.pindex=curPIndex
	self.OnDesk=true
	self.x=x self.y=y
	AllIndexesPic[curPIndex]=self

	apfp(7,2,24,24,imageDirForASuit(self.suit),AllPicIndexes[curPIndex])
	self.text=NumberToText(self.number)
	atfp(self.text,AllPicIndexes[curPIndex],7,26,100,100,0x0)
	return	curPIndex
end
function Card:AddCardPicReturnCard(x,y)
	AddPic(x,y,cardWidth,cardHeight,"image/card/"..self.english..".png")
	self.pindex=curPIndex
	AllIndexesPic[curPIndex]=self
	apfp(7,2,24,24,"image/system/suit/"..self.suit..".png",AllPicIndexes[curPIndex])
	self.text=NumberToText(self.number)
	atfp(self.text,AllPicIndexes[curPIndex],7,26,29,27,0x0)
	return	self
end
function AddCardBackPic( x,y )
	AddPic(x,y,cardWidth,cardHeight,"image/system/card-back.png")
	return	curPIndex
end
function Card:AddCardBackPic(x,y)
	AddPic(x,y,cardWidth,cardHeight,"image/system/card-back.png")
	self.cardbackIndex=curPIndex
	return	self
end

function Card:responseClick()
	if self.clicked then
		self:down()
		self.clicked=false
	else
		self:raise()
		self.clicked=true
	end
end

FakeCardFather={isfake=true}
setmetatable(FakeCardFather,Card)
FakeCardFather.__index=FakeCardFather
function fakeCard(o)
	local o =o or {}
	setmetatable(o,FakeCardFather)
	return o
end

CardPile={}
CardPile.__index=CardPile
function CardPile:new(o )
	local o =o or {}
	setmetatable(o,self)
	self.__index=self
	return o
end
function CardPile:shuffle( )
	for i=1,#self do
		local c = math.random(#self)
		self[i],self[c]=self[c],self[i]
	end
end
function CardPile:deal(  )
	if #self>0 then
		return table.remove(self)
	else
		return nil
	end
end
function popCard( cards,thecard )
	return table.remove(cards,thecard:getIndexInCards(cards))
end



function clickWhenChoosePlayers(responseItem)
	if getmetatable(responseItem)==Player and not TContainsA(curSelectedPlayers,responseItem) then
		table.insert(curSelectedPlayers,responseItem)	
		restoreFade(AllPicIndexes[responseItem.pindex])
		if #curSelectedPlayers==ChoosePlayersN then
			preSetFuncAfterChoosePlayers()
		end
	elseif TContainsA(curSelectedPlayers,responseItem) then
		table.remove(curSelectedPlayers,getIndexInT(responseItem))
		fadeT1ExceptT2({responseItem},{})
	elseif TContainsA(curSelectedCards,responseItem) then
		responseItem:responseClick()
		curSelectedCards={}
		clearPicSelection()
		restoreAllFade()
		clickstate(preClickState)
		AddInfoBar(preInfo)
	end
end
table.insert(PressFuncSet,{"wait human choose players",clickWhenChoosePlayers})
function mutiTargetFuncForHumanChupai(info,n)
	local name = curSelectedCards[1].name
	
	clickstate("wait human choose players")
	
	AddInfoBar(info)
	fadeT1ExceptT2(gamePlayers,{})
	local function Determine()
		local function Ok( )
			curSelectedCards[1].skill:doHumanSkill( )
		end
		StdSimpleShowButton(Ok)
		
		clickstate("wait human click button")
	end
	ChoosePlayersN=n
	preSetFuncAfterChoosePlayers=Determine
	
end


function simpleFuncForHumanChupai()
	
	clickstate("wait human click button")
	AddInfoBar("请单击确定来使用")
	local function fOk( )
		preSetFunc=doNothing
		curSelectedCards[1].skill:doHumanSkill( )
	end
	local function fCancel( )
		curSelectedCards[1]:responseClick()
		curSelectedCards={}
		clearPicSelection()
		restoreAllFade()
		clickstate(preClickStateWithCard)
		AddInfoBar(preInfo)
	end
	stdShowButton( fOk,fCancel,true,false )
end

function clickWhenChoosePlayer(responseItem)
	if getmetatable(responseItem)==Player then
		curSelectedPlayers[1]=responseItem
		playerHumanChosen=true
		fadeT1ExceptT2(gamePlayers,{responseItem})
		preSetFuncAfterChooseAPlayer()
	elseif responseItem==curSelectedCards[1] then
		responseItem:responseClick()
		curSelectedCards={}
		clearPicSelection()
		restoreAllFade()
		clickstate(preClickState)
		AddInfoBar(preInfo)
	end
end
table.insert(PressFuncSet,{"wait human choose a player",clickWhenChoosePlayer})

function singleTargetFuncForHumanChupai()
	local name = curSelectedCards[1].name
	
	clickstate("wait human choose a player")
	preInfoForClickPlayer="请单击一个想"..name.."的人"
	AddInfoBar(preInfoForClickPlayer)
	local function Determine()
		--preSetFuncAfterChooseAPlayer=doNothing
		local function Ok( )
			curSelectedCards[1].skill:doHumanSkill( )
		end
		StdSimpleShowButton(Ok)
		AddInfoBar("请单击确定来"..name)
		clickstate("wait human click button")
		preClickStateWithPlayer="wait human choose a player"
	end
	preSetFuncAfterChooseAPlayer=Determine
	
end



shaCard=Card:new("杀","jiben","sha","slash")
	Player.shaTimes=0 Player.shaMax=1
	shaSkill=Skill:new{name="Sha"}
	shaCard.FuncForHumanChupai=singleTargetFuncForHumanChupai

shanCard=Card:new("闪","jiben","shan","jink")

taoCard=Card:new("桃","jiben","tao","peach")
	taoSkill=Skill:new{name="Tao"}
	taoCard.FuncForHumanChupai=function(  )
		if curSelectedCards[1].skill:isChupaiAv() then	simpleFuncForHumanChupai()	end 
	end
zhugeCard=Card:new("诸葛连弩","zhuangbei","zhuge","crossbow","wuqi_1")
	zhugeSkill=Skill:new{name="zhuge"}

cixiongCard=Card:new("雌雄双股剑","zhuangbei","cixiong","double_sword","wuqi_2")
	cixiongSkill=Skill:new{name="cixiong"}
	
qinggangCard=Card:new("青冈剑","zhuangbei","qinggang","qinggang_sword","wuqi_2")
	qinggangSkill=Skill:new{name="qinggang"}

qinglongCard=Card:new("青龙偃月刀","zhuangbei","qinglong","blade","wuqi_3")
	qinglongSkill=Skill:new{name="qinglong"}

guanshiCard=Card:new("贯石斧","zhuangbei","guanshi","axe","wuqi_3")
	guanshiSkill=Skill:new{name="guanshi"}

hanbingCard=Card:new("寒冰剑","zhuangbei","hanbing","ice_sword","wuqi_2")
qilinCard=Card:new("麒麟弓","zhuangbei","qilin","kylin_bow","wuqi_5")

zhangbaCard=Card:new("丈八蛇矛","zhuangbei","zhangba","spear","wuqi_3")
	zhangbaSkill=Skill:new{name="zhangba",CN="丈八蛇矛"}

fangtianCard=Card:new("方天画戟","zhuangbei","fangtian","halberd","wuqi_4")
baguaCard=Card:new("八卦阵","zhuangbei","bagua","eight_diagram","fangju")
	baguaSkill=Skill:new{name="Bagua"}

renwangCard=Card:new("仁王盾","zhuangbei","renwang","renwang_shield","fangju")
	renwangSkill=Skill:new{name="renwang"}

jueyingCard=Card:new("绝影","zhuangbei","jueying","jueying","ma_plus1")
diluCard=Card:new("的卢","zhuangbei","dilu","dilu","ma_plus1")
zhuahuangCard=Card:new("爪黄飞电","zhuangbei","zhuahuang","zhuahuangfeidian","ma_plus1")
chituCard=Card:new("赤兔","zhuangbei","chitu","chitu","ma_minus1")
dawanCard=Card:new("大宛","zhuangbei","dawan","dawan","ma_minus1")
zixingCard=Card:new("紫騂","zhuangbei","zixing","zixing","ma_minus1")

wuguCard=Card:new("五谷丰登","jinnang","wugufengdeng","amazing_grace","fys")
	wugufengdengSkill=Skill:new{name="Wugufengdeng"}
	wuguCard.FuncForHumanChupai=simpleFuncForHumanChupai

taoyuanCard=Card:new("桃园结义","jinnang","taoyuanjieyi","god_salvation","fys")
	taoyuanjieyiSkill=Skill:new{name="TaoYuanJieYi"}
	taoyuanCard.FuncForHumanChupai=simpleFuncForHumanChupai

nanmanCard=Card:new("南蛮入侵","jinnang","nanmanruqin","savage_assault","fys")
	nanmanruqinSkill=Skill:new{name="Nanmanruqin"}
	nanmanCard.FuncForHumanChupai=simpleFuncForHumanChupai

wanjianCard=Card:new("万箭齐发","jinnang","wanjianqifa","archery_attack","fys")
	wanjianqifaSkill=Skill:new{name="Wanjianqifa"}
	wanjianCard.FuncForHumanChupai=simpleFuncForHumanChupai

juedouCard=Card:new("决斗","jinnang","juedou","duel","fys")
	juedouSkill=Skill:new{name="Juedou"}
	juedouCard.FuncForHumanChupai=singleTargetFuncForHumanChupai

wuzhongCard=Card:new("无中生有","jinnang","wuzhongshengyou","ex_nihilo","fys")
	wuzhongshengyouSkill=Skill:new{name="WuZhongShengYou"}
	wuzhongCard.FuncForHumanChupai=simpleFuncForHumanChupai

shunshouCard=Card:new("顺手牵羊","jinnang","shunshouqianyang","snatch","fys")
	shunshouqianyangSkill=Skill:new{name="Shunshouqianyang"}
	shunshouCard.FuncForHumanChupai=singleTargetFuncForHumanChupai

guoheCard=Card:new("过河拆桥","jinnang","guohechaiqiao","dismantlement","fys")
	guohechaiqiaoSkill=Skill:new{name="Guohechaiqiao"}
	guoheCard.FuncForHumanChupai=singleTargetFuncForHumanChupai

jiedaoCard=Card:new("借刀杀人","jinnang","jiedaosharen","collateral","fys")
	jiedaosharenSkill=Skill:new{name="Jiedaosharen"}
	function jiedaoHumanFunc()	mutiTargetFuncForHumanChupai("请借刀杀人",2)	end
	jiedaoCard.FuncForHumanChupai=jiedaoHumanFunc

wuxieCard=Card:new("无懈可击","jinnang","wuxiekeji","nullification","fys")
	wuxiekejiSkill=Skill:new{name="WuXieKeJi"}

lebuCard=Card:new("乐不思蜀","jinnang","lebusishu","indulgence","ys")
	lebusishuSkill=Skill:new{name="Lebusishu"}
	lebuCard.FuncForHumanChupai=singleTargetFuncForHumanChupai
	lebuCard.iconDir="image/icon/le.png"

shandianCard=Card:new("闪电","jinnang","shandian","lightning","ys")
	shandianSkill=Skill:new{name="Shandian"}
	shandianCard.FuncForHumanChupai=simpleFuncForHumanChupai

gudingCard=Card:new("古锭刀","zhuangbei","gudingdao","guding_blade","wuqi_2")
zhuqueCard=Card:new("朱雀羽扇","zhuangbei","zhuqueyushan","fan","wuqi_4")
tengjiaCard=Card:new("藤甲","zhuangbei","tengjia","vine","fangju")
baiyinCard=Card:new("白银狮子","zhuangbei","baiyinshizi","silver_lion","fangju")
hualiuCard=Card:new("骅骝","zhuangbei","hualiu","hualiu","ma_plus1")


jiuCard=Card:new("酒","jiben","jiu","analeptic")
leishaCard=Card:new("雷杀","jiben","leisha","thunder_slash","shuxing_lei")
huoshaCard=Card:new("火杀","jiben","huosha","fire_slash","shuxing_lei")

huogongCard=Card:new("火攻","jinnang","huogong","fire_attack","fys")
tiesuoCard=Card:new("铁索连环","jinnang","tiesuolianhuan","iron_chain","fys")
bingCard=Card:new("兵粮寸断","jinnang","bingliangcunduan","supply_shortage","ys")

muniuCard=Card:new("木牛流马","zhuangbei","muniuliuma","muniuliuma","baowu")

biaozhunPackage=CardPile:new{
	newCard(shaCard,7,"Spades"),
	newCard(shaCard,8,"Spades"),
	newCard(shaCard,8,"Spades"),
	newCard(shaCard,9,"Spades"),
	newCard(shaCard,9,"Spades"),
	newCard(shaCard,10,"Spades"),
	newCard(shaCard,10,"Spades"),
	newCard(shaCard,2,"Clubs"),
	newCard(shaCard,3,"Clubs"),
	newCard(shaCard,4,"Clubs"),
	newCard(shaCard,5,"Clubs"),
	newCard(shaCard,6,"Clubs"),
	newCard(shaCard,7,"Clubs"),
	newCard(shaCard,8,"Clubs"),
	newCard(shaCard,8,"Clubs"),
	newCard(shaCard,9,"Clubs"),
	newCard(shaCard,9,"Clubs"),
	newCard(shaCard,10,"Clubs"),
	newCard(shaCard,10,"Clubs"),
	newCard(shaCard,11,"Clubs"),
	newCard(shaCard,11,"Clubs"),
	newCard(shaCard,10,"Hearts"),
	newCard(shaCard,10,"Hearts"),
	newCard(shaCard,11,"Hearts"),
	newCard(shaCard,6,"Diamonds"),
	newCard(shaCard,7,"Diamonds"),
	newCard(shaCard,8,"Diamonds"),
	newCard(shaCard,9,"Diamonds"),
	newCard(shaCard,10,"Diamonds"),
	newCard(shaCard,13,"Diamonds"),
	newCard(shanCard,2,"Hearts"),
	newCard(shanCard,2,"Hearts"),
	newCard(shanCard,13,"Hearts"),
	newCard(shanCard,2,"Diamonds"),
	newCard(shanCard,2,"Diamonds"),
	newCard(shanCard,3,"Diamonds"),
	newCard(shanCard,4,"Diamonds"),
	newCard(shanCard,5,"Diamonds"),
	newCard(shanCard,6,"Diamonds"),
	newCard(shanCard,7,"Diamonds"),
	newCard(shanCard,8,"Diamonds"),
	newCard(shanCard,9,"Diamonds"),
	newCard(shanCard,10,"Diamonds"),
	newCard(shanCard,11,"Diamonds"),
	newCard(shanCard,11,"Diamonds"),
	newCard(taoCard,3,"Hearts"),
	newCard(taoCard,4,"Hearts"),
	newCard(taoCard,6,"Hearts"),
	newCard(taoCard,7,"Hearts"),
	newCard(taoCard,8,"Hearts"),
	newCard(taoCard,9,"Hearts"),
	newCard(taoCard,12,"Hearts"),
	newCard(taoCard,12,"Diamonds"),
	newCard(zhugeCard,1,"Clubs"),
	newCard(zhugeCard,1,"Diamonds"),
	newCard(cixiongCard,2,"Spades"),
	newCard(qinggangCard,6,"Spades"),
	newCard(qinglongCard,5,"Spades"),
	newCard(zhangbaCard,12,"Spades"),
	newCard(guanshiCard,5,"Diamonds"),
	newCard(fangtianCard,12,"Diamonds"),
	newCard(qilinCard,5,"Hearts"),
	newCard(baguaCard,2,"Spades"),
	newCard(baguaCard,2,"Clubs"),
	newCard(jueyingCard,5,"Spades"),
	newCard(diluCard,2,"Clubs"),
	newCard(zhuahuangCard,13,"Hearts"),
	newCard(chituCard,2,"Hearts"),
	newCard(dawanCard,13,"Spades"),
	newCard(zixingCard,13,"Diamonds"),
	newCard(wuguCard,3,"Hearts"),
	newCard(wuguCard,4,"Hearts"),
	newCard(taoyuanCard,1,"Hearts"),
	newCard(nanmanCard,7,"Spades"),
	newCard(nanmanCard,13,"Spades"),
	newCard(nanmanCard,7,"Clubs"),
	newCard(wanjianCard,1,"Hearts"),
	newCard(juedouCard,1,"Spades"),
	newCard(juedouCard,1,"Clubs"),
	newCard(juedouCard,1,"Diamonds"),
	newCard(wuzhongCard,7,"Hearts"),
	newCard(wuzhongCard,8,"Hearts"),
	newCard(wuzhongCard,9,"Hearts"),
	newCard(wuzhongCard,11,"Hearts"),
	newCard(shunshouCard,3,"Spades"),
	newCard(shunshouCard,4,"Spades"),
	newCard(shunshouCard,11,"Spades"),
	newCard(shunshouCard,3,"Diamonds"),
	newCard(shunshouCard,4,"Diamonds"),
	newCard(guoheCard,3,"Spades"),
	newCard(guoheCard,4,"Spades"),
	newCard(guoheCard,12,"Spades"),
	newCard(guoheCard,3,"Clubs"),
	newCard(guoheCard,4,"Clubs"),
	newCard(guoheCard,12,"Hearts"),
	newCard(jiedaoCard,12,"Clubs"),
	newCard(jiedaoCard,13,"Clubs"),
	newCard(wuxieCard,11,"Spades"),
	newCard(wuxieCard,12,"Clubs"),
	newCard(wuxieCard,13,"Clubs"),
	newCard(lebuCard,6,"Spades"),
	newCard(lebuCard,6,"Clubs"),
	newCard(lebuCard,6,"Hearts"),
	newCard(shandianCard,1,"Spades"),
	newCard(hanbingCard,2,"Spades"),
	newCard(renwangCard,2,"Clubs"),
	newCard(shandianCard,12,"Hearts"),
	newCard(wuxieCard,12,"Diamonds"),

}

debugPrint("Card.lua loaded")