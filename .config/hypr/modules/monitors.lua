local env = require("modules.variables")

------------------
---- MONITORS ----
------------------

-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
hl.monitor({
    output = env.outputs.laptop,
    mode = "2880x1920@120.00",
    position = "0x800",
    scale = "1.6",
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
