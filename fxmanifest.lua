fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'EJJ_04'
description 'Pilotjob'
version '1.0.0'

client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    'config.lua',
    'server.lua',
    '@oxmysql/lib/MySQL.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
    '@es_extended/imports.lua'
}

dependencies {
    'ox_lib'
}
