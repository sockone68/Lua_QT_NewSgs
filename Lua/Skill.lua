Skill={}
function Skill:new( o )
	--o中的name专门用来调用相应的音频
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	
	return o
end
function Skill:isChupaiAv( )
	return false
end
function Skill:addSelf(p)
	self.player=p
end
function Skill:removeSelf( )
	self.player=nil
end
function Skill:addForHuman()
	local theButton=AddTextButton(self.CN,TheHuman.x-100,380,100,50)
	self.humanButton=theButton
	theButton.func=self.humanButtonFunc
end
function Skill:doSkill()
	Sleep(self.player)
	self:strictSkill()
end
function Skill:playSound(wujiangskill)
	local wholeDir
	if not wujiangskill then
		
		local dir = "playcard/"
		if self.player.isMale then
			dir=dir.."male/"
		else
			dir=dir.."female/"
		end
		wholeDir=dir..self.name..".mp3"
		
	else
		local dir = "skillSound/"
		wholeDir=dir..self.soundName..".mp3"
	end
	playSound(wholeDir)
end
printForGame("Skill.lua loaded")