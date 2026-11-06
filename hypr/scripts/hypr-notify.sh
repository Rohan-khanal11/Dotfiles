#!/usr/bin/env bash

# keep dunst from drawing its own popups (it still owns the D-Bus name)
dunstctl set-paused true

send() {
    local urgency=$1 app=$2 summary=$3 body=$4 icon color msg
    case $urgency in
        0) icon=2; color="rgb(888888)" ;;
        2) icon=3; color="rgb(ff4444)" ;;
        *) icon=1; color="rgb(5e9cff)" ;;
    esac
    msg=$summary
    [[ -n $body ]] && msg+=" - $body"
    hyprctl notify "$icon" 2000 "$color" "$msg" >/dev/null
}

n=0 urgency=1 want_urgency=0
app="" summary="" body=""

dbus-monitor --session "interface='org.freedesktop.Notifications',member='Notify'" |
while IFS= read -r line; do
    if [[ $line == *"member=Notify"* ]]; then
        n=0 urgency=1 want_urgency=0
        app="" summary="" body=""
        continue
    fi

    line="${line#"${line%%[![:space:]]*}"}"   # trim leading whitespace

    if [[ $line == 'string "'* ]]; then
        val="${line#string \"}"
        val="${val%\"}"
        if (( want_urgency )); then
            continue
        fi
        case $n in
            0) app=$val ;;
            1) ;;                 # icon, ignored
            2) summary=$val ;;
            3) body=$val ;;
        esac
        # hint keys also look like strings; urgency key marks the hint we want
        if [[ $val == urgency && $n -ge 4 ]]; then want_urgency=1; fi
        ((n++))
    elif [[ $line == *'string "urgency"'* ]]; then
        want_urgency=1
    elif (( want_urgency )) && [[ $line =~ byte[[:space:]]+([0-9]) ]]; then
        urgency=${BASH_REMATCH[1]}
        want_urgency=0
    elif [[ $line == int32* ]]; then
        send "$urgency" "$app" "$summary" "$body"
    fi
done
