#!/bin/bash

SESSION_TYPE="$XDG_SESSION_TYPE"
ENABLED_COLOR="#A3BE8C"
DISABLED_COLOR="#D35F5E"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROFI_CMD="rofi -dmenu -i -theme "$DIR/config.rasi""

SIGNAL_ICONS=("󰤟 " "󰤢 " "󰤥 " "󰤨 ")
SECURED_SIGNAL_ICONS=("󰤡 " "󰤤 " "󰤧 " "󰤪 ")
WIFI_CONNECTED_ICON=" "
ETHERNET_CONNECTED_ICON=" "

get_status() {
    if nmcli -t -f TYPE,STATE device status | grep 'ethernet:connected' > /dev/null; then
        local status_icon="󰈀"
        local status_color=$ENABLED_COLOR
    elif nmcli -t -f TYPE,STATE device status | grep 'wifi:connected' > /dev/null; then
        local wifi_info=$(nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list --rescan no | grep '\*')
        if [ -n "$wifi_info" ]; then
            IFS=: read -r in_use signal security ssid <<< "$wifi_info"
            local signal_level=$((signal / 25))
            local signal_icon="${SIGNAL_ICONS[$signal_level]:-${SIGNAL_ICONS[3]}}"

            if [[ "$security" =~ WPA || "$security" =~ WEP ]]; then
                signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"
            fi

            local status_icon="$signal_icon"
            local status_color=$ENABLED_COLOR
        else
            local status_icon=" "
            local status_color=$DISABLED_COLOR
        fi
    else
        local status_icon=" "
        local status_color=$DISABLED_COLOR
    fi

    if [[ "$SESSION_TYPE" == "wayland" ]]; then
        echo "<span color=\"$status_color\">$status_icon</span>"
    elif [[ "$SESSION_TYPE" == "x11" ]]; then
        echo "%{F$status_color}$status_icon%{F-}"
    fi
}

manage_wifi() {
    nmcli --terse --fields "IN-USE,SIGNAL,SECURITY,SSID" device wifi list > /tmp/wifi_list.txt

    local ssids=()
    local formatted_ssids=()
    local active_ssid=""

    while IFS=: read -r in_use signal security ssid; do
        [[ -z "$ssid" ]] && continue

        local signal_level=$((signal / 25))
        local signal_icon="${SIGNAL_ICONS[$signal_level]:-${SIGNAL_ICONS[3]}}"

        [[ "$security" =~ WPA || "$security" =~ WEP ]] && \
            signal_icon="${SECURED_SIGNAL_ICONS[$signal_level]}"

        local formatted="$signal_icon $ssid"
        if [[ "$in_use" =~ \* ]]; then
            active_ssid="$ssid"
            formatted="$WIFI_CONNECTED_ICON $formatted"
        fi

        ssids+=("$ssid")
        formatted_ssids+=("$formatted")
    done < /tmp/wifi_list.txt

    local chosen_network=$(printf "%s\n" "${formatted_ssids[@]}" | \
        $ROFI_CMD -p "Wi-Fi SSID:")

    [[ -z "$chosen_network" ]] && rm /tmp/wifi_list.txt && return

    local ssid_index=-1
    for i in "${!formatted_ssids[@]}"; do
        [[ "${formatted_ssids[$i]}" == "$chosen_network" ]] && ssid_index=$i && break
    done

    local chosen_id="${ssids[$ssid_index]}"

    local action
    if [[ "$chosen_id" == "$active_ssid" ]]; then
        action=$(printf "  Disconnect\n  Forget" | $ROFI_CMD -p "Action:")
    else
        action=$(printf "󰸋  Connect\n  Forget" | $ROFI_CMD -p "Action:")
    fi

    case $action in
        "󰸋  Connect")
            if nmcli -g NAME connection show | grep -Fxq "$chosen_id"; then
                nmcli connection up id "$chosen_id" && \
                    notify-send "Connection Established" "Connected to \"$chosen_id\"."
            else
                local wifi_password=$($ROFI_CMD -password -p "Password:")
                nmcli device wifi connect "$chosen_id" password "$wifi_password" && \
                    notify-send "Connection Established" "Connected to \"$chosen_id\"."
            fi
            ;;
        "  Disconnect")
            nmcli device disconnect wlp1s0 && \
                notify-send "Disconnected" "Disconnected from $chosen_id."
            ;;
        "  Forget")
            nmcli connection delete id "$chosen_id" && \
                notify-send "Forgotten" "Network $chosen_id forgotten."
            ;;
    esac

    rm /tmp/wifi_list.txt
}

manage_ethernet() {
    local eth_devices=$(nmcli device status | awk '$2=="ethernet"{print $1}')
    [[ -z "$eth_devices" ]] && notify-send "Error" "Ethernet device not found." && return

    local eth_list=""
    for dev in $eth_devices; do
        if nmcli device status | grep -q "^$dev .* connected"; then
            eth_list+="$ETHERNET_CONNECTED_ICON$dev\n"
        else
            eth_list+="$dev\n"
        fi
    done

    local chosen_device=$(echo -e "$eth_list" | $ROFI_CMD -p "Select Ethernet:")
    [[ -z "$chosen_device" ]] && return

    chosen_device="${chosen_device#$ETHERNET_CONNECTED_ICON}"

    if nmcli device status | grep -q "^$chosen_device .* connected"; then
        nmcli device disconnect "$chosen_device" && \
            notify-send "Disconnected" "$chosen_device disconnected."
    else
        nmcli device connect "$chosen_device" && \
            notify-send "Connected" "$chosen_device connected."
    fi
}

main_menu() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --status) status_mode=true ;;
            --enabled-color) ENABLED_COLOR="$2"; shift ;;
            --disabled-color) DISABLED_COLOR="$2"; shift ;;
        esac
        shift
    done

    [[ $status_mode == true ]] && get_status && exit 0

    pgrep -x NetworkManager >/dev/null || sudo systemctl start NetworkManager

    local wifi_status=$(nmcli -fields WIFI g)
    if [[ "$wifi_status" =~ enabled ]]; then
        local wifi_toggle="󱛅  Disable Wi-Fi"
        local wifi_cmd="off"
        local wifi_manage="\n󱓥 Manage Wi-Fi"
    else
        local wifi_toggle="󱚽  Enable Wi-Fi"
        local wifi_cmd="on"
        local wifi_manage=""
    fi

    local choice=$(echo -e "$wifi_toggle$wifi_manage\n󱓥 Manage Ethernet" | \
        $ROFI_CMD -p "Wi-Fi")

    case $choice in
        "$wifi_toggle") nmcli radio wifi $wifi_cmd ;;
        "󱓥 Manage Wi-Fi") manage_wifi ;;
        "󱓥 Manage Ethernet") manage_ethernet ;;
    esac
}

main_menu "$@"
