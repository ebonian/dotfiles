local wezterm = require 'wezterm'

local mux = wezterm.mux

wezterm.on("gui-startup", function()
    local tab, pane, window = mux.spawn_window {}
    window:gui_window():maximize()
end)

local module = {}

function module.apply_to_config(config)
    config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '-i', '-l' }

    config.window_close_confirmation = 'NeverPrompt'

    config.window_decorations = "RESIZE"

    config.initial_cols = 140
    config.initial_rows = 40
end

return module
