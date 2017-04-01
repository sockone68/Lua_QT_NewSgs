function Skill:GeneralAddSelf(p )
	self.player=p
	table.insert(p.skills,self)
	if p==TheHuman then
		local b=self:addSkillButtonForHuman(p)
		b.func=self.humanButtonFunc
	end
end
function Skill:GeneralPlaySound()
	playSound("skillSound/skill_"..self.SoundCatagoryNumber.."_"..math.random(self.SoundSum)..".mp3")
end
function Skill:addSkillButtonForHuman(p)
	local theButton
	if qml then
		theButton=TextButton:new()
		addQp(theButton)
		
		theTable1={self.CN}
		callQmlFTable("addHumanSkill",theTable1)
	else
		theButton=AddTextButton(self.CN,p.x-100,p.y+#p.skillButtons*50,120,50)
		
	end
	self.humanButton=theButton
	table.insert(p.skillButtons,theButton)
	return theButton
end

function Skill:removeSkillButton()
	if qml then
		callQmlF("removeHumanSkill",self.humanButton.qpindex)
		
	else
		DeletePic(self.humanButton.pindex)
		removeAInT(self.player.skillButtons,self.humanButton)
	end
end

Rende=Skill:new{inChupai=true,CN="仁德",SoundCatagoryNumber="031",SoundSum=2}
table.insert(liubei.skills,Rende)

function Rende:addSelf( p )	self:GeneralAddSelf(p)	end
function Rende:doSkill() end
function Rende:strictSkill( p,cards )
	self:GeneralPlaySound()
	self.player:pointAnotherPlayer(p)
	for i,v in pairs(cards) do
		self.player:popCard(v,true)
		--mo1PaiOnDesk(p,v)
	end
	for i,v in pairs(cards) do
		
		mo1PaiOnDesk(p,v)
	end
	self.player:arrangeCardsPos()
end
function Rende:humanButtonFunc()
	preSetFunc=function ( ... )
		HumanQiN=nil
		HumanQiSelection={}
		AddInfoBar("请选择任意张手牌")

		preSetFunc=function ( ... )
			preSetFunc=doNothing
			clickstate("wait human choose a player")
			preInfoForClickPlayer="请单击一个想给的人"
			AddInfoBar(preInfoForClickPlayer)

			local function Determine()
				local function tOk( )
					preSetFunc=function ( ... )
						local _,sk=TContainsAsChild(TheHuman.skills,Rende)
						sk:strictSkill(curSelectedPlayers[1],HumanQiSelection)
						afterDoHumanSkill()
					end
					
					resume()
				end
				stdShowButton( tOk,doNothing,false,false )
				AddInfoBar("请单击确定来给")
				clickstate("wait human click button")
				preClickStateWithPlayer="wait human choose a player"

				--pause()
			end
			preSetFuncAfterChooseAPlayer=Determine
			waitClick()
		end
		--preSetFunc=qipaiOkF
		clickstate("wait human qipai")
		clearPicSelection()
		waitClick()
	end
	resume()
end


Jijiang=Skill:new{inChupai=false,CN="激将",SoundCatagoryNumber="032",SoundSum=2}
table.insert(liubei.skills,Jijiang)

function Jijiang:addSelf( p )
	if p.shenfen=="zhu" then
		self:GeneralAddSelf(p)
	end
end

function Jijiang:humanButtonFunc()

end
function Jijiang:doSkill()

end
function Jijiang:strictSkill()

end

printForGame("wujiangSkills.lua loaded")