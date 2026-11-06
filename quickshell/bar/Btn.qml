import QtQuick

Rectangle {
    id: b
    property alias text: t.text
    property color fg: Theme.text
    property bool alignLeft: false
    property bool active: false
    signal clicked()
    signal middleClicked()
    signal scrolled(int dir)

    implicitWidth: Math.round(t.implicitWidth + 20)
    implicitHeight: 26
    radius: height / 2
    color: active ? Theme.btnActive : m.containsMouse ? Theme.btnHover : Theme.fade(Theme.btnHover)
    scale: m.pressed ? 0.92 : m.containsMouse ? 1.06 : 1

    Behavior on implicitWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
    Behavior on color { ColorAnimation { duration: 140 } }
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    Text {
        id: t
        anchors.verticalCenter: parent.verticalCenter
        x: Math.round(b.alignLeft ? 12 : (b.width - width) / 2)
        color: b.fg
        font.family: Theme.font
        font.pixelSize: 14
    }

    MouseArea {
        id: m
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.MiddleButton
        onClicked: mouse => mouse.button === Qt.MiddleButton ? b.middleClicked() : b.clicked()
        onWheel: w => b.scrolled(w.angleDelta.y > 0 ? 1 : -1)
    }
}
