#!/usr/bin/env bash

set -euo pipefail

WALLPAPER_DIR="/home/admin/Wallpaper-Bank/wallpapers"

DATA_DIR="/home/admin/temp_swww"

HISTORY_FILE="$DATA_DIR/hist.txt"

FUTURE_FILE="$DATA_DIR/future.txt"

mkdir -p "$DATA_DIR"
touch "$HISTORY_FILE"
touch "$FUTURE_FILE"

wallpapers=("$WALLPAPER_DIR"/*.{png,jpg,jpeg,webp} "/home/admin/Wallpapers/images/*.png")

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

	swww img "$SELECTED_WALLPAPER" --transition-type random

	wallust run "$SELECTED_WALLPAPER"
	

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

	swww img "$SELECTED_WALLPAPER" --transition-type random

	wallust run "$SELECTED_WALLPAPER"

fi	


# Refresh Waybar (SIGUSR2 reloads style without restarting)
pkill -SIGUSR2 waybar

# Refresh Kitty (sends signal to all open Kitty instances)
killall -USR1 kitty

# 
hyprctl reload

hyprpm reload
