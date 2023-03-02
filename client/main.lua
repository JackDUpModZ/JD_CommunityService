local active = nil
local inService = false
local existingActions
local targetList = {}
local drawMarker = false
local markerData = nil
local obj

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(playerData)
	Citizen.Wait(2000)
	local count = lib.callback.await('JD_CommunityService:getCurrentActions', false)
	if count ~= nil then
		beginService(count)
	end
end)

local function onExit(self)
    if inService then
		if Config.ServiceExtensionOnEscape >= 1 then
			local currentNumber = existingActions
			local extensionCount = Config.ServiceExtensionOnEscape
			existingActions = currentNumber + extensionCount
			ESX.ShowNotification('Youre time has been extended by '.. extensionCount ..' actions!')
		end
		teleportToZone()
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

local function beginService (actionCount)
	existingActions = actionCount
	inService = true
	teleportToZone()
	startActions()
	changeClothing()
end

local function startActions()
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
	local modelHash = `v_ind_rc_rubbishppr` -- The ` return the jenkins hash of a string. see more at: https://cookbook.fivem.net/2019/06/23/lua-support-for-compile-time-jenkins-hashes/

	if not HasModelLoaded(modelHash) then
		-- If the model isnt loaded we request the loading of the model and wait that the model is loaded
		RequestModel(modelHash)

		while not HasModelLoaded(modelHash) do
			Citizen.Wait(1)
		end
	end

	-- At this moment the model its loaded, so now we can create the object
	obj = CreateObject(modelHash, Config.ServiceLocations[indexNumber].coords.xyz, true)
	table.insert(targetList, target)
end

local function changeClothing()
	local gender = nil
	
	TriggerEvent('skinchanger:getSkin', function(skin)
		gender = skin.model
	end)

	local outfitComponents = Config.Clothes.male.components
	if gender ~= 'mp_m_freemode_01' then
		outfitComponents = Config.Clothes.female.components
	end

	for k,v in pairs(outfitComponents) do
		SetPedComponentVariation(PlayerPedId(), v["component_id"], v["drawable"], v["texture"], 0)
	end
end

local function returnClothing()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
	end)
end

local function removeTargets()
	for k,v in pairs(targetList) do 
		exports.ox_target:removeZone(v)
		targetList[k] = nil
	end
	drawMarker = false
	markerData = nil
end

local function targetInteract(data)
	if data.name == 'sweep' then
		startSweep()
	end
end

local function startSweep()
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

	existingActions = existingActions - 1
	if existingActions >= 1 then
		ESX.ShowNotification('Actions remaining'..' '.. existingActions ..'!')
	end

	updateFunction()
end

local function updateFunction()
	removeTargets()
	DeleteObject(obj)
	obj = nil
	if existingActions >= 1 then
		startActions()
	else
		active = false
		inService = false
		releaseFromZone()
		lib.callback('JD_CommunityService:completeService')
		ESX.ShowNotification('Youve been released from community service, Best behaviour citizen!')
	end
end

local function teleportToZone()
	SetEntityCoords(PlayerPedId(), Config.StartLocation.xyz)
end

local function releaseFromZone()
	returnClothing()
	SetEntityCoords(PlayerPedId(), Config.ReleaseLocation.xyz)
end

lib.callback.register('JD_CommunityService:inputCallback', function()
	local input = lib.inputDialog('Community Service', {'Player ID', 'Number of actions'})
	if not input then return end
    return input
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
