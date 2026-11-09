pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Theme names, in cycling order (the qs-theme script reads this line):
// @themes: mono catppuccin gruvbox nord tokyonight rosepine dracula macchiato everforest caesar solarized kanagawa onedark ayu nightfox palenight monokai
Singleton {
    id: t
    readonly property string font: "Iosevka Nerd Font"

    // ---- which theme is active ----
    // One small file shared by every Quickshell process, so the bar,
    // launcher and panels all switch live when it changes.
    readonly property string stateFile: Quickshell.env("HOME") + "/.local/state/qs-theme-name"
    property string name: "mono"

    FileView {
        id: fv
        path: t.stateFile
        watchChanges: true
        blockLoading: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: t.read()
        Component.onCompleted: t.read()
    }
    // keeps the last good theme if the file is empty or misspelled
    function read() {
        const n = fv.text().trim()
        if (palettes[n]) name = n
    }

    // ---- palettes ----
    // base: surfaces and text drawn on accent    ink: neutral overlays
    // accent: main colour (selection, borders, active dots)
    // accent2: secondary highlight   warn: caution   info: cool/neutral status
    readonly property var palettes: ({
        mono: {
            base: "#000000", ink: "#ffffff", accent: "#ffffff", text: "#d0d0d0", muted: "#6e6e6e",
            bright: "#f2f2f2", line: "#e8e8e8", good: "#ffffff", bad: "#ffffff",
            accent2: "#bdbdbd", warn: "#e0e0e0", info: "#9e9e9e"
        },
        catppuccin: {
            base: "#1e1e2e", ink: "#cdd6f4", accent: "#89b4fa", text: "#cdd6f4", muted: "#6c7086",
            bright: "#cdd6f4", line: "#bac2de", good: "#a6e3a1", bad: "#f38ba8",
            accent2: "#cba6f7", warn: "#f9e2af", info: "#89dceb"
        },
        gruvbox: {
            base: "#282828", ink: "#ebdbb2", accent: "#fabd2f", text: "#ebdbb2", muted: "#928374",
            bright: "#fbf1c7", line: "#d5c4a1", good: "#b8bb26", bad: "#fb4934",
            accent2: "#d3869b", warn: "#fe8019", info: "#83a598"
        },
        nord: {
            base: "#2e3440", ink: "#eceff4", accent: "#88c0d0", text: "#d8dee9", muted: "#7b88a1",
            bright: "#eceff4", line: "#d8dee9", good: "#a3be8c", bad: "#bf616a",
            accent2: "#b48ead", warn: "#ebcb8b", info: "#81a1c1"
        },
        tokyonight: {
            base: "#1a1b26", ink: "#c0caf5", accent: "#7aa2f7", text: "#c0caf5", muted: "#565f89",
            bright: "#c0caf5", line: "#a9b1d6", good: "#9ece6a", bad: "#f7768e",
            accent2: "#bb9af7", warn: "#e0af68", info: "#7dcfff"
        },
        rosepine: {
            base: "#191724", ink: "#e0def4", accent: "#ebbcba", text: "#e0def4", muted: "#6e6a86",
            bright: "#e0def4", line: "#908caa", good: "#9ccfd8", bad: "#eb6f92",
            accent2: "#c4a7e7", warn: "#f6c177", info: "#31748f"
        },
        dracula: {
            base: "#282a36", ink: "#f8f8f2", accent: "#bd93f9", text: "#f8f8f2", muted: "#6272a4",
            bright: "#ffffff", line: "#e2e2dc", good: "#50fa7b", bad: "#ff5555",
            accent2: "#ff79c6", warn: "#f1fa8c", info: "#8be9fd"
        },
        macchiato: {
            base: "#24273a", ink: "#cad3f5", accent: "#8aadf4", text: "#cad3f5", muted: "#6e738d",
            bright: "#cad3f5", line: "#b8c0e0", good: "#a6da95", bad: "#ed8796",
            accent2: "#c6a0f6", warn: "#eed49f", info: "#91d7e3"
        },
        everforest: {
            base: "#2d353b", ink: "#d3c6aa", accent: "#a7c080", text: "#d3c6aa", muted: "#859289",
            bright: "#e6dfc3", line: "#9da9a0", good: "#a7c080", bad: "#e67e80",
            accent2: "#d699b6", warn: "#dbbc7f", info: "#7fbbb3"
        },
        solarized: {
            base: "#002b36", ink: "#eee8d5", accent: "#268bd2", text: "#93a1a1", muted: "#586e75",
            bright: "#fdf6e3", line: "#839496", good: "#859900", bad: "#dc322f",
            accent2: "#d33682", warn: "#b58900", info: "#2aa198"
        },
        kanagawa: {
            base: "#1f1f28", ink: "#dcd7ba", accent: "#7e9cd8", text: "#dcd7ba", muted: "#727169",
            bright: "#e6e0c2", line: "#c8c093", good: "#98bb6c", bad: "#e82424",
            accent2: "#957fb8", warn: "#e6c384", info: "#7fb4ca"
        },
        onedark: {
            base: "#282c34", ink: "#abb2bf", accent: "#61afef", text: "#abb2bf", muted: "#5c6370",
            bright: "#e6e6e6", line: "#9da5b4", good: "#98c379", bad: "#e06c75",
            accent2: "#c678dd", warn: "#e5c07b", info: "#56b6c2"
        },
        caesar: {
            base: "#18211f", ink: "#ece3d0", accent: "#e0a63e", text: "#e6dcc6", muted: "#7d7a70",
            bright: "#f6efe0", line: "#c9bfa8", good: "#6fa592", bad: "#d9483b",
            accent2: "#d9603b", warn: "#e89a3c", info: "#6f93d6"
        },
        ayu: {
            base: "#1f2430", ink: "#cccac2", accent: "#ffcc66", text: "#cccac2", muted: "#707a8c",
            bright: "#f3f4f5", line: "#9aa5b8", good: "#87d96c", bad: "#f28779",
            accent2: "#dfbfff", warn: "#ffa759", info: "#73d0ff"
        },
        nightfox: {
            base: "#192330", ink: "#cdcecf", accent: "#719cd6", text: "#cdcecf", muted: "#738091",
            bright: "#dfdfe0", line: "#aeafb0", good: "#81b29a", bad: "#c94f6d",
            accent2: "#9d79d6", warn: "#dbc074", info: "#63cdcf"
        },
        palenight: {
            base: "#292d3e", ink: "#a6accd", accent: "#c792ea", text: "#a6accd", muted: "#676e95",
            bright: "#eeffff", line: "#959dcb", good: "#c3e88d", bad: "#f07178",
            accent2: "#82aaff", warn: "#ffcb6b", info: "#89ddff"
        },
        monokai: {
            base: "#272822", ink: "#f8f8f2", accent: "#a6e22e", text: "#f8f8f2", muted: "#75715e",
            bright: "#ffffff", line: "#cfcfc2", good: "#a6e22e", bad: "#f92672",
            accent2: "#ae81ff", warn: "#e6db74", info: "#66d9ef"
        }
    })
    readonly property var pal: palettes[name]

    // base palette (animated, so switching crossfades)
    property color base: pal.base
    property color ink: pal.ink
    property color accent: pal.accent
    property color text: pal.text
    property color muted: pal.muted
    property color bright: pal.bright
    property color line: pal.line
    property color good: pal.good
    property color bad: pal.bad
    property color accent2: pal.accent2
    property color warn: pal.warn
    property color info: pal.info
    Behavior on base { ColorAnimation { duration: 250 } }
    Behavior on ink { ColorAnimation { duration: 250 } }
    Behavior on accent { ColorAnimation { duration: 250 } }
    Behavior on text { ColorAnimation { duration: 250 } }
    Behavior on muted { ColorAnimation { duration: 250 } }
    Behavior on bright { ColorAnimation { duration: 250 } }
    Behavior on line { ColorAnimation { duration: 250 } }
    Behavior on good { ColorAnimation { duration: 250 } }
    Behavior on bad { ColorAnimation { duration: 250 } }
    Behavior on accent2 { ColorAnimation { duration: 250 } }
    Behavior on warn { ColorAnimation { duration: 250 } }
    Behavior on info { ColorAnimation { duration: 250 } }

    // ---- everything below is derived from the palette ----

    // base nudged toward the accent, so every surface carries a faint hue
    // instead of being flat black/grey
    readonly property color tinted: Qt.tint(base, Qt.alpha(accent, 0.07))
    readonly property color tintedDeep: Qt.tint(base, Qt.alpha(accent, 0.14))

    // bar / popups
    readonly property color panel: Qt.alpha(tinted, 0.68)
    readonly property color panelHover: Qt.alpha(tintedDeep, 0.85)
    readonly property color popup: Qt.alpha(tinted, 0.94)
    readonly property color border: Qt.alpha(accent, 0.25)
    readonly property color borderHover: Qt.alpha(accent, 0.70)

    readonly property color drawer: Qt.alpha(tinted, 0.88)
    readonly property color row: Qt.alpha(accent, 0.07)
    readonly property color rowHover: Qt.alpha(accent, 0.16)
    readonly property color track: Qt.alpha(accent, 0.18)
    readonly property color fill: accent          // slider / progress fill
    readonly property color select: accent        // solid coloured highlight
    readonly property color selectSoft: Qt.alpha(accent, 0.22)

    readonly property color selectFg: base
    readonly property color accentFg: base

    readonly property color btnHover: Qt.alpha(accent, 0.14)
    readonly property color btnActive: Qt.alpha(accent, 0.28)
    readonly property color trayHover: Qt.alpha(accent2, 0.20)

    // workspace dots
    readonly property color dotActive: accent
    readonly property color dotOccupied: Qt.alpha(accent2, 0.65)
    readonly property color dotHover: Qt.alpha(accent, 0.85)
    readonly property color dotEmpty: Qt.alpha(ink, 0.20)

    // status colours (battery, volume mute, network, etc.)
    readonly property color statusGood: good
    readonly property color statusWarn: warn
    readonly property color statusBad: bad
    readonly property color statusInfo: info

    // fullscreen overlays (launcher, wallpaper picker)
    readonly property color overlay: Qt.alpha(tinted, 0.92)
    readonly property color scrim: Qt.alpha(base, 0.60)
    readonly property color disk: Qt.alpha(tintedDeep, 0.88)
    readonly property color lineSoft: Qt.alpha(line, 0.80)
    readonly property color lineDim: Qt.alpha(line, 0.60)
    readonly property color lineFaint: Qt.alpha(line, 0.33)
    readonly property color selection: Qt.alpha(accent, 0.33)
    readonly property color glow: Qt.alpha(accent, 0.35)   // for shadows / focus rings

    function fade(c) { return Qt.rgba(c.r, c.g, c.b, 0) }
}
