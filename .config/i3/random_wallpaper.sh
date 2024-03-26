#!/bin/bash

# Path to the directory containing wallpapers
WALLPAPER_DIR="$HOME/Pictures/.wallpaper"

# Select a random wallpaper from the directory
selected_wallpaper=$(find "$WALLPAPER_DIR" -type f | shuf -n 1)

# Set the selected wallpaper using feh
feh --bg-scale "$selected_wallpaper"
