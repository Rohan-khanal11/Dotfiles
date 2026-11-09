import "../theme"
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

PanelWindow {
    id: win
    property real islandWidth: 400
    property bool open: true
    default property alias content: body.data
    signal dismissed()
    signal closed()

    readonly property int r: 18
    readonly property int pad: 14

    property real p: 0
    NumberAnimation { id: anim; target: win; property: "p"; running: true; to: 1; duration: 340; easing.type: Easing.OutQuint }
    onOpenChanged: {
        anim.stop()
        anim.to = open ? 1 : 0
        anim.duration = open ? 340 : 220
        anim.easing.type = open ? Easing.OutQuint : Easing.InCubic
        anim.start()
    }
    Connections { target: anim; function onFinished() { if (win.p === 0) win.closed() } }

    property real h: body.implicitHeight + pad * 2
    Behavior on h { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }

    anchors { top: true; right: true }
    margins.top: 36
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qsdrawer"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    color: "transparent"
    implicitWidth: Math.round(islandWidth)
    implicitHeight: Math.round(h)

    HyprlandFocusGrab { windows: [win]; active: win.open; onCleared: win.dismissed() }

    Item {
        anchors.fill: parent
        clip: true
        focus: true
        enabled: win.open
        Keys.onEscapePressed: win.dismissed()

        Rectangle {
            width: parent.width + win.r
            height: parent.height + win.r
            radius: win.r
            color: Theme.drawer
            border.color: Theme.borderHover
            y: -win.r - (height - win.r) * (1 - win.p)

            Column {
                id: body
                x: win.pad
                y: win.r + win.pad
                width: win.width - win.pad * 2
                spacing: 8
                opacity: Math.max(0, Math.min(1, (win.p - 0.3) / 0.7))
            }
        }
    }
}
