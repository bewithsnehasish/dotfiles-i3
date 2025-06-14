#!/bin/bash

cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    ██████╗ ██╗     ██╗   ██╗███████╗████████╗ ██████╗  ██████╗ ████████╗██╗  ║
║    ██╔══██╗██║     ██║   ██║██╔════╝╚══██╔══╝██╔═══██╗██╔═══██╗╚══██╔══╝██║  ║
║    ██████╔╝██║     ██║   ██║█████╗     ██║   ██║   ██║██║   ██║   ██║   ██║  ║
║    ██╔══██╗██║     ██║   ██║██╔══╝     ██║   ██║   ██║██║   ██║   ██║   ██║  ║
║    ██████╔╝███████╗╚██████╔╝███████╗   ██║   ╚██████╔╝╚██████╔╝   ██║   ██║  ║
║    ╚═════╝ ╚══════╝ ╚═════╝ ╚══════╝   ╚═╝    ╚═════╝  ╚═════╝    ╚═╝   ╚═╝  ║
║                                                                              ║
║          🔵 BLUETOOTH SETUP FOR ARCH LINUX (PIPEWIRE) 🔵                    ║
║                           i3wm Integration                                  ║
╚══════════════════════════════════════════════════════════════════════════════╝
EOF

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

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

# Variables
I3_CONFIG="$HOME/.config/i3/config"
BLUEMAN_AUTOSTART="exec --no-startup-id blueman-applet"
CONFIG_CHANGED=false

# Function to check if package is installed
is_package_installed() {
    pacman -Qi "$1" &>/dev/null
}

# Function to check if service is enabled
is_service_enabled() {
    systemctl is-enabled "$1" &>/dev/null
}

# Function to check if service is active
is_service_active() {
    systemctl is-active "$1" &>/dev/null
}

# Function to check if user is in group
is_user_in_group() {
    groups $USER | grep -q "\b$1\b"
}

