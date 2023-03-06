-- local actionsTable = {}
-- actionsTable[target.identifier] = actions

-- for k,v in pairs(actionsTable) do
-- 	print(k,v)
-- end

local curVersion = GetResourceMetadata(GetCurrentResourceName(), "version")
local resourceName = "JD_CommunityService"

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
			if Config.EnableWebhook then
				local name = getPlayerName(targetPlayer)
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
		local targetID = tonumber(input[1])
		local actionCount = input[2]
		sendToService(targetID, actionCount)
	else
		showNotification(source,'No permissions to access this!')
	end
end,false)

RegisterCommand('communityServiceAdmin', function(source, args, rawCommand)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)
	local input = lib.callback.await('JD_CommunityService:inputCallback', source)
	local targetID = tonumber(input[1])
	local actionCount = input[2]
	sendToService(targetID, actionCount)
end,true)

RegisterCommand('releaseCommunityService', function(source, args, rawCommand)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)

	if Player.job.name == Config.PoliceJob then
		local input = lib.callback.await('JD_CommunityService:inputCallbackRelease', source)
		if Config.EnableWebhook then
			local realeased = GetPlayer(input[1])
			local realeaser = GetPlayer(_source)
			local name = getPlayerName(realeased)
			local name2 = getPlayerName(realeaser)
			sendToDiscord(16753920, "Community Service Alert", name.." was released from community service by "..name2, "Made by JackDUpModZ")		
		end
		TriggerClientEvent('JD_CommunityService:releaseService',input[1])
	else
		showNotification(source,'No permissions to access this!')
	end
end,true)

RegisterCommand('releaseCommunityServiceAdmin', function(source, args, rawCommand)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)
	local input = lib.callback.await('JD_CommunityService:inputCallbackRelease', source)
	if Config.EnableWebhook then
		local realeased = GetPlayer(input[1])
		local realeaser = GetPlayer(_source)
		local name = getPlayerName(realeased)
		local name2 = getPlayerName(realeaser)
		sendToDiscord(16753920, "Community Service Alert", name.." was released from community service by "..name2, "Made by JackDUpModZ")		
	end
	TriggerClientEvent('JD_CommunityService:releaseService',input[1])
end,true)

lib.callback.register('JD_CommunityService:communityMenu', function()
	local _source = source -- cannot parse source to client trigger for some weird reason
	local Player = GetPlayer(_source)

	if Player.job.name == Config.PoliceJob then
		local input = lib.callback.await('JD_CommunityService:inputCallback', source)
		local targetID = tonumber(input[1])
		local actionCount = input[2]
		sendToService(targetID, actionCount)
	else
		showNotification(source,'No permissions to access this!')
	end
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

if Config.checkForUpdates then
    CreateThread(function()
        if GetCurrentResourceName() ~= "JD_CommunityService" then
            resourceName = "JD_CommunityService (" .. GetCurrentResourceName() .. ")"
        end
    end)

    CreateThread(function()
        while true do
            PerformHttpRequest("https://api.github.com/repos/JackDUpModZ/JD_CommunityService/releases/latest", CheckVersion, "GET")
            Wait(3600000)
        end
    end)

    CheckVersion = function(err, responseText, headers)
        local repoVersion, repoURL, repoBody = GetRepoInformations()

        CreateThread(function()
            if curVersion ~= repoVersion then
                Wait(4000)
                print("^0[^3WARNING^0] " .. resourceName .. " is ^1NOT ^0up to date!")
                print("^0[^3WARNING^0] Your Version: ^2" .. curVersion .. "^0")
                print("^0[^3WARNING^0] Latest Version: ^2" .. repoVersion .. "^0")
                print("^0[^3WARNING^0] Get the latest Version from: ^2" .. repoURL .. "^0")
            else
                Wait(4000)
                print("^0[^2INFO^0] " .. resourceName .. " is up to date! (^2" .. curVersion .. "^0)")
            end
        end)
    end

    GetRepoInformations = function()
        local repoVersion, repoURL, repoBody = nil, nil, nil

        PerformHttpRequest("https://api.github.com/repos/JackDUpModZ/JD_CommunityService/releases/latest", function(err, response, headers)
            if err == 200 then
                local data = json.decode(response)

                repoVersion = data.tag_name
                repoURL = data.html_url
                repoBody = data.body
            else
                repoVersion = curVersion
                repoURL = "https://github.com/JackDUpModZ/JD_CommunityService"
            end
        end, "GET")

        repeat
            Wait(50)
        until (repoVersion and repoURL and repoBody)

        return repoVersion, repoURL, repoBody
    end
end