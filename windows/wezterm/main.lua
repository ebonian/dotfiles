local wezterm = require 'wezterm'
local config = wezterm.config_builder()

local program = require 'program'
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
                enabled = true,
            },
            cwd = {
                enabled = false,
            },
        },
    }
)

program.apply_to_config(config)
appearance.apply_to_config(config)
keybinds.apply_to_config(config)




return config
