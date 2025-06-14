#!/bin/bash

# Dracula Theme Auto-Installer for Arch Linux i3wm
# ASCII Art Header
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    ██████╗ ██████╗  █████╗  ██████╗██╗   ██╗██╗      █████╗                ║
║    ██╔══██╗██╔══██╗██╔══██╗██╔════╝██║   ██║██║     ██╔══██╗               ║
║    ██║  ██║██████╔╝███████║██║     ██║   ██║██║     ███████║               ║
║    ██║  ██║██╔══██╗██╔══██║██║     ██║   ██║██║     ██╔══██║               ║
║    ██████╔╝██║  ██║██║  ██║╚██████╗╚██████╔╝███████╗██║  ██║               ║
║    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝╚═╝  ╚═╝               ║
║                                                                              ║
║              🧛 AUTOMATIC THEME INSTALLER FOR ARCH LINUX 🧛                 ║
║                           i3wm + LXAppearance                               ║
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

# Step 1: Install required packages
print_header "📦 INSTALLING REQUIRED PACKAGES"
print_status "Installing LXAppearance and dependencies..."

sudo pacman -S --needed --noconfirm lxappearance gtk3 gtk2 gnome-themes-extra git base-devel

if [ $? -eq 0 ]; then
    print_success "Required packages installed successfully!"
else
    print_error "Failed to install required packages!"
    exit 1
fi

# Step 2: Install YAY if not present
print_header "🔧 CHECKING FOR YAY AUR HELPER"
if ! command -v yay &> /dev/null; then
    print_status "YAY not found. Installing YAY..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    if command -v yay &> /dev/null; then
        print_success "YAY installed successfully!"
    else
        print_error "Failed to install YAY!"
        exit 1
    fi
else
    print_success "YAY is already installed!"
fi

# Step 3: Install Dracula GTK Theme
print_header "🧛 INSTALLING DRACULA GTK THEME"
print_status "Installing Dracula GTK theme from AUR..."

yay -S --noconfirm dracula-gtk-theme

if [ $? -eq 0 ]; then
    print_success "Dracula GTK theme installed successfully!"
else
    print_error "Failed to install Dracula GTK theme!"
    exit 1
fi

# Step 4: Install Dracula Cursors
print_header "🖱️ INSTALLING DRACULA CURSORS"
print_status "Installing Dracula cursor theme..."

yay -S --noconfirm dracula-cursors-git

if [ $? -eq 0 ]; then
    print_success "Dracula cursors installed successfully!"
else
    print_warning "Failed to install Dracula cursors, continuing without cursors..."
fi

# Step 5: Install Azure Dark Icons
print_header "🎨 INSTALLING AZURE DARK ICONS"
print_status "Looking for Azure Dark Icons in assets folder..."

ASSETS_DIR="../assets/"
AZURE_ICONS_FILE=""

# Look for Azure Dark Icons tar.gz file
if [ -d "$ASSETS_DIR" ]; then
    AZURE_ICONS_FILE=$(find "$ASSETS_DIR" -name "*azure*dark*icons*.tar.gz" -o -name "*Azure*Dark*Icons*.tar.gz" | head -1)
fi

if [ -n "$AZURE_ICONS_FILE" ] && [ -f "$AZURE_ICONS_FILE" ]; then
    print_status "Found Azure Dark Icons: $AZURE_ICONS_FILE"
    
    # Convert to absolute path before changing directories
    AZURE_ICONS_ABSOLUTE=$(realpath "$AZURE_ICONS_FILE")
    
    # Verify the absolute path exists
    if [ ! -f "$AZURE_ICONS_ABSOLUTE" ]; then
        print_error "Azure Dark Icons file not accessible: $AZURE_ICONS_ABSOLUTE"
        print_status "Attempting to install from AUR..."
        yay -S --noconfirm azure-icon-theme
    else
        # Create icons directory if it doesn't exist
        mkdir -p ~/.local/share/icons
        
        # Extract icons using absolute path
        cd ~/.local/share/icons
        
        print_status "Extracting icons from: $AZURE_ICONS_ABSOLUTE"
        if tar -xzf "$AZURE_ICONS_ABSOLUTE"; then
            # Find the extracted directory and rename if needed
            EXTRACTED_DIR=$(find . -maxdepth 1 -type d -name "*azure*" -o -name "*Azure*" | head -1)
            if [ -n "$EXTRACTED_DIR" ] && [ "$EXTRACTED_DIR" != "./Azure-Dark-Icons" ]; then
                mv "$EXTRACTED_DIR" "Azure-Dark-Icons"
                print_status "Renamed extracted directory to Azure-Dark-Icons"
            fi
            
            cd ~
            print_success "Azure Dark Icons installed successfully!"
        else
            print_error "Failed to extract Azure Dark Icons archive!"
            cd ~
            print_status "Attempting to install from AUR..."
            yay -S --noconfirm azure-icon-theme
        fi
    fi
else
    print_warning "Azure Dark Icons not found in assets folder!"
    print_status "Checking if Azure Dark Icons are available in AUR..."
    if yay -Ss azure-icon-theme | grep -q "aur/azure-icon-theme"; then
        yay -S --noconfirm azure-icon-theme
        print_success "Azure Icon Theme installed from AUR!"
    else
        print_error "Azure Dark Icons not found in assets folder or in AUR!"
    fi
fi


# Step 6: Install ZedMono Nerd Font
print_header "🔤 INSTALLING ZEDMONO NERD FONT"
print_status "Installing ZedMono Nerd Font..."

