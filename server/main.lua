-- local actionsTable = {}
-- actionsTable[target.identifier] = actions

-- for k,v in pairs(actionsTable) do
-- 	print(k,v)
-- end

RegisterNetEvent("JD_CommunityService:sendToService", function(target, actions)
	local senderPlayer = ESX.GetPlayerFromId(source)
	local targetPlayer = ESX.GetPlayerFromId(target)

	if targetPlayer then
		if actions == nil then
			senderPlayer.showNotification('Invalid action count / No one sent!')
		else
			senderPlayer.showNotification('Player sent to community service!')
			targetPlayer.showNotification('Youve been sent to community service for '..actions..' actions!')
			TriggerClientEvent('JD_CommunityService:beginService',target,actions)
			TriggerEvent('JD_CommunityService:updateService',target,actions)
		end
	else
		senderPlayer.showNotification('Invalid ID / No one sent!')
	end
end)

RegisterNetEvent("JD_CommunityService:updateService", function(target, actions)
	local _source = target -- cannot parse source to client trigger for some weird reason
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier

	local currentCount = MySQL.scalar.await('SELECT actions_remaining FROM communityservice WHERE identifier = ?', {identifier})
	if currentCount then
		local updateRows = MySQL.update.await('UPDATE communityservice SET actions_remaining = ? WHERE identifier = ?', {actions, identifier})
	else
		local insert = MySQL.insert.await('INSERT INTO communityservice (identifier, actions_remaining) VALUES (?, ?)', {identifier, actions})
	end
end)

RegisterServerEvent('JD_CommunityService:completeService')
AddEventHandler('JD_CommunityService:completeService', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier
	local delete = MySQL.query.await('DELETE FROM communityservice WHERE identifier = ?', {identifier})

	--TriggerClientEvent('JD_CommunityService:finishCommunityService', target)
end)

lib.callback.register('JD_CommunityService:getCurrentActions', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier
	local count = MySQL.scalar.await('SELECT actions_remaining FROM communityservice WHERE identifier = ?', {identifier})
	return count
end)
