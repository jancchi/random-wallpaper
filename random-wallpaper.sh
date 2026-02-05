#!/usr/bin/env bash

set -euo pipefail

# --- Configuration & Paths ---
CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/random-wallpaper"
CONF_FILE="$CONF_DIR/config"
DATA_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/random-wallpaper"
HISTORY_FILE="$DATA_DIR/hist.txt"
FUTURE_FILE="$DATA_DIR/future.txt"

# Matugen specific paths
MATUGEN_DIR="$HOME/.config/matugen"
MATUGEN_TEMPLATES="$MATUGEN_DIR/templates"
GLOBAL_TEMPLATES="/usr/share/random-wallpaper/templates"

# Create necessary directories
mkdir -p "$CONF_DIR" "$DATA_DIR" "$MATUGEN_TEMPLATES"
touch "$HISTORY_FILE" "$FUTURE_FILE"

# --- 1. User Configuration Check ---
if [[ ! -f "$CONF_FILE" ]]; then
    echo "WALLPAPER_DIR=$HOME/Pictures/Wallpapers" > "$CONF_FILE"
    echo "Error: Config not found. Created template at $CONF_FILE"
    echo "Please edit it and set your wallpaper directory."
    exit 1
fi

source "$CONF_FILE"

if [[ ! -d "${WALLPAPER_DIR:-}" ]]; then
    echo "Error: WALLPAPER_DIR '$WALLPAPER_DIR' is not a valid directory."
    exit 1
fi

# --- 2. Automatic Template Sync ---
# This ensures Matugen always has the latest templates in ~/.config/matugen/templates
sync_templates() {
    local src=""
    if [ -d "./templates" ]; then
        src="./templates" # Development mode (local folder)
    elif [ -d "$GLOBAL_TEMPLATES" ]; then
        src="$GLOBAL_TEMPLATES" # Production mode (system folder)
    fi

    if [ -n "$src" ]; then
        cp "$src/config.toml" "$MATUGEN_DIR/config.toml" 2>/dev/null || cp "$src/matugen.toml" "$MATUGEN_DIR/config.toml"
        cp "$src"/*.conf "$MATUGEN_TEMPLATES/" 2>/dev/null || true
        cp "$src"/*.css "$MATUGEN_TEMPLATES/" 2>/dev/null || true
    fi
}

sync_templates

# --- 3. Wallpaper Collection ---
shopt -s nullglob
wallpapers=("$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp})
shopt -u nullglob

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "Error: No images found in $WALLPAPER_DIR"
    exit 1
fi

# --- 4. Logic ---
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
    if [[ $(wc -l < "$HISTORY_FILE") -lt 2 ]]; then
        echo "No previous wallpaper in history."
        exit 1
    fi
    tail -1 "$HISTORY_FILE" >> "$FUTURE_FILE"
    sed -i '$d' "$HISTORY_FILE"
    SELECTED_WALLPAPER=$(tail -1 "$HISTORY_FILE")
fi

# --- 5. Execution ---
matugen image "$SELECTED_WALLPAPER"

# Set wallpaper
swww img "$SELECTED_WALLPAPER" --transition-type random

# Reload components
hyprctl reload
pkill -SIGUSR2 waybar || waybar &
killall -USR1 kitty || true