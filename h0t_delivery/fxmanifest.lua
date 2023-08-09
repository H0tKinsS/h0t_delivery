fx_version 'cerulean'
game 'gta5'

author "H0tKinsS"
description "Delivery job for ESX framework"
version "0.1_1"

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
}
server_script {
    'server/main.lua',
}
shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
}
client_scripts {
    'client/main.lua',
}