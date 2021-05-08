local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local theme = {}

theme.config_root = "/home/main/.config/awesome"
theme.font          = "Monospace 12"
theme.bg_focus      = "#bd93f9"
theme.bg_urgent     = "#ff79c6"
theme.bg_minimize   = "#444444"
theme.bg_normal     = "#282a36"
theme.bg_systray    = theme.bg_normal

theme.fg_normal     = "#aaaaaa"
theme.fg_focus      = "#ffffff"
theme.fg_urgent     = "#ffffff"
theme.fg_minimize   = "#ffffff"

theme.useless_gap         = dpi(6)
theme.border_width        = dpi(3)
theme.border_color_normal = "#282a36"
theme.border_color_active = "#bd93f9"
theme.border_color_marked = "#ff79c6"
theme.border_color_focus  = "#bd93f9"

return theme
