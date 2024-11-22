local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
    config.font = wezterm.font 'CaskaydiaCove Nerd Font'

    config.hide_tab_bar_if_only_one_tab = true
end

return module