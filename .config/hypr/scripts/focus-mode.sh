#!/bin/bash

fullscreen=$(hyprctl activewindow -j | jq -r '.fullscreen')

if [ "$fullscreen" = "0" ]; then
    hyprctl dispatch fullscreen 1
    pkill -USR1 waybar
else
    hyprctl dispatch fullscreen 0
    pkill -USR1 waybar
fi
