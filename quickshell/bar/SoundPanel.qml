import QtQuick
import Quickshell.Services.Pipewire
import Quickshell.Bluetooth

Drawer {
    id: win
    property string tab: "sound"

    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property bool btOn: !!adapter && adapter.enabled
    readonly property var sinks: Pipewire.nodes.values.filter(n => n.isSink && !n.isStream && n.audio)
    readonly property var sources: Pipewire.nodes.values.filter(n => !n.isSink && !n.isStream && n.audio)
    readonly property var btDevices: Bluetooth.devices.values
        .filter(d => d.name)
        .sort((a, b) => ((a.connected ? 0 : a.paired ? 1 : 2) - (b.connected ? 0 : b.paired ? 1 : 2)) || a.name.localeCompare(b.name))
    property string pairingAddr: ""

    PwObjectTracker { objects: Pipewire.nodes.values }

    function syncScan() { if (adapter) adapter.discovering = tab === "bluetooth" && adapter.enabled }
    onTabChanged: syncScan()
    Component.onCompleted: syncScan()
    Component.onDestruction: { if (adapter && adapter.discovering) adapter.discovering = false }
    Connections { target: win.adapter; function onEnabledChanged() { win.syncScan() } }

    function btIcon(d) {
        const i = d.icon || ""
        if (i.includes("headset") || i.includes("headphone")) return "󰋋"
        if (i.includes("keyboard")) return "󰌌"
        if (i.includes("mouse")) return "󰍽"
        if (i.includes("phone")) return "󰄜"
        if (i.includes("audio") || i.includes("speaker")) return "󰓃"
        return "󰂯"
    }
    function btSub(d) {
        if (d.state === BluetoothDeviceState.Connecting) return "Connecting…"
        if (d.state === BluetoothDeviceState.Disconnecting) return "Disconnecting…"
        if (d.pairing) return "Pairing…"
        if (d.connected) return "Connected" + (d.batteryAvailable ? "  ·  " + Math.round(d.battery * 100) + "%" : "")
        return d.paired ? "Paired" : "Available"
    }
    function btToggle(d) {
        if (d.connected) d.disconnect()
        else if (d.paired) d.connect()
        else { pairingAddr = d.address; d.trusted = true; d.pair() }
    }

    component Section: Text {
        topPadding: 6
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 10
        font.letterSpacing: 1.5
    }

    component Note: Text {
        width: parent.width
        topPadding: 8
        bottomPadding: 8
        horizontalAlignment: Text.AlignHCenter
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 12
    }

    component VolRow: Item {
        id: vr
        property var node: null
        property bool input: false
        readonly property var a: node ? node.audio : null
        readonly property real vol: a ? a.volume : 0
        readonly property bool muted: a ? a.muted : false
        height: 32

        Rectangle {
            width: 32; height: 32; radius: 16
            color: mma.containsMouse ? Theme.btnHover : Theme.fade(Theme.btnHover)
            Text {
                anchors.centerIn: parent
                text: vr.input ? (vr.muted ? "󰍭" : "󰍬")
                    : vr.muted ? "󰖁" : vr.vol < 0.33 ? "󰕿" : vr.vol < 0.66 ? "󰖀" : "󰕾"
                color: vr.muted ? Theme.muted : Theme.accent
                font.family: Theme.font
                font.pixelSize: 17
            }
            MouseArea {
                id: mma
                anchors.fill: parent
                hoverEnabled: true
                onClicked: if (vr.a) vr.a.muted = !vr.a.muted
            }
        }
        Slider {
            x: 40
            width: parent.width - 86
            anchors.verticalCenter: parent.verticalCenter
            value: vr.vol
            dim: vr.muted
            onMoved: v => { if (vr.a) vr.a.volume = v }
        }
        Text {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            width: 40
            horizontalAlignment: Text.AlignRight
            text: Math.round(vr.vol * 100) + "%"
            color: vr.muted ? Theme.muted : Theme.text
            font.family: Theme.font
            font.pixelSize: 12
        }
    }

    Rectangle {
        width: parent.width; height: 34; radius: 17
        color: Theme.row

        Item {
            id: tabArea
            anchors.fill: parent
            anchors.margins: 3

            Rectangle {
                width: tabArea.width / 2
                height: tabArea.height
                radius: height / 2
                color: Theme.select
                x: win.tab === "sound" ? 0 : tabArea.width / 2
                Behavior on x { NumberAnimation { duration: 280; easing.type: Easing.OutQuart } }
            }

            Row {
                anchors.fill: parent
                Repeater {
                    model: [
                        { id: "sound", icon: "󰕾", label: "Sound" },
                        { id: "bluetooth", icon: "󰂯", label: "Bluetooth" }
                    ]
                    Item {
                        id: tb
                        required property var modelData
                        width: tabArea.width / 2
                        height: tabArea.height

                        Rectangle {
                            anchors.fill: parent
                            radius: height / 2
                            color: tma.containsMouse && win.tab !== tb.modelData.id ? Theme.btnHover : Theme.fade(Theme.btnHover)
                        }
                        Text {
                            anchors.centerIn: parent
                            text: tb.modelData.icon + "  " + tb.modelData.label
                            color: win.tab === tb.modelData.id ? Theme.selectFg : Theme.text
                            font.family: Theme.font
                            font.pixelSize: 13
                        }
                        MouseArea {
                            id: tma
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: win.tab = tb.modelData.id
                        }
                    }
                }
            }
        }
    }

    Loader {
        width: parent.width
        sourceComponent: win.tab === "sound" ? soundPage : btPage
    }

    Component {
        id: soundPage

        Column {
            width: parent.width
            spacing: 4
            NumberAnimation on opacity { from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }

            Section { text: "OUTPUT" }
            VolRow { width: parent.width; node: Pipewire.defaultAudioSink }
            Repeater {
                model: win.sinks
                Entry {
                    required property var modelData
                    width: parent.width
                    icon: modelData.name.startsWith("bluez") ? "󰋋" : "󰓃"
                    label: modelData.description || modelData.name
                    on: Pipewire.defaultAudioSink === modelData
                    onClicked: Pipewire.preferredDefaultAudioSink = modelData
                }
            }

            Section { text: "INPUT"; visible: !!Pipewire.defaultAudioSource }
            VolRow { width: parent.width; visible: !!Pipewire.defaultAudioSource; input: true; node: Pipewire.defaultAudioSource }
            Repeater {
                model: win.sources
                Entry {
                    required property var modelData
                    width: parent.width
                    icon: "󰍬"
                    label: modelData.description || modelData.name
                    on: Pipewire.defaultAudioSource === modelData
                    onClicked: Pipewire.preferredDefaultAudioSource = modelData
                }
            }
        }
    }

    Component {
        id: btPage

        Column {
            width: parent.width
            spacing: 4
            NumberAnimation on opacity { from: 0; to: 1; duration: 220; easing.type: Easing.OutCubic }

            Item {
                width: parent.width
                height: 40

                Text {
                    x: 6
                    anchors.verticalCenter: parent.verticalCenter
                    text: win.btOn ? "󰂯" : "󰂲"
                    color: win.btOn ? Theme.accent : Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 20
                }
                Column {
                    x: 40
                    anchors.verticalCenter: parent.verticalCenter
                    Text {
                        text: "Bluetooth"
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 14
                    }
                    Text {
                        text: !win.adapter ? "No adapter found"
                            : !win.btOn ? "Off"
                            : win.adapter.discovering ? "Scanning…" : "On"
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 10
                    }
                }
                Toggle {
                    id: btSwitch
                    visible: !!win.adapter
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    checked: win.btOn
                    onToggled: win.adapter.enabled = !win.adapter.enabled
                }
                Rectangle {
                    visible: win.btOn
                    anchors.right: btSwitch.left
                    anchors.rightMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    width: 28; height: 28; radius: 14
                    color: scanMa.containsMouse ? Theme.btnHover : Theme.fade(Theme.btnHover)
                    Text {
                        id: scanIcon
                        anchors.centerIn: parent
                        text: "󰑐"
                        color: win.btOn && win.adapter.discovering ? Theme.accent : Theme.text
                        font.family: Theme.font
                        font.pixelSize: 15
                        NumberAnimation on rotation {
                            running: win.btOn && win.adapter.discovering
                            from: 0; to: 360; duration: 1200; loops: Animation.Infinite
                            onRunningChanged: if (!running) scanIcon.rotation = 0
                        }
                    }
                    MouseArea {
                        id: scanMa
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: win.adapter.discovering = !win.adapter.discovering
                    }
                }
            }

            ListView {
                id: btList
                width: parent.width
                height: Math.min(contentHeight, 264)
                visible: win.btOn
                clip: true
                spacing: 2
                interactive: contentHeight > height
                boundsBehavior: Flickable.StopAtBounds
                model: win.btDevices
                delegate: Entry {
                    id: be
                    required property var modelData
                    width: ListView.view.width
                    icon: win.btIcon(modelData)
                    label: modelData.name
                    sub: win.btSub(modelData)
                    on: modelData.connected
                    onClicked: win.btToggle(modelData)
                    onRightClicked: if (modelData.paired) modelData.forget()

                    Connections {
                        target: be.modelData
                        function onPairedChanged() {
                            if (be.modelData.paired && win.pairingAddr === be.modelData.address) {
                                win.pairingAddr = ""
                                be.modelData.connect()
                            }
                        }
                    }
                }
            }

            Note {
                visible: !!win.adapter && (!win.btOn || btList.count === 0)
                text: win.btOn ? "No devices yet" : "Bluetooth is off"
            }
            Note {
                visible: btList.visible && btList.count > 0
                topPadding: 4
                bottomPadding: 0
                font.pixelSize: 10
                text: "click: connect / disconnect   ·   right-click: forget"
            }
        }
    }
}
