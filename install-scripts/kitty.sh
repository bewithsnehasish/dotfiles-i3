#!/bin/bash

# Define the source and target paths
SOURCE_CONF_DIR="../.config/kitty/kitty.conf"
TARGET_CONF_DIR="$HOME/.config/kitty"
KITTY_CONFIG_FILE="kitty.conf"

# Function to check if Kitty is installed
function check_kitty_installed {
    if command -v kitty &> /dev/null; then
        echo "Kitty is installed."
        return 0
    else
        echo "Kitty is not installed. Please install Kitty first."
        return 1
    fi
}

# Function to update Kitty config
function update_kitty_config {
    if [ ! -d "$TARGET_CONF_DIR" ]; then
        echo "Creating Kitty config directory at $TARGET_CONF_DIR"
        mkdir -p "$TARGET_CONF_DIR"
    fi

    echo "Copying $KITTY_CONFIG_FILE from $SOURCE_CONF_DIR to $TARGET_CONF_DIR"
    cp "$SOURCE_CONF_DIR/$KITTY_CONFIG_FILE" "$TARGET_CONF_DIR/"

    echo "Kitty configuration updated."
}

# Function to restart Kitty
function restart_kitty {
    echo "Restarting Kitty..."
    # Sending SIGHUP to Kitty process to reload config
    pkill -HUP kitty
    echo "Kitty restarted."
}

# Main script execution
if check_kitty_installed; then
    update_kitty_config
    restart_kitty
fi
