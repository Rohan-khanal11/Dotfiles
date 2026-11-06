local p = require("modules.programs")

-- ============================================================
--  Window rules
-- ============================================================

-- Browser always opens on workspace 2
hl.window_rule({
    name      = "brave-workspace",
    match     = { class = p.browser },
    workspace = 2,
})

-- Ignore apps asking to maximize themselves
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland drag-and-drop ghost windows stealing focus
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})
