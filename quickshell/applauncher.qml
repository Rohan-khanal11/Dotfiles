import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "./theme"

ShellRoot {
    id: root
    property bool open: false

    IpcHandler {
        target: "launcher"
        function toggle(): void { root.open = !root.open }
    }

    PanelWindow {
        id: win
        visible: root.open
        color: "transparent"
        implicitWidth: 560
        implicitHeight: 440
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.namespace: "launcher"
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        onVisibleChanged: if (visible) { search.text = ""; search.forceActiveFocus() }

        function launch(entry) {
            if (!entry) return
            entry.execute()
            root.open = false
        }

        Rectangle {
            anchors.fill: parent
            radius: 14
            color: Theme.popup
            border.color: Theme.borderHover
            border.width: 1

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                TextInput {
                    id: search
                    Layout.fillWidth: true
                    color: Theme.text
                    font.pixelSize: 18
                    font.family: Theme.font
                    focus: true
                    selectByMouse: true

                    Text {
                        visible: !search.text
                        text: "Search apps…"
                        color: Theme.muted
                        font: search.font
                    }

                    onTextChanged: list.currentIndex = 0
                    Keys.onEscapePressed: root.open = false
                    Keys.onDownPressed: list.incrementCurrentIndex()
                    Keys.onUpPressed: list.decrementCurrentIndex()
                    Keys.onReturnPressed: win.launch(list.currentItem ? list.currentItem.entry : null)
                    Keys.onEnterPressed: win.launch(list.currentItem ? list.currentItem.entry : null)
                }

                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border }

                ListView {
                    id: list
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    currentIndex: 0
                    highlightMoveDuration: 0

                    model: ScriptModel {
                        values: {
                            const q = search.text.toLowerCase();
                            return DesktopEntries.applications.values
                                .filter(e => !e.noDisplay && e.name.toLowerCase().includes(q))
                                .sort((a, b) => {
                                    const as = a.name.toLowerCase().startsWith(q);
                                    const bs = b.name.toLowerCase().startsWith(q);
                                    if (as !== bs) return as ? -1 : 1;
                                    return a.name.localeCompare(b.name);
                                });
                        }
                    }

                    delegate: Rectangle {
                        required property var modelData
                        required property int index
                        property var entry: modelData
                        width: list.width
                        height: 44
                        radius: 8
                        color: ListView.isCurrentItem ? Theme.rowHover : "transparent"

                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 8
                            spacing: 10

                            Image {
                                source: Quickshell.iconPath(modelData.icon, "application-x-executable")
                                sourceSize: Qt.size(28, 28)
                                Layout.preferredWidth: 28
                                Layout.preferredHeight: 28
                            }
                            Text {
                                text: modelData.name
                                color: Theme.text
                                font.pixelSize: 15
                                font.family: Theme.font
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            onEntered: list.currentIndex = index
                            onClicked: win.launch(modelData)
                        }
                    }
                }
            }
        }
    }
}
