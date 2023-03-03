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
	print('triggered')
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
