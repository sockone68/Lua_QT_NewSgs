math.randomseed(os.time())
function doNothing()
	printForGame("do nothing")
end
function debugPrint(s)
	--printForGame(s)
	--qtLog(s)
end


--[[
function  sleep(s)
	os.execute("sleep "..s)
end
]]
function getTrueIndex(fakeIndex)--called by c
	return AllPicIndexes[fakeIndex]
end
function clear()--clear the right text bar:iobar
	clearD()
	thelastCommandEndPosition=0
end



curPIndex=0
AllPicIndexes={}
--use a constant figure of the index to get the inconstant index contained in C++ program,send in fake index and return true index
AllIndexesPic={}
--for getting the certain instance representing  the pic of that index
PressFuncSet={}
clickState=""

function StdPressedFunc(param,x,y )
	-- body
	debugPrint("picindex:"..param.." x"..x.." y"..y)
	--findWay(AllPicIndexes[param],244,227,x,y)
	local responseItem=AllIndexesPic[param]
	if responseItem then
		debugPrint((responseItem:info() or ""))
		
		pressedItem=responseItem
		if getmetatable(getmetatable(responseItem))==Card then
			if responseItem.OnDesk then
				debugPrint("ondeskClick")
			else
				debugPrint("notOndeskClick")
			end
		end
		if  responseItem.isStaticButton==true then
			responseItem.func()
		else
			local flag = 1
			for _,v in pairs(PressFuncSet) do
				if clickState==v[1] then
					flag=0
					v[2](responseItem)
					break
				end
			end
			if flag==1 then
				printForGame("BigWrong!state="..gameState)
				printForGame("clickState="..clickState)
			end
		end
	end
end

function AddPic( x,y,w,h,d,t)
	addPic(x,y,w,h,d,true,true,t or "")
	afteraddpic( )
end
function afteraddpic( )
	curPIndex=curPIndex+1
	if curPIndex~=1 then
		table.insert(AllPicIndexes,AllPicIndexes[#AllPicIndexes]+1)
	else
		table.insert(AllPicIndexes,0)
	end
end
function DeletePic(index )
	local theindex = AllPicIndexes[index]
	
	deletePic(theindex)
	for i=index,#AllPicIndexes do
		AllPicIndexes[i]=AllPicIndexes[i]-1
	end
	
	if AllIndexesPic[index] then
		AllIndexesPic[index].OnDesk=false
	end
end
function AddPicCantMove( x,y,w,h,d ,t)
	addPic(x,y,w,h,d,false,true,t or "")
	afteraddpic()
end
function AddPicCantSelectAndMove( x,y,w,h,d ,t)
	addPic(x,y,w,h,d,false,false,t or "")
	afteraddpic( )
end


function stdDeletePic( i,index )
	DeletePic(index )

end



Button={name="noneButton",answerFunc=doNothing}
curButtonSet={}
stateBeforeButton=""
function Button:new(o)
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	return o
end
function Button:info(  )
	return self.name
end

function Button:destruct( )
	DeletePic(self.pindex)
	self=nil
end
function AddButton(x,y,w,h,dir,thename)
	AddPicCantMove(x,y,w,h,dir)
	local b = Button:new{name=thename}
	AllIndexesPic[curPIndex]=b
	b.pindex=curPIndex
	b.x=x
	b.y=y
	return b
end

function clearButton(b)
	
	DeletePic(b.pindex)
	
end

function addOkB(okFunc,isContinue)
	AddPicCantSelectAndMove(700-120,960-cardHeight-30,60,28,"image/system/button/ok.png")
	local bok = Button:new{name="okButton",answerFunc=okFunc}
	printForGame("addOk")
	bok.Continue=isContinue
	AllIndexesPic[curPIndex]=bok
end

function restoreStateBeforeButton()
	clearButtons()
	clearPicSelection()
	restoreAllFade()
	curSelectedCards={}
	clickstate(preClickState)
end
function addCancelB(cFunc,isContinue)
	local fun = cFunc or restoreStateBeforeButton
	AddPicCantSelectAndMove(700+120,960-cardHeight-30,60,28,"image/system/button/cancel.png")
	--local bcancel = Button:new{name="cancelButton",answerFunc=waitHumanClickForChupai}
	local bcancel = Button:new{name="cancelButton",answerFunc=fun}
	bcancel.Continue=isContinue
	AllIndexesPic[curPIndex]=bcancel
end


function StdSimpleShowButton( okFunc )
	stdShowButton( okFunc,nil,true,false )
end



TextButton={}
function TextButton:new( o )
	local o=o or {}
	setmetatable(o,self)
	self.__index=self
	self.isStaticButton=true
	return o
end
function TextButton:info()
	return "TextButton"
end
function TextButton.func()
	doNothing()
end
function TextButton:destruct( )
	DeletePic(self.pindex)
	self=nil
end

function AddTextButton(n,x,y,w,h)
	local o=TextButton:new()

	atp(n,x,y,w,h)
	afteraddpic( )
	o.pindex=curPIndex
	AllIndexesPic[curPIndex]=o
	return o
end

function FinishGame()
	gameState="End"
	clearButtons()
	restoreAllFade()
	--StdPressedFunc=nil
end



--]]

--[[
function resumeXc( )
	--coroutine.resume(co)
	resume()
end
function testCFunction( )
	a=Nnewarray(100)
	printForGame(type(a))
	printForGame(Ngetsize(a))
	for i=1,100 do
	    Nsetarray(a, i, 1/i)
	end
	printForGame(Ngetarray(a, 6))
	printForGame(Ngetarray(a, 8))
	printForGame(Ngetarray(a, 78))
end
]]