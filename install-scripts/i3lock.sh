#!/bin/bash

# Remove existing i3lock if it's installed
if pacman -Q i3lock &> /dev/null; then
    sudo pacman -R --noconfirm i3lock
fi

# Install i3lock-color using yay AUR helper
if ! command -v yay &> /dev/null; then
    echo "yay AUR helper is not installed. Please install yay first."
    exit 1
fi

yay -S --noconfirm i3lock-color

# Create the directory for custom scripts if it doesn't exist
mkdir -p ~/.config/scripts

# Create the lock script with custom configurations
cat << 'EOF' > ~/.config/scripts/lock
#!/bin/sh

BACKGROUND='#222831'
BORDER='#00ADB5'
BACKGROUND2='#393E46'
TEXT='#EEEEEE'
WARNING='#F05454'

i3lock \
    --insidever-color=$BACKGROUND     \
    --ringver-color=$BORDER           \
    \
    --insidewrong-color=$BACKGROUND   \
    --ringwrong-color=$WARNING        \
    \
    --inside-color=$BACKGROUND        \
    --ring-color=$BACKGROUND2         \
    --line-color=$BACKGROUND          \
    --separator-color=$BACKGROUND2    \
    \
    --verif-color=$TEXT               \
    --wrong-color=$WARNING            \
    --time-color=$TEXT                \
    --date-color=$TEXT                \
    --layout-color=$TEXT              \
    --keyhl-color=$BORDER             \
    --bshl-color=$BORDER              \
    \
    --screen 1                        \
    --blur 5                          \
    --clock                           \
    --indicator                       \
    --time-str="%H:%M:%S"             \
    --date-str="%A, %m %Y"            \
    --keylayout 1                     \
    --nofork
EOF

# Make the lock script executable
chmod +x ~/.config/scripts/lock

# Reload i3 configuration to apply the new keybinding
i3-msg reload

echo "Setup complete. You can now lock your screen with Mod+x."
