local function sendToService(src, target, actions)
	local senderPlayer = ESX.GetPlayerFromId(src)
	local targetPlayer = ESX.GetPlayerFromId(target)

	if targetPlayer then
		if actions == nil then
			return senderPlayer.showNotification('Invalid action count / No one sent!')
		end
		
		senderPlayer.showNotification('Player sent to community service!')
		targetPlayer.showNotification('Youve been sent to community service for '.. actions ..' actions!')
		TriggerClientEvent('JD_CommunityService:beginService', target, actions)
		updateService(target,actions)
	else
		senderPlayer.showNotification('Invalid ID / No one sent!')
	end
end

local function updateService(target, actions)
	local xPlayer = ESX.GetPlayerFromId(target)
	local identifier = xPlayer.identifier

	local currentCount = MySQL.scalar.await('SELECT actions_remaining FROM communityservice WHERE identifier = ?', { identifier })
	if currentCount then
		MySQL.update.await('UPDATE communityservice SET actions_remaining = ? WHERE identifier = ?', { actions, identifier })
	else
		MySQL.insert.await('INSERT INTO communityservice (actions_remaining, identifier) VALUES (?, ?)', { actions, identifier })
	end
end

local function openCommunityServiceMenu(src)
	local xPlayer = ESX.GetPlayerFromId(src)

	if xPlayer.job.name ~= Config.PoliceJob then
		return xPlayer.showNotification('No permissions to access this!')
	end

	local input = lib.callback.await('JD_CommunityService:inputCallback', source)
	if input ~= nil then
		local targetID = tonumber(input[1])
		local actionCount = input[2]
		sendToService(src, targetID, actionCount)
	end
end

lib.callback.register('JD_CommunityService:completeService', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	MySQL.query.await('DELETE FROM communityservice WHERE identifier = ?', { xPlayer.identifier })
end)

lib.callback.register('JD_CommunityService:getCurrentActions', function()
	local src = source
	local xPlayer = ESX.GetPlayerFromId(src)
	return MySQL.scalar.await('SELECT actions_remaining FROM communityservice WHERE identifier = ?', { xPlayer.identifier })
end)

lib.callback.register('JD_CommunityService:communityMenu', function()
	openCommunityServiceMenu(source)
end)

RegisterCommand('communityService', openCommunityServiceMenu, false)
