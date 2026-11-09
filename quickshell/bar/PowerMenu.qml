import "../theme"
import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Fullscreen power overlay: dimmed backdrop, big clock, round action buttons.
PanelWindow {
    id: win
    property bool open: true
    signal dismissed()
    signal closed()

    readonly property int d: 84
    readonly property var entries: [
        { icon: "󰐥", label: "Shutdown", cmd: ["systemctl", "poweroff"], danger: true },
        { icon: "󰜉", label: "Reboot",   cmd: ["systemctl", "reboot"],   danger: true },
        { icon: "󰒲", label: "Sleep",    cmd: ["systemctl", "suspend"],  danger: false },
        { icon: "󰍃", label: "Log Out",  cmd: ["hyprlock"],              danger: false }
    ]
    property int cur: 0
    property bool armed: false
    property int moves: 0
    Timer { interval: 400; running: true; onTriggered: win.armed = true }

    property real p: 0
    NumberAnimation { id: anim; target: win; property: "p" }
    function go() {
        anim.stop()
        anim.to = open ? 1 : 0
        anim.duration = open ? 360 : 200
        anim.easing.type = open ? Easing.OutCubic : Easing.InCubic
        anim.start()
    }
    onOpenChanged: go()
    Component.onCompleted: go()
    Connections { target: anim; function onFinished() { if (win.p === 0) win.closed() } }

    function step(dir) { cur = (cur + dir + entries.length) % entries.length }
    function run(i) {
        if (!armed || !open || i < 0 || i >= entries.length) return
        Quickshell.execDetached(entries[i].cmd)
        dismissed()
    }

    anchors { left: true; right: true; top: true; bottom: true }
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "qspower"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
    color: "transparent"

    HyprlandFocusGrab { windows: [win]; active: win.open; onCleared: win.dismissed() }

    SystemClock { id: clock; precision: SystemClock.Seconds }

    Item {
        anchors.fill: parent
        focus: true
        enabled: win.open
        Keys.onEscapePressed: win.dismissed()
        Keys.onTabPressed:     win.step(1)
        Keys.onBacktabPressed: win.step(-1)
        Keys.onRightPressed:   win.step(1)
        Keys.onLeftPressed:    win.step(-1)
        Keys.onPressed: e => {
            if (e.key === Qt.Key_L) win.step(1)
            else if (e.key === Qt.Key_H) win.step(-1)
            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter || e.key === Qt.Key_Space) win.run(win.cur)
        }

        // backdrop (click empty space to dismiss)
        Rectangle { anchors.fill: parent; color: "black"; opacity: 0.6 * win.p }
        MouseArea { anchors.fill: parent; onClicked: if (win.armed) win.dismissed() }

        Column {
            anchors.centerIn: parent
            spacing: 56

            // clock block
            Column {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 6
                opacity: win.p
                y: 0
                transform: Translate { y: (1 - win.p) * -16 }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "h:mm:ss AP")
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 110
                    font.weight: Font.Light
                }
                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: Qt.formatDateTime(clock.date, "dddd, d MMMM")
                    color: Theme.text
                    opacity: 0.7
                    font.family: Theme.font
                    font.pixelSize: 18
                }
            }

            // round buttons
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: 28

                Repeater {
                    model: win.entries
                    Item {
                        id: item
                        required property var modelData
                        required property int index
                        readonly property bool selected: win.cur === index
                        width: win.d
                        height: win.d + 34
                        opacity: Math.max(0, Math.min(1, win.p * 2.2 - index * 0.2))
                        transform: Translate { y: (1 - win.p) * 24 }

                        Rectangle {
                            id: disc
                            width: win.d; height: win.d
                            radius: width / 2
                            color: item.selected
                            ? (item.modelData.danger ? "#e5484d" : Theme.select)
                            : Qt.rgba(1, 1, 1, 0.06)
                            border.color: item.selected ? "transparent" : Theme.borderHover
                            border.width: 1
                            scale: item.selected ? 1.1 : 1
                            Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }
                            Behavior on color { ColorAnimation { duration: 160 } }

                            Text {
                                anchors.centerIn: parent
                                text: item.modelData.icon
                                color: item.selected
                                ? (item.modelData.danger ? "white" : Theme.selectFg)
                                : Theme.text
                                font.family: Theme.font
                                font.pixelSize: 32
                                Behavior on color { ColorAnimation { duration: 140 } }
                            }
                        }

                        Text {
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: win.d + 14
                            text: item.modelData.label
                            color: Theme.text
                            font.family: Theme.font
                            font.pixelSize: 13
                            opacity: item.selected ? 1 : 0
                            Behavior on opacity { NumberAnimation { duration: 140 } }
                        }

                        MouseArea {
                            anchors.fill: disc
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
