-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/
--
hl.on("hyprland.start", function()
    hl.exec_cmd("noctalia") -- Shell environment
    hl.exec_cmd("udiskie")  -- Disk manager
end)
