#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# SDDM Log-in Manager #

# Check if preset configuration is to be used
if [[ $USE_PRESET = [Yy] ]]; then
  source ./preset.sh
fi

# Define the SDDM packages to install
sddm_packages=(
  qt5-graphicaleffects
  qt5-quickcontrols2
  qt5-svg
  sddm
)

## WARNING: DO NOT EDIT BEYOND THIS LINE IF YOU DON'T KNOW WHAT YOU ARE DOING! ##

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Function to install a package
install_package() {
  package_name="$1"
  printf "Installing %s...\n" "$package_name"
  sudo pacman -S --noconfirm "$package_name"
  if [ $? -ne 0 ]; then
    echo "Error: Failed to install $package_name."
    exit 1
  fi
}

# Install SDDM and its dependencies
printf "${NOTE} Installing SDDM and dependencies...\n"
for package in "${sddm_packages[@]}"; do
  install_package "$package"
done

# Disable other login managers
for login_manager in lightdm gdm lxdm lxdm-gtk3; do
  if pacman -Qs "$login_manager" > /dev/null; then
    echo "Disabling $login_manager..."
    sudo systemctl disable "$login_manager.service"
  fi
done

# Enable SDDM service
printf "Activating SDDM service...\n"
sudo systemctl enable sddm

# Set up SDDM configuration
echo -e "${NOTE} Setting up the login screen."

# Create necessary directories
sddm_conf_dir="/etc/sddm.conf.d"
[ ! -d "$sddm_conf_dir" ] && { printf "Creating $sddm_conf_dir...\n"; sudo mkdir "$sddm_conf_dir"; }

wayland_sessions_dir="/usr/share/wayland-sessions"
[ ! -d "$wayland_sessions_dir" ] && { printf "Creating $wayland_sessions_dir...\n"; sudo mkdir "$wayland_sessions_dir"; }

# Copy session desktop file
sudo cp assets/hyprland.desktop "$wayland_sessions_dir/"

# Install SDDM themes
valid_input=false
while [ "$valid_input" != true ]; do
    if [[ -z $install_sddm_theme ]]; then
      read -n 1 -r -p "OPTIONAL - Would you like to install SDDM themes? (y/n)" install_sddm_theme
    fi
  if [[ $install_sddm_theme =~ ^[Yy]$ ]]; then
    printf "\nInstalling Simple SDDM Theme\n"

    # Remove existing theme directory if it exists
    if [ -d "/usr/share/sddm/themes/simple-sddm" ]; then
      sudo rm -rf "/usr/share/sddm/themes/simple-sddm"
      echo "Removed existing 'simple-sddm' directory."
    fi

    # Check if simple-sddm directory exists in the current directory and remove if it does
    if [ -d "simple-sddm" ]; then
      rm -rf "simple-sddm"
      echo "Removed existing 'simple-sddm' directory from the current location."
    fi

    if git clone https://github.com/JaKooLit/simple-sddm.git; then
      while [ ! -d "simple-sddm" ]; do
        sleep 1
      done

      if [ ! -d "/usr/share/sddm/themes" ]; then
        sudo mkdir -p /usr/share/sddm/themes
        echo "Directory '/usr/share/sddm/themes' created."
      fi

      sudo mv simple-sddm /usr/share/sddm/themes/
      echo -e "[Theme]\nCurrent=simple-sddm" | sudo tee "$sddm_conf_dir/10-theme.conf" &>> /dev/null
    else
      echo "Failed to clone the theme repository. Please check your internet connection"
    fi
    valid_input=true
  elif [[ $install_sddm_theme =~ ^[Nn]$ ]]; then
    printf "\nNo SDDM themes will be installed.\n"
    valid_input=true
  else
    printf "\nInvalid input. Please enter 'y' for Yes or 'n' for No.\n"
    install_sddm_theme=""
  fi
done

clear

