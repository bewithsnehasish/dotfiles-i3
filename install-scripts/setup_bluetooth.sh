#!/bin/bash

# Update the package list and install necessary packages
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm bluez bluez-utils blueman

# Enable and start the Bluetooth service
sudo systemctl enable bluetooth
sudo systemctl start bluetooth

# Add current user to the 'lp' group for Bluetooth management
sudo usermod -aG lp $USER

# Add 'blueman-applet' to i3 config for autostart
I3_CONFIG="$HOME/.config/i3/config"

if [ ! -d "$(dirname $I3_CONFIG)" ]; then
  mkdir -p "$(dirname $I3_CONFIG)"
fi

if ! grep -q "blueman-applet" "$I3_CONFIG"; then
  echo "exec --no-startup-id blueman-applet" >> "$I3_CONFIG"
  echo "Added 'blueman-applet' to i3 config for autostart."
else
  echo "'blueman-applet' is already configured to start with i3."
fi

# Reload i3 configuration
i3-msg reload

echo "Bluetooth setup is complete. Please log out and log back in for changes to take effect."
