import "../theme"
import QtQuick

Rectangle {
    id: t
    property bool checked: false
    signal toggled()

    implicitWidth: 40
    implicitHeight: 22
    radius: height / 2
    color: checked ? Theme.accent : Theme.track
    Behavior on color { ColorAnimation { duration: 180 } }

    Rectangle {
        y: 3
        width: 16; height: 16; radius: 8
        x: t.checked ? t.width - 19 : 3
        color: t.checked ? Theme.accentFg : Theme.text
        scale: ma.pressed ? 0.85 : 1
        Behavior on x { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
        Behavior on scale { NumberAnimation { duration: 100 } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: t.toggled()
    }
}
