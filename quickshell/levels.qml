import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Pipewire
import "./theme"

// Brightness + volume panel. Standalone: only needs the shared ./theme folder (Theme.qml + qmldir).
// On demand: the process starts open and exits when the panel closes.
// Toggle: qs ipc -p <this file> call levels toggle || qs -d -p <this file>
// OSD style (auto-hides): LEVELS_OSD=1 qs -d -p <this file>
ShellRoot {
    id: root
    property bool open: true
    property bool isOsd: Quickshell.env("LEVELS_OSD") === "1"   // no focus grab, hides itself

    Component.onCompleted: if (isOsd) hideTimer.start()

    onOpenChanged: if (!open) isOsd = false

    // show the panel briefly (OSD) without changing anything
    function flash() {
        if (!open) { isOsd = true; open = true }
        if (isOsd) hideTimer.restart()
    }
    Timer {
        id: hideTimer
        interval: 1800
        onTriggered: if (root.isOsd) root.open = false
    }

    // ---- brightness (brightnessctl) ----
    property real brightness: 0
    property bool hasBacklight: false
    property double brightSetAt: 0
    property real brightPending: -1
    property real stepAfterRead: 0

    // relative step; reads the real value first when the panel is closed
    function stepBrightness(d) {
        if (open && hasBacklight) { setBrightness(brightness + d); flash(); return }
        stepAfterRead = d
        if (!brightRead.running) brightRead.running = true
        flash()
    }

    function setBrightness(v) {
        v = Math.max(0.01, Math.min(1, v))
        brightness = v
        brightSetAt = Date.now()
        brightPending = v
        if (!brightApply.running) brightApply.start()
    }
    Timer {
        id: brightApply
        interval: 60
        onTriggered: {
            if (root.brightPending < 0) return
            Quickshell.execDetached(["brightnessctl", "-q", "-e4", "-n2", "-c", "backlight", "set", Math.round(root.brightPending * 100) + "%"])
            root.brightPending = -1
        }
    }
    Process {
        id: brightRead
        command: ["brightnessctl", "-m", "-e4", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split(",")
                if (f.length < 5) { root.hasBacklight = false; root.stepAfterRead = 0; return }
                root.hasBacklight = true
                if (Date.now() - root.brightSetAt > 1000) root.brightness = parseInt(f[3]) / 100
                if (root.stepAfterRead !== 0) {
                    const d = root.stepAfterRead
                    root.stepAfterRead = 0
                    root.setBrightness(root.brightness + d)
                }
            }
        }
    }
    Timer {
        interval: 1000
        running: root.open
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!brightRead.running) brightRead.running = true
    }

    // ---- volume (Pipewire default sink) ----
    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var aud: sink ? sink.audio : null
    readonly property real vol: aud ? aud.volume : 0
    readonly property bool muted: aud ? aud.muted : false
    PwObjectTracker { objects: [root.sink] }

    function volumeStep(d) {
        if (!aud) return
        aud.muted = false
        aud.volume = Math.max(0, Math.min(1, aud.volume + d))
        flash()
    }
    function volumeMute() {
        if (!aud) return
        aud.muted = !aud.muted
        flash()
    }

    function volIcon() {
        const p = Math.round(vol * 100)
        return muted ? "󰖁" : p < 33 ? "󰕿" : p < 66 ? "󰖀" : "󰕾"
    }
    function brightIcon() { return brightness < 0.34 ? "󰃞" : brightness < 0.67 ? "󰃟" : "󰃠" }

    IpcHandler {
        target: "levels"
        function toggle(): void { root.open = !root.open }
        function show(): void { root.open = true }
        function hide(): void { root.open = false }
        function flash(): void { root.flash() }
        function volumeUp(): void { root.volumeStep(0.05) }
        function volumeDown(): void { root.volumeStep(-0.05) }
        function volumeMute(): void { root.volumeMute() }
        function brightnessUp(): void { root.stepBrightness(0.05) }
        function brightnessDown(): void { root.stepBrightness(-0.05) }
    }

    // ---- components ----
    component VSlider: Item {
        id: s
        property real value: 0
        property bool dim: false
        signal moved(real v)

        implicitWidth: 30
        implicitHeight: 150

        readonly property real v: Math.max(0, Math.min(1, value))
        property real shown: v
        Behavior on shown { enabled: !ma.pressed; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

        function emit(x) { moved(Math.max(0, Math.min(1, x))) }

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            color: Theme.track
            border.width: 1
            border.color: ma.containsMouse || ma.pressed ? Theme.borderHover : "transparent"
            Behavior on border.color { ColorAnimation { duration: 140 } }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: s.shown * parent.height
                radius: width / 2
                color: s.dim ? Theme.muted : Theme.accent
            }
        }

        MouseArea {
            id: ma
            anchors.fill: parent
            hoverEnabled: true
            onPressed: m => s.emit(1 - m.y / s.height)
            onPositionChanged: m => { if (pressed) s.emit(1 - m.y / s.height) }
            onWheel: w => s.emit(s.v + (w.angleDelta.y > 0 ? 0.05 : -0.05))
        }
    }

    component Lane: Column {
        id: ln
        property real value: 0
        property string icon: ""
        property bool dim: false
        signal moved(real v)
        signal iconClicked()
        spacing: 10

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Math.round(ln.value * 100) + "%"
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 11
        }

        VSlider {
            anchors.horizontalCenter: parent.horizontalCenter
            value: ln.value
            dim: ln.dim
            onMoved: v => ln.moved(v)
        }

        Rectangle {
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32; height: 32; radius: 16
            color: ima.containsMouse ? Theme.btnHover : Theme.fade(Theme.btnHover)
            Behavior on color { ColorAnimation { duration: 140 } }
            Text {
                anchors.centerIn: parent
                text: ln.icon
                color: ln.dim ? Theme.muted : Theme.text
                font.family: Theme.font
                font.pixelSize: 16
            }
            MouseArea {
                id: ima
                anchors.fill: parent
                hoverEnabled: true
                onClicked: ln.iconClicked()
            }
        }
    }

    // ---- window ----
    PanelWindow {
        id: win
        property bool shown: false
        Component.onCompleted: shown = true
        property real p: root.open && shown ? 1 : 0
        onPChanged: if (shown && p === 0 && !root.open) Qt.quit()
        Behavior on p { NumberAnimation { duration: root.open ? 260 : 160; easing.type: root.open ? Easing.OutCubic : Easing.InCubic } }

        visible: root.open || p > 0
        anchors.right: true     // right edge only: the compositor centers it vertically
        margins.right: 8
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "qslevels"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.OnDemand
        color: "transparent"
        implicitWidth: Math.max(row.implicitWidth, 96) + 44
        implicitHeight: row.implicitHeight + 44

        HyprlandFocusGrab { windows: [win]; active: root.open && !root.isOsd; onCleared: root.open = false }

        Item {
            anchors.fill: parent
            focus: true
            Keys.onEscapePressed: root.open = false
            opacity: win.p
            scale: 0.95 + 0.05 * win.p
            transformOrigin: Item.Right

            Rectangle {
                anchors.fill: parent
                radius: 18
                color: Theme.drawer
                border.color: Theme.borderHover
                border.width: 1
            }

            Row {
                id: row
                anchors.centerIn: parent
                spacing: 40

                Lane {
                    visible: root.hasBacklight
                    value: root.brightness
                    icon: root.brightIcon()
                    onMoved: v => { root.isOsd = false; root.setBrightness(v) }
                }

                Lane {
                    value: root.vol
                    dim: root.muted
                    icon: root.volIcon()
                    onMoved: v => { root.isOsd = false; if (root.aud) { root.aud.muted = false; root.aud.volume = v } }
                    onIconClicked: { root.isOsd = false; if (root.aud) root.aud.muted = !root.aud.muted }
                }
            }
        }
    }
}
