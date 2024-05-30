fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

author 'infinitum-Scripts'
description 'The script was written by: infinitum-Scripts'
version '1.0.0'

shared_scripts{
	'config.lua'
}

client_scripts{
	'client/main.lua',
	'client/functions.lua'
}

server_scripts{
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua',
	'server/functions.lua'
}

ui_page 'html/index.html'

files {
	'html/assets/*.jpg',
	'html/*.html',
	'html/*.css',
	'html/*.js',
	'data/*.json'
}