import QtQuick
import Qt.labs.folderlistmodel
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import "./theme"

Scope {
    id: root
    property string dir: Quickshell.env("HOME") + "/.config/hypr/images"
    property string current: ""
    property bool open: false
    readonly property real skew: 0.2

    IpcHandler {
        target: "wallpaper"
        function toggle(): void { root.open = !root.open }
    }

    Process { id: setter }
    Process { id: deleter }

    function apply(path) {
        if (!path) return
        root.current = path
        const names = Quickshell.screens.map(s => s.name)
        setter.command = ["sh", "-c",
            'p="$1"; shift; for m in "$@"; do hyprctl hyprpaper wallpaper "$m,$p,cover"; done',
            "sh", path].concat(names)
        setter.running = true
        root.open = false
    }

    function remove(path) {
        if (!path) return
        deleter.command = ["sh", "-c",
            'gio trash -- "$1" 2>/dev/null || rm -- "$1"', "sh", path]
        deleter.running = true
    }

    LazyLoader {
        active: root.open

        PanelWindow {
            anchors { top: true; bottom: true; left: true; right: true }
            color: Theme.scrim
            exclusionMode: ExclusionMode.Ignore
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

            ListModel { id: paths }

            FolderListModel {
                id: folderModel
                folder: "file://" + root.dir
                nameFilters: ["*.jpg", "*.jpeg", "*.png", "*.webp"]
                caseSensitive: false
                showDirs: false

                property bool loaded: false

                onStatusChanged: {
                    if (status !== FolderListModel.Ready || loaded) return
                    loaded = true
                    let idx = 0
                    for (let i = 0; i < count; i++) {
                        const p = get(i, "filePath")
                        paths.append({ filePath: p })
                        if (p === root.current) idx = i
                    }
                    list.currentIndex = idx
                    folder = ""
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: root.open = false
            }

            ListView {
                id: list
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                height: 520
                orientation: ListView.Horizontal
                spacing: 6
                focus: true
                clip: false
                cacheBuffer: 200
                model: paths

                function pathAt(i) {
                    return (i >= 0 && i < paths.count) ? paths.get(i).filePath : ""
                }

                Component.onCompleted: forceActiveFocus()

                highlightRangeMode: ListView.StrictlyEnforceRange
                preferredHighlightBegin: (width - 340) / 2
                preferredHighlightEnd: (width + 340) / 2
                highlightMoveDuration: 250

                Keys.onPressed: (e) => {
                    switch (e.text) {
                    case "h": decrementCurrentIndex(); break
                    case "l": incrementCurrentIndex(); break
                    case "k":
                    case "w": currentIndex = Math.min(count - 1, currentIndex + 4); break
                    case "j":
                    case "b": currentIndex = Math.max(0, currentIndex - 4); break
                    case "g": currentIndex = 0; break
                    case "G": currentIndex = count - 1; break
                    case "d": {
                        const p = pathAt(currentIndex)
                        if (p) {
                            root.remove(p)
                            paths.remove(currentIndex)
                        }
                        break
                    }
                    case "q": root.open = false; break
                    case " ": root.apply(pathAt(currentIndex)); break
                    default:
                        if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter)
                            root.apply(pathAt(currentIndex))
                        else if (e.key === Qt.Key_Escape)
                            root.open = false
                        else return
                    }
                    e.accepted = true
                }

                WheelHandler {
                    onWheel: (e) => {
                        if (e.angleDelta.y < 0 || e.angleDelta.x < 0) list.incrementCurrentIndex()
                        else list.decrementCurrentIndex()
                    }
                }

                delegate: Item {
                    id: cell
                    required property int index
                    required property string filePath
                    readonly property bool cur: ListView.isCurrentItem

                    width: cur ? 340 : 130
                    height: list.height
                    Behavior on width { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                    Item {
                        id: card
                        width: parent.width
                        height: cell.cur ? 460 : 310
                        anchors.verticalCenter: parent.verticalCenter
                        Behavior on height { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

                        opacity: cell.cur ? 1.0 : 0.8
                        Behavior on opacity { NumberAnimation { duration: 250 } }

                        transform: Matrix4x4 {
                            matrix: Qt.matrix4x4(
                                1, -root.skew, 0, root.skew * card.height / 2,
                                0, 1, 0, 0,
                                0, 0, 1, 0,
                                0, 0, 0, 1)
                        }

                        Image {
                            anchors.fill: parent
                            source: "file://" + cell.filePath
                            // Height only: Qt keeps the aspect ratio, so the crop
                            // has enough pixels on the wide side. Constant, so
                            // selecting a card never triggers a reload.
                            sourceSize.height: 600
                            fillMode: Image.PreserveAspectCrop
                            asynchronous: true
                            cache: false            // free pixmaps when the picker closes
                            retainWhileLoading: true
                            smooth: true
                            mipmap: false
                            clip: true
                        }

                        Rectangle {
                            anchors.fill: parent
                            color: "transparent"
                            border.width: cell.cur ? 2 : 1
                            border.color: cell.cur ? Theme.accent : Theme.borderHover
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: cell.cur ? root.apply(cell.filePath)
                                            : list.currentIndex = cell.index
                    }
                }
            }
        }
    }
}