# Function to detect audio server
detect_audio_server() {
    if pactl info | grep -q "PipeWire"; then
        echo "pipewire"
    elif pactl info | grep -q "PulseAudio"; then
        echo "pulseaudio"
    else
        echo "unknown"
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

# Step 2: Detect audio server
print_header "🔊 DETECTING AUDIO SERVER"
AUDIO_SERVER=$(detect_audio_server)
print_status "Detected audio server: $AUDIO_SERVER"

# Step 3: Install Bluetooth packages based on audio server
print_header "📦 INSTALLING BLUETOOTH PACKAGES"

if [ "$AUDIO_SERVER" = "pipewire" ]; then
    PACKAGES=("bluez" "bluez-utils" "blueman" "pipewire-pulse" "libldac" "wireplumber")
    print_status "Installing PipeWire-compatible Bluetooth packages..."
else
    PACKAGES=("bluez" "bluez-utils" "blueman" "pulseaudio-bluetooth")
    print_status "Installing PulseAudio-compatible Bluetooth packages..."
fi

for package in "${PACKAGES[@]}"; do
    if is_package_installed "$package"; then
        print_success "$package is already installed!"
    else
        print_status "Installing $package..."
        if sudo pacman -S --noconfirm "$package"; then
            print_success "$package installed successfully!"
        else
            print_warning "Failed to install $package, continuing..."
        fi
    fi
done

# Step 4: Enable and start Bluetooth service
print_header "🔧 CONFIGURING BLUETOOTH SERVICE"

if is_service_enabled "bluetooth"; then
    print_success "Bluetooth service is already enabled!"
else
    print_status "Enabling Bluetooth service..."
    if sudo systemctl enable bluetooth; then
        print_success "Bluetooth service enabled!"
    else
        print_error "Failed to enable Bluetooth service!"
        exit 1
    fi
fi

if is_service_active "bluetooth"; then
    print_success "Bluetooth service is already running!"
else
    print_status "Starting Bluetooth service..."
    if sudo systemctl start bluetooth; then
        print_success "Bluetooth service started!"
    else
        print_error "Failed to start Bluetooth service!"
        exit 1
    fi
fi

# Step 5: Add user to necessary groups
print_header "👥 CONFIGURING USER GROUPS"

# Check for bluetooth group first, fallback to lp group
if getent group bluetooth > /dev/null 2>&1; then
    if is_user_in_group "bluetooth"; then
        print_success "User is already in bluetooth group!"
    else
        print_status "Adding user to bluetooth group..."
        if sudo usermod -aG bluetooth $USER; then
            print_success "User added to bluetooth group!"
        else
            print_warning "Failed to add user to bluetooth group, continuing..."
        fi
    fi
else
    print_warning "Bluetooth group doesn't exist, using lp group instead..."
    if is_user_in_group "lp"; then
        print_success "User is already in lp group!"
    else
        print_status "Adding user to lp group for Bluetooth access..."
        if sudo usermod -aG lp $USER; then
            print_success "User added to lp group!"
        else
            print_warning "Failed to add user to lp group, continuing..."
        fi
    fi
fi

# Also add to audio group for better audio device access
if getent group audio > /dev/null 2>&1; then
    if is_user_in_group "audio"; then
        print_success "User is already in audio group!"
    else
        print_status "Adding user to audio group..."
        if sudo usermod -aG audio $USER; then
            print_success "User added to audio group!"
        else
            print_warning "Failed to add user to audio group, continuing..."
        fi
    fi
fi


# Step 6: Configure i3 autostart
print_header "🪟 CONFIGURING I3WM INTEGRATION"

# Create i3 config directory if it doesn't exist
if [ ! -d "$(dirname "$I3_CONFIG")" ]; then
    print_status "Creating i3 config directory..."
    mkdir -p "$(dirname "$I3_CONFIG")"
fi

# Create i3 config file if it doesn't exist
if [ ! -f "$I3_CONFIG" ]; then
    print_status "Creating i3 config file..."
    touch "$I3_CONFIG"
fi

# Add blueman-applet to i3 config if not present
if ! grep -q "blueman-applet" "$I3_CONFIG"; then
    print_status "Adding blueman-applet to i3 autostart..."
    echo "$BLUEMAN_AUTOSTART" >> "$I3_CONFIG"
    print_success "blueman-applet added to i3 config!"
    CONFIG_CHANGED=true
else
    print_success "blueman-applet is already configured in i3!"
fi

# Step 7: Configure audio support based on detected server
print_header "🔊 CONFIGURING AUDIO SUPPORT"

if [ "$AUDIO_SERVER" = "pipewire" ]; then
    print_status "Configuring PipeWire Bluetooth support..."
    
    # Ensure WirePlumber is enabled
    if systemctl --user is-enabled wireplumber &>/dev/null; then
        print_success "WirePlumber is already enabled!"
    else
        print_status "Enabling WirePlumber..."
        systemctl --user enable wireplumber
        print_success "WirePlumber enabled!"
    fi
    
    # Start WirePlumber if not running
    if systemctl --user is-active wireplumber &>/dev/null; then
        print_success "WirePlumber is already running!"
    else
        print_status "Starting WirePlumber..."
        systemctl --user start wireplumber
        print_success "WirePlumber started!"
    fi
    
    print_success "PipeWire Bluetooth support configured!"
    
else
    print_status "Configuring PulseAudio Bluetooth support..."
    
    # Add bluetooth audio modules to PulseAudio
    if [ -f ~/.config/pulse/default.pa ]; then
        if ! grep -q "load-module module-bluetooth-discover" ~/.config/pulse/default.pa; then
            echo "load-module module-bluetooth-discover" >> ~/.config/pulse/default.pa
            print_success "Bluetooth audio module added to PulseAudio!"
        else
            print_success "Bluetooth audio already configured!"
        fi
    else
        mkdir -p ~/.config/pulse
        echo "load-module module-bluetooth-discover" > ~/.config/pulse/default.pa
        print_success "PulseAudio bluetooth configuration created!"
    fi
fi

# Step 8: Start blueman-applet if not running
print_header "🚀 STARTING BLUETOOTH SERVICES"

if pgrep -x "blueman-applet" > /dev/null; then
    print_success "blueman-applet is already running!"
else
    print_status "Starting blueman-applet..."
    blueman-applet &
    print_success "blueman-applet started!"
fi

# Step 9: Reload i3 if config changed
if [ "$CONFIG_CHANGED" = true ]; then
    print_status "Reloading i3 configuration..."
    if i3-msg reload; then
        print_success "i3 configuration reloaded!"
    else
        print_warning "Failed to reload i3 config, please restart i3 manually"
    fi
fi

# Final success message
print_header "🎉 BLUETOOTH SETUP COMPLETE!"
cat << EOF

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🔵 BLUETOOTH SETUP COMPLETED SUCCESSFULLY! 🔵                              ║
║                                                                              ║
║  ✅ Bluetooth packages installed (PipeWire-compatible)                       ║
║  ✅ Bluetooth service enabled and started                                    ║
║  ✅ User added to bluetooth group                                            ║
║  ✅ blueman-applet configured for i3 autostart                              ║
║  ✅ PipeWire Bluetooth audio support configured                             ║
║  ✅ WirePlumber session manager configured                                   ║
║                                                                              ║
║  📋 BLUETOOTH MANAGEMENT:                                                    ║
║  • Use 'blueman-manager' for GUI device management                          ║
║  • Use 'bluetoothctl' for command-line management                           ║
║  • Bluetooth icon will appear in your system tray                          ║
║                                                                              ║
║  🎧 PIPEWIRE AUDIO SUPPORT:                                                  ║
║  • Bluetooth audio devices work automatically with PipeWire                 ║
║  • Use 'pavucontrol' or 'pwvucontrol' for audio device management           ║
║  • High-quality codecs (LDAC, aptX) supported                               ║
║                                                                              ║
║  📱 BASIC COMMANDS:                                                          ║
║  • bluetoothctl scan on - Scan for devices                                  ║
║  • bluetoothctl pair [MAC] - Pair with device                               ║
║  • bluetoothctl connect [MAC] - Connect to device                           ║
║  • bluetoothctl disconnect [MAC] - Disconnect device                        ║
║                                                                              ║
║  🔧 PIPEWIRE COMMANDS:                                                       ║
║  • pw-cli ls Node - List audio nodes                                        ║
║  • wpctl status - Show WirePlumber status                                   ║
║                                                                              ║
║  📋 NEXT STEPS:                                                              ║
║  1. Log out and back in for group changes to take effect                    ║
║  2. Bluetooth icon should appear in your system tray                        ║
║  3. Right-click the Bluetooth icon to manage devices                        ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

EOF

print_success "Bluetooth setup completed for PipeWire! Please log out and back in for all changes to take effect."

# Ask if user wants to test Bluetooth
echo -e "\n${CYAN}Would you like to test Bluetooth functionality now? (y/N):${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_status "Testing Bluetooth and PipeWire..."
    echo -e "\n${BLUE}Bluetooth Status:${NC}"
    systemctl status bluetooth --no-pager
    echo -e "\n${BLUE}PipeWire Status:${NC}"
    pactl info
    echo -e "\n${BLUE}WirePlumber Status:${NC}"
    systemctl --user status wireplumber --no-pager
fi

