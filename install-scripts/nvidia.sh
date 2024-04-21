#!/bin/bash
# 💫 https://github.com/JaKooLit 💫 #
# Nvidia Stuffs #

# Determine the directory where the script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Change the working directory to the parent directory of the script
PARENT_DIR="$SCRIPT_DIR/.."
cd "$PARENT_DIR" || exit 1

# Set the name of the log file to include the current date and time
LOG="Install-Logs/install-$(date +%d-%H%M%S)_nvidia.log"

# Nvidia packages
nvidia_pkg=(
  nvidia-dkms
  nvidia-settings
  nvidia-utils
  libva
  libva-nvidia-driver-git
)

# Install additional Nvidia packages
printf "${YELLOW} Installing additional Nvidia packages...\n"
for krnl in $(cat /usr/lib/modules/*/pkgbase); do
  for NVIDIA in "${krnl}-headers" "${nvidia_pkg[@]}"; do
    install_package "$NVIDIA" 2>&1 | tee -a "$LOG"
  done
done

# Check if the Nvidia modules are already added in mkinitcpio.conf and add if not
if grep -qE '^MODULES=.*nvidia. *nvidia_modeset.*nvidia_uvm.*nvidia_drm' /etc/mkinitcpio.conf; then
  echo "Nvidia modules already included in /etc/mkinitcpio.conf" 2>&1 | tee -a "$LOG"
else
  sudo sed -Ei 's/^(MODULES=\([^\)]*)\)/\1 nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf 2>&1 | tee -a "$LOG"
  echo "Nvidia modules added in /etc/mkinitcpio.conf"
fi

sudo mkinitcpio -P 2>&1 | tee -a "$LOG"
printf "\n\n\n"

# Additional Nvidia steps
NVEA="/etc/modprobe.d/nvidia.conf"
if [ -f "$NVEA" ]; then
  printf "${OK} Seems like nvidia-drm modeset=1 is already added in your system..moving on.\n"
  printf "\n"
else
  printf "\n"
  printf "${YELLOW} Adding options to $NVEA..."
  sudo echo -e "options nvidia-drm modeset=1" | sudo tee -a /etc/modprobe.d/nvidia.conf 2>&1 | tee -a "$LOG"
  printf "\n"
fi

# Blacklist nouveau
if [[ -z $blacklist_nouveau ]]; then
  read -n1 -rep "${CAT} Would you like to blacklist nouveau? (y/n)" blacklist_nouveau
fi
echo
if [[ $blacklist_nouveau =~ ^[Yy]$ ]]; then
  NOUVEAU="/etc/modprobe.d/nouveau.conf"
  if [ -f "$NOUVEAU" ]; then
    printf "${OK} Seems like nouveau is already blacklisted..moving on.\n"
  else
    printf "\n"
    echo "blacklist nouveau" | sudo tee -a "$NOUVEAU" 2>&1 | tee -a "$LOG"
    printf "${NOTE} has been added to $NOUVEAU.\n"
    printf "\n"

    # To completely blacklist nouveau (See wiki.archlinux.org/title/Kernel_module#Blacklisting 6.1)
    if [ -f "/etc/modprobe.d/blacklist.conf" ]; then
      echo "install nouveau /bin/true" | sudo tee -a "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a "$LOG"
    else
      echo "install nouveau /bin/true" | sudo tee "/etc/modprobe.d/blacklist.conf" 2>&1 | tee -a "$LOG"
    fi
  fi
else
  printf "${NOTE} Skipping nouveau blacklisting.\n" 2>&1 | tee -a "$LOG"
fi

clear
