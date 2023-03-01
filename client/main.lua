local active = nil
local inService = false
local existingActions
local targetList = {}
local drawMarker = false
local markerData = nil

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	Citizen.Wait(2000)
	local count = lib.callback.await('JD_CommunityService:getCurrentActions', false)
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
					return not lib.progressActive()
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

targetInteract = function(data)
	if data.name == 'sweep' then
		startSweep()
	end
end

startSweep = function()
	local progress = lib.progressCircle({
		duration = 5000,
		label = 'Sweeping ground',
		useWhileDead = false,
		allowRagdoll = false,
		allowCuffed = false,
		allowFalling = false,
		canCancel = false,
		anim = { dict = 'amb@world_human_janitor@male@idle_a', clip = 'idle_a' },
		prop = { model = `prop_tool_broom`, bone = 28422, pos = { x = -0.005, y = 0.0, z = 0.0}, rot = { x = 360.0, y = 360.0, z = 0.0 } },
		disable = { move = true, combat = true }
	})

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
		TriggerServerEvent('JD_CommunityService:completeService')
		ESX.ShowNotification('Youve been released from community service, Best behaviour citizen!')
	end
end
