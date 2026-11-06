import QtQuick
import Quickshell
import Quickshell.Hyprland

PopupWindow {
    id: pop
    required property Item target
    property bool rightAlign: false
    signal dismissed()
    default property alias content: box.data

    anchor.item: target
    anchor.edges: Edges.Bottom | (rightAlign ? Edges.Right : Edges.Left)
    anchor.gravity: Edges.Bottom | (rightAlign ? Edges.Left : Edges.Right)
    anchor.adjustment: PopupAdjustment.Slide
    anchor.margins.top: 8

    implicitWidth: box.implicitWidth + 28
    implicitHeight: box.implicitHeight + 28
    color: "transparent"

    data: [
        HyprlandFocusGrab { windows: [pop]; active: pop.visible; onCleared: pop.dismissed() },
        Rectangle {
            anchors.fill: parent
            radius: 18
            color: Theme.popup
            border.color: Theme.border
        },
        Column { id: box; x: 14; y: 14; spacing: 6 }
    ]
}
