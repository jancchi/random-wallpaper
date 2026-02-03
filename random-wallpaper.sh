#!/usr/bin/env bash

set -euo pipefail

WALLPAPER_DIR="${WALLPAPER_DIR:-$HOME/Pictures/Wallpapers}"
DATA_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/random-wallpaper"
HISTORY_FILE="$DATA_DIR/hist.txt"
FUTURE_FILE="$DATA_DIR/future.txt"

CONF_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/random-wallpaper"
CONF_FILE="$CONF_DIR/config"

mkdir -p "$CONF_DIR" 

if [[ ! -f "$CONF_FILE" ]]; then
    echo "Error: Configuration file not found at $CONF_FILE"
    echo "Please create it and add: WALLPAPER_DIR=/path/to/your/wallpapers"

    echo "WALLPAPER_DIR=$HOME/Pictures/Wallpapers" > "$CONF_FILE"
    echo "A template has been created for you. Please edit it and run again."
    exit 1
fi


source "$CONF_FILE"

if [[ ! -d "${WALLPAPER_DIR:-}" ]]; then
    echo "Error: WALLPAPER_DIR is not set or is not a valid directory."
    echo "Check your config at: $CONF_FILE"
    exit 1
fi

MATUGEN_CONF_DIR="$HOME/.config/matugen"
MATUGEN_TEMPLATE_DIR="$MATUGEN_CONF_DIR/templates"

if [ ! -f "$MATUGEN_CONF_DIR/config.toml" ]; then
    echo "Initializing Matugen config..."
    mkdir -p "$MATUGEN_CONF_DIR"
    cp /usr/share/random-wallpaper/templates/matugen.toml "$MATUGEN_CONF_DIR/config.toml"
fi

if [ ! -d "$MATUGEN_TEMPLATE_DIR" ]; then
    echo "Initializing Matugen templates..."
    mkdir -p "$MATUGEN_TEMPLATE_DIR"
    cp /usr/share/random-wallpaper/templates/colors.conf "$MATUGEN_TEMPLATE_DIR/"
fi

mkdir -p "$DATA_DIR"
touch "$HISTORY_FILE" "$FUTURE_FILE"

shopt -s nullglob
wallpapers=("$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp})
shopt -u nullglob

if [ ${#wallpapers[@]} -eq 0 ]; then
    echo "Error: No wallpapers found in $WALLPAPER_DIR"
    exit 1
fi

ARG=${1:-next}

if [[ "$ARG" == "next" ]]; then
	
	if [[ $(wc -l < "$FUTURE_FILE") -gt 0 ]]; then

		echo "Taking from the future file "

		SELECTED_WALLPAPER=$(tail -1 "$FUTURE_FILE")

		sed -i '$d' "$FUTURE_FILE"	

	else

		RANDOM_INDEX=$(( RANDOM % ${#wallpapers[@]} ))

		SELECTED_WALLPAPER="${wallpapers[$RANDOM_INDEX]}"

	fi

	echo "$SELECTED_WALLPAPER" >> "$HISTORY_FILE"

	
elif [[ "$ARG" == "prev" ]]; then

	if [[ $(wc -l < "$HISTORY_FILE") -lt 2 ]]; then

		echo "No prev wallpaper"
		exit 1

	fi

	SELECTED_WALLPAPER=$(tail -2 "$HISTORY_FILE" | head -n 1)
	
	tail -1 "$HISTORY_FILE" >> "$FUTURE_FILE"
	echo "Last 2 lines are:"
	echo -e "$(tail -2 $HISTORY_FILE)"
	sed -i '$d' "$HISTORY_FILE"

fi	

swww img "$SELECTED_WALLPAPER" --transition-type random

matugen image "$SELECTED_WALLPAPER"
	
if pgrep -x "waybar" > /dev/null; then
    pkill -SIGUSR2 waybar
else
    waybar & # Start it if it isn't running
fi

killall -USR1 kitty

hyprctl reload

hyprpm reload
