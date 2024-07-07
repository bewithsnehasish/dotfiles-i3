# Connect Android to Arch Linux via USB

This guide explains how to connect your Android device to an Arch Linux system via USB using the Media Transfer Protocol (MTP). By following these steps, you'll be able to transfer data between your Android phone and your PC.

## Prerequisites

- A running Arch Linux system.
- An Android device.
- A USB cable to connect your Android device to your PC.
- Internet connection to install the required packages.

## Steps to Enable MTP Support

### 1. Install MTPFS

MTP (Media Transfer Protocol) is not enabled by default on Arch Linux. To enable MTP support, install `mtpfs`:

```sh
sudo pacman -S mtpfs
```

### 2. Install JMTPFS

For devices running Android 4+ or later, you may need an additional package called `jmtpfs`, which can be installed from the AUR repository:

```sh
paru -S jmtpfs
```

**Note:** If you don't have `paru` (an AUR helper) installed, you can install it by following the [Paru installation guide](https://github.com/Morganamilo/paru).

### 3. Install GVFS-MTP

To enable auto-mounting of the Android device, install the `gvfs-mtp` package:

```sh
sudo pacman -S gvfs-mtp
```

### 4. Enable PTP Support

PTP (Picture Transfer Protocol) is a protocol based on MTP, allowing your Android device to appear as a digital camera. To enable PTP support, install `gvfs-gphoto2`:

```sh
sudo pacman -S gvfs-gphoto2
```

### 5. Reboot the System

For the changes to take effect, reboot your system:

```sh
sudo reboot
```

### 6. Accessing Device Files

After rebooting, connect your Android device to your PC using a USB cable. When prompted on your device, choose the desired connection option (e.g., "Transfer files" or "PTP"). Your file manager should now list your device, allowing you to access and manage your Android files.

## Summary

By following these steps, you've enabled MTP and PTP support on your Arch Linux system, allowing you to connect and manage your Android device via USB. This setup will let you easily transfer data between your Android phone and your PC.

If you encounter any issues, make sure that all packages were installed correctly and that you selected the correct option on your Android device when prompted.

Happy file transferring!

---

This guide was created by Snehasish Mandal.