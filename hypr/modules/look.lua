-- ============================================================
--  General / decoration
-- ============================================================

hl.config({
    general = {
        gaps_in          = 2,
        gaps_out         = 5,
        border_size      = 1,
        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",

        col = {
            active_border   = "rgba(cccccccc)",
            inactive_border = "rgba(FFFFFF33)",
        },
    },

    decoration = {
        rounding         = 4,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,

        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },

    animations = { enabled = true },
})


-- ============================================================
--  Bezier curves
-- ============================================================

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear",         { type = "bezier", points = { {0,    0},    {1,    1} } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5,  0.5},  {0.75, 1} } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1,  1} } })


-- ============================================================
--  Animations
-- ============================================================

local anims = {
    -- Borders / windows
    { "border",        5.39, "easeOutQuint"                 },
    { "windows",       4.79, "easeOutQuint"                 },
    { "windowsIn",     4.1,  "easeOutQuint", "popin 87%"    },
    { "windowsOut",    1.49, "linear",       "popin 87%"    },

    -- Fades
    { "fade",          3.03, "quick"                        },
    { "fadeIn",        1.73, "almostLinear"                 },
    { "fadeOut",       1.46, "almostLinear"                 },

    -- Layers
    { "layers",        3.81, "easeOutQuint"                 },
    { "layersIn",      4,    "easeOutQuint", "fade"         },
    { "layersOut",     1.5,  "linear",       "fade"         },
    { "fadeLayersIn",  1.79, "almostLinear"                 },
    { "fadeLayersOut", 1.39, "almostLinear"                 },

    -- Workspaces
    { "workspaces",    1.94, "almostLinear", "fade"         },
    { "workspacesIn",  1.21, "almostLinear", "fade"         },
    { "workspacesOut", 1.94, "almostLinear", "fade"         },

    -- Misc
    { "zoomFactor",    7,    "quick"                        },
}

for _, a in ipairs(anims) do
    hl.animation({
        leaf    = a[1],
        enabled = true,
        speed   = a[2],
        bezier  = a[3],
        style   = a[4],
    })
end


-- ============================================================
--  Layouts / misc
-- ============================================================

hl.config({ dwindle  = { preserve_split = true } })
hl.config({ master   = { new_status = "master" } })
hl.config({ xwayland = { force_zero_scaling = true } })
hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})
