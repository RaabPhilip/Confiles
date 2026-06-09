require("hyprkeybinds")
require("hyprworkspaces")
require("hyprrules")

-- Variables
local monitor1 = "eDP-1"
local monitor2 = "desc:Microstep MSI MP273Q E2 PB6H454A00496"
local monitor3 = "desc:Microstep MSI MP273Q E2 PB6H454A00249"
local beamer = "HDMI-A-1"

--###############
--## MONITORS ###
--###############

-- See https://wiki.hyprland.org/Configuring/Monitors/
hl.monitor({
    output = monitor1,
    mode = "1920x1080@60",
    position = "0x400",
    scale = "1",
})

hl.monitor({
    output = monitor2,
    mode = "2560x1440@100",
    position = "1920x0",
    scale = "1",
})

hl.monitor({
    output = monitor3,
    mode = "2560x1440@100",
    position = "4480x0",
    scale = "1",
})

hl.monitor({
    output = beamer,
    mode = "preferred",
    position = "auto",
    scale = "1",
    mirror = "$monitor1",
})

-- hl.monitor({
--     output = beamer,
--     mode = "preferred",
--     position = "auto",
--     scale = "1",
-- })

--################
--## AUTOSTART ###
--################

hl.on("hyprland.start", function()
    hl.exec_cmd("mako")                                                    -- Notification daemon
    hl.exec_cmd("systemctl --user start hyprpolkitagent")                  -- PolicyKit agent
    hl.exec_cmd("waybar")                                                  -- Status bar
    -- hl.exec_cmd("qs -c noctalia-shell")
    hl.exec_cmd("hyprpaper")                                               -- Wallpaper daemon
    hl.exec_cmd("clipse -listen")                                          -- Clipboard manager
    hl.exec_cmd("udiskie")                                                 -- Disk manager
    hl.exec_cmd("nm-applet &")                                             -- Network manager
    hl.exec_cmd("hypridle")                                                -- Idle manager
    hl.exec_cmd("hyprpm reload -n")                                        -- Plugin manager
    hl.exec_cmd("alacritty --class daily -e ~/.local/bin/daily-update.sh") -- Terminal emulator
    hl.exec_cmd("synology-drive")                                          -- Synology Drive
    hl.exec_cmd("systemctl --user start elephant.service")                 -- Elephant => is
    hl.exec_cmd("walker --gapplication-service")                           -- Walker
end)

--############################
--## ENVIRONMENT VARIABLES ###
--############################

-- See https://wiki.hyprland.org/Configuring/Environment-variables/

