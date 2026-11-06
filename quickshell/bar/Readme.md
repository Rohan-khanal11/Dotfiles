# Understanding My Quickshell QML Status Bar

This project builds a custom status bar for Arch Linux, Hyprland, and Wayland using Quickshell and Qt Quick (QML).

The code is organized into reusable components:

- `shell.qml` — assembles the bar, manages state, and connects system services.
- `Btn.qml` — reusable interactive button.
- `Island.qml` — groups widgets inside a rounded panel.
- `Pop.qml` — reusable popup window.
- `Drawer.qml` — panel that slides down out of the right island.
- `PowerMenu.qml` — power menu that slides out of the left screen edge.
- `SoundPanel.qml` / `WifiPanel.qml` — sound + Bluetooth and Wi-Fi drawers.
- `Entry.qml`, `Slider.qml`, `Toggle.qml` — small controls used inside the drawers.
- `../theme/Theme.qml` — shared colors and font settings for the bar, launcher, app launcher and wallpaper picker. Every color and the font come from here; no other file hardcodes one. Files import it with `import "../theme"` (`"./theme"` from the config root).

---

## 1. `Btn.qml` — reusable button

`Btn.qml` defines the button used throughout the bar.

```qml
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
}
```

### Root object

- `import QtQuick` makes basic QML types available, including `Rectangle`, `Text`, and `MouseArea`.
- `Rectangle` is the button's visual root. It provides its background, size, and rounded corners.
- `id: b` lets other objects inside this component refer to the root.

### Properties and signals

| Declaration | Meaning |
|---|---|
| `property alias text: t.text` | Exposes the internal `Text` object's text as the button's `text` property. |
| `property color fg` | Controls the text color. |
| `property bool alignLeft` | Selects left-aligned or centered text. |
| `property bool active` | Indicates whether the button is in its active state. |
| `signal clicked()` | Reports a normal click. |
| `signal middleClicked()` | Reports a middle-click. |
| `signal scrolled(int dir)` | Reports scrolling as `1` or `-1`. |

Example use:

```qml
Btn {
    text: "󰣇"
    fg: Theme.accent
    active: root.pop === "power"
    onClicked: root.toggle("power")
}
```

### Property aliases

`property alias text: t.text` directly connects the component's public `text` property to the internal text object's `text` property. Setting `text: "Hello"` on `Btn` changes the displayed text without requiring a separate function.

### Sizing

```qml
implicitWidth: t.implicitWidth + 20
implicitHeight: 26
radius: height / 2
```

- `implicitWidth` gives the button a natural width based on the text plus 20 pixels of extra space.
- `implicitHeight` gives it a natural height of 26 pixels.
- `radius: height / 2` rounds the ends.

An implicit size is a preferred size; a parent layout or explicit `width` can override it.

### Hover and pressed effects

```qml
color: active
    ? Theme.btnActive
    : (m.containsMouse ? Theme.btnHover : "transparent")

scale: m.pressed ? 0.9 : (m.containsMouse ? 1.07 : 1)
```

The color expression means:

1. If `active` is true, use `Theme.btnActive`.
2. Otherwise, if the pointer is hovering, use `Theme.btnHover`.
3. Otherwise, use a transparent background.

The scale expression shrinks the button to 90% while pressed, enlarges it to 107% while hovered, and returns it to normal size otherwise.

```qml
Behavior on scale {
    NumberAnimation {
        duration: 120
        easing.type: Easing.OutBack
    }
}
```

`Behavior` automatically animates changes to a property. `NumberAnimation` animates numeric values, while `Easing.OutBack` adds a slight overshoot effect. A similar behavior animates the background color.

### Text element

```qml
Text {
    id: t
    anchors.verticalCenter: parent.verticalCenter
    x: b.alignLeft ? 12 : (b.width - width) / 2
    color: b.fg
    font.family: Theme.font
    font.pixelSize: 14
}
```

- `anchors.verticalCenter` vertically centers the text.
- `x` positions the text horizontally: 12 pixels from the left when `alignLeft` is true, or centered otherwise.
- `b.fg` reads the parent button's text color.
- `Theme.font` uses the configured font.
- `font.pixelSize` sets the text size.

### Mouse interaction

```qml
MouseArea {
    id: m
    anchors.fill: parent
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.MiddleButton

    onClicked: mouse =>
        mouse.button === Qt.MiddleButton
            ? b.middleClicked()
            : b.clicked()

    onWheel: w => b.scrolled(w.angleDelta.y > 0 ? 1 : -1)
}
```

`MouseArea` captures mouse input:

