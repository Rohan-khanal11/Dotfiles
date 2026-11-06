-- ============================================================
--  Cursor
-- ============================================================

local cursor_theme = "GoogleDot-Black"
local cursor_size  = "24"

hl.env("XCURSOR_THEME",     cursor_theme)
hl.env("XCURSOR_SIZE",      cursor_size)
hl.env("HYPRCURSOR_THEME",  cursor_theme)
hl.env("HYPRCURSOR_SIZE",   cursor_size)


-- ============================================================
--  Nvidia
-- ============================================================

hl.env("LIBVA_DRIVER_NAME",          "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME",  "nvidia")


-- ============================================================
--  Qt
-- ============================================================

hl.env("QT_STYLE_OVERRIDE", "kvantum")
