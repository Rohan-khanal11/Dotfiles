import Quickshell
import Quickshell.Wayland
import QtQuick

ShellRoot {
    PanelWindow {
        id: win
        anchors { top: true; bottom: true; left: true; right: true }
        color: Theme.overlay
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.layer: WlrLayer.Overlay
        WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

        Item {
            id: root
            anchors.fill: parent
            opacity: 0
            OpacityAnimator on opacity { from: 0; to: 1; duration: 250 }

            // ---------- config ----------
            readonly property color fg: Theme.bright
            readonly property color dim: Theme.lineDim
            readonly property color faint: Theme.lineFaint
            readonly property int maxApps: 12
            readonly property string terminal: "ghostty"
            readonly property string mono: Theme.font
            readonly property string cjk: "Noto Sans CJK JP"
            readonly property real sz: Math.min(width, height) * 0.92
            readonly property real rad: sz / 2
            readonly property string kana: "過ぎ去る時を惜しまず訪れる時を恐れず今この瞬間を生きる"

            // ---------- state ----------
            property int sel: 0
            property int page: 0
            property real turn: 0           // continuous dial position (animated)
            Behavior on turn { NumberAnimation { duration: 220; easing.type: Easing.OutCubic } }

            readonly property var entries: {
                var all = DesktopEntries.applications.values, out = [];
                for (var i = 0; i < all.length; i++) {
                    if (all[i].noDisplay) continue;
                    out.push({ e: all[i], n: all[i].name.toLowerCase() });
                }
                out.sort(function (a, b) { return a.n < b.n ? -1 : 1; });
                return out;
            }

            property var allResults: {
                var q = input.text.toLowerCase(), out = [];
                if (q === "") {
                    for (var i = 0; i < entries.length; i++) out.push(entries[i].e);
                    return out;
                }
                var pre = [], rest = [];
                for (var j = 0; j < entries.length; j++) {
                    var idx = entries[j].n.indexOf(q);
                    if (idx === 0) pre.push(entries[j].e);
                    else if (idx > 0) rest.push(entries[j].e);
                }
                return pre.concat(rest);
            }
            readonly property int pages: Math.max(1, Math.ceil(allResults.length / maxApps))
            property var results: allResults.slice(page * maxApps, (page + 1) * maxApps)
            onAllResultsChanged: { page = 0; sel = 0; turn = 0; }
            onSelChanged: { flash.restart(); iconPop.restart(); }
            onPageChanged: { flash.restart(); iconPop.restart(); }

            // shortest path so the dial never spins the long way round
            function setSel(i) {
                var n = results.length;
                if (n === 0) { sel = 0; return; }
                var d = i - sel;
                if (d > n / 2) d -= n;
                else if (d < -n / 2) d += n;
                turn += d;
                sel = i;
            }
            function next() {
                var n = results.length;
                if (sel + 1 < n) { setSel(sel + 1); return; }
                if (pages === 1) { setSel(0); return; }
                page = (page + 1) % pages; sel = 0; turn = 0;
            }
            function prev() {
                var n = results.length;
                if (sel > 0) { setSel(sel - 1); return; }
                if (pages === 1) { setSel(n - 1); return; }
                page = (page - 1 + pages) % pages;
                sel = Math.min(maxApps, allResults.length - page * maxApps) - 1;
                turn = sel;
            }
            function launch() {
                if (results.length === 0) return;
                var e = results[sel];
                if (e.runInTerminal)
                    Quickshell.execDetached([terminal, "-e"].concat(e.command));
                else
                    e.execute();
                Qt.quit();
            }
            function iconFor(entry) {
                if (!entry) return "";
                var i = entry.icon || "";
                if (i === "") return "";
                if (i.indexOf("/") === 0) return "file://" + i;
                var p = Quickshell.iconPath(i, true);
                if (p !== "") return p;
                var alt = i.replace(/^nm-device-/, "network-").replace(/-symbolic$/, "");
                return Quickshell.iconPath(alt, true);
            }
            function pad(n) { return (n < 10 ? "0" : "") + n; }

            // ---------- drawing helpers ----------
            function circle(ctx, c, r, lw, dash) {
                ctx.beginPath();
                ctx.lineWidth = lw;
                ctx.setLineDash(dash || []);
                ctx.arc(c, c, r, 0, Math.PI * 2);
                ctx.stroke();
            }
            function ticks(ctx, c, r0, r1, n, every, r2) {
                ctx.setLineDash([]);
                ctx.lineWidth = 1;
                ctx.beginPath();
                for (var i = 0; i < n; i++) {
                    var a = i * Math.PI * 2 / n;
                    var rr = (i % every === 0) ? r2 : r1;
                    ctx.moveTo(c + r0 * Math.cos(a), c + r0 * Math.sin(a));
                    ctx.lineTo(c + rr * Math.cos(a), c + rr * Math.sin(a));
                }
                ctx.stroke();
            }
            function arcText(ctx, c, str, r, a0, step) {
                for (var i = 0; i < str.length; i++) {
                    var a = a0 + i * step;
                    ctx.save();
                    ctx.translate(c + r * Math.cos(a), c + r * Math.sin(a));
                    ctx.rotate(a + Math.PI / 2);
                    ctx.fillText(str[i], 0, 0);
                    ctx.restore();
                }
            }
            function poly(ctx, c, r, n, rot) {
                ctx.beginPath();
                for (var i = 0; i <= n; i++) {
                    var a = rot + i * Math.PI * 2 / n;
                    var x = c + r * Math.cos(a), y = c + r * Math.sin(a);
                    if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                }
                ctx.stroke();
            }

            // ---------- static outer tyre + top pointer ----------
            Canvas {
                width: root.sz; height: root.sz; anchors.centerIn: parent
                renderTarget: Canvas.FramebufferObject
                onWidthChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
                    var c = width / 2, R = c;
                    ctx.strokeStyle = Theme.line; ctx.fillStyle = Theme.bright;
                    root.circle(ctx, c, R * 0.99, 2);
                    root.circle(ctx, c, R * 0.93, 3);
                    root.circle(ctx, c, R * 0.86, 1);
                    root.ticks(ctx, c, R * 0.93, R * 0.915, 360, 5, R * 0.90);
                    // pointer: marks the selected slot at 12 o'clock
                    ctx.beginPath();
                    ctx.moveTo(c, c - R * 0.825);
                    ctx.lineTo(c - R * 0.016, c - R * 0.866);
                    ctx.lineTo(c + R * 0.016, c - R * 0.866);
                    ctx.closePath(); ctx.fill();
                }
            }

            // ---------- dial rings: turn together with the apps ----------
            Canvas {
                id: dial
                width: root.sz; height: root.sz; anchors.centerIn: parent
                renderTarget: Canvas.FramebufferObject
                rotation: root.turn * 360 / Math.max(root.results.length, 1)
                onWidthChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
                    var c = width / 2, R = c;
                    ctx.strokeStyle = Theme.line;
                    root.circle(ctx, c, R * 0.66, 1, [18, 10]);
                    root.circle(ctx, c, R * 0.60, 1, [1, 5]);
                }
            }

            // ---------- rotating kana ring ----------
            Canvas {
                id: kanaRing
                width: root.sz; height: root.sz; anchors.centerIn: parent
                renderTarget: Canvas.FramebufferObject
                onWidthChanged: requestPaint()
                RotationAnimator { target: kanaRing; from: 0; to: 360; duration: 90000; loops: Animation.Infinite; running: true }
                onPaint: {
                    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
                    var c = width / 2, R = c;
                    ctx.strokeStyle = Theme.lineSoft; ctx.fillStyle = Theme.bright;
                    root.circle(ctx, c, R * 0.82, 1);
                    root.circle(ctx, c, R * 0.76, 1, [2, 6]);
                    ctx.font = Math.round(R * 0.048) + "px '" + root.cjk + "'";
                    ctx.textAlign = "center"; ctx.textBaseline = "middle";
                    var s = root.kana + "・" + root.kana + "・";
                    root.arcText(ctx, c, s, R * 0.79, 0, Math.PI * 2 / s.length);
                }
            }

            // ---------- counter-rotating geometry ----------
            Canvas {
                id: geo
                width: root.sz * 0.56; height: width; anchors.centerIn: parent
                renderTarget: Canvas.FramebufferObject
                onWidthChanged: requestPaint()
                RotationAnimator { target: geo; from: 360; to: 0; duration: 120000; loops: Animation.Infinite; running: true }
                onPaint: {
                    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
                    var c = width / 2, R = root.rad;
                    ctx.strokeStyle = Theme.lineDim; ctx.setLineDash([]);
                    ctx.lineWidth = 1.5;
                    root.poly(ctx, c, R * 0.52, 3, -Math.PI / 2);
                    root.circle(ctx, c, R * 0.52, 1);
                    root.circle(ctx, c, R * 0.34, 1);
                    root.poly(ctx, c, R * 0.40, 3, Math.PI / 2);
                    ctx.fillStyle = Theme.line;
                    for (var i = 0; i < 3; i++) {
                        var a = -Math.PI / 2 + i * Math.PI * 2 / 3;
                        ctx.beginPath(); ctx.arc(c + R * 0.52 * Math.cos(a), c + R * 0.52 * Math.sin(a), 4, 0, Math.PI * 2); ctx.fill();
                    }
                }
            }

            // ---------- centre disk (masks lines behind the text) + centre ring ----------
            Rectangle {
                anchors.centerIn: parent
                width: root.rad * 0.57; height: width; radius: width / 2
                color: Theme.disk
            }
            Canvas {
                width: root.sz * 0.7; height: width; anchors.centerIn: parent
                renderTarget: Canvas.FramebufferObject
                onWidthChanged: requestPaint()
                onPaint: {
                    var ctx = getContext("2d"); ctx.clearRect(0, 0, width, height);
                    var c = width / 2, R = root.rad;
                    ctx.strokeStyle = Theme.line;
                    root.circle(ctx, c, R * 0.28, 2);
                    root.circle(ctx, c, R * 0.31, 1, [10, 6]);
                    root.ticks(ctx, c, R * 0.28, R * 0.27, 72, 6, R * 0.255);
                }
            }

            // ---------- selection ripple ----------
            Rectangle {
                id: ripple
                anchors.centerIn: parent
                width: root.rad * 0.56; height: width; radius: width / 2
                color: "transparent"; border.color: Theme.accent; border.width: 2
                opacity: 0
            }
            ParallelAnimation {
                id: flash
                NumberAnimation { target: ripple; property: "opacity"; from: 0.7; to: 0; duration: 420 }
                NumberAnimation { target: ripple; property: "scale"; from: 0.95; to: 1.25; duration: 420; easing.type: Easing.OutCubic }
            }

            // ---------- dial: apps rotate so the selected one sits at the top ----------
            Repeater {
                model: root.maxApps
                delegate: Item {
                    id: node
                    required property int index
                    readonly property var entry: index < root.results.length ? root.results[index] : null
                    readonly property bool active: index === root.sel
                    readonly property real ang: -Math.PI / 2 + (index - root.turn) * 2 * Math.PI / Math.max(root.results.length, 1)
                    visible: entry !== null
                    z: active ? 1 : 0
                    width: 64; height: 64
                    x: root.width / 2 + root.rad * 0.63 * Math.cos(ang) - width / 2
                    y: root.height / 2 + root.rad * 0.63 * Math.sin(ang) - height / 2
                    scale: active ? 1.35 : 1
                    opacity: active ? 1 : 0.75
                    Behavior on scale { NumberAnimation { duration: 140; easing.type: Easing.OutBack } }
                    Behavior on opacity { NumberAnimation { duration: 140 } }

                    Rectangle {
                        anchors.fill: parent; radius: width / 2
                        color: node.active ? Theme.btnActive : Theme.panelHover
                        border.color: node.active ? Theme.accent : Theme.lineDim
                        border.width: node.active ? 2 : 1
                    }
                    Rectangle {
                        anchors.centerIn: parent; width: parent.width + 8; height: width; radius: width / 2
                        color: "transparent"; border.color: Theme.lineFaint; border.width: 1
                        visible: node.active
                    }
                    Image {
                        id: img
                        anchors.centerIn: parent; width: 38; height: 38
                        source: root.iconFor(node.entry)
                        sourceSize: Qt.size(76, 76); smooth: true
                        asynchronous: true; cache: false
                        visible: status === Image.Ready
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: node.entry && img.status !== Image.Ready
                        text: node.entry ? node.entry.name.charAt(0).toUpperCase() : ""
                        color: root.fg; font.pixelSize: 26; font.family: root.mono; font.weight: Font.DemiBold
                        renderType: Text.NativeRendering
                    }
                    MouseArea {
                        anchors.fill: parent
                        enabled: node.visible
                        onClicked: { if (node.active) root.launch(); else root.setSel(node.index); }
                    }
                }
            }

            // ---------- centre: big icon / name / search / counter ----------
            Column {
                anchors.centerIn: parent
                spacing: 6

                Item {
                    id: coreIcon
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.rad * 0.16; height: width
                    readonly property var cur: root.results.length > 0 ? root.results[root.sel] : null
                    SequentialAnimation {
                        id: iconPop
                        NumberAnimation { target: coreIcon; property: "scale"; from: 0.6; to: 1; duration: 220; easing.type: Easing.OutBack }
                    }
                    Image {
                        id: coreImg
                        anchors.fill: parent
                        source: root.iconFor(coreIcon.cur)
                        sourceSize: Qt.size(256, 256); smooth: true
                        asynchronous: true; cache: false
                        visible: status === Image.Ready
                    }
                    Text {
                        anchors.centerIn: parent
                        visible: coreIcon.cur && coreImg.status !== Image.Ready
                        text: coreIcon.cur ? coreIcon.cur.name.charAt(0).toUpperCase() : ""
                        color: root.fg; font.pixelSize: parent.width * 0.7; font.family: root.mono; font.weight: Font.DemiBold
                        renderType: Text.NativeRendering
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.rad * 0.4
                    horizontalAlignment: Text.AlignHCenter
                    elide: Text.ElideRight
                    text: root.results.length > 0 ? root.results[root.sel].name.toUpperCase() : "NO MATCH"
                    color: root.results.length > 0 ? root.fg : root.dim
                    font.family: root.mono; font.pixelSize: 13; font.weight: Font.DemiBold
                    font.letterSpacing: 3
                    renderType: Text.NativeRendering
                }

                Item {
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: root.rad * 0.34; height: 30

                    TextInput {
                        id: input
                        anchors.fill: parent
                        anchors.bottomMargin: 4
                        verticalAlignment: TextInput.AlignVCenter
                        horizontalAlignment: TextInput.AlignHCenter
                        color: root.fg
                        font.family: root.mono; font.pixelSize: 20; font.weight: Font.Medium
                        selectionColor: Theme.selection; clip: true
                        renderType: Text.NativeRendering
                        focus: true
                        Component.onCompleted: forceActiveFocus()
                        Keys.onPressed: (e) => {
                            var n = root.results.length;
                            if (e.key === Qt.Key_Escape) Qt.quit();
                            else if (e.key === Qt.Key_Return || e.key === Qt.Key_Enter) root.launch();
                            else if (e.key === Qt.Key_Right || e.key === Qt.Key_Down || e.key === Qt.Key_Tab ||
                                     (e.modifiers & Qt.ControlModifier && e.key === Qt.Key_N)) {
                                if (n) root.next(); e.accepted = true;
                            } else if (e.key === Qt.Key_Left || e.key === Qt.Key_Up || e.key === Qt.Key_Backtab ||
                                     (e.modifiers & Qt.ControlModifier && e.key === Qt.Key_P)) {
                                if (n) root.prev(); e.accepted = true;
                            }
                        }
                    }
                    Text {
                        anchors.centerIn: parent; anchors.verticalCenterOffset: -2
                        visible: input.text === ""
                        text: "SEARCH"
                        color: root.faint
                        font.family: root.mono; font.pixelSize: 13; font.letterSpacing: 5
                        renderType: Text.NativeRendering
                    }
                    Rectangle {
                        anchors.bottom: parent.bottom
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: parent.width
                        height: 1; color: root.dim
                    }
                }

                Text {
                    anchors.horizontalCenter: parent.horizontalCenter
                    text: root.results.length === 0 ? " " :
                          root.pad(root.sel + 1 + root.page * root.maxApps) + " / " + root.pad(root.allResults.length)
                    color: root.dim
                    font.family: root.mono; font.pixelSize: 11; font.letterSpacing: 2
                    renderType: Text.NativeRendering
                }
            }

            // scroll wheel turns the dial
            WheelHandler {
                onWheel: (event) => { if (event.angleDelta.y > 0) root.prev(); else root.next(); }
            }

            MouseArea { anchors.fill: parent; z: -1; onClicked: Qt.quit() }
        }
    }
}
