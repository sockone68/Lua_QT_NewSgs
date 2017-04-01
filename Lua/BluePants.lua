--BluePants


--Thread part:CAPI:pause,resume

--UI part--------------------------------------------------------------
--CAPI:printForGame
--luaAPI:StdPressedFunc,mousePressEvent,mouseMoveEvent,HoverEnterEvent,HoverMoveEvent,HoverLeaveEvent


--Network part--------------------------------------------------------------
--CAPI:startServer,startClient,sendMsgToClient,sendMsgToServer,ServerKnowAConnect,ServerKnowADisconnect,ClientKnowSelfDisconnect
--luaAPI:ServerAnswerFunc,ClientAnswerFunc
function sendMsgToPlayer(p,s)
	sendMsgToClient(p.socketIndex,s)
end
function sendTableToClient(i,t)
	translateClassIntoString(t)
	serializeToString(t)
	sendMsgToClient(i,theSString)
end
function sendTableToServer(t)
	translateClassIntoString(t)
	serializeToString(t)
	sendMsgToServer(theSString)
end

function sendTableToPlayer(p,t)
	sendTableToClient(p.socketIndex,t)
end

function broadCastRoom(room,s)--transmission broadcast
	for i,v in pairs(room.players) do
		if v.ishuman then
			sendMsgToClient(v.socketIndex,s)
		end
	end
end

function broadCastRoomByTable(room,t)
	for i,v in pairs(room.players) do
		if v.ishuman then
			sendTableToClient(v.socketIndex,t)
		end
	end
end
function broadCastRoomByTableExceptOne(room,t,p)
	for i,v in pairs(room.players) do
		if v.ishuman and v~=p then
			sendTableToClient(v.socketIndex,t)
		end
	end
end

ServerAnswerTFuncSet={}
function ServerAnswerTable(i,tt)
	--printForGame("REcived client TABLE")
	--printForGame("ACTIONNAME is"..tt.actionName)
	local flag = 1
	for _,v in pairs(ServerAnswerTFuncSet) do
		if tt.actionName==v[1] then
			flag=0
			v[2](i,tt)
			break
		end
	end
	if flag==1 then

	end
end

ClientAnswerTFuncSet={}
function ClientAnswerTable( thetable)
	local flag = 1
	for _,v in pairs(ClientAnswerTFuncSet) do
		if thetable.actionName==v[1] then
			flag=0
			v[2](thetable)
			break
		end
	end
	if flag==1 then

	end
end

function ServerBroadcastA(thetable)
	debugPrint 'BA'
	translateStringIntoClass(thetable)
	preSetFunc=function ( ... )
		preSetFunc=doNothing
		printForGame('TEST0')
		
		myPlayer:answerBroadcast(thetable)
		waitClick()
	end
	resume()
end
table.insert(ClientAnswerTFuncSet,{"broadcast",ServerBroadcastA})
--abstract:--------------------------------------------------------------
--Broadcast part
require("BPBroadcast")
--player part
AbstractPlayer={}
function AbstractPlayer:new(o)
	local o=o or {broadcastAnswerList={}}
	setmetatable(o,self)
	self.__index=self
	return o
end
function AbstractPlayer:cantResponse( detail )
	return true
end
function AbstractPlayer:answerBroadcast(detail)
	local flag = 0
	if not self:cantResponse(detail)  then
	--sleep(1)
		--debugPrint("BEFORE"..detail["act"])
		for i=1,#self.broadcastAnswerList do
			if self.broadcastAnswerList[i] then
				if self.broadcastAnswerList[i][1]==detail["act"] then
					--debugPrint("CAtCH")
					 self.broadcastAnswerList[i][2](self,detail)
					 --debugPrint 'AFtERANSWER'
					 flag=1
				end
			end
		end
	else
		--debugPrint("CANtreSPONE")
	end
	--debugPrint("FLAG is"..flag)
	--死亡或者没有相应的响应函数则返回默认响应，后来改为直接完成广播回应
	if self.isInClient then
		sendTableToServer{actionName="finishBroadcast",detail=detail}
		--debugPrint("AfterClientfinish")
	else
		--debugPrint("NOTCLIENTFINISH")
		finishAnsBroadcast(self.isInServer)
	end
end

--Fundamental part--------------------------------------------------------------
function CallFuncByName(name,params)
	local f = _G[name]
	if type(f)=="function" then
		f(unpack(params))
	end
end

