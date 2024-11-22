local module = {}

function module.apply_to_config(config)
    config.default_prog = { 'C:/Program Files/Git/bin/bash.exe', '-i', '-l' }

    config.window_close_confirmation = 'NeverPrompt'

    config.initial_cols = 140
    config.initial_rows = 40
end

return module
