local wezterm = require 'wezterm'

local module = {}

function module.apply_to_config(config)
    config.font = wezterm.font 'CaskaydiaCove Nerd Font'

    config.hide_tab_bar_if_only_one_tab = false

    config.inactive_pane_hsb = {
        saturation = 0.8,
        brightness = 0.8,
    }

    config.colors = {
        background = '#141414',
        foreground = "#eeffff",

        ansi = {
            "#212121",
            "#f07178",
            "#c3e88d",
            "#ffcb6b",
            "#82aaff",
            "#c792ea",
            "#89ddff",
            "#eeffff"
        },
        brights = {
            "#4a4a4a",
            "#f07178",
            "#c3e88d",
            "#ffcb6b",
            "#82aaff",
            "#c792ea",
            "#89ddff",
            "#ffffff"
        },

        cursor_bg = "#eeffff",
        cursor_border = "#eeffff",
        cursor_fg = "#212121",

        selection_bg = "#eeffff",
        selection_fg = "#212121",

        indexed = {
            [16] = "#f78c6c",
            [17] = "#ff5370",
            [18] = "#303030",
            [19] = "#353535",
            [20] = "#b2ccd6",
            [21] = "#eeffff",
        },

        tab_bar = {
            background = '#141414',
        },
    }
end

return module
