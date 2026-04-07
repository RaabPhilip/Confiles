local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { '/usr/bin/fish' }


return config
