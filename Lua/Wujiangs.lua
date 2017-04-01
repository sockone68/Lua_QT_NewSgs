Wujiang={}
function Wujiang:new( o )
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	o.skills={}
	return o
end
Wujiangs={}
liubei = Wujiang:new{CN="刘备",pinyin="liubei",isMale=true,life=4,isZhugong=true,shili="shu"}
table.insert(Wujiangs,liubei)
guanyu = Wujiang:new{CN="关羽",pinyin="guanyu",isMale=true,life=4,shili="shu"}
table.insert(Wujiangs,guanyu)
zhangfei = Wujiang:new{CN="张飞",pinyin="zhangfei",isMale=true,life=4,shili="shu"}
table.insert(Wujiangs,zhangfei)
zhaoyun = Wujiang:new{CN="赵云",pinyin="zhaoyun",isMale=true,life=4,shili="shu"}
table.insert(Wujiangs,zhaoyun)
machao = Wujiang:new{CN="马超",pinyin="machao",isMale=true,life=4,shili="shu"}
table.insert(Wujiangs,machao)
zhugeliang = Wujiang:new{CN="诸葛亮",pinyin="zhugeliang",isMale=true,life=3,shili="shu"}
table.insert(Wujiangs,zhugeliang)
huangyueying = Wujiang:new{CN="黄月英",pinyin="huangyueying",isMale=false,life=3,shili="shu"}
table.insert(Wujiangs,huangyueying)

sunquan = Wujiang:new{CN="孙权",pinyin="sunquan",isMale=true,life=4,isZhugong=true,shili="wu"}
table.insert(Wujiangs,sunquan)
ganning = Wujiang:new{CN="甘宁",pinyin="ganning",isMale=true,life=4,shili="wu"}
table.insert(Wujiangs,ganning)
lumeng = Wujiang:new{CN="吕蒙",pinyin="lvmeng",isMale=true,life=4,shili="wu"}
table.insert(Wujiangs,lumeng)
huanggai = Wujiang:new{CN="黄盖",pinyin="huanggai",isMale=true,life=4,shili="wu"}
table.insert(Wujiangs,huanggai)


caocao = Wujiang:new{CN="曹操",pinyin="caocao",isMale=true,life=4,isZhugong=true,shili="wei"}
table.insert(Wujiangs,caocao)
zhangliao =Wujiang:new{CN="张辽",pinyin="zhangliao",isMale=true,life=4,shili="wei"}
table.insert(Wujiangs,zhangliao)
xuchu =Wujiang:new{CN="许褚",pinyin="xuchu",isMale=true,life=4,shili="wei"}
table.insert(Wujiangs,xuchu)
guojia =Wujiang:new{CN="郭嘉",pinyin="guojia",isMale=true,life=3,shili="wei"}
table.insert(Wujiangs,guojia)
zhenji =Wujiang:new{CN="甄姬",pinyin="zhenji",isMale=false,life=3,shili="wei"}
table.insert(Wujiangs,zhenji)
simayi =Wujiang:new{CN="司马懿",pinyin="simayi",isMale=true,life=3,shili="wei"}
table.insert(Wujiangs,simayi)

WujiangsCopy={}
for i,v in pairs(Wujiangs) do
	WujiangsCopy[i]=v
end
printForGame("Wujiangs.lua loaded")
require "wujiangSkills"