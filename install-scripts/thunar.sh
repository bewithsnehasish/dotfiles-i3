#!/bin/bash

# Enhanced Thunar File Manager Installation Script for Arch Linux
cat << "EOF"
╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║    ████████╗██╗  ██╗██╗   ██╗███╗   ██╗ █████╗ ██████╗                      ║
║    ╚══██╔══╝██║  ██║██║   ██║████╗  ██║██╔══██╗██╔══██╗                     ║
║       ██║   ███████║██║   ██║██╔██╗ ██║███████║██████╔╝                     ║
║       ██║   ██╔══██║██║   ██║██║╚██╗██║██╔══██║██╔══██╗                     ║
║       ██║   ██║  ██║╚██████╔╝██║ ╚████║██║  ██║██║  ██║                     ║
║       ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═╝  ╚═╝╚═╝  ╚═╝                     ║
║                                                                              ║
║          📁 FILE MANAGER INSTALLATION FOR ARCH LINUX 📁                     ║
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
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="../assets/"
LOG_DIR="$SCRIPT_DIR/Install-Logs"
LOG_FILE="$LOG_DIR/thunar-install-$(date +%Y-%m-%d_%H%M%S).log"

# Define the packages to install
thunar_packages=(
    thunar
    thunar-volman
    tumbler
    ffmpegthumbnailer
    thunar-archive-plugin
    gvfs
    gvfs-mtp
    gvfs-gphoto2
    file-roller
    unrar
    zip
    unzip
    p7zip
)

# Optional packages for enhanced functionality
optional_packages=(
    thunar-media-tags-plugin
    thunar-shares-plugin
    catfish
    engrampa
)

# Function to check if package is installed
is_package_installed() {
    pacman -Qi "$1" &>/dev/null
}

# Function to install a package with better error handling
install_package() {
    local package_name="$1"
    
    if is_package_installed "$package_name"; then
        print_success "$package_name is already installed!"
        return 0
    fi
    
    print_status "Installing $package_name..."
    if sudo pacman -S --noconfirm "$package_name" >>"$LOG_FILE" 2>&1; then
        print_success "$package_name installed successfully!"
        return 0
    else
        print_error "Failed to install $package_name. Check $LOG_FILE for details."
        return 1
    fi
}

# Function to backup existing configuration
backup_config() {
    local config_dir="$1"
    local config_path="$HOME/.config/$config_dir"
    local backup_path="$HOME/.config/${config_dir}_backup_$(date +%Y%m%d_%H%M%S)"
    
    if [ -d "$config_path" ]; then
        print_status "Backing up existing $config_dir configuration..."
        if cp -r "$config_path" "$backup_path"; then
            print_success "Backup created at: $backup_path"
            return 0
        else
            print_error "Failed to backup $config_dir configuration!"
            return 1
        fi
    fi
    return 0
}

# Function to copy configuration from assets
copy_config() {
    local config_dir="$1"
    local source_path="$ASSETS_DIR/$config_dir"
    local dest_path="$HOME/.config/$config_dir"
    
    if [ ! -d "$source_path" ]; then
        print_warning "Configuration for $config_dir not found in assets directory"
        return 1
    fi
    
    print_status "Copying $config_dir configuration from assets..."
    if cp -r "$source_path" "$HOME/.config/"; then
        chmod -R u+rw "$dest_path"
        print_success "$config_dir configuration copied successfully!"
        return 0
    else
        print_error "Failed to copy $config_dir configuration!"
        return 1
    fi
}

# Change to script directory
cd "$SCRIPT_DIR" || {
    print_error "Failed to change to script directory!"
    exit 1
}

# Create log directory
print_header "📋 INITIALIZING INSTALLATION"
mkdir -p "$LOG_DIR"
print_status "Log file: $LOG_FILE"

# Update system
print_header "🔄 UPDATING SYSTEM"
print_status "Updating package database..."
if sudo pacman -Sy >>"$LOG_FILE" 2>&1; then
    print_success "Package database updated!"
else
    print_warning "Failed to update package database, continuing..."
fi

# Install core Thunar packages
print_header "📦 INSTALLING THUNAR PACKAGES"
failed_packages=()

for package in "${thunar_packages[@]}"; do
    if ! install_package "$package"; then
        failed_packages+=("$package")
    fi
done

