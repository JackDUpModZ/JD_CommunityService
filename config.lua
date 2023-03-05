Config = {}

Config.Framework = 'esx' -- qbcore | esx

Config.InteractionType = 'points' -- Either ox_target or points (Qtarget maybe soon?)

Config.EnableWebhook = true

Config.Webhook = ''

-- # By how many services a player's community service gets extended if he tries to escape
Config.ServiceExtensionOnEscape = 2

-- # Don't change this unless you know what you are doing.
Config.StartLocation = vector4(161.7046, -1004.414, 29.36884, 163.6481)

-- # Don't change this unless you know what you are doing.
Config.ReleaseLocation = vector4(426.8537, -978.7916, 30.71013, 86.49715)

-- # Don't change this unless you know what you are doing.
Config.ServiceLocations = {
	{type = 'sweep', coords = vector4(158.8423, -1002.271, 28.35584, 37.37579)},
	{type = 'sweep', coords = vector4(167.5971, -1003.667, 28.34581, 241.3034)},
	{type = 'sweep', coords = vector4(144.6603, -994.816, 28.35664, 65.06136)},
	{type = 'sweep', coords = vector4(178.3475, -1006.496, 28.33046, 246.9683)},
	{type = 'sweep', coords = vector4(189.593, -1010.494, 28.31478, 251.131)},
	{type = 'sweep', coords = vector4(198.8164, -1015.651, 28.30341, 236.8525)}
}

Config.PoliceJob = 'police'

Config.Clothes = {
    male = {
        components = {{["component_id"] = 0, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 1, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 3, ["texture"] = 0, ["drawable"] = 63},{["component_id"] = 4, ["texture"] = 0, ["drawable"] = 163},{["component_id"] = 5, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 6, ["texture"] = 0, ["drawable"] = 60},{["component_id"] = 7, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 8, ["texture"] = 0, ["drawable"] = 15},{["component_id"] = 9, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 10, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 11, ["texture"] = 0, ["drawable"] = 56},},
    },
    female = {
        components = {{["component_id"] = 0, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 1, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 3, ["texture"] = 0, ["drawable"] = 76},{["component_id"] = 4, ["texture"] = 0, ["drawable"] = 35},{["component_id"] = 5, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 6, ["texture"] = 0, ["drawable"] = 49},{["component_id"] = 7, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 8, ["texture"] = 0, ["drawable"] = 14},{["component_id"] = 9, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 10, ["texture"] = 0, ["drawable"] = 0},{["component_id"] = 11, ["texture"] = 0, ["drawable"] = 118},},
    }
}