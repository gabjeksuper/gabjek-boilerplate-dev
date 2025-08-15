
fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'gabjeksuper'
description 'gabjek-boilerplate-dev – secure dev boilerplate: server-routed actions, ESX/QBCore/Qbox bridge, ox_lib/ox_target/ox_inventory/oxmysql (optional), CI/tests'
version '1.1.0'

ui_page 'web/index.html'

files {
  'web/index.html',
  'web/app.js',
  'web/style.css'
}

shared_scripts {
  'shared/config.lua',
  'shared/util.lua',
  'shared/locale.lua',
  'locales/*.lua',
  'shared/bridge.lua'
}

client_scripts {
  'client/lib.lua',
  'client/main.lua'
}

server_scripts {
  'server/main.lua'
}
