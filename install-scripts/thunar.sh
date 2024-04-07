#!/bin/bash

# Define the packages to install
thunar_packages=(
    thunar
    thunar-volman 
    tumbler
    ffmpegthumbnailer 
    thunar-archive-plugin
)

# Change the working directory to the parent directory of the script
parent_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$parent_dir" || exit 1

# Create the Install-Logs directory if it doesn't exist
mkdir -p Install-Logs

# Set the name of the log file to include the current date and time
log="Install-Logs/install-$(date +%d-%H%M%S)_thunar.log"

# Function to install a package and log the output
install_package() {
    package_name="$1"
    printf "Installing %s...\n" "$package_name"
    if sudo pacman -S --noconfirm "$package_name" >>"$log" 2>&1; then
        echo "Installation of $package_name completed successfully."
    else
        echo "Error: Failed to install $package_name. See $log for details."
        exit 1
    fi
}

# Install Thunar packages
for package in "${thunar_packages[@]}"; do
    install_package "$package"
done

# Check for existing configs and copy if does not exist
for dir in Thunar xfce4; do
    dir_path="$HOME/.config/$dir"
    if [ -d "$dir_path" ]; then
        echo "Config for $dir found, no need to copy."
    else
        echo "Config for $dir not found, copying from assets."
        if cp -r assets/$dir "$HOME/.config/"; then
            echo "Copy $dir completed!"
        else
            echo "Error: Failed to copy $dir config files."
            exit 1
        fi
    fi
done

echo "Script completed successfully."