- `anchors.fill: parent` makes the whole button interactive.
- `hoverEnabled` enables hover detection.
- `acceptedButtons` allows left and middle clicks.
- `onClicked` emits the matching signal.
- `onWheel` translates wheel movement to `1` or `-1`.

The component emits signals; the code that uses the button decides what each action does. For example, the audio button interprets scrolling as volume adjustment.

---

## 2. `Island.qml` — grouping widgets

An island groups related widgets inside a rounded panel.

### Root item and properties

```qml
Item {
    id: isl
    default property alias content: row.data
    property alias spacing: row.spacing
    property int pad: 8
    property int r: 18
}
```

The root is an `Item` because the component contains multiple objects and uses a separate rectangle for its background.

- `content` allows children to be written directly inside `Island`.
- `spacing` exposes the internal row's spacing.
- `pad` controls horizontal padding.
- `r` controls the background corner radius.

For example:

```qml
Island {
    pad: 6
    Btn { text: "A" }
    Btn { text: "B" }
    Btn { text: "C" }
}
```

The `default property alias content: row.data` declaration places the directly declared child objects into the internal row, so callers do not need to write a `Row` each time.

### Sizing and clipping

```qml
implicitWidth: row.implicitWidth + pad * 2
implicitHeight: 36
clip: true
```

The island's preferred width is the row's preferred width plus padding on both sides. Its preferred height is 36 pixels. `clip: true` prevents child visuals from being drawn outside the item's bounds.

```qml
Behavior on implicitWidth {
    NumberAnimation {
        duration: 220
        easing.type: Easing.OutCubic
    }
}
```

This animates changes to the island's implicit width, such as when the system tray expands or collapses.

### Background and hover state

```qml
Rectangle {
    y: -isl.r
    width: parent.width
    height: parent.height + isl.r
    radius: isl.r
    color: hh.hovered ? Theme.panelHover : Theme.panel
    border.color: hh.hovered ? Theme.borderHover : Theme.border
    border.width: 1
}
HoverHandler { id: hh }
```

The rectangle is moved upward by the corner radius and made taller by the same amount. This makes the background extend above the top edge, creating the effect of only the bottom corners being rounded.

`HoverHandler` tracks pointer hover without requiring a click. The background and border become more prominent while hovered.

### Internal row

```qml
Row {
    id: row
    anchors.centerIn: parent
    spacing: 2
}
```

`Row` places its children horizontally, centers them inside the island, and leaves two pixels between adjacent items.

---

## 3. `Pop.qml` — reusable popup windows

Unlike an island, which belongs to the bar, `Pop` creates a separate `PopupWindow`.

### Properties and content

```qml
PopupWindow {
    id: pop
    required property Item target
    property bool rightAlign: false
    signal dismissed()
    default property alias content: box.data
}
```

- `target` specifies the item to which the popup is anchored.
- `rightAlign` changes its horizontal alignment.
- `dismissed()` signals that the popup has been dismissed.
- `content` lets callers place children directly inside the popup.

Example:

```qml
Pop {
    target: logoBtn
    visible: root.pop === "power"

    Btn { text: "Lock" }
}
```

### Positioning

```qml
anchor.item: target

anchor.edges: rightAlign
    ? (Edges.Bottom | Edges.Right)
    : (Edges.Bottom | Edges.Left)

anchor.gravity: rightAlign
    ? (Edges.Bottom | Edges.Left)
    : (Edges.Bottom | Edges.Right)

anchor.adjustment: PopupAdjustment.Slide
anchor.margins.top: 8
```

These settings position the popup relative to its target.

- `anchor.item` identifies the target item.
- `anchor.edges` selects the target edges used for anchoring.
- `anchor.gravity` controls the popup's placement direction.
- `PopupAdjustment.Slide` allows it to slide to fit within available bounds.
- `anchor.margins.top` adds an 8-pixel top margin.

When `rightAlign` is false, the popup uses the target's left edge; when true, it uses the right edge. Right alignment is useful for widgets near the right side of the screen.

### Size and contents

```qml
implicitWidth: box.implicitWidth + 28
implicitHeight: box.implicitHeight + 28
color: "transparent"

Column {
    id: box
    x: 14
    y: 14
    spacing: 6
}
```

The popup's preferred dimensions are based on its content, with 28 pixels added to each overall dimension. The content column starts 14 pixels from the top and left and separates its children by six pixels.

The background rectangle fills the popup:

```qml
Rectangle {
    anchors.fill: parent
    radius: 18
    color: Theme.popup
    border.color: Theme.border
    border.width: 1
}
```

### Focus management

```qml
HyprlandFocusGrab {
    windows: [pop]
    active: pop.visible
    onCleared: pop.dismissed()
}
```