yay -S --noconfirm ttf-zed-mono-nerd

if [ $? -eq 0 ]; then
    print_success "ZedMono Nerd Font installed successfully!"
else
    print_warning "Failed to install ZedMono Nerd Font, using default font..."
fi

# Step 7: Create GTK configuration directories
print_header "📁 CREATING CONFIGURATION DIRECTORIES"
print_status "Creating GTK configuration directories..."

mkdir -p ~/.config/gtk-3.0
mkdir -p ~/.config/gtk-4.0

print_success "Configuration directories created!"

# Step 8: Apply GTK3 settings
print_header "⚙️ APPLYING GTK3 CONFIGURATION"
print_status "Writing GTK3 settings..."

cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=Dracula
gtk-icon-theme-name=Azure-Dark-Icons
gtk-font-name=ZedMono NF 11
gtk-cursor-theme-name=Dracula-cursors
gtk-application-prefer-dark-theme=1
EOF

print_success "GTK3 settings applied!"

# Step 9: Apply GTK2 settings
print_header "⚙️ APPLYING GTK2 CONFIGURATION"
print_status "Writing GTK2 settings..."

cat > ~/.gtkrc-2.0 << EOF
gtk-theme-name="Dracula"
gtk-icon-theme-name="Azure-Dark-Icons"
gtk-font-name="ZedMono NF 11"
gtk-cursor-theme-name="Dracula-cursors"
EOF

print_success "GTK2 settings applied!"

# Step 10: Apply GTK4 settings
print_header "⚙️ APPLYING GTK4 CONFIGURATION"
print_status "Writing GTK4 settings..."

cat > ~/.config/gtk-4.0/settings.ini << EOF
[Settings]
gtk-theme-name=Dracula
gtk-icon-theme-name=Azure-Dark-Icons
gtk-font-name=ZedMono NF 11
gtk-cursor-theme-name=Dracula-cursors
gtk-application-prefer-dark-theme=1
EOF

print_success "GTK4 settings applied!"

# Step 11: Install and configure xsettingsd
print_header "🔧 CONFIGURING XSETTINGSD"
print_status "Installing xsettingsd for better theme support..."

sudo pacman -S --needed --noconfirm xsettingsd

cat > ~/.xsettingsd << EOF
Net/ThemeName "Dracula"
Net/IconThemeName "Azure-Dark-Icons"
Gtk/CursorThemeName "Dracula-cursors"
Net/EnableEventSounds 1
EnableInputFeedbackSounds 0
Xft/Antialias 1
Xft/Hinting 1
Xft/HintStyle "hintfull"
Xft/RGBA "rgb"
EOF

print_success "xsettingsd configured!"

# Step 12: Add xsettingsd to i3 config
print_header "🪟 UPDATING I3 CONFIGURATION"
I3_CONFIG="$HOME/.config/i3/config"

if [ -f "$I3_CONFIG" ]; then
    if ! grep -q "xsettingsd" "$I3_CONFIG"; then
        print_status "Adding xsettingsd to i3 startup..."
        echo "exec --no-startup-id xsettingsd &" >> "$I3_CONFIG"
        print_success "xsettingsd added to i3 config!"
    else
        print_success "xsettingsd already in i3 config!"
    fi
else
    print_warning "i3 config not found at $I3_CONFIG"
fi

# Step 13: Start xsettingsd
print_header "🚀 STARTING SERVICES"
print_status "Starting xsettingsd..."

pkill xsettingsd 2>/dev/null
xsettingsd &

print_success "xsettingsd started!"

# Step 14: Apply gsettings for additional compatibility
print_header "🔧 APPLYING GSETTINGS"
print_status "Applying additional GTK settings via gsettings..."

if command -v gsettings &> /dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
    gsettings set org.gnome.desktop.interface icon-theme "Azure-Dark-Icons"
    gsettings set org.gnome.desktop.interface cursor-theme "Dracula-cursors"
    gsettings set org.gnome.desktop.interface font-name "ZedMono NF 11"
    print_success "gsettings applied!"
else
    print_warning "gsettings not available, skipping..."
fi

# Final success message
print_header "🎉 INSTALLATION COMPLETE!"
cat << "EOF"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  🧛 DRACULA THEME INSTALLATION COMPLETED SUCCESSFULLY! 🧛                   ║
║                                                                              ║
║  ✅ LXAppearance installed                                                   ║
║  ✅ Dracula GTK theme installed                                              ║
║  ✅ Azure Dark Icons installed                                               ║
║  ✅ ZedMono Nerd Font installed                                              ║
║  ✅ Dracula cursors installed                                                ║
║  ✅ GTK2/3/4 configurations applied                                          ║
║  ✅ xsettingsd configured and started                                        ║
║                                                                              ║
║  📋 NEXT STEPS:                                                              ║
║  1. Restart your applications or log out/in to see changes                  ║
║  2. Run 'lxappearance' to verify theme selection                            ║
║  3. Restart i3wm: $mod+Shift+r                                              ║
║                                                                              ║
║  🎨 Your system now has the Dracula theme with Azure Dark Icons!            ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

EOF

print_success "Theme installation completed! Please restart your applications or log out/in to see the changes."
print_status "You can run 'lxappearance' to verify the theme is properly applied."

# Optional: Ask if user wants to restart i3
echo -e "\n${CYAN}Would you like to restart i3wm now to apply changes? (y/N):${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    i3-msg restart
    print_success "i3wm restarted!"
fi

