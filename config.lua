Config = {}

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

Config.Uniforms = {
	prison_wear = {
		male = {
			['tshirt_1'] = 15,  ['tshirt_2'] = 0,
			['torso_1']  = 146, ['torso_2']  = 0,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms']     = 119, ['pants_1']  = 3,
			['pants_2']  = 7,   ['shoes_1']  = 12,
			['shoes_2']  = 12,  ['chain_1']  = 0,
			['chain_2']  = 0
		},
		female = {
			['tshirt_1'] = 3,   ['tshirt_2'] = 0,
			['torso_1']  = 38,  ['torso_2']  = 3,
			['decals_1'] = 0,   ['decals_2'] = 0,
			['arms']     = 120,  ['pants_1'] = 3,
			['pants_2']  = 15,  ['shoes_1']  = 66,
			['shoes_2']  = 5,   ['chain_1']  = 0,
			['chain_2']  = 0
		}
	}
}
