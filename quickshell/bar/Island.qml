import "../theme"
import QtQuick

Item {
    id: isl
    default property alias content: row.data
    property alias spacing: row.spacing
    property int pad: 8
    property int r: 18
    property bool clipLeft: false
    property bool clipRight: false
    property bool joined: false

    property real j: joined ? 1 : 0
    Behavior on j { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

    implicitWidth: Math.round(row.implicitWidth + pad * 2)
    implicitHeight: 36
    clip: true

    Rectangle {
        x: isl.clipLeft ? -isl.r : 0
        y: -isl.r
        width: parent.width + (isl.clipLeft ? isl.r : 0) + (isl.clipRight ? isl.r : 0)
        height: parent.height + isl.r + 2 * isl.j
        radius: isl.r
        bottomLeftRadius: isl.r * (1 - isl.j)
        bottomRightRadius: bottomLeftRadius
        color: isl.joined ? Theme.drawer : hh.hovered ? Theme.panelHover : Theme.panel
        border.color: hh.hovered || isl.joined ? Theme.borderHover : Theme.border
        Behavior on color { ColorAnimation { duration: 180 } }
        Behavior on border.color { ColorAnimation { duration: 180 } }
    }

    HoverHandler { id: hh }

    Row { id: row; anchors.centerIn: parent; spacing: 2 }
}
