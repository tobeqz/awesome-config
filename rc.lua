local theme = require "theme"
-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local cairo = require("lgi").cairo
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")
local keybinds = require('keybinds')
require('bar')

-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)

function log(msg)
    naughty.notification({
        title = "Log",
        message = msg
    })
end

-- Themes define colours, icons, font and wallpapers.
beautiful.init("~/.config/awesome/theme.lua")


-- Config constants
local terminal = "alacritty"
local modkey = "Mod1"

local layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.spiral.dwindle
}

local tags = {
    "\u{f121}", -- Code
    "\u{f0ac}", -- Web
    "\u{f02d}", -- Book (?)
    "\u{f392}", -- Discord
    "\u{f1bc}", -- Spotify
    "\u{f11b}"  -- Controller
}

-- End of config constants
menubar.utils.terminal = terminal -- Set the terminal for applications that require it

screen.connect_signal("request::desktop_decoration", function(s)
    awful.tag(tags, s, layouts[1])
end)

-- Set layouts
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts(layouts)
end)

-- Bind keys
local function bind_key_global(key_data, action)
    awful.keyboard.append_global_keybindings({
        awful.key(key_data[1], key_data[2], action)
    })
end

-- General awesome bindings
bind_key_global(keybinds.Reload, awesome.restart)
bind_key_global(keybinds.Quit, awesome.quit)
bind_key_global(keybinds.OpenTerminal, function()
   awful.spawn(terminal)
end)
bind_key_global(keybinds.ShowMenubar, function()
    menubar.show()
end)

-- Layouts
bind_key_global(keybinds.JumpToUrgent, awful.client.urgent.jumpto)
bind_key_global(keybinds.IncSizeLeft, function()
    awful.tag.incmwfact(0.05)
end)
bind_key_global(keybinds.IncSizeRight, function()
    awful.tag.incmwfact(-0.05)
end)
bind_key_global(keybinds.IncrementMasterClients, function()
    awful.tag.incnmaster(1, nil, true)
end)
bind_key_global(keybinds.DecreaseMasterClients, function()
    awful.tag.incnmaster(-1, nil, true)
end)
bind_key_global(keybinds.NextLayout, function()
    awful.layout.inc(1)
end)
bind_key_global(keybinds.PreviousLayout, function()
    awful.layout.inc(-1)
end)

-- Tag management
awful.keyboard.append_global_keybindings({
    -- Only view specific tag
    awful.key({
        modifiers = keybinds.OnlyViewModifiers,
        keygroup = "numrow",
        on_press = function(idx)
            local screen = awful.screen.focused() 
            screen.tags[idx]:view_only()
        end
    }),

    -- Toggle tag
    awful.key({
        modifiers = keybinds.ToggleTag,
        keygroup = "numrow",
        on_press = function(idx)
            local screen = awful.screen.focused()
            local tag = screen.tags[idx]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end
    }),

    -- Move client to tag
    awful.key({
        modifiers = keybinds.MoveClientToTag,
        keygroup = "numrow",
        on_press = function(idx)
            if client.focus then
                local tag = client.focus.screen.tags[idx]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end
    })
})

-- Client management
local function bind_key_clients(key_data, action)
    awful.keyboard.append_client_keybindings({
        awful.key(key_data[1], key_data[2], action)
    })
end
bind_key_clients(keybinds.MoveToScreen, function(c)
    c:move_to_screen()
end)
bind_key_clients(keybinds.Fullscreen, function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
end)
bind_key_clients(keybinds.KillClient, function(c)
    c:kill()
end)
bind_key_clients(keybinds.ToggleFloating, awful.client.floating.toggle) 
bind_key_clients(keybinds.MoveToMaster, function(c)
    c:swap(awful.client.getmaster())
end)
bind_key_clients(keybinds.KeepOnTopToggle, function(c)
    c.ontop = not c.ontop
end)
bind_key_clients(keybinds.MaximizeToggle, function(c)
    c.maximized = not c.maximized
end)


-- Focus
bind_key_global(keybinds.FocusNext, function()
    awful.client.focus.byidx(1)
end)
bind_key_global(keybinds.FocusPrevious, function()
    awful.client.focus.byidx(-1)
end)
bind_key_global(keybinds.FocusNextScreen, function()
    awful.screen.focus_relative(1)
end)
bind_key_global(keybinds.FocusPreviousScreen, function()
    awful.screen.focus_relative(-1)
end)

-- Bind mouse thingies
client.connect_signal("request::default_mousebindings", function()
    awful.mouse.append_client_mousebindings({
        awful.button({}, 1, function(c)
            c:activate({context = "mouse_click"})
        end),
        awful.button({modkey}, 1, function(c)
            c:activate({context = "mouse_click", action = "mouse_move"})
        end),
        awful.button({modkey}, 3, function(c)
            c:activate({context = "mouse_click", action = "mouse_resize"})
        end)
    })
end)

ruled.client.connect_signal("request::rules", function()
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus     = awful.client.focus.filter,
            raise     = true,
            screen    = awful.screen.preferred,
            placement = awful.placement.no_overlap+awful.placement.no_offscreen,
        }
    }

    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }

    -- Make glava audio visualizer appear maximized, in background and in every tag
    ruled.client.append_rule {
        rule = { class = "GLava"} ,
        properties = {
            below = true,
            floating = true,
            focusable = false,
            border_width = 0,
            maximized = true,
            sticky = true
        }
    }
end)

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:activate { context = "mouse_enter", raise = false }
end)

awful.screen.connect_for_each_screen(function(s)
    if s.geometry.height == 1440 then
        screen.primary = s
    end
end)

local autolanch_cmd = theme.config_root .. "/autolaunch.sh > " .. theme.config_root .. "/autolaunch.log"
awesome.spawn(autolanch_cmd, false)
