fx_version 'adamant'
game 'gta5'

description 'ESX Community Service'

version '1.0.0'
lua54 'yes'

shared_scripts {
	'config.lua',
	'@es_extended/locale.lua',
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

client_script 'client/main.lua'

dependency 'es_extended'