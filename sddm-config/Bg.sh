#!/bin/bash

# Path to the directory containing background images
BACKGROUND_DIR="/usr/share/sddm/themes/simple-sddm/Backgrounds"

# Generate a random filename from either jpg or png files in the Backgrounds folder
random_image=$(find "$BACKGROUND_DIR" -type f \( -iname \*.jpg -o -iname \*.png \) | shuf -n 1)

# Set the background image in the theme.conf file
sed -i "s|Background=.*|Background=\"$random_image\"|" /usr/share/sddm/themes/simple-sddm/theme.conf

