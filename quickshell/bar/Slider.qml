import QtQuick

Item {
    id: s
    property real value: 0
    property bool dim: false
    signal moved(real v)

    implicitWidth: 200
    implicitHeight: 24

    readonly property real v: Math.max(0, Math.min(1, value))
    property real shown: v
    Behavior on shown { enabled: !ma.pressed; NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

    function emit(x) { moved(Math.max(0, Math.min(1, x))) }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: ma.containsMouse || ma.pressed ? 8 : 6
        radius: height / 2
        color: Theme.track
        Behavior on height { NumberAnimation { duration: 140; easing.type: Easing.OutCubic } }

        Rectangle {
            width: s.shown * parent.width
            height: parent.height
            radius: height / 2
            color: s.dim ? Theme.muted : Theme.accent
        }
    }

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        x: s.shown * (s.width - width)
        width: 14; height: 14; radius: 7
        color: s.dim ? Theme.text : Theme.accent
        scale: ma.pressed ? 1.25 : ma.containsMouse ? 1.12 : 1
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        onPressed: m => s.emit((m.x - 7) / (s.width - 14))
        onPositionChanged: m => { if (pressed) s.emit((m.x - 7) / (s.width - 14)) }
        onWheel: w => s.emit(s.v + (w.angleDelta.y > 0 ? 0.05 : -0.05))
    }
}
