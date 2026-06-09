--#############################
--## WINDOWS AND WORKSPACES ###
--#############################

-- See https://wiki.hyprland.org/Configuring/Window-Rules/ for more
-- See https://wiki.hyprland.org/Configuring/Workspace-Rules/ for workspace rules

local monitor1 = "eDP-1"
local monitor2 = "desc:Microstep MSI MP273Q E2 PB6H454A00496"
local monitor3 = "desc:Microstep MSI MP273Q E2 PB6H454A00249"
local beamer = "HDMI-A-1"

hl.workspace_rule({
    workspace = "1",
    monitor = monitor1,
    default = true,
    on_created_empty = "alacritty",
    persistent = true,
})

hl.workspace_rule({
    workspace = "2",
    monitor = monitor2,
    default = true,
    persistent = true,
})

hl.workspace_rule({
    workspace = "3",
    monitor = monitor3,
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



-- workspace = 4,monitor:$beamer,default:true

hl.workspace_rule({
    workspace = "name:music",
    on_created_empty = "spotify",
})

hl.workspace_rule({
    workspace = "name:notes",
    on_created_empty = "obsidian",
})

-- Ref https://wiki.hyprland.org/Configuring/Workspace-Rules/
-- "Smart gaps" / "No gaps when only"
-- uncomment all if you wish to use that.
hl.workspace_rule({
    workspace = "w[tv1]",
    gaps_out = 0,
    gaps_in = 0,
})

hl.workspace_rule({
    workspace = "f[1]",
    gaps_out = 0,
    gaps_in = 0,
})
