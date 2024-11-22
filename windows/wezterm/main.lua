local wezterm = require 'wezterm'

local appearance = require 'appearance'
local keybinds = require 'keybinds'

local config = wezterm.config_builder()

config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '-i', '-l' }

appearance.apply_to_config(config)
keybinds.apply_to_config(config)

return config