This associates the popup with Hyprland's focus-grab mechanism. The grab becomes active while the popup is visible. When the grab is cleared, the component emits `dismissed()`.

The main bar listens for that signal and closes the popup by updating its state.

---

## 4. `theme/Theme.qml` — shared styling

The theme is declared as a singleton:

```qml
pragma Singleton
import QtQuick
import Quickshell

Singleton {
    readonly property string font: "Iosevka Nerd Font"
}
```

A singleton provides a shared object that other QML files can reference without creating a separate theme instance for every component.

For example:

```qml
color: Theme.text
```

reads the shared text color.

`readonly` means the property cannot be reassigned after initialization, helping keep the palette consistent.

### Theme groups

| Group | Examples | Purpose |
|---|---|---|
| Font | `font` | Text and icon typography |
| Core palette | `accent`, `text`, `muted`, `good`, `bad` | Foreground and status colors |
| Surfaces | `panel`, `panelHover`, `popup`, `border`, `borderHover` | Backgrounds and borders |
| Drawers | `drawer`, `row`, `rowHover`, `track`, `select` | Drawer background, rows, slider track / switch off, selected tab or menu row |
| Text on colour | `selectFg`, `accentFg` | Text or icons drawn on top of `select` and `accent` surfaces |
| Button states | `btnHover`, `btnActive`, `trayHover` | Interaction feedback |
| Workspace dots | `dotActive`, `dotOccupied`, `dotHover`, `dotEmpty` | Workspace indicator colors |

### Helper: `fade(c)`

```qml
function fade(c) { return Qt.rgba(c.r, c.g, c.b, 0) }
```

Returns the same color with alpha 0. Use it as the resting color of anything that fades *to* a color (for example `mma.containsMouse ? Theme.btnHover : Theme.fade(Theme.btnHover)`). Plain `"transparent"` is `#00000000`, so a `ColorAnimation` would pass through dark grey and flash.

### Rule: no hardcoded colors

Components never write colors like `"#ffffff"` or `Qt.rgba(...)`. Text on the selected tab or menu row uses `Theme.selectFg`, and the toggle knob while on uses `Theme.accentFg`. The only literal left is `"transparent"` on window backgrounds (`Pop`, `Drawer`, `PowerMenu`, the bar), where it just means "no background". To re-theme everything, edit `theme/Theme.qml` only.

### RGBA transparency

```qml
readonly property color panel: Qt.rgba(0, 0, 0, 0.65)
readonly property color popup: Qt.rgba(0, 0, 0, 0.92)
```

`Qt.rgba(red, green, blue, alpha)` uses values from 0 to 1. Here, all RGB values are zero, so both colors are black. Alpha `0.65` gives the panel 65% opacity; alpha `0.92` makes the popup nearly opaque.

The monochrome palette uses white, gray, black, and transparency to create visual depth.

---

## 5. `shell.qml` — connecting the bar

The main file assembles the components, maintains shared state, and connects to system services.

### Global state

```qml
ShellRoot {
    id: root

    property bool showDate: false
    property bool trayOpen: false
    property string pop: ""
}
```

`ShellRoot` is the top-level shell object. Its properties store state shared by the bar.

- `showDate` toggles between time and date.
- `trayOpen` controls whether the system tray is expanded.
- `pop` identifies the open popup.

The popup toggle function behaves like a small state machine:

```qml
function toggle(n) {
    if (pop === n) {
        pop = ""
        return
    }

    pop = n
}
```

Typical values are:

- `""` — no popup.
- `"power"` — power menu.
- `"audio"` — audio menu.
- `"wifi"` — Wi-Fi menu.
- `"notif"` — notification menu.

Each popup's `visible` binding checks this value.

The full code also has `lastClosed` and `lastClosedAt`, which implement a short timing guard against immediately reopening a popup after dismissal.

### Multiple monitors

```qml
Variants {
    model: Quickshell.screens

    PanelWindow {
        required property var modelData
        screen: modelData
    }
}
```

`Quickshell.screens` supplies the available screens. `Variants` creates a corresponding panel window for each screen, and `modelData` represents the screen associated with that instance.

The panel is configured at the top of the screen:

```qml
anchors {
    top: true
    left: true
    right: true
}

implicitHeight: 38
color: "transparent"
WlrLayershell.namespace: "qsbar"
```

The window spans the screen width, has a preferred height of 38 pixels, and has a transparent background so the island components supply the visible surfaces.

### Left section: logo and workspaces

The Arch logo is a `Btn` whose click handler toggles the power popup.

Workspace indicators are generated with a `Repeater`:

```qml
Repeater {
    model: 10
    Item {
        readonly property int wsId: index + 1
    }
}
```

The repeater generates ten items. Since `index` starts at zero, `wsId` becomes 1 through 10.

