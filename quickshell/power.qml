import QtQuick
import Quickshell
import "bar"

ShellRoot {
    PowerMenu {
        onDismissed: open = false
        onClosed: Qt.quit()
    }
}
