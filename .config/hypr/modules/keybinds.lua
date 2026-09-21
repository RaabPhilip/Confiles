---------------------
---- KEYBINDINGS ----
---------------------
local env = require("modules.variables")


hl.bind(env.mainMod .. " + SPACE", hl.dsp.exec_cmd(env.apps.ipc .. " panel-toggle launcher"))
hl.bind(env.mainMod .. " + S", hl.dsp.exec_cmd(env.apps.ipc .. " panel-toggle control-center"))
hl.bind(env.mainMod .. " + comma", hl.dsp.exec_cmd(env.apps.ipc .. " settings-toggle"))

-- Example binds, see https://wiki.hypr.land/Configuring/Basics/Binds/ for more
hl.bind(env.mainMod .. " + RETURN", hl.dsp.exec_cmd(env.apps.terminal))
hl.bind(env.mainMod .. " + C", hl.dsp.window.close())
hl.bind(env.mainMod .. " + M",
    hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(env.mainMod .. " + E", hl.dsp.exec_cmd(env.apps.tuiFm))
hl.bind(env.mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(env.apps.guiFm))
hl.bind(env.mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(env.mainMod .. " + I", hl.dsp.exec_cmd("zeditor ./Confiles/"))

-- Move focus with env.mainMod + arrow keys
hl.bind(env.mainMod .. " + left", hl.dsp.focus({ direction = "left" }))
hl.bind(env.mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(env.mainMod .. " + up", hl.dsp.focus({ direction = "up" }))
hl.bind(env.mainMod .. " + down", hl.dsp.focus({ direction = "down" }))

-- Switch workspaces with env.mainMod + [0-9]
-- Move active window to a workspace with env.mainMod + SHIFT + [0-9]
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(env.mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(env.mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

hl.bind(env.mainMod .. " + Tab", hl.dsp.focus({ workspace = "prev" }))

-- move workspace left and rigth
hl.bind(env.mainMod .. " + CTRL + left", hl.dsp.focus({ workspace = -1 }))
hl.bind(env.mainMod .. " + CTRL + right", hl.dsp.focus({ workspace = "+1" }))

-- Scroll through existing workspaces with env.mainMod + scroll
hl.bind(env.mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(env.mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize windows with + LMB/RMB and dragging
hl.bind(env.mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(env.mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })


-- Screenshot
-- hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd("hyprshot-gui"))
hl.bind(env.mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(env.apps.ipc .. " screenshot-region"))
-- Screenlocking
hl.bind(env.mainMod .. " + SHIFT + L", hl.dsp.exec_cmd(env.apps.ipc .. " session lock"))

-- Clipboard Manager
hl.bind(env.mainMod .. " + V", hl.dsp.exec_cmd(env.apps.ipc .. " panel-toggle clipboard"))

-- Colour Picker
hl.bind(env.mainMod .. " + SHIFT + I", hl.dsp.exec_cmd("hyprpicker -a -f hex"))
hl.bind(env.mainMod .. " + ALT + I", hl.dsp.exec_cmd("hyprpicker -a -f rgb"))

-- Wallpaper
hl.bind(env.mainMod .. " + SHIFT + W", hl.dsp.exec_cmd(env.apps.ipc .. " panel-toggle wallpaper"))

-- Power Menu
hl.bind(env.mainMod .. " + P", hl.dsp.exec_cmd(env.apps.ipc .. " panel-toggle session"))

-- Scrolling Layout
-- hl.bind(env.mainMod .. " + SHIFT + up", hl.dsp.layout("promote"))

hl.bind(env.mainMod .. " + ALT + f", hl.dsp.layout("fit_into_view"))
hl.bind(env.mainMod .. " + SHIFT + down", hl.dsp.layout("consume_or_expel next"))
hl.bind(env.mainMod .. " + SHIFT + up", hl.dsp.layout("consume_or_expel prev"))

local function layout_bind(bind_table)
    return function()
        local workspace = hl.get_active_special_workspace() or
            hl.get_active_workspace()

        if not workspace then
            return
        end

        local layout = workspace.tiled_layout

        if bind_table[layout] then
            hl.dispatch(bind_table[layout])
        end
    end
end

-- Move window in workspace
-- hl.bind(env.mainMod .. " + SHIFT + up", hl.dsp.window.move({ direction = "u" }))
-- hl.bind(env.mainMod .. " + SHIFT + down", hl.dsp.window.move({ direction = "d" }))

hl.bind(env.mainMod .. " + SHIFT + left", layout_bind({
    scrolling = hl.dsp.layout("swapcol r"), -- Scrolling: swap column with left one
    master    = hl.dsp.window.move({ direction = "l" }),
}))

hl.bind(env.mainMod .. " + SHIFT + right", layout_bind({
    scrolling = hl.dsp.layout("swapcol l"), -- Scrolling: swap column with right one
    master    = hl.dsp.window.move({ direction = "r" }),
}))
hl.bind(env.mainMod .. " + SHIFT + f", layout_bind({
    scrolling = hl.dsp.layout("colresize +conf"), -- Scrolling: swap column with left one
    master    = hl.dsp.window.fullscreen(),
}))
