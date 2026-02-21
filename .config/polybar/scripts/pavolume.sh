#!/usr/bin/env bash

inc=2
maxvol=200

has_pactl() {
    command -v pactl >/dev/null 2>&1
}

get_cur_vol() {
    pactl get-sink-volume @DEFAULT_SINK@ \
        | awk -F'/' 'NR==1 {gsub(/[[:space:]]|%/, "", $2); print $2}'
}

get_mute_status() {
    pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}'
}

output() {
    if ! has_pactl; then
        echo " N/A"
        return
    fi

    local cur_vol cur_status
    cur_vol="$(get_cur_vol 2>/dev/null)"
    cur_status="$(get_mute_status 2>/dev/null)"

    if [ -z "$cur_vol" ]; then
        cur_vol=0
    fi

    if [ "$cur_status" = "yes" ]; then
        echo " $cur_vol%"
    else
        echo " $cur_vol%"
    fi
}

vol_up() {
    has_pactl || return
    local cur_vol
    cur_vol="$(get_cur_vol 2>/dev/null)"
    if [ -z "$cur_vol" ]; then
        return
    fi

    if [ "$cur_vol" -ge "$maxvol" ]; then
        pactl set-sink-volume @DEFAULT_SINK@ "${maxvol}%"
    else
        pactl set-sink-volume @DEFAULT_SINK@ "+${inc}%"
    fi
}

vol_down() {
    has_pactl || return
    pactl set-sink-volume @DEFAULT_SINK@ "-${inc}%"
}

vol_toggle_mute() {
    has_pactl || return
    pactl set-sink-mute @DEFAULT_SINK@ toggle
}

vol_mute() {
    has_pactl || return
    pactl set-sink-mute @DEFAULT_SINK@ 1
}

vol_unmute() {
    has_pactl || return
    pactl set-sink-mute @DEFAULT_SINK@ 0
}

listen() {
    output
    has_pactl || return

    pactl subscribe 2>/dev/null | while read -r event; do
        case "$event" in
            *"on sink"*|*"on server"*)
                output
                ;;
        esac
    done
}

case "$1" in
    --up)
        vol_up
        ;;
    --down)
        vol_down
        ;;
    --togmute)
        vol_toggle_mute
        ;;
    --mute)
        vol_mute
        ;;
    --unmute)
        vol_unmute
        ;;
    --listen)
        listen
        ;;
    *)
        output
        ;;
esac