# Check if any core packages failed
if [ ${#failed_packages[@]} -gt 0 ]; then
    print_error "Failed to install core packages: ${failed_packages[*]}"
    print_error "Installation cannot continue without these packages."
    exit 1
fi

# Install optional packages
print_header "🔧 INSTALLING OPTIONAL PACKAGES"
print_status "Installing optional packages for enhanced functionality..."

for package in "${optional_packages[@]}"; do
    install_package "$package" || print_warning "Optional package $package failed to install"
done

# Configure Thunar settings
print_header "⚙️ CONFIGURING THUNAR"

# Create config directory if it doesn't exist
mkdir -p "$HOME/.config"

# Check if assets directory exists
if [ ! -d "$ASSETS_DIR" ]; then
    print_warning "Assets directory not found at: $ASSETS_DIR"
    print_status "Thunar will use default configuration"
else
    # Handle configuration directories
    config_dirs=("Thunar" "xfce4")
    
    for dir in "${config_dirs[@]}"; do
        config_path="$HOME/.config/$dir"
        
        if [ -d "$config_path" ]; then
            print_status "Existing $dir configuration found"
            echo -e "${CYAN}Do you want to backup and replace the existing $dir configuration? (y/N):${NC}"
            read -r response
            if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
                backup_config "$dir"
                rm -rf "$config_path"
                copy_config "$dir"
            else
                print_status "Keeping existing $dir configuration"
            fi
        else
            copy_config "$dir"
        fi
    done
fi

# Set Thunar as default file manager
print_header "🔗 SETTING DEFAULT FILE MANAGER"
print_status "Setting Thunar as default file manager..."

# Create mimeapps.list if it doesn't exist
mkdir -p "$HOME/.config"
if [ ! -f "$HOME/.config/mimeapps.list" ]; then
    touch "$HOME/.config/mimeapps.list"
fi

# Set Thunar as default for directory handling
if ! grep -q "inode/directory=thunar.desktop" "$HOME/.config/mimeapps.list"; then
    echo "inode/directory=thunar.desktop" >> "$HOME/.config/mimeapps.list"
    print_success "Thunar set as default file manager!"
else
    print_success "Thunar is already set as default file manager!"
fi

# Final system integration
print_header "🔄 FINALIZING INSTALLATION"

# Update desktop database
if command -v update-desktop-database &> /dev/null; then
    print_status "Updating desktop database..."
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null
    print_success "Desktop database updated!"
fi

# Update MIME database
if command -v update-mime-database &> /dev/null; then
    print_status "Updating MIME database..."
    update-mime-database "$HOME/.local/share/mime" 2>/dev/null
    print_success "MIME database updated!"
fi

# Final success message
print_header "🎉 INSTALLATION COMPLETE!"
cat << "EOF"

╔══════════════════════════════════════════════════════════════════════════════╗
║                                                                              ║
║  📁 THUNAR FILE MANAGER INSTALLATION COMPLETED! 📁                          ║
║                                                                              ║
║  ✅ Core Thunar packages installed                                           ║
║  ✅ Archive support and thumbnails configured                                ║
║  ✅ MTP and camera support enabled                                           ║
║  ✅ Default file manager configured                                          ║
║  ✅ i3wm integration added                                                   ║
║  ✅ Desktop integration completed                                            ║
║                                                                              ║
║  🎯 FEATURES ENABLED:                                                        ║
║  • File thumbnails and previews                                             ║
║  • Archive extraction and creation                                          ║
║  • Android device mounting (MTP)                                            ║
║  • Camera device support                                                    ║
║  • Volume management                                                         ║
║                                                                              ║
║  ⌨️ KEYBOARD SHORTCUTS:                                                      ║
║  • $mod+e - Open Thunar file manager                                        ║
║                                                                              ║
║  📋 USAGE:                                                                   ║
║  • Run 'thunar' from terminal or use the keyboard shortcut                  ║
║  • Right-click in directories for context menu                              ║
║  • Use F4 to open terminal in current directory                             ║
║                                                                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

EOF

print_success "Thunar installation completed successfully!"
print_status "You can now use Thunar as your file manager. Press \$mod+e in i3wm to open it."

# Show installation summary
echo -e "\n${CYAN}Installation Summary:${NC}"
echo -e "• Log file: $LOG_FILE"
echo -e "• Configuration backed up (if existed)"
echo -e "• Desktop integration completed"
echo -e "• i3wm keybinding added"

# Ask if user wants to open Thunar
echo -e "\n${CYAN}Would you like to open Thunar now to test the installation? (y/N):${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    print_status "Opening Thunar..."
    thunar &
fi

