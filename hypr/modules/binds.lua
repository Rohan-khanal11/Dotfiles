local p       = require("modules.programs")
local mainMod = "SUPER"
local home    = "/home/khanal"

local bind = hl.bind
local exec = hl.dsp.exec_cmd


-- ============================================================
-- Helpers
-- ============================================================

local levels_path = home .. "/Projects/Dotfiles/quickshell/levels.qml"

local levels_osd =
    "sh -c 'qs ipc -p " .. levels_path .. " call levels flash"
    .. " || LEVELS_OSD=1 qs -n -d -p " .. levels_path .. "'"

local shutdown_cmd =
    "command -v hyprshutdown >/dev/null 2>&1"
    .. " && hyprshutdown"
    .. " || hyprctl dispatch 'hl.dsp.exit()'"

local shot_full = [[bash -c '
    file=~/Pictures/$(date +%Y-%m-%d_%H-%M-%S)_full.png
    grim "$file" && wl-copy < "$file" &&
    hyprctl notify 1 3000 "rgb(137,180,250)" "Fullscreen screenshot saved and copied"
']]

local shot_area = [[bash -c '
    file=~/Pictures/$(date +%Y-%m-%d_%H-%M-%S).png
    grim -g "$(slurp)" "$file" && wl-copy < "$file" &&
    hyprctl notify 1 3000 "rgb(166,227,161)" "Screenshot saved and copied"
']]


-- ============================================================
-- Apps
-- ============================================================

bind(mainMod .. " + RETURN", exec(p.terminal .. " -e bash -lc 'fastfetch; exec bash'"))
bind(mainMod .. " + N",      exec(p.terminal .. " -e nvim"))
bind(mainMod .. " + E",      exec(p.fileManager))
bind(mainMod .. " + B",      exec(p.browser))
bind(mainMod .. " + SPACE",  exec("qs -p " .. home .. "/.config/quickshell/launcher.qml"))
bind(mainMod .. " + C",      exec("snapshot"))
bind(mainMod .. " + Y",      exec("emacs"))
bind(mainMod .. " + T",      exec(home .. "/Downloads/PrismLauncher-Linux-x86_64.AppImage"))
bind(mainMod .. " + A",      exec("qs -p " .. home .. "/.config/quickshell/Wallpaper.qml ipc call wallpaper toggle"))
bind(mainMod .. " + W",      exec(home .. "/.config/hypr/scripts/shell-toggle.sh toggle"))


-- ============================================================
-- Session / window control
-- ============================================================

bind(mainMod .. " + Q", hl.dsp.window.close())
bind(mainMod .. " + M", exec(shutdown_cmd))
bind(mainMod .. " + Z", exec("hyprlock"))
bind(mainMod .. " + V", hl.dsp.window.float({ action = "toggle" }))
bind(mainMod .. " + P", hl.dsp.window.pseudo())
bind(mainMod .. " + I", hl.dsp.layout("togglesplit"))


-- ============================================================
-- Focus (SUPER + HJKL)
-- ============================================================

bind(mainMod .. " + H", hl.dsp.focus({ direction = "left"  }))
bind(mainMod .. " + L", hl.dsp.focus({ direction = "right" }))
bind(mainMod .. " + K", hl.dsp.focus({ direction = "up"    }))
bind(mainMod .. " + J", hl.dsp.focus({ direction = "down"  }))


-- ============================================================
-- Swap windows (SUPER + SHIFT + HJKL)
-- ============================================================

local mod = "SUPER + SHIFT"

bind(mod .. " + h", hl.dsp.window.swap({ direction = "l" }))
bind(mod .. " + l", hl.dsp.window.swap({ direction = "r" }))
bind(mod .. " + k", hl.dsp.window.swap({ direction = "u" }))
bind(mod .. " + j", hl.dsp.window.swap({ direction = "d" }))


-- ============================================================
-- Workspaces
-- ============================================================

for i = 1, 10 do
    local key = i % 10

    bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

bind(mainMod .. " + D",         hl.dsp.workspace.toggle_special("magic"))
bind(mainMod .. " + SHIFT + D", hl.dsp.window.move({ workspace = "special:magic" }))


-- ============================================================
-- Mouse drag / resize
-- ============================================================

bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })


-- ============================================================
-- Screenshots
-- ============================================================

bind("SUPER + S",         exec(shot_full))
bind("SUPER + SHIFT + S", exec(shot_area))


-- ============================================================
-- Media / volume / brightness
-- ============================================================

local held = { locked = true, repeating = true }
local lock = { locked = true }


-- Volume

bind("XF86AudioRaiseVolume",
    exec("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+ && " .. levels_osd), held)

bind("XF86AudioLowerVolume",
    exec("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%- && " .. levels_osd), held)

bind("XF86AudioMute",
    exec("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle && " .. levels_osd), held)

bind("XF86AudioMicMute",
    exec("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), held)


-- Brightness

bind("XF86MonBrightnessUp",
    exec("brightnessctl -e4 -n2 set 5%+ && " .. levels_osd), held)

bind("XF86MonBrightnessDown",
    exec("brightnessctl -e4 -n2 set 5%- && " .. levels_osd), held)


-- Player

bind("XF86AudioNext",  exec("playerctl next"),       lock)
bind("XF86AudioPause", exec("playerctl play-pause"), lock)
bind("XF86AudioPlay",  exec("playerctl play-pause"), lock)
bind("XF86AudioPrev",  exec("playerctl previous"),   lock)


-- Misc

bind("XF86Calculator", exec("gnome-calculator"))
