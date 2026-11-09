import "./bar"
import "./theme"
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import Quickshell.Services.SystemTray
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower

ShellRoot {
    id: root

    property bool showDate: false
    property bool trayOpen: false
    property string wifiSsid: ""
    property int wifiSignal: 0
    property bool wifiOn: true
    property bool vpnOn: false
    property var wifiList: []
    property bool wifiScanning: false
    property string wifiBusy: ""
    property string wifiError: ""
    property bool wifiConnectNew: false
    property string soundTab: "sound"
    readonly property var terminal: ["ghostty"]

    property real ramUsed: 0

    property string pop: ""
    property string lastClosed: ""
    property double lastClosedAt: 0

    function toggle(n) {
        if (pop === n) { pop = ""; return }
        if (lastClosed === n && Date.now() - lastClosedAt < 250) return
        pop = n
    }
    function openSound(tab) {
        if (pop !== "sound") soundTab = tab
        toggle("sound")
    }
    function dismiss() {
        if (pop !== "") { lastClosed = pop; lastClosedAt = Date.now(); pop = "" }
    }
    onPopChanged: if (pop === "wifi" && !wifiScan.running) wifiScan.running = true

    function sigIcon(s) { return s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟" }

    PwObjectTracker { objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource] }
    SystemClock { id: clock; precision: SystemClock.Seconds }

    Process {
        id: wifiScan
        command: ["sh", "-c", "nmcli radio wifi; nmcli -t -f TYPE connection show --active | grep -qxE 'vpn|wireguard' && echo vpn || echo novpn; nmcli -t -f NAME,TYPE connection show; echo '=='; nmcli -t -f IN-USE,SIGNAL,SECURITY,SSID dev wifi list"]
        onRunningChanged: root.wifiScanning = running
        stdout: StdioCollector {
            onStreamFinished: {
                const unesc = x => x.replace(/\\(.)/g, "$1")
                const lines = text.split("\n")
                root.wifiOn = lines[0].trim() === "enabled"
                root.vpnOn = lines[1].trim() === "vpn"
                const mid = lines.indexOf("==")
                const saved = {}
                for (const l of lines.slice(2, mid < 0 ? 2 : mid)) {
                    const m = l.match(/^(.*):(wifi|802-11-wireless)$/)
                    if (m) saved[unesc(m[1])] = true
                }
                const seen = {}, out = []
                for (const l of (mid < 0 ? [] : lines.slice(mid + 1))) {
                    const m = l.match(/^([* ]):(\d+):([^:]*):(.+)$/)
                    if (!m) continue
                    const name = unesc(m[4])
                    if (seen[name]) continue
                    seen[name] = 1
                    out.push({
                        ssid: name, signal: +m[2], active: m[1] === "*",
                        secure: m[3] !== "" && m[3] !== "--", security: m[3],
                        saved: !!saved[name]
                    })
                }
                out.sort((a, b) => (b.active - a.active) || (b.signal - a.signal))
                root.wifiList = out
                const a = out.find(x => x.active)
                root.wifiSsid = a ? a.ssid : ""
                root.wifiSignal = a ? a.signal : 0
            }
        }
    }
    Process {
        id: wifiRescan
        command: ["nmcli", "dev", "wifi", "rescan"]
        onExited: wifiScan.running = true
    }
    Process {
        id: wifiConnect
        onExited: code => {
            if (code !== 0) {
                root.wifiError = root.wifiBusy
                if (root.wifiConnectNew) Quickshell.execDetached(["nmcli", "connection", "delete", "id", root.wifiBusy])
            }
            root.wifiBusy = ""
            wifiScan.running = true
        }
    }
    Timer { id: wifiRefresh; interval: 1500; onTriggered: wifiScan.running = true }
    function wifiConnectTo(name, pw) {
        if (wifiConnect.running) return
        wifiError = ""
        wifiBusy = name
        wifiConnectNew = pw !== ""
        wifiConnect.command = ["nmcli", "dev", "wifi", "connect", name].concat(pw !== "" ? ["password", pw] : [])
        wifiConnect.running = true
    }
    Timer {
        interval: 10000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: if (!wifiScan.running) wifiScan.running = true
    }

    FileView {
        id: mem
        path: "/proc/meminfo"
        onLoaded: {
            const t = text()
            const tot = t.match(/MemTotal:\s+(\d+)/), av = t.match(/MemAvailable:\s+(\d+)/)
            if (tot && av) root.ramUsed = +tot[1] - +av[1]
        }
    }
    Timer {
        interval: 3000; running: true; repeat: true; triggeredOnStart: true
        onTriggered: mem.reload()
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: bar
            required property var modelData
            screen: modelData
            anchors { top: true; left: true; right: true }
            implicitHeight: 38
            color: "transparent"
            WlrLayershell.namespace: "qsbar"

            Island {
                x: 0
                clipLeft: true
                pad: 6

                Btn {
                    text: "󰣇"; fg: Theme.accent
                    active: root.pop === "power"
                    onClicked: if (root.pop !== "power") root.toggle("power")
                }

                Row {
                    Repeater {
                        model: 10
                        Item {
                            id: d
                            required property int index
                            readonly property int wsId: index + 1
                            readonly property bool active: Hyprland.focusedWorkspace?.id === wsId
                            readonly property bool occupied: Hyprland.workspaces.values.some(w => w.id === wsId)
                            width: (active ? 26 : occupied ? 12 : 8) + 8
                            height: 26
                            Behavior on width { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

                            Rectangle {
                                anchors.centerIn: parent
                                width: parent.width - 8
                                height: wsMa.pressed ? 6 : 8
                                radius: 4
                                scale: wsMa.containsMouse && !d.active ? 1.5 : 1
                                color: d.active ? Theme.dotActive
                                : wsMa.containsMouse ? Theme.dotHover
                                : d.occupied ? Theme.dotOccupied
                                : Theme.dotEmpty
                                Behavior on color { ColorAnimation { duration: 150 } }
                            }
                            MouseArea {
                                id: wsMa
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: Hyprland.dispatch("workspace " + d.wsId)
                            }
                        }
                    }
                    WheelHandler {
                        onWheel: e => Hyprland.dispatch("workspace " + (e.angleDelta.y > 0 ? "e-1" : "e+1"))
                    }
                }
            }

            Island {
                anchors.horizontalCenter: parent.horizontalCenter
                pad: 6
                Btn {
                    text: Qt.formatDateTime(clock.date, root.showDate ? "dddd, MMMM d" : "hh:mm:ss AP")
                    onClicked: root.showDate = !root.showDate
                }
            }

            Island {
                id: rightIsl
                anchors.right: parent.right
                clipRight: true
                pad: 6
                joined: root.pop === "sound" || root.pop === "wifi" || soundLL.keep || wifiLL.keep

                Btn {
                    visible: SystemTray.items.values.length > 0
                    text: root.trayOpen ? "" : ""
                    onClicked: root.trayOpen = !root.trayOpen
                }

                Item {
                    visible: SystemTray.items.values.length > 0 && (root.trayOpen || width > 0)
                    height: 26
                    clip: true
                    width: root.trayOpen ? trayRow.implicitWidth : 0
                    opacity: root.trayOpen ? 1 : 0
                    Behavior on width { NumberAnimation { duration: 280; easing.type: Easing.OutCubic } }
                    Behavior on opacity { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

                    Row {
                        id: trayRow
                        spacing: 2
                        height: 26

                        Repeater {
                            model: SystemTray.items
                            Item {
                                id: ti
                                required property var modelData
                                width: 26; height: 26
                                scale: tma.pressed ? 0.88 : tma.containsMouse ? 1.12 : 1

                                Rectangle {
                                    anchors.fill: parent
                                    radius: 13
                                    color: tma.containsMouse ? Theme.trayHover : Theme.fade(Theme.trayHover)
                                }
                                IconImage {
                                    anchors.centerIn: parent
                                    width: 16; height: 16
                                    source: ti.modelData.icon
                                }
                                QsMenuAnchor {
                                    id: tmenu
                                    menu: ti.modelData.menu
                                    anchor.item: ti
                                    anchor.edges: Edges.Bottom
                                    anchor.gravity: Edges.Bottom
                                }
                                MouseArea {
                                    id: tma
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                                    onClicked: mouse => {
                                        if (mouse.button === Qt.LeftButton && !ti.modelData.onlyMenu) ti.modelData.activate()
                                        else if (mouse.button === Qt.MiddleButton) ti.modelData.secondaryActivate()
                                        else if (ti.modelData.hasMenu) tmenu.open()
                                    }
                                }
                            }
                        }
                    }
                }

                Btn {
                    text: "  " + (root.ramUsed / 1048576).toFixed(1) + "G"
                    onClicked: Quickshell.execDetached(root.terminal.concat(["-e", "htop"]))
                }

                Btn {
                    property var a: Pipewire.defaultAudioSink?.audio
                    property int pct: Math.round((a?.volume ?? 0) * 100)
                    text: (a?.muted ? "󰖁" : pct < 33 ? "󰕿" : pct < 66 ? "󰖀" : "󰕾") + " " + pct + "%"
                    active: root.pop === "sound" && root.soundTab === "sound"
                    onClicked: root.openSound("sound")
                    onMiddleClicked: if (a) a.muted = !a.muted
                    onScrolled: dir => { if (a) a.volume = Math.max(0, Math.min(1, a.volume + dir * 0.05)) }
                }

                Btn {
                    visible: root.vpnOn
                    text: "󰌾"
                    fg: Theme.good
                }

                Btn {
                    text: !root.wifiOn ? "󰤮"
                    : !root.wifiSsid ? "󰤯"
                    : root.sigIcon(root.wifiSignal) + " " + (root.wifiSsid.length > 14 ? root.wifiSsid.slice(0, 13) + "…" : root.wifiSsid)
                    fg: root.wifiOn ? Theme.text : Theme.muted
                    active: root.pop === "wifi"
                    onClicked: root.toggle("wifi")
                }

                Btn {
                    property var b: UPower.displayDevice
                    property bool chg: b.state === UPowerDeviceState.Charging || b.state === UPowerDeviceState.FullyCharged
                    readonly property var icons: ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"]
                    visible: b.ready && b.isPresent
                    text: (chg ? "󰂄" : icons[Math.min(9, Math.floor(b.percentage * 10))]) + " " + Math.round(b.percentage * 100) + "%"
                    fg: chg ? Theme.good : b.percentage < 0.2 ? Theme.bad : Theme.text
                }
            }

            LazyLoader {
                id: powerLL
                property bool want: root.pop === "power"
                property bool keep: false
                onWantChanged: if (want) keep = true
                active: want || keep
                PowerMenu {
                    screen: bar.screen
                    open: powerLL.want
                    onDismissed: root.dismiss()
                    onClosed: Qt.callLater(() => powerLL.keep = false)
                }
            }

            LazyLoader {
                id: soundLL
                property bool want: root.pop === "sound"
                property bool keep: false
                onWantChanged: if (want) keep = true
                active: want || keep
                SoundPanel {
                    screen: bar.screen
                    open: soundLL.want
                    islandWidth: rightIsl.width
                    tab: root.soundTab
                    onDismissed: root.dismiss()
                    onClosed: Qt.callLater(() => soundLL.keep = false)
                }
            }

            LazyLoader {
                id: wifiLL
                property bool want: root.pop === "wifi"
                property bool keep: false
                onWantChanged: if (want) keep = true
                active: want || keep
                WifiPanel {
                    screen: bar.screen
                    open: wifiLL.want
                    islandWidth: rightIsl.width
                    wifiOn: root.wifiOn
                    vpn: root.vpnOn
                    ssid: root.wifiSsid
                    strength: root.wifiSignal
                    networks: root.wifiList
                    scanning: root.wifiScanning
                    busy: root.wifiBusy
                    error: root.wifiError
                    onToggleRadio: {
                        const on = !root.wifiOn
                        root.wifiOn = on
                        Quickshell.execDetached(["nmcli", "radio", "wifi", on ? "on" : "off"])
                        wifiRefresh.restart()
                    }
                    onRescan: wifiRescan.running = true
                    onConnectRequested: (network, password) => root.wifiConnectTo(network, password)
                    onDismissed: root.dismiss()
                    onClosed: Qt.callLater(() => wifiLL.keep = false)
                }
            }
        }
    }
}
