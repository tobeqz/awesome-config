local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')
local xresources = require('beautiful.xresources')
local naughty = require('naughty')
local theme = require("theme")
local dpi = xresources.apply_dpi

awful.screen.connect_for_each_screen(function(s)
    s.padding = {
        top = dpi(35)
    }
end)

local function log(msg)
    naughty.notification({
        title = "Log",
        message = msg
    })
end

function create_rounded_rect(radius)
    return function(cr, width, height)
        return gears.shape.rounded_rect(cr, width, height, radius)
    end
end

screen.connect_signal("request::desktop_decoration", function(s)
    local ran, err = pcall(function()
        local dateclock = wibox.widget.textclock(" %a %d %b")
        local bar_height = s.padding.top-5
        s.main_wibox = wibox({
            height = bar_height,
            width = s.geometry.width - theme.useless_gap*2 - theme.border_width * 4,
            x = s.geometry.x + theme.useless_gap + theme.border_width*2,
            y = 7,
            visible = true,
            border_width = 0,
            bg = theme.bg_normal,
        })

        local left_widgets = wibox.layout.fixed.horizontal()
        local right_widgets = wibox.layout.fixed.horizontal({
            expand = "outside"
        })
        local center_widgets = wibox.layout.fixed.horizontal()

        local arch_logo = wibox.widget.imagebox(theme.config_root .. "/images/distro_logo.png", false)
        arch_logo.resize = true
        local margined_arch_logo = wibox.container.margin(arch_logo, 5, 10, 3, 3)
        left_widgets:add(margined_arch_logo)

        local taglist = awful.widget.taglist({
            screen = s,
            filter = awful.widget.taglist.filter.all,
            buttons = {
                awful.button({
                    modifiers = {},
                    button = 1,
                    on_press = function(tag)
                        tag:view_only()
                    end
                })
            },
            widget_template = {
                widget = wibox.container.margin,
                right = 5,
                top = 7,
                bottom = 7,
                {
                    id = "image_box",
                    resize = true,
                    image = theme.config_root .. "/images/unfocused_empty.png",
                    widget = wibox.widget.imagebox
                },
                update_callback = function(self, updating_tag)
                    local imagebox = self:get_children_by_id("image_box")[1]
                    if updating_tag.selected then
                        imagebox.image = theme.config_root .. "/images/focused.png"
                    elseif #updating_tag:clients() > 0 then
                        imagebox.image = theme.config_root .. '/images/unfocused_has_client.png'
                    else
                        imagebox.image = theme.config_root .. "/images/unfocused_empty.png"
                    end
                end
            },
        })
        taglist.visible = true

        local is_playing = false
        local play_command = theme.config_root .. "/spotify_manage/target/release/spotify_manage --play"
        local pause_command = theme.config_root .. "/spotify_manage/target/release/spotify_manage --pause"
        local play_button = wibox.widget.textbox("\u{f04b}")
        play_button:connect_signal("button::press", function(self)
            is_playing = not is_playing
            
            if is_playing then
                awful.spawn(play_command, false)
                self.text = "\u{f04c}"
            else
                awful.spawn(pause_command, false)
                self.text = "\u{f04b}"
            end
        end)
        play_button.font = "Monospace 13"
        local playing_cmd = theme.config_root .. "/spotify_manage/target/release/spotify_manage --status"
        play_button = awful.widget.watch(playing_cmd, 3, function(widget, out)
            -- Not not coerces it into an actual boolean
            is_playing = not not string.find(out, "Playing")

            if not is_playing then
                widget.text = "\u{f04b}"
                return
            end

            widget.text = "\u{f04c}"
        end, play_button)
        play_button = wibox.container.margin(play_button, 70, 5)
        local next_button = wibox.widget.textbox("\u{f04e}")
        next_button.font = "Monospace 13"
        next_button:connect_signal("button::press", function()
            awful.spawn(theme.config_root .. "/spotify_manage/target/release/spotify_manage --next", false)
        end)

        local music_progress = wibox.widget.progressbar()
        music_progress.forced_height = 10
        music_progress.width = 100
        music_progress.background_color = theme.bg_minimize
        music_progress.color = theme.bg_focus
        music_progress.value = 0.5
        music_progress.max_value = 1
        music_progress.border_width = 0
        music_progress.clip = true
        music_progress.bar_border_width = 0
        music_progress.shape = function(cr)
            return gears.shape.rounded_rect(cr, 100, 10, 5)
        end

        local last = 0
        local progress_cmd = theme.config_root .. "/spotify_manage/target/release/spotify_manage --progress"
        music_progress = awful.widget.watch(progress_cmd, 2, function(widget, out)
            last = tonumber(out) or last
            widget.value = last
        end, music_progress)
        music_progress = wibox.container.margin(music_progress, 10, 10, 12)

        local music_name_cmd = theme.config_root .. "/spotify_manage/target/release/spotify_manage --song"
        local last_name = "Unknown - Unknown"
        local music_scroll = wibox.widget.textbox(last_name)
        music_scroll = awful.widget.watch(music_name_cmd, 2, function(widget, out)
            last_name = (" | " .. out) or last_name
            widget.text = last_name
            widget.font = "Monospace 10"
            widget.forced_height = bar_height
        end)
        music_scroll = wibox.container.scroll.horizontal(music_scroll, 60, 60)
        music_scroll.forced_width = 150

        local time_icon = wibox.widget.textbox("\u{f017}")
        time_icon.font = "Monospace 13"
        time_icon.forced_height = bar_height
        local textclock = wibox.widget.textclock(" %H:%M")
        textclock.font = "Monospace 12"
        textclock.forced_height = bar_height
        local time_margined = {
            widget = wibox.container.margin,
            right = 20,
            {
                widget = wibox.layout.fixed.horizontal(),
                time_icon,
                textclock
            }
        }

        local date_icon = wibox.widget.textbox("\u{f783}")
        date_icon.font = "Monospace 13"
        date_icon.forced_height = bar_height
        local date_clock = wibox.widget.textclock(" %a %b %d")
        date_clock.font = "Monospace 12"
        date_clock.forced_height = bar_height
        local date_margined = {
            widget = wibox.container.margin,
            right = 20,
            {
                widget = wibox.layout.fixed.horizontal(),
                date_icon,
                date_clock
            }
        }

        local systray = wibox.widget.systray(false)
        --systray.forced_width = 100
        systray.visible = true

        local margined_systray = wibox.container.margin(systray, 5, 5, 5, 5)

        local cpu_icon = wibox.widget.textbox("\u{f2db}")
        cpu_icon.font = "Monospace 13"

        local cpu_command = theme.config_root .. "/get_cpu_usage/target/release/get_cpu_usage"
        local cpu_percent = awful.widget.watch.new(cpu_command, 5, function(widget, out)
            local as_num = tonumber(out)
            widget.text = " " .. tostring(math.ceil(as_num)) .. "%"
        end)
        cpu_percent.font = "Monospace 12"
        cpu_percent.forced_height = bar_height
        cpu_icon.forced_height = bar_height

        local mem_command = theme.config_root .. "/get_mem_usage/target/release/get_mem_usage"
        local mem_icon = wibox.widget.textbox("\u{f538}")
        local mem_percent = awful.widget.watch.new(mem_command, 5, function(widget, out)
            local as_num = tonumber(out)
            widget.text = " " .. tostring(math.ceil(as_num)) .. "%"
        end)
        mem_percent.font = "Monospace 12"
        mem_percent.forced_height = bar_height
        mem_icon.forced_height = bar_height

        

        local mem_margined = {
            widget = wibox.container.margin,
            right = 20,
            {
                widget = wibox.layout.fixed.horizontal(),
                mem_icon,
                mem_percent
            }
        }

        local cpu_margined = {
            widget = wibox.container.margin,
            right = 20,
            {
                widget = wibox.layout.fixed.horizontal(),
                cpu_icon,
                cpu_percent
            }
        }


        -- Get amount of threads in system


        --coroutine.resume(coroutine.create(function()
        --    while os.execute("sleep 1") do
        --        log("coolio")
        --    end
        --end))

        left_widgets:add(taglist)
        left_widgets:add(play_button)
        left_widgets:add(next_button)
        left_widgets:add(music_progress)
        left_widgets:add(music_scroll)

        right_widgets:add(time_margined)
        right_widgets:add(date_margined)

        right_widgets:add(cpu_margined)
        right_widgets:add(mem_margined)
        right_widgets:add(margined_systray)

        local c = wibox.layout.align.horizontal(
            left_widgets,
            center_widgets,
            right_widgets
        )
        s.main_wibox.widget = c
    end)

    if not ran then
        log(err)
    end
end)
