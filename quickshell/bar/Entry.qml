import "../theme"
import QtQuick

Rectangle {
    id: e
    property string icon: ""
    property string label: ""
    property string sub: ""
    property string trail: ""
    property bool on: false
    signal clicked()
    signal rightClicked()

    height: 42
    radius: 12
    color: ma.pressed ? Theme.btnActive : ma.containsMouse ? Theme.rowHover : on ? Theme.row : Theme.fade(Theme.rowHover)
    scale: ma.pressed ? 0.985 : 1

    Behavior on color { ColorAnimation { duration: 120 } }
    Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }

    Text {
        x: 14
        anchors.verticalCenter: parent.verticalCenter
        text: e.icon
        color: e.on ? Theme.accent : Theme.text
        font.family: Theme.font
        font.pixelSize: 17
    }

    Column {
        x: 46
        width: parent.width - 86
        anchors.verticalCenter: parent.verticalCenter

        Text {
            width: parent.width
            text: e.label
            elide: Text.ElideRight
            color: e.on ? Theme.accent : Theme.text
            font.family: Theme.font
            font.pixelSize: 13
        }
        Text {
            visible: e.sub !== ""
            width: parent.width
            text: e.sub
            elide: Text.ElideRight
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 10
        }
    }

    Text {
        anchors.right: parent.right
        anchors.rightMargin: 14
        anchors.verticalCenter: parent.verticalCenter
        text: e.on ? "󰄬" : e.trail
        color: e.on ? Theme.accent : Theme.muted
        font.family: Theme.font
        font.pixelSize: 14
    }

    MouseArea {
        id: ma
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onClicked: m => m.button === Qt.RightButton ? e.rightClicked() : e.clicked()
    }
}