function getIndexInT(t,e)
	for i,v in pairs(t) do
		if v==e then
			return i
		end
	end
end

function removeAInT(t,a)
	table.remove(t,getIndexInT(t,a))
end

function findTByAttrs( t,attrName,n )
	for i,v in ipairs(t) do

		if v[attrName]==n then
			return true,v
		end
	end
	return false
end
function TContainsT( t1,t2 )
	for i,v in ipairs(t1) do

		if TContainsA(t2,v) then return true,v end
	end
	return false
end
function TContainsA( t,a )
	for i,v in ipairs(t) do
		if a==v then return true,v,i end
	end
	return false
end

function TContainsAsChild( t,a )
	for i,v in ipairs(t) do
		if a==getmetatable(v) then return true,v,i end
	end
	return false
end

function RandomCombination(t,N)
	local indexs = {}
	for i=1,#t do
		indexs[i]=i
	end

	local Collection = {}
	for i=1,N do
		Collection[i]=t[table.remove(indexs,math.random(#indexs))]
	end

	return Collection
end

function generalSerialize(o,outputFunc)
	if type(o) == "number" then
       outputFunc(o)
    elseif type(o) == "string" then
       outputFunc(string.format("%q", o))
    elseif type(o) == "boolean" then
		if o==true then
	   		outputFunc("true")
	   	else
	   		outputFunc("false")
	   	end
    elseif type(o) == "table" then
       outputFunc("{\n")
       for k,v in pairs(o) do
           outputFunc(" [")
			generalSerialize(k,outputFunc)
			outputFunc("] = ")
           generalSerialize(v,outputFunc)
           outputFunc(",\n")
       end
       outputFunc("}\n")

    else
       error("cannot serialize a " .. type(o)) 
	end
end

function serialize (o)
    generalSerialize(o,io.write)
end


function serializeToString (o)
	theSString=""
	local function f(s )
		theSString=theSString..s
		--qtLog(theSString)
	end
    generalSerialize(o,f)
end

transmissionTranslateClassRegisterTable={}
function ttClassRegister( t )
	table.insert(transmissionTranslateClassRegisterTable,t)
end
function returnCertainMetatable(level,object)
	local result = getmetatable(object)
	if level==1 then
		return result
	else
		level=level-1
		return returnCertainMetatable(level,result)
	end
end

function translateClassIntoString( t)
	local faketable = {}
	for k,v in pairs(t) do
		table.insert(faketable,{k,v})
	end
	
	local reDo = 1
	for _,vv in pairs(faketable) do
		local k = vv[1]
		local v = vv[2]
		local thetype = type(v)
		
		local function insertttt(o,typestring)
			if o~=nil then
				t[k]=o
			end
			if not t.ttt then
				t.ttt={}
			end

			t.ttt[k]=typestring
		end
		if thetype=="function" then
			for kk,vv in pairs(_G) do
				if vv==v then
					insertttt(kk,"function")
					break
				end
			end
		elseif type(v)=="table" and k~="ttt" then
			local metatableNotCatch = true
			for _,v1 in pairs(transmissionTranslateClassRegisterTable) do
				if type(v1[1])=="number" then
					if returnCertainMetatable(v1[1],v)==v1[2] then
						insertttt(v[v1[3]],v1[4])
						metatableNotCatch=false
						break
					end
				else
					if getmetatable(v)==v1[1] then
						insertttt(v[v1[2]],v1[3])
						metatableNotCatch=false
						break
					end
				end
			end
			if metatableNotCatch then
				insertttt(v,"table")
				translateClassIntoString(t[k])
			end
		end
	end
	
	debugPrint("FINISHTOSTRING")
end

function translateStringIntoClass(t)
	if t.ttt then
		debugPrint("Yes,have tTable")
		for k,v in pairs(t.ttt) do
			if v=="table" then
				translateStringIntoClass(t[k])
			elseif v=="function" then
				t[k]=_G[t[k]]
				if type(t[k])~="function" then
					debugPrint("FUKKKK,type is "..type(t[k]))
					
				end
			else
				for _,v1 in pairs(transmissionTranslateClassRegisterTable) do
					if type(v1[1])=="number" then
						if v1[4]==v then
							t[k]=v1[5](t[k])
							break
						end
					else
						if v1[3]==v then
							t[k]=v1[4](t[k])
							break
						end
					end
				end
			end
		end
		debugPrint("FINISHTOCLASS")
		--return t
	end

end
