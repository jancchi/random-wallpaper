#!/usr/bin/env bash

set -euo pipefail

# --- Paths ---
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/random-wallpaper"
CONF_FILE="$CONF_DIR/config"
DATA_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/random-wallpaper"
HISTORY_FILE="$DATA_DIR/hist.txt"
FUTURE_FILE="$DATA_DIR/future.txt"

# Wallust specific paths
WALLUST_DIR="$HOME/.config/wallust"
GLOBAL_TEMPLATES="/usr/share/random-wallpaper/templates"

mkdir -p "$CONF_DIR" "$DATA_DIR" "$WALLUST_DIR"
touch "$HISTORY_FILE" "$FUTURE_FILE"

# --- 1. User Configuration Check ---
if [[ ! -f "$CONF_FILE" ]]; then
    echo "WALLPAPER_DIR=$HOME/Pictures/Wallpapers" > "$CONF_FILE"
    echo "Error: Config not found. Created template at $CONF_FILE"
    echo "Please edit it and set your wallpaper directory."
    exit 1
fi
source "$CONF_FILE"

# --- 2. Template Sync ---
# Copies templates from the package to the user's wallust folder
sync_templates() {
    local src=""
    [ -d "./templates" ] && src="./templates" || src="$GLOBAL_TEMPLATES"
    
    if [ -d "$src" ]; then
        cp "$src/wallust.toml" "$WALLUST_DIR/wallust.toml" 2>/dev/null || true
        # Wallust looks for templates in the same folder or a subfolder defined in .toml
        cp "$src"/*.{conf,css} "$WALLUST_DIR/" 2>/dev/null || true
    fi
}
sync_templates

# --- 3. Wallpaper Collection ---
shopt -s nullglob
wallpapers=("$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp})
shopt -u nullglob

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "Error: No images found in $WALLPAPER_DIR" && exit 1
fi

# --- 4. Logic (Next/Prev) ---
ARG=${1:-next}

if [[ "$ARG" == "next" ]]; then
    if [[ $(wc -l < "$FUTURE_FILE") -gt 0 ]]; then
        SELECTED_WALLPAPER=$(tail -1 "$FUTURE_FILE")
        sed -i '$d' "$FUTURE_FILE"
    else
        SELECTED_WALLPAPER="${wallpapers[RANDOM % ${#wallpapers[@]}]}"
    fi
    echo "$SELECTED_WALLPAPER" >> "$HISTORY_FILE"
elif [[ "$ARG" == "prev" ]]; then
    [[ $(wc -l < "$HISTORY_FILE") -lt 2 ]] && exit 1
    tail -1 "$HISTORY_FILE" >> "$FUTURE_FILE"
    sed -i '$d' "$HISTORY_FILE"
    SELECTED_WALLPAPER=$(tail -1 "$HISTORY_FILE")
fi

# --- 5. Execution ---
swww img "$SELECTED_WALLPAPER" --transition-type random
wallust run "$SELECTED_WALLPAPER"

# Refresh UI
hyprctl reload
pkill -SIGUSR2 waybar || waybar &
killall -USR1 kitty || true