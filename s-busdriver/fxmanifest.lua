fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Szatu'
description 'A simple script to bus driver job'

shared_scripts {
    'config.lua',
}

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/main.lua',
}

dependencies {
    'ox_target',
    'ox_lib'
}