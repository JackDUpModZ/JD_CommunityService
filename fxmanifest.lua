fx_version 'adamant'
games {'gta5'}

description 'JD Community Service'

version '1.0.0'
lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'config.lua',
	'server/main.lua'
}

client_scripts {
	'config.lua',
	'client/main.lua'
}