hl.env("XCURSOR_THEME", "capitaine-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

--##################
--## PERMISSIONS ###
--##################

-- See https://wiki.hyprland.org/Configuring/Permissions/
-- Please note permission changes here require a Hyprland restart and are not applied on-the-fly
-- for security reasons

-- ecosystem {
--   enforce_permissions = 1
-- }

hl.permission({ binary = "/usr/bin/grim", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/lib/xdg-desktop-portal-hyprland", type = "screencopy", mode = "allow" })
hl.permission({ binary = "/usr/bin/hyprpm", type = "plugin", mode = "allow" })

--####################
--## LOOK AND FEEL ###w
--####################

-- Refer to https://wiki.hyprland.org/Configuring/Variables/

-- https://wiki.hyprland.org/Configuring/Variables/#general

hl.curve("easeOutQuint", { type = "bezier", points = { { 0.23, 1 }, { 0.32, 1 } } })
hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1 } } })
hl.curve("linear", { type = "bezier", points = { { 0, 0 }, { 1, 1 } } })
hl.curve("almostLinear", { type = "bezier", points = { { 0.5, 0.5 }, { 0.75, 1.0 } } })
hl.curve("quick", { type = "bezier", points = { { 0.15, 0 }, { 0.1, 1 } } })
hl.animation({
    leaf = "global",
    enabled = true,
    speed = 10,
    bezier = "default",
})
hl.animation({
    leaf = "border",
    enabled = true,
    speed = 5.39,
    bezier = "easeOutQuint",
})
hl.animation({
    leaf = "windows",
    enabled = true,
    speed = 4.79,
    bezier = "easeOutQuint",
})
hl.animation({
    leaf = "windowsIn",
    enabled = true,
    speed = 4.1,
    bezier = "easeOutQuint",
    style = "popin 87%",
})
hl.animation({
    leaf = "windowsOut",
    enabled = true,
    speed = 1.49,
    bezier = "linear",
    style = "popin 87%",
})
hl.animation({
    leaf = "fadeIn",
    enabled = true,
    speed = 1.73,
    bezier = "almostLinear",
})
hl.animation({
    leaf = "fadeOut",
    enabled = true,
    speed = 1.46,
    bezier = "almostLinear",
})
hl.animation({
    leaf = "fade",
    enabled = true,
    speed = 3.03,
    bezier = "quick",
})
hl.animation({
    leaf = "layers",
    enabled = true,
    speed = 3.81,
    bezier = "easeOutQuint",
})
hl.animation({
    leaf = "layersIn",
    enabled = true,
    speed = 4,
    bezier = "easeOutQuint",
    style = "fade",
})
hl.animation({
    leaf = "layersOut",
    enabled = true,
    speed = 1.5,
    bezier = "linear",
    style = "fade",
})
hl.animation({
    leaf = "fadeLayersIn",
    enabled = true,
    speed = 1.79,
    bezier = "almostLinear",
})
hl.animation({
    leaf = "fadeLayersOut",
    enabled = true,
    speed = 1.39,
    bezier = "almostLinear",
})
hl.animation({
    leaf = "workspaces",
    enabled = true,
    speed = 1.94,
    bezier = "almostLinear",
    style = "fade",
})
hl.animation({
    leaf = "workspacesIn",
    enabled = true,
    speed = 1.21,
    bezier = "almostLinear",
    style = "fade",
})
hl.animation({
    leaf = "workspacesOut",
    enabled = true,
    speed = 1.94,
    bezier = "almostLinear",
    style = "fade",
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

hl.device({
    name = "syna32b3:01-06cb:ce7d-touchpad",
    enabled = true,
})

-- TODO: manual review on line 215 — no mapping for dispatcher "Speech-to-text"
-- hl.bind("SUPER + ALT + D", hl.dsp.Speech_to_text("exec", "/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record"), { drag = true })
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
-- hl.env("PATH", "$HOME/.local/bin:$PATH")
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 5,
        border_size = 2,
        -- https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
        col = {
            active_border = "rgba(ffffffff)",
            inactive_border = "rgba(595959aa)",
        },
        -- Set to true enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = true,
        -- Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
        allow_tearing = false,
        layout = "master",
    },
    -- https://wiki.hyprland.org/Configuring/Variables/#decoration
    decoration = {
        rounding = 0,
        rounding_power = 0,
        -- Change transparency of focused and unfocused windows
        active_opacity = 1,
        inactive_opacity = 1,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = "rgba(1a1a1aee)",
        },
        -- https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
            enabled = true,
            size = 3,
            passes = 2,
            vibrancy = 0.1696,
        },
    },
    -- https://wiki.hyprland.org/Configuring/Variables/#animations
    animations = {
        enabled = true,
        -- Default animations, see https://wiki.hyprland.org/Configuring/Animations/ for more
    },
    -- See https://wiki.hyprland.org/Configuring/Dwindle-Layout/ for more
    dwindle = {
        preserve_split = true, -- You probably want this
    },
    -- See https://wiki.hyprland.org/Configuring/Master-Layout/ for more
    master = {
        new_status = "slave",
    },
    -- https://wiki.hyprland.org/Configuring/Variables/#misc
    misc = {
        force_default_wallpaper = 0,  -- Set to 0 or 1 to disable the anime mascot wallpapers
        disable_hyprland_logo = true, -- If true disables the random hyprland logo / anime girl background. :(
    },
    --############
    --## INPUT ###
    --############
    -- https://wiki.hyprland.org/Configuring/Variables/#input
    input = {
        kb_layout = "de",
        kb_variant = "",
        kb_model = "",
        kb_options = "caps:escape",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.
        -- kb_options = fkeys:basic_13-24
        touchpad = {
            natural_scroll = true,
        },
    },
    -- https://wiki.hyprland.org/Configuring/Variables/#gestures
    --gestures {
    --    workspace_swipe = true
    --}
    --

    hl.layer_rule({
        name = "noctalia",
        match = {
            namespace = "noctalia-background-.*$",
        },
        ignore_alpha = 0.5,
        blur = true,
        blur_popups = true,
    })
})
