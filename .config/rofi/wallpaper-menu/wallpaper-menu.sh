#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROFI_CMD="rofi -dmenu -i -show-icons -theme "$DIR/config.rasi""

WALL_DIR="$HOME/dotfiles/assets/wallpapers"
HYPRLOCK_LINK="$HOME/.config/hypr/hyprlock/hyprlock_wallpaper"

[ ! -d "$WALL_DIR" ] && exit 1

# Collect wallpapers
mapfile -t WALLS < <(find "$WALL_DIR" -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \) \
    | sort)

[ ${#WALLS[@]} -eq 0 ] && exit 0

# Build rofi entries with thumbnails
ROFI_LIST=""
for wall in "${WALLS[@]}"; do
    name=$(basename "$wall")
    ROFI_LIST+="$name\0icon\x1f$wall\n"
done

# Show menu
CHOICE=$(echo -en "$ROFI_LIST" | $ROFI_CMD -p "Wallpapers")
[ -z "$CHOICE" ] && exit 0

# Match chosen file
for wall in "${WALLS[@]}"; do
    [[ "$(basename "$wall")" == "$CHOICE" ]] && SELECTED="$wall"
done

[ -z "$SELECTED" ] && exit 0

# Start awww daemon if not running
pgrep -x awww-daemon >/dev/null || (awww-daemon & sleep 0.5)

# Apply wallpaper (desktop)
awww img "$SELECTED" \
    --transition-type any \
    --transition-duration 1.5

# --- Sync wallpaper with Hyprlock ---
mkdir -p "$(dirname "$HYPRLOCK_LINK")"
ln -sf "$SELECTED" "$HYPRLOCK_LINK"

# --- Generate Rofi wallpaper
magick "$SELECTED" \
    -gravity center \
    -resize 500x500^ \
    -extent 500x500 \
    "$HOME/.config/rofi/rofi_wallpaper"
