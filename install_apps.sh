#!/bin/bash

# Choose your AUR helper: yay or paru
AUR_HELPER="yay"   # Change to "paru" if you prefer

# Check if Application.txt exists
if [[ ! -f Application.txt ]]; then
    echo "Application.txt not found!"
    exit 1
fi

# Read each line (application name) and install
while IFS= read -r app; do
    # Skip empty lines and comments
    [[ -z "$app" || "$app" =~ ^# ]] && continue
    $AUR_HELPER -S --noconfirm "$app"
done < Application.txt

