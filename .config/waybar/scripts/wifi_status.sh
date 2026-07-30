#!/usr/bin/env bash

HOME_24G="MEGHBELA-2.4G-1E1DE0"
HOME_5G="MEGHBELA-5G-1E1DE0"
HOTSPOT="Redmi 11 Prime"

CONNECTIVITY=$(nmcli -t -f CONNECTIVITY g)

SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | awk -F: '$1=="yes"{print $2}')

if [[ -z "$SSID" ]]; then
  echo "Disconnected"
  exit 0
fi

if [[ "$SSID" == "$HOME_24G" ]]; then
  SSID="Home-2.4G"
elif [[ "$SSID" == "$HOME_5G" ]]; then
  SSID="Home-5G"
elif [[ "$SSID" == "$HOTSPOT" ]]; then
  SSID="Hotspot"
fi

case "$CONNECTIVITY" in
  full)
    ICON=""
    ;;
  limited|portal|none)
    ICON="󰖪"
    ;;
  *)
    ICON=""
    ;;
esac

echo "$ICON $SSID"
