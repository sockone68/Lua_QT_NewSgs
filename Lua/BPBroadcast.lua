--BluePants Broadcast part
broadcastStack={}
--local part--------------------------------------------------------------
function broadcastByTable( cbt )
	table.insert(broadcastStack,cbt)
	debugPrint("<font color=DarkViolet  >broadcast "..cbt.detail.act.."</font> ")
	cbt.currentPlayer:answerBroadcast(cbt.detail)--注意broadcast的是cbt的detail而不是cbt
	
end

function  broadcast(broadcastSource,detail)
	if isServer or isClient then
		NetworkBroadcast(broadcastSource,detail)
	else
		local cbt={}--currentBraodcastTable
		cbt.running=true
		cbt.startPlayer=broadcastSource
		cbt.currentPlayer=cbt.startPlayer
		--cbt.bAE=broadcastAfterEnd
		cbt.detail=detail
		broadcastByTable(cbt)
	end
	
end
function CurBC( )
	return broadcastStack[#broadcastStack]
end
function finishAnsBroadcast(isserver)
	debugPrint("finishAnsBroadcast called")
	if isserver then
		debugPrint("ISSERVER")
	end
	if not CurBC().detail.stop then
		
		debugPrint("not stop")
		
		if xiajia(CurBC().currentPlayer)~=CurBC().startPlayer then
			debugPrint 'CONTINUE'
			continueBroadcast(isserver)
		else
			debugPrint("<font color=DarkGray>&nbsp;&nbsp;end "..CurBC().detail.act.."</font> ")
			endBroadcast(isserver)
		end
		
	else
		debugPrint(" stop")
		debugPrint("<font color=DarkGray>&nbsp;&nbsp;end "..CurBC().detail.act.."</font> ")
		endBroadcast(isserver)
	end
	

end
function continueBroadcast(isserver)
	if isserver then
		NetworkContinueBroadcast(isserver)
	else
		CurBC().currentPlayer=xiajia(CurBC().currentPlayer)
		CurBC().currentPlayer:answerBroadcast(CurBC().detail)
	end
end
function endBroadcast(isserver)
	--table.remove(broadcastStack,#broadcastStack)
	if isserver then
		NetworkEndBroadcast()
	else
		local cbt = CurBC()
		if cbt.detail.afterBroFunc then
			cbt.detail.afterBroFunc(cbt.detail)
		end
		broadcastStack[#broadcastStack]=nil
		
		if #broadcastStack~=0 then
			if not CurBC().running   then--running为一般状态，not running表示被暂停
				debugPrint("end and continue pre")
				continueBroadcast()
			end
		else

		end
	end
end



--Network part--------------------------------------------------------------
function  NetworkBroadcast(broadcastSource,detail)
	
	if broadcastSource.isInServer then
		local cbt={}--currentBraodcastTable
		cbt.running=true
		cbt.startPlayer=broadcastSource
		cbt.currentPlayer=cbt.startPlayer
		cbt.detail=detail
		NetworkBroadcastByTable(cbt)
		
	elseif broadcastSource.isInClient then
		--if detail.isContinue or detail.act=="useAoeJinnang" then
		--	shouldResume=true
		--end
		TheNetBroadcastTable=detail
		sendTableToServer{actionName="broadcast",detail=detail}
		waitClick()
	end
end

--每当给人类广播时暂停线程，给机器人广播时不需要，因为在同一个线程里工作
function NetworkBroadcastByTable( cbt)--game broadcast,not transmission broadcast；its called by server
	
	table.insert(broadcastStack,cbt)
	printForGame("<font color=DarkViolet  >broadcast "..cbt.detail.act.."</font> ")
	local player = cbt.currentPlayer

	if player.ishuman then
		debugPrint("HUMAN")
		cbt.detail.actionName="broadcast"
		sendTableToPlayer(player,cbt.detail)
		if CurBC().detail.act~="gameStart" then
			debugPrint("WAITCLICK")
			waitClick()
		end

	else
		debugPrint("NOTHUMAN")
		--translateStringIntoClass(cbt.detail)
		player:answerBroadcast(cbt.detail)--注意broadcast的是cbt的detail而不是cbt

	end
	
end
function NetworkContinueBroadcast(isserver)--for server，called by clienthuman or serverrobot
	CurBC().currentPlayer=xiajia(CurBC().currentPlayer)
	local player =CurBC().currentPlayer
	if player.ishuman then

		CurBC().detail.actionName="broadcast"
		sendTableToPlayer(player,CurBC().detail)
		if CurBC().detail.act~="gameStart" then
			debugPrint("WAITCLICK")
			waitClick()
		end
	else
		if CurBC().detail.act~="gameStart" then
			debugPrint 'NOTHUMAN'
			
			preSetFunc=function ( ... )
				preSetFunc=doNothing
				debugPrint("SUper")
				player:answerBroadcast(CurBC().detail)--注意broadcast的是cbt的detail而不是cbt
				--if CurBC().detail.act=="gameStart" then
					--waitClick()
				--end
			end
			resume()
		else
			player:answerBroadcast(CurBC().detail)
		end
	end

end

function NetworkEndBroadcast()--for server
	local cbt = CurBC()
	if cbt.detail.afterBroFunc then
		cbt.detail.afterBroFunc(cbt.detail)
	end
	if cbt.detail.act=="gameStart" then
		broadcastStack[#broadcastStack]=nil
			
		preSetFunc=function ( ... )
			preSetFunc=doNothing
			NetworkGame()
		end
		resume()
		
	elseif cbt.detail.isJB then
		if cbt.currentPlayer.ishuman then
			debugPrint 'RESUMEGAMEO'
			preSetFunc=doNothing
			resume()
		else

		end
	else
		broadcastStack[#broadcastStack]=nil
		
		--if not cbt.detail.isJB then
		if cbt.startPlayer.ishuman and cbt.detail.fromClient then
			sendTableToPlayer(cbt.startPlayer,{actionName="EndAndResume",detail=cbt.detail})
		else
			if cbt.currentPlayer.ishuman then
				debugPrint("GOINGTORESUME")
				preSetFunc=function ( ... )
					preSetFunc=doNothing
					--translateStringIntoClass(cbt.detail)
					
				end
				resume()
			end
		end

		if #broadcastStack~=0 then
			if not CurBC().running   then--running为一般状态，not running表示被暂停
				debugPrint("end and continue pre")
				NetworkContinueBroadcast()
			end
		end
	end
	
end

