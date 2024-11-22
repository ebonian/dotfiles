local config_path = "C:/Users/ebonian/dotfiles/windows/wezterm/?.lua"

package.path = package.path .. ";" .. config_path

return require("main")
