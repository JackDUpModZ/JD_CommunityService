local active = nil
local inService = false
local existingActions
local targetList = {}
local drawMarker = false
local markerData = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	Citizen.Wait(2000)

end)

CreateThread(function()
    local count = exports["boba-callbacks"]:ExecuteServerCallback('JD_CommunityService:getCurrentActions')
	if count >= 1 then
		beginService(count)
	end
end)

Citizen.CreateThread(function()
  	while true do
		Citizen.Wait(1)
		if drawMarker then 
			DrawMarker(20, markerData.x, markerData.y, markerData.z + 1.0, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.4, 0.4, 0.4, 235, 64, 52, 100, true, false, 2, true, false, false, false)
		else 
			Wait(500)
		end
	end
end)

function onExit(self)
    if inService then
		tpToZone()
	end
end

local poly = lib.zones.poly({
	points = {
		vec3(117.0, -1000.0, 29.0),
		vec3(213.0, -1034.0, 29.0),
		vec3(277.0, -864.0, 29.0),
		vec3(180.0, -831.0, 29.0),
	},
	thickness = 16.0,
    debug = false,
    onExit = onExit
})

RegisterNetEvent('JD_CommunityService:beginService')
AddEventHandler('JD_CommunityService:beginService', function(count)
	beginService(count)
end)

beginService = function(actionCount)
	existingActions = actionCount
	inService = true
	tpToZone()
	startActions()
end

startActions = function()
	local indexNumber = math.random(1,#Config.ServiceLocations)

	drawMarker = true
	markerData = Config.ServiceLocations[indexNumber].coords.xyz
	local target = exports.ox_target:addSphereZone({
		coords = Config.ServiceLocations[indexNumber].coords.xyz,
		radius = 1,
		options = {
			{
				name = 'sweep',
				onSelect = targetInteract,
				icon = 'fa-solid fa-location-crosshairs',
				label = 'Sweep',
				canInteract = function(entity, distance, coords, name)
					return true
				end
			}
		}
	})
	table.insert(targetList, target)
end

tpToZone = function()
	SetEntityCoords(PlayerPedId(), Config.StartLocation.xyz)
end

releaseZone = function()
	SetEntityCoords(PlayerPedId(), Config.ReleaseLocation.xyz)
end

removeTargets = function()
	for k,v in pairs(targetList) do 
		exports.ox_target:removeZone(v)
		targetList[k] = nil
	end
	drawMarker = false
	markerData = nil
end

RegisterCommand('communityService', function()
	if ESX.PlayerData.job.name == 'police' then
		local input = lib.inputDialog('Community Service', {'Player ID', 'Number of actions'})

		if not input then return end
		local targetID = tonumber(input[1])
		local actionCount = input[2]
		exports["boba-callbacks"]:ExecuteServerCallback("JD_CommunityService:sendToService", targetID, actionCount)
	else
		ESX.ShowNotification('No permissions to access this!')
	end
end,false)

targetInteract = function(data)
	if data.name == 'sweep' then
		startSweep()
	end
end

startSweep = function()
	if not HasAnimDictLoaded("anim@amb@drug_field_workers@rake@male_a@base") then
        RequestAnimDict("anim@amb@drug_field_workers@rake@male_a@base")
    end
    while not HasAnimDictLoaded("anim@amb@drug_field_workers@rake@male_a@base") do
        Citizen.Wait(0)
    end
	TaskPlayAnim(GetPlayerPed(-1), 'anim@amb@drug_field_workers@rake@male_a@base', 'base', 2.0, 2.0, 17000, 1, 0, false, false, false)
	local boneindex = GetPedBoneIndex(PlayerPedId(-1), 28422)
	broom = CreateObject(GetHashKey("prop_tool_broom"), 0, 0, 0, true, true, true)
	AttachEntityToEntity(broom, PlayerPedId(-1), boneindex, -0.010000, 0.040000, -0.030000, 0.000000, 0.000000, 0.000000, true, true, false, true, 1, true)

	Wait(5000)
    DeleteEntity(broom)
	ClearPedTasks(GetPlayerPed(-1))

	local currentNumber = existingActions
	existingActions = currentNumber -1
	if existingActions >= 1 then
		ESX.ShowNotification('Actions remaining'..' '..existingActions..'!')
	end
	updateFunction()
end

updateFunction = function()
	removeTargets()
	if existingActions >= 1 then
		startActions()
	else
		active = false
		inService = false
		releaseZone()
		exports["boba-callbacks"]:ExecuteServerCallback('JD_CommunityService:completeService')
		ESX.ShowNotification('Youve been released from community service, Best behaviour citizen!')
	end
end