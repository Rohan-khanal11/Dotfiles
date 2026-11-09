#!/usr/bin/env bash

DIR=/home/khanal/.config/quickshell
CONFIGS=("$DIR/Wallpaper.qml" "$DIR/bar.qml")
LAUNCHER="$DIR/launcher.qml"

any_running() {
  pgrep -x quickshell >/dev/null || pgrep -x qs >/dev/null
}

stop_all() {
  qs kill --all 2>/dev/null
  pkill -x quickshell 2>/dev/null
  pkill -x qs 2>/dev/null
  sleep 0.3
  pkill -9 -x quickshell 2>/dev/null
}

case "$1" in
  on)
    any_running && exit 0
    for c in "${CONFIGS[@]}"; do
      qs -d -p "$c"
    done
    ;;
  off)
    stop_all
    ;;
  toggle)
    if any_running; then
      stop_all
    else
      "$0" on
    fi
    ;;
  launcher)
    if pgrep -f "launcher/shell.qml" >/dev/null; then
      pkill -f "launcher/shell.qml"
    else
      qs -d -p "$LAUNCHER"
    fi
    ;;
  *)
    echo "usage: $0 {on|off|toggle|launcher}" >&2
    exit 1
    ;;
esac

exit 0
