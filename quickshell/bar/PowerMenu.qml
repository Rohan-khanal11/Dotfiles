import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Power menu: slides out of the LEFT screen edge, vertically centred.
// Opened from the arch logo in shell.qml.
// open: false -> slides back in, then emits closed().
PanelWindow {
    id: win
    property bool open: true
    signal dismissed()
    signal closed()

    readonly property int r: 18
    readonly property var entries: [
        { icon: "󰐥", label: "Shutdown", cmd: ["systemctl", "poweroff"] },
        { icon: "󰜉", label: "Reboot", cmd: ["systemctl", "reboot"] },
        { icon: "󰒲", label: "Sleep", cmd: ["systemctl", "suspend"] }
    ]
    property int cur: 0           // Shutdown selected by default
    property bool armed: false    // ignore input for a moment after opening
    property int moves: 0         // mouse clicks only count after the pointer really moved over the menu
    Timer { interval: 400; running: true; onTriggered: win.armed = true }

    // ---- open / close progress: 0 = hidden past the left edge, 1 = fully out ----
    property real p: 0
    NumberAnimation { id: anim; target: win; property: "p" }
    function go() {
        anim.stop()
        anim.to = open ? 1 : 0
        anim.duration = open ? 340 : 220
        anim.easing.type = open ? Easing.OutQuint : Easing.InCubic
        anim.start()
    }
    onOpenChanged: go()
    Component.onCompleted: go()
    Connections { target: anim; function onFinished() { if (win.p === 0) win.closed() } }

    function step(d) {
        const n = entries.length
        cur = cur < 0 ? (d > 0 ? 0 : n - 1) : (cur + d + n) % n
    }

    function run(i) {
        if (!armed || !open || i < 0) return
        Quickshell.execDetached(entries[i].cmd)
        dismissed()
    }

    // pinned to the left edge, vertically centred by an explicit top margin
    // (so it can never sit on top of the bar / arch logo)
    anchors { left: true; top: true }
    margins.top: Math.max(60, Math.round(((screen ? screen.height : 1080) - implicitHeight) / 2))
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qspower"
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    color: "transparent"
    implicitWidth: 200
    implicitHeight: col.implicitHeight + 28

    HyprlandFocusGrab { windows: [win]; active: win.open; onCleared: win.dismissed() }

    Item {
        anchors.fill: parent
        clip: true
        focus: true
        enabled: win.open
        Keys.onEscapePressed: win.dismissed()
        Keys.onTabPressed:     win.step(1)
        Keys.onBacktabPressed: win.step(-1)
        Keys.onDownPressed:    win.step(1)
        Keys.onUpPressed:      win.step(-1)
        Keys.onPressed: e => {
            if (e.key === Qt.Key_J) win.step(1)
            else if (e.key === Qt.Key_K) win.step(-1)
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space) win.run(win.cur)
        }

        // same look as an island: flush with the screen edge, rounded on the inside
        Rectangle {
            id: sheet
            y: 0
            width: parent.width + win.r
            height: parent.height
            radius: win.r
            color: Theme.drawer
            border.color: Theme.borderHover
            border.width: 1
            x: -win.r - (width - win.r) * (1 - win.p)

            // ONE highlight that glides between rows (instead of two rows cross-fading)
            Rectangle {
                id: hl
                visible: win.cur >= 0
                x: col.x
                y: col.y + win.cur * (38 + col.spacing)
                width: col.width
                height: 38
                radius: 8
                color: Theme.select
                opacity: Math.min(1, win.p * 2)
                Behavior on y { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
            }

            Column {
                id: col
                x: win.r + 14      // sheet is shifted left by r, so skip that part
                y: 14
                width: win.implicitWidth - 28
                spacing: 4

                Repeater {
                    model: win.entries
                    Item {
                        id: item
                        required property var modelData
                        required property int index
                        readonly property bool selected: win.cur === index
                        // rows fade in one after another
                        opacity: Math.max(0, Math.min(1, win.p * 2.2 - index * 0.18))
                        width: col.width
                        height: 38

                        Text {
                            x: 14
                            anchors.verticalCenter: parent.verticalCenter
                            text: item.modelData.icon
                            color: item.selected ? Theme.selectFg : Theme.text
                            font.family: Theme.font
                            font.pixelSize: 16
                            Behavior on color { ColorAnimation { duration: 140 } }
                        }
                        Text {
                            x: 44
                            anchors.verticalCenter: parent.verticalCenter
                            text: item.modelData.label
                            color: item.selected ? Theme.selectFg : Theme.text
                            font.family: Theme.font
                            font.pixelSize: 14
                            Behavior on color { ColorAnimation { duration: 140 } }
                        }
                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            acceptedButtons: Qt.LeftButton
                            onEntered: win.cur = item.index
                            onPositionChanged: win.moves++
                            onClicked: if (win.moves > 3) win.run(item.index)
                        }
                    }
                }
            }
        }
    }
}
