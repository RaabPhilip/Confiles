local env = require("modules.variables")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output = env.outputs.laptop,
    mode = "1920x1080@60",
    position = "0x400",
    scale = "1",
})

hl.monitor({
    output = env.outputs.middle,
    mode = "2560x1440@100",
    position = "1920x0",
    scale = "1",
})

hl.monitor({
    output = env.outputs.second,
    mode = "2560x1440@100",
    position = "4480x0",
    scale = "1",
})

hl.monitor({
    output = env.outputs.hdmi,
    mode = "preferred",
    position = "auto",
    scale = 1,
    mirror = env.outputs.laptop,
})
