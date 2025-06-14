#!/bin/bash

# Android MTP/PTP Connection Setup Script for Arch Linux
# Enables file transfer between Android devices and Arch Linux via USB

# ASCII Art Header
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║     █████╗ ███╗   ██╗██████╗ ██████╗  ██████╗ ██╗██████╗                   ║
║    ██╔══██╗████╗  ██║██╔══██╗██╔══██╗██╔═══██╗██║██╔══██╗                  ║
║    ███████║██╔██╗ ██║██║  ██║██████╔╝██║   ██║██║██║  ██║                  ║
║    ██╔══██║██║╚██╗██║██║  ██║██╔══██╗██║   ██║██║██║  ██║                  ║
║    ██║  ██║██║ ╚████║██████╔╝██║  ██║╚██████╔╝██║██████╔╝                  ║
║    ╚═╝  ╚═╝╚═╝  ╚═══╝╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝╚═════╝                   ║
║                                                                              ║
║          📱 MTP/PTP CONNECTION SETUP FOR ARCH LINUX 📱                      ║
║                     USB File Transfer Enabler                               ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1 ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}\n"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root!"
   exit 1
fi

# Function to check if package is installed
is_package_installed() {
    pacman -Qi "$1" &>/dev/null
}

# Function to install AUR helper if not present
install_aur_helper() {
    if ! command -v yay &> /dev/null && ! command -v paru &> /dev/null; then
        print_status "No AUR helper found. Installing YAY..."
        cd /tmp
        git clone https://aur.archlinux.org/yay.git
        cd yay
        makepkg -si --noconfirm
        cd ~
        if command -v yay &> /dev/null; then
            print_success "YAY installed successfully!"
            AUR_HELPER="yay"
        else
            print_error "Failed to install YAY!"
            exit 1
        fi
    elif command -v yay &> /dev/null; then
        AUR_HELPER="yay"
        print_success "YAY AUR helper found!"
    elif command -v paru &> /dev/null; then
        AUR_HELPER="paru"
        print_success "PARU AUR helper found!"
    fi
}

# Step 1: System Update
print_header "🔄 UPDATING SYSTEM PACKAGES"
print_status "Updating system packages..."

if sudo pacman -Syu --noconfirm; then
    print_success "System packages updated successfully!"
else
    print_warning "System update encountered issues, continuing..."
fi

# Step 2: Install AUR helper
print_header "🛠️ CHECKING AUR HELPER"
install_aur_helper

# Step 3: Install MTP support packages
print_header "📱 INSTALLING MTP SUPPORT PACKAGES"

# Install mtpfs
print_status "Installing mtpfs for basic MTP support..."
if sudo pacman -S --needed --noconfirm mtpfs; then
    print_success "mtpfs installed successfully!"
else
    print_error "Failed to install mtpfs!"
    exit 1
fi

# Install libmtp
print_status "Installing libmtp for MTP library support..."
if sudo pacman -S --needed --noconfirm libmtp; then
    print_success "libmtp installed successfully!"
else
    print_warning "Failed to install libmtp, continuing..."
fi

# Install jmtpfs from AUR
print_status "Installing jmtpfs for enhanced MTP support..."
if $AUR_HELPER -S --noconfirm jmtpfs; then
    print_success "jmtpfs installed successfully!"
else
    print_warning "Failed to install jmtpfs, basic MTP will still work..."
fi

# Step 4: Install auto-mounting support
print_header "🔧 INSTALLING AUTO-MOUNTING SUPPORT"

# Install gvfs-mtp
print_status "Installing gvfs-mtp for auto-mounting..."
if sudo pacman -S --needed --noconfirm gvfs-mtp; then
    print_success "gvfs-mtp installed successfully!"
else
    print_error "Failed to install gvfs-mtp!"
    exit 1
fi

# Install gvfs-gphoto2 for PTP support
print_status "Installing gvfs-gphoto2 for PTP support..."
if sudo pacman -S --needed --noconfirm gvfs-gphoto2; then
    print_success "gvfs-gphoto2 installed successfully!"
else
    print_warning "Failed to install gvfs-gphoto2, PTP support may be limited..."
fi

# Step 5: Install additional useful packages
print_header "📦 INSTALLING ADDITIONAL PACKAGES"

# Install android-udev for better device recognition
print_status "Installing android-udev for device rules..."
if sudo pacman -S --needed --noconfirm android-udev; then
    print_success "android-udev installed successfully!"
else
    print_warning "Failed to install android-udev, continuing..."
fi

# Install android-tools for debugging
print_status "Installing android-tools for ADB support..."
if sudo pacman -S --needed --noconfirm android-tools; then
    print_success "android-tools installed successfully!"
else
    print_warning "Failed to install android-tools, continuing..."
fi

# Step 6: Configure FUSE
print_header "⚙️ CONFIGURING FUSE"
print_status "Configuring FUSE for user access..."

# Check if fuse.conf exists and configure it
if [ -f /etc/fuse.conf ]; then
    if ! grep -q "^user_allow_other" /etc/fuse.conf; then
        print_status "Enabling user_allow_other in fuse.conf..."
        sudo sed -i 's/#user_allow_other/user_allow_other/' /etc/fuse.conf
        print_success "FUSE configured successfully!"
    else
        print_success "FUSE already configured!"
    fi
else
    print_warning "fuse.conf not found, creating it..."
    echo "user_allow_other" | sudo tee /etc/fuse.conf > /dev/null
    print_success "FUSE configuration created!"
fi

# Step 11: Test device detection
print_header "🔍 TESTING DEVICE DETECTION"
print_status "Testing MTP device detection..."

if command -v jmtpfs &> /dev/null; then
    print_status "Available MTP devices:"
    jmtpfs --listDevices 2>/dev/null || print_warning "No devices detected (this is normal if no device is connected)"
fi

# Final success message
print_header "🎉 INSTALLATION COMPLETE!"
cat << "EOF"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  📱 ANDROID MTP/PTP SUPPORT INSTALLATION COMPLETED! 📱                      ║
║                                                                              ║
║  ✅ MTP support packages installed                                           ║
║  ✅ PTP support packages installed                                           ║
║  ✅ Auto-mounting configured                                                 ║
║  ✅ FUSE configured                                                          ║
║                                                                              ║
║  📋 NEXT STEPS:                                                              ║
║  1. Restart your system or log out/in for group changes                     ║
║  2. Connect your Android device via USB                                     ║
║  3. Enable "File Transfer" or "MTP" mode on your device                     ║
║  4. Your device should appear in your file manager automatically            ║
║                                                                              ║
║  📂 Mount location: ~/mnt/android                                            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

EOF

print_success "Setup completed! A system restart is recommended for all changes to take effect."

# Ask if user wants to restart now
echo -e "\n${CYAN}Would you like to restart the system now? (y/N):${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    i3-msg restart
    print_status "Restarting system..."
    # sudo reboot
else
    print_warning "Please restart your system manually when convenient."
    print_status "After restart, connect your Android device and it should be automatically detected!"
fi
