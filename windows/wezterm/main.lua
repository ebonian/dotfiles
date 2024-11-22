-- wezterm config
local wezterm = require 'wezterm'

local config = wezterm.config_builder()

config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '-i', '-l' }
config.window_close_confirmation = 'NeverPrompt'


-- config modules
local appearance = require 'appearance'
local keybinds = require 'keybinds'


-- bar plugin
local bar = wezterm.plugin.require("https://github.com/adriankarlen/bar.wezterm")
bar.apply_to_config(
    config,
    {
        modules = {
            workspace = {
                enabled = false
            },
            leader = {
                enabled = false
            },
            pane = {
                enabled = false
            },
            clock = {
                enabled = false,
            },
            cwd = {
                enabled = false,
            },
        },
    }
)

appearance.apply_to_config(config)
keybinds.apply_to_config(config)




return config
