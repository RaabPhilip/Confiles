local env = require("modules.variables")

--------------------------------
---- GLOBAL WINDOW RULES ----
--------------------------------

hl.window_rule({
    -- Ignore maximize requests from all apps. You'll probably like this.
    name           = "suppress-maximize-events",
    match          = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name     = "fix-xwayland-drags",
    match    = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

--------------------------------
---- LAYER RULES ----
--------------------------------

hl.layer_rule({
    name = "noctalia",
    match = {
        namespace = "noctalia-background-.*$",
    },
    ignore_alpha = 0.5,
    blur = true,
    blur_popups = true,
})

--------------------------------
---- APPLICATION WORKSPACE ASSIGNMENTS ----
--------------------------------

hl.window_rule({
    match = {
        class = "(code-oss)",
    },
    workspace = "2",
})

hl.window_rule({
    match = {
        class = "(dev.zed.Zed)",
    },
    workspace = "2",
})

hl.window_rule({
    match = {
        class = "(obsidian)",
    },
    workspace = 2,
})

hl.window_rule({
    match = {
        class = "(zen)",
    },
    workspace = "3",
})

hl.window_rule({
    match = {
        class = "(spotify)",
    },
    workspace = "name:music",
})

-- Video Player
-- hl.window_rule({
--     match = {
--         class = "(mpv)",
--     },
--     float = true,
--     fullscreen = false,
--     stay_focused = false,
-- })

--------------------------------
---- WORKSPACE DEFINITIONS ----
--------------------------------

hl.workspace_rule({
    workspace = "1",
    monitor = env.outputs.laptop,
    default = true,
    on_created_empty = "alacritty",
    persistent = true,
})

hl.workspace_rule({
    workspace = "2",
    monitor = env.outputs.middle,
    default = true,
    persistent = true,
    layout = "scrolling"
})

hl.workspace_rule({
    workspace = "3",
    monitor = env.outputs.second,
    default = true,
    persistent = true,
    on_created_empty = "zen-browser",
})

hl.workspace_rule({
    workspace = "4",
    default = true,
    persistent = true,
})

hl.workspace_rule({
    workspace = "5",
    default = true,
    persistent = true,
})

hl.workspace_rule({
    workspace = "name:music",
    on_created_empty = "spotify",
})
