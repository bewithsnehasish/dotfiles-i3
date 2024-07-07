#!/bin/bash

# Script to enable MTP and PTP support on Arch Linux and mount Android device automatically

# Update system packages
echo "Updating system packages..."
sudo pacman -Syu --noconfirm

# Install mtpfs
echo "Installing mtpfs for MTP support..."
sudo pacman -S mtpfs --noconfirm

# Install jmtpfs from AUR
echo "Installing jmtpfs for extended MTP support..."
if ! command -v paru &> /dev/null
then
    echo "paru could not be found. Please install paru to continue."
    exit
fi
paru -S jmtpfs --noconfirm

# Install gvfs-mtp for auto-mounting
echo "Installing gvfs-mtp for auto-mounting..."
sudo pacman -S gvfs-mtp --noconfirm

# Install gvfs-gphoto2 for PTP support
echo "Installing gvfs-gphoto2 for PTP support..."
sudo pacman -S gvfs-gphoto2 --noconfirm

# Reboot the system to apply changes
echo "Rebooting the system to apply changes..."
sudo reboot

echo "Script execution completed. After reboot, connect your Android device and choose the desired option from the popup."

