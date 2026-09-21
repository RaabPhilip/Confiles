-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia") -- Shell environment
    hl.exec_cmd("udiskie")  -- Disk manager
    hl.exec_cmd("synology-drive")  -- Synology file sync client
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")  -- Keychain
end)
