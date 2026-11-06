#!/usr/bin/env bash

THRESHOLD=20
NOTIFIED=false

while true; do
    BATTERY=$(cat /sys/class/power_supply/BAT*/capacity)

    if (( BATTERY < THRESHOLD )) && [[ "$NOTIFIED" == false ]]; then
        hyprctl notify 1 1000 "rgb(ff5555)" "⚠ Low Battery: ${BATTERY}%"
        NOTIFIED=true
    elif (( BATTERY >= THRESHOLD )); then
        NOTIFIED=false
    fi

    sleep 300
done
