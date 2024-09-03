#!/bin/bash

# Function to check if the script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo "Please run this script as root or with sudo."
        exit 1
    fi
}

# Function to install ntfs-3g if not present
install_ntfs_3g() {
    if ! pacman -Qs ntfs-3g > /dev/null; then
        echo "ntfs-3g is not installed. Installing now..."
        pacman -S --noconfirm ntfs-3g
        if [ $? -ne 0 ]; then
            echo "Failed to install ntfs-3g. Please install it manually."
            exit 1
        fi
        echo "ntfs-3g installed successfully."
    else
        echo "ntfs-3g is already installed."
    fi
}

# Function to get Windows partition
get_windows_partition() {
    echo "Available partitions:"
    lsblk
    read -p "Enter the Windows partition (e.g., nvme0n1p4): " windows_partition
    if [ ! -b "/dev/${windows_partition}" ]; then
        echo "Invalid partition. Exiting."
        exit 1
    fi
}

# Function to create mount point
create_mount_point() {
    mount_point="/mnt/windows"
    if [ ! -d "$mount_point" ]; then
        mkdir -p "$mount_point"
        echo "Mount point created at $mount_point"
    else
        echo "Mount point already exists at $mount_point"
    fi
}

# Function to mount Windows partition
mount_windows() {
    if mount | grep -q "$mount_point"; then
        echo "Windows partition is already mounted."
    else
        mount -t ntfs3 "/dev/${windows_partition}" "$mount_point"
        if [ $? -eq 0 ]; then
            echo "Windows partition mounted successfully at $mount_point"
        else
            echo "Failed to mount Windows partition. Trying with ntfs..."
            mount -t ntfs "/dev/${windows_partition}" "$mount_point"
            if [ $? -eq 0 ]; then
                echo "Windows partition mounted successfully at $mount_point using ntfs"
            else
                echo "Failed to mount Windows partition. Please check the filesystem and try again."
                exit 1
            fi
        fi
    fi
}

# Function to add entry to /etc/fstab
add_to_fstab() {
    uuid=$(blkid -s UUID -o value "/dev/${windows_partition}")
    if grep -q "$uuid" /etc/fstab; then
        echo "Updating existing entry in /etc/fstab"
        sed -i "s|UUID=$uuid.*|UUID=$uuid $mount_point ntfs3 defaults 0 0|" /etc/fstab
    else
        echo "Adding new entry to /etc/fstab"
        echo "UUID=$uuid $mount_point ntfs3 defaults 0 0" >> /etc/fstab
    fi
    echo "Entry added/updated in /etc/fstab"
}

# Function to reload systemd
reload_systemd() {
    systemctl daemon-reload
    echo "Systemd configuration reloaded"
}

# Main script execution
check_root
install_ntfs_3g
get_windows_partition
create_mount_point
mount_windows
add_to_fstab
reload_systemd

echo "Script completed successfully. Here's a summary of actions:"
echo "1. Checked for root privileges"
echo "2. Installed or confirmed ntfs-3g"
echo "3. Identified Windows partition: /dev/${windows_partition}"
echo "4. Created or confirmed mount point: $mount_point"
echo "5. Mounted Windows partition"
echo "6. Updated /etc/fstab"
echo "7. Reloaded systemd configuration"
echo ""
echo "Your Windows partition should now be accessible at $mount_point"
echo "If you encounter any issues, please run 'sudo mount -a' to remount all filesystems."