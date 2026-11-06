pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string font: "Iosevka Nerd Font"

    // base palette: edit these to re-theme everything
    readonly property color base: "#000000"   // surfaces and text drawn on accent
    readonly property color ink: "#ffffff"    // overlays, hovers, borders
    readonly property color accent: "#ffffff"
    readonly property color text: "#d0d0d0"
    readonly property color muted: "#6e6e6e"
    readonly property color bright: "#f2f2f2" // launcher foreground
    readonly property color line: "#e8e8e8"   // launcher strokes
    readonly property color good: accent
    readonly property color bad: accent

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
