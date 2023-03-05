-- local actionsTable = {}
-- actionsTable[target.identifier] = actions

-- for k,v in pairs(actionsTable) do
-- 	print(k,v)
-- end
if Config.Framework == 'qbcore' then
	QBCore = exports['qb-core']:GetCoreObject()
	function GetPlayer(source)
		return QBCore.Functions.GetPlayer(source)
	end
	function GetIdentifier(source)
		local Player = QBCore.Functions.GetPlayer(source)
		return Player.PlayerData.citizenid
	end
	function showNotification(source,msg)
	    TriggerClientEvent('QBCore:Notify', source, msg, "success")
	end
	function getPlayerName(player)
		local name = player.PlayerData.charInfo.firstname
		return name
	end
elseif Config.Framework == 'esx' then
	ESX = exports['es_extended']:getSharedObject()
	function GetPlayer(source)
		return ESX.GetPlayerFromId(source)
	end
	function GetIdentifier(source)
		local Player = GetPlayer(source)
		return Player.identifier
	end
	function showNotification(source,msg)
		TriggerClientEvent('esx:showNotification', source, msg)
	end
	function getPlayerName(player)
		local name = player.getName()
		return name
	end
end

sendToService = function(target, actions)
	local senderPlayer = GetPlayer(source)
	local targetPlayer = GetPlayer(target)

	if targetPlayer then
		if actions == nil then
			showNotification(source,'Invalid action count / No one sent!')
		else
			showNotification(source,'Player sent to community service!')
			showNotification(target,'Youve been sent to community service for '..actions..' actions!')
			TriggerClientEvent('JD_CommunityService:beginService',target,actions)
			updateService(target,actions)
			local name = getPlayerName(targetPlayer)
			if Config.EnableWebhook then
				sendToDiscord(16753920, "Community Service Alert", name.." was sent to community service for "..actions.." months!", "Made by JackDUpModZ")		
			end
		end
	else
		showNotification(source,'Invalid ID / No one sent!')
	end
end

updateService= function(target, actions)
	local _source = target -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)
	local identifier = Player.identifier

	local currentCount = MySQL.scalar.await('SELECT actions_remaining FROM communityservice WHERE identifier = ?', {identifier})
	if currentCount then
		local updateRows = MySQL.update.await('UPDATE communityservice SET actions_remaining = ? WHERE identifier = ?', {actions, identifier})
	else
		local insert = MySQL.insert.await('INSERT INTO communityservice (identifier, actions_remaining) VALUES (?, ?)', {identifier, actions})
	end
end

lib.callback.register('JD_CommunityService:completeService', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)
	local identifier = Player.identifier
	MySQL.query.await('DELETE FROM communityservice WHERE identifier = ?', {identifier})
end)

lib.callback.register('JD_CommunityService:getCurrentActions', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)
	local identifier = Player.identifier
	local count = MySQL.scalar.await('SELECT actions_remaining FROM communityservice WHERE identifier = ?', {identifier})
	return count
end)

RegisterCommand('communityService', function(source, args, rawCommand)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)

	if Player.job.name == Config.PoliceJob then
		local input = lib.callback.await('JD_CommunityService:inputCallback', source)
		if input == nil then
		else
		local targetID = tonumber(input[1])
		local actionCount = input[2]
		sendToService(targetID, actionCount)
		end
	else
		showNotification(source,'No permissions to access this!')
	end
end,false)

RegisterCommand('communityServiceAdmin', function(source, args, rawCommand)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)
	local input = lib.callback.await('JD_CommunityService:inputCallback', source)
	if input == nil then
	else
		local targetID = tonumber(input[1])
		local actionCount = input[2]
		sendToService(targetID, actionCount)
	end
end,true)

RegisterCommand('releaseCommunityService', function(source, args, rawCommand)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)

	if Player.job.name == Config.PoliceJob then
		local input = lib.callback.await('JD_CommunityService:inputCallbackRelease', source)
		if input == nil then
		else
			local realeased = GetPlayer(input[1])
			local realeaser = GetPlayer(_source)
			local name = getPlayerName(realeased)
			local name2 = getPlayerName(realeaser)
			if Config.EnableWebhook then
				sendToDiscord(16753920, "Community Service Alert", name.." was released from community service by "..name2, "Made by JackDUpModZ")		
			end
			TriggerClientEvent('JD_CommunityService:releaseService',input[1])
		end
	else
		showNotification(source,'No permissions to access this!')
	end
end,true)

RegisterCommand('releaseCommunityServiceAdmin', function(source, args, rawCommand)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)
	local input = lib.callback.await('JD_CommunityService:inputCallbackRelease', source)
	if input == nil then
	else
		local realeased = GetPlayer(input[1])
		local realeaser = GetPlayer(_source)
		local name = getPlayerName(realeased)
		local name2 = getPlayerName(realeaser)
		if Config.EnableWebhook then
			sendToDiscord(16753920, "Community Service Alert", name.." was released from community service by "..name2, "Made by JackDUpModZ")		
		end
		TriggerClientEvent('JD_CommunityService:releaseService',input[1])
	end
end,true)

lib.callback.register('JD_CommunityService:communityMenu', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)

	if Player.job.name == Config.PoliceJob then
		local input = lib.callback.await('JD_CommunityService:inputCallback', source)
		if input == nil then
		else
		local targetID = tonumber(input[1])
		local actionCount = input[2]
		sendToService(targetID, actionCount)
		end
	else
		showNotification(source,'No permissions to access this!')
	end
end)

Citizen.CreateThread(function()

end)

function sendToDiscord(color, name, message, footer)
	local embed = {
		  {
			  ["color"] = color,
			  ["title"] = "**".. name .."**",
			  ["description"] = message,
			  ["footer"] = {
				  ["text"] = footer,
			  },
		  }
	  }
  
	PerformHttpRequest(Config.Webhook, function(err, text, headers) end, 'POST', json.encode({username = name, embeds = embed}), { ['Content-Type'] = 'application/json' })
  end