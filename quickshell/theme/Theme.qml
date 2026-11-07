pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Theme names, in cycling order (the qs-theme script reads this line):
// @themes: mono catppuccin gruvbox nord tokyonight rosepine dracula
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
    // base: surfaces and text drawn on accent    ink: hover/border overlays
    readonly property var palettes: ({
        mono: {
            base: "#000000", ink: "#ffffff", accent: "#ffffff", text: "#d0d0d0", muted: "#6e6e6e",
            bright: "#f2f2f2", line: "#e8e8e8", good: "#ffffff", bad: "#ffffff"
        },
        catppuccin: {
            base: "#1e1e2e", ink: "#cdd6f4", accent: "#89b4fa", text: "#cdd6f4", muted: "#6c7086",
            bright: "#cdd6f4", line: "#bac2de", good: "#a6e3a1", bad: "#f38ba8"
        },
        gruvbox: {
            base: "#282828", ink: "#ebdbb2", accent: "#fabd2f", text: "#ebdbb2", muted: "#928374",
            bright: "#fbf1c7", line: "#d5c4a1", good: "#b8bb26", bad: "#fb4934"
        },
        nord: {
            base: "#2e3440", ink: "#eceff4", accent: "#88c0d0", text: "#d8dee9", muted: "#7b88a1",
            bright: "#eceff4", line: "#d8dee9", good: "#a3be8c", bad: "#bf616a"
        },
        tokyonight: {
            base: "#1a1b26", ink: "#c0caf5", accent: "#7aa2f7", text: "#c0caf5", muted: "#565f89",
            bright: "#c0caf5", line: "#a9b1d6", good: "#9ece6a", bad: "#f7768e"
        },
        rosepine: {
            base: "#191724", ink: "#e0def4", accent: "#ebbcba", text: "#e0def4", muted: "#6e6a86",
            bright: "#e0def4", line: "#908caa", good: "#9ccfd8", bad: "#eb6f92"
        },
        dracula: {
            base: "#282a36", ink: "#f8f8f2", accent: "#bd93f9", text: "#f8f8f2", muted: "#6272a4",
            bright: "#ffffff", line: "#e2e2dc", good: "#50fa7b", bad: "#ff5555"
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
    Behavior on base { ColorAnimation { duration: 250 } }
    Behavior on ink { ColorAnimation { duration: 250 } }
    Behavior on accent { ColorAnimation { duration: 250 } }
    Behavior on text { ColorAnimation { duration: 250 } }
    Behavior on muted { ColorAnimation { duration: 250 } }
    Behavior on bright { ColorAnimation { duration: 250 } }
    Behavior on line { ColorAnimation { duration: 250 } }
    Behavior on good { ColorAnimation { duration: 250 } }
    Behavior on bad { ColorAnimation { duration: 250 } }

    // ---- everything below is derived from the palette ----

    // bar / popups
    readonly property color panel: Qt.alpha(base, 0.65)
    readonly property color panelHover: Qt.alpha(base, 0.82)
    readonly property color popup: Qt.alpha(base, 0.92)
    readonly property color border: Qt.alpha(ink, 0.16)
    readonly property color borderHover: Qt.alpha(ink, 0.40)

    readonly property color drawer: Qt.alpha(base, 0.86)
    readonly property color row: Qt.alpha(ink, 0.06)
    readonly property color rowHover: Qt.alpha(ink, 0.12)
    readonly property color track: border
    readonly property color select: Qt.alpha(ink, 0.90)

    readonly property color selectFg: base
    readonly property color accentFg: base

    readonly property color btnHover: Qt.alpha(ink, 0.10)
    readonly property color btnActive: Qt.alpha(ink, 0.20)
    readonly property color trayHover: Qt.alpha(ink, 0.14)

    readonly property color dotActive: accent
    readonly property color dotOccupied: Qt.alpha(ink, 0.55)
    readonly property color dotHover: Qt.alpha(ink, 0.80)
    readonly property color dotEmpty: Qt.alpha(ink, 0.20)

    // fullscreen overlays (launcher, wallpaper picker)
    readonly property color overlay: Qt.alpha(base, 0.90)
    readonly property color scrim: Qt.alpha(base, 0.60)
    readonly property color disk: Qt.alpha(base, 0.85)
    readonly property color lineSoft: Qt.alpha(line, 0.80)
    readonly property color lineDim: Qt.alpha(line, 0.60)
    readonly property color lineFaint: Qt.alpha(line, 0.33)
    readonly property color selection: Qt.alpha(accent, 0.33)

    function fade(c) { return Qt.rgba(c.r, c.g, c.b, 0) }
}
