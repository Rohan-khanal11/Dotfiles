import "../theme"
import QtQuick

Drawer {
    id: win
    property bool wifiOn: true
    property bool vpn: false
    property string ssid: ""
    property int strength: 0
    property var networks: []
    property bool scanning: false
    property string busy: ""
    property string error: ""
    property string askFor: ""

    signal toggleRadio()
    signal rescan()
    signal connectRequested(string network, string password)

    function sigIcon(s) { return s > 75 ? "󰤨" : s > 50 ? "󰤥" : s > 25 ? "󰤢" : "󰤟" }
    function pick(n) {
        if (n.active || busy !== "") return
        if (n.secure && !n.saved) askFor = askFor === n.ssid ? "" : n.ssid
        else { askFor = ""; connectRequested(n.ssid, "") }
    }

    Item {
        width: parent.width
        height: 40

        Text {
            x: 6
            anchors.verticalCenter: parent.verticalCenter
            text: !win.wifiOn ? "󰖪" : win.ssid ? win.sigIcon(win.strength) : "󰖩"
            color: win.wifiOn ? Theme.accent : Theme.muted
            font.family: Theme.font
            font.pixelSize: 20
        }
        Column {
            x: 40
            anchors.verticalCenter: parent.verticalCenter
            Text {
                text: "Wi-Fi"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 14
            }
            Text {
                text: (!win.wifiOn ? "Off"
                    : win.busy !== "" ? "Connecting to " + win.busy + "…"
                    : win.ssid !== "" ? win.ssid : "Not connected") + (win.vpn ? "  ·  VPN" : "")
                color: Theme.muted
                font.family: Theme.font
                font.pixelSize: 10
            }
        }
        Toggle {
            id: sw
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            checked: win.wifiOn
            onToggled: win.toggleRadio()
        }
        Rectangle {
            visible: win.wifiOn
            anchors.right: sw.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            width: 28; height: 28; radius: 14
            color: rma.containsMouse ? Theme.btnHover : Theme.fade(Theme.btnHover)
            Text {
                id: rIcon
                anchors.centerIn: parent
                text: "󰑐"
                color: win.scanning ? Theme.accent : Theme.text
                font.family: Theme.font
                font.pixelSize: 15
                NumberAnimation on rotation {
                    running: win.scanning
                    from: 0; to: 360; duration: 1200; loops: Animation.Infinite
                    onRunningChanged: if (!running) rIcon.rotation = 0
                }
            }
            MouseArea {
                id: rma
                anchors.fill: parent
                hoverEnabled: true
                onClicked: win.rescan()
            }
        }
    }

    ListView {
        id: list
        width: parent.width
        height: Math.min(contentHeight, 308)
        visible: win.wifiOn
        clip: true
        spacing: 2
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        model: win.networks

        delegate: Item {
            id: nd
            required property var modelData
            readonly property bool asking: win.askFor === modelData.ssid
            width: ListView.view.width
            height: ent.height + (asking ? 44 : 0)
            clip: true
            Behavior on height { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            Entry {
                id: ent
                width: parent.width
                icon: win.sigIcon(nd.modelData.signal)
                label: nd.modelData.ssid
                sub: nd.modelData.active ? "Connected"
                   : win.busy === nd.modelData.ssid ? "Connecting…"
                   : win.error === nd.modelData.ssid ? "Couldn't connect"
                   : nd.modelData.saved ? "Saved"
                   : nd.modelData.secure ? nd.modelData.security : "Open"
                on: nd.modelData.active
                trail: nd.modelData.secure ? "󰌾" : ""
                onClicked: win.pick(nd.modelData)
            }

            Loader {
                y: ent.height + 6
                width: parent.width
                active: nd.asking

                sourceComponent: Rectangle {
                    height: 38
                    radius: 12
                    color: Theme.row
                    border.color: pw.activeFocus ? Theme.borderHover : Theme.border

                    function submit() {
                        if (pw.text === "") return
                        win.connectRequested(nd.modelData.ssid, pw.text)
                        win.askFor = ""
                    }

                    TextInput {
                        id: pw
                        anchors.left: parent.left
                        anchors.right: go.left
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 14
                        anchors.rightMargin: 8
                        echoMode: TextInput.Password
                        passwordCharacter: "•"
                        clip: true
                        selectByMouse: true
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 13
                        Component.onCompleted: forceActiveFocus()
                        onAccepted: parent.submit()
                        Keys.onEscapePressed: win.askFor = ""

                        Text {
                            visible: pw.text === ""
                            text: "Password"
                            color: Theme.muted
                            font: pw.font
                        }
                    }
                    Rectangle {
                        id: go
                        anchors.right: parent.right
                        anchors.rightMargin: 5
                        anchors.verticalCenter: parent.verticalCenter
                        width: 28; height: 28; radius: 14
                        color: goMa.containsMouse ? Theme.btnActive : Theme.btnHover
                        Text {
                            anchors.centerIn: parent
                            text: "󰁔"
                            color: Theme.accent
                            font.family: Theme.font
                            font.pixelSize: 15
                        }
                        MouseArea {
                            id: goMa
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: parent.parent.submit()
                        }
                    }
                }
            }
        }
    }

    Text {
        visible: !win.wifiOn || list.count === 0
        width: parent.width
        topPadding: 8
        bottomPadding: 8
        horizontalAlignment: Text.AlignHCenter
        text: !win.wifiOn ? "Wi-Fi is off" : win.scanning ? "Scanning…" : "No networks found"
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 12
    }
}