Each item checks whether its workspace is focused or occupied:

```qml
readonly property bool active:
    Hyprland.focusedWorkspace?.id === wsId

readonly property bool occupied:
    Hyprland.workspaces.values.some(w => w.id === wsId)
```

- `active` means the workspace is focused.
- `occupied` means a matching workspace object exists.
- Otherwise, the indicator is treated as empty.

The indicator changes width and color according to its state. Clicking it runs:

```qml
Hyprland.dispatch("workspace " + d.wsId)
```

The `WheelHandler` also lets the user switch workspaces with the mouse wheel.

### Center section: clock

```qml
SystemClock {
    id: clock
    precision: SystemClock.Seconds
}
```

The clock supplies the current date and time. The button displays either:

```qml
Qt.formatDateTime(clock.date, "hh:mm:ss AP")
```

or:

```qml
Qt.formatDateTime(clock.date, "dddd, MMMM d")
```

Clicking the clock toggles `showDate`.

### Right section: system widgets

The right island contains the tray, audio, Wi-Fi, battery, and notification buttons.

| Service | Responsibility |
|---|---|
| `SystemTray` | Provides application tray items and menus |
| `Pipewire` | Provides audio output devices, mute state, and volume |
| `UPower` | Provides battery presence, percentage, and charging state |
| `NotificationServer` | Tracks and dismisses notifications |
| `Process` + `nmcli` | Retrieves Wi-Fi status and nearby networks |
| `SystemClock` | Supplies the current time and date |
| `Hyprland` | Provides workspace state and switching |

#### System tray

A `Repeater` creates an icon for each item in `SystemTray.items`. The tray row animates its width and opacity when `trayOpen` changes.

Each tray item has a `MouseArea` that handles left, middle, and right clicks, including activation and opening an item's menu.

#### Audio

The audio button reads `Pipewire.defaultAudioSink?.audio`. It calculates a percentage from the volume and chooses an icon based on mute state and volume level.

- Left-click opens the audio popup.
- Middle-click toggles mute.
- Scrolling changes volume in 5-percentage-point steps.

The popup lists available output sinks and allows one to be selected as the preferred default.

#### Wi-Fi

The bar runs `nmcli` through Quickshell's `Process` object.

The scan command is:

```bash
nmcli -t -f IN-USE,SIGNAL,SSID dev wifi list
```

The output collector parses network entries, removes duplicate SSIDs, sorts them by signal strength, and updates the connected SSID and signal.

A second process runs:

```bash
nmcli radio wifi
```

A timer starts refreshes every five seconds when the relevant processes are not already running.

The Wi-Fi popup provides a radio toggle and displays up to eight networks. Selecting a network asks NetworkManager to connect to it.

#### Battery

`UPower.displayDevice` provides the battery information. The button chooses a battery icon based on percentage and uses a charging icon when the battery is charging or fully charged. It hides itself if the device is not ready or not present.

#### Notifications

`NotificationServer` tracks notifications. The button displays the tracked count and opens a popup containing notification summaries. Each notification can be dismissed individually, and the clear-all action dismisses all currently tracked notifications.

### Popup instances

The main file creates four instances of the same `Pop` component:

- Power popup targets `logoBtn`.
- Audio popup targets `audioBtn`.
- Wi-Fi popup targets `wifiBtn`.
- Notification popup targets `notifBtn`.

Each instance reuses the same positioning, background, and focus behavior. Only its target and contents differ.

---

## 6. How a click travels through the code

For example, clicking the audio button follows this sequence:

1. **`MouseArea`** detects the left click.
2. **`Btn.qml`** emits `clicked()`.
3. **`shell.qml`** runs `root.toggle("audio")`.
4. The `root.pop` property becomes `"audio"`.
5. The audio popup's binding `visible: root.pop === "audio"` becomes true.
6. **`Pop.qml`** displays the menu anchored to the audio button.

This pattern is the foundation of the interface: reusable components emit signals, `shell.qml` handles application logic, and QML bindings determine what appears.

---

## 7. The overall architecture

Think of the project as four layers:

1. **Theme:** defines every color, transparency, and the font.
2. **Reusable components:** define buttons, islands, popups, drawers, and controls.
3. **Main bar:** arranges components and manages state.
4. **System services:** provide live system information and perform actions.

This separation makes the bar easier to maintain. To change its appearance, edit `Theme.qml`; to change button behavior, edit `Btn.qml`; to change popup layout, edit `Pop.qml`; and to add or rearrange widgets, edit `shell.qml`.

Once these layers make sense, adding a brightness widget, media controls, or another system menu becomes much easier because the same component and state-management patterns can be reused.
