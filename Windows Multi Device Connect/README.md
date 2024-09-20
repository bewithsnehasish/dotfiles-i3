
---

# README: Simultaneous Audio Output on Arch Linux

## Overview

This guide provides instructions to configure simultaneous audio output through multiple Bluetooth devices on Arch Linux using PulseAudio and i3wm. It also explains how to revert to a single audio device.

## Prerequisites

- Arch Linux installed
- i3 Window Manager
- PulseAudio installed

## Installation Steps

1. **Install Required Packages**

   Open a terminal and run:

   ```bash
   sudo pacman -S pulseaudio pavucontrol
   ```

## Enabling Simultaneous Audio Output

1. **Load the Combine Sink Module**

   Open a terminal and execute:

   ```bash
   pactl load-module module-combine-sink
   ```

2. **Open PulseAudio Volume Control**

   Launch `pavucontrol`:

   ```bash
   pavucontrol
   ```

3. **Set Up the Output Devices**

   - Go to the **Playback** tab and ensure your audio application is playing sound.
   - Switch to the **Output Devices** tab.
   - Locate the "Combined" output device (created by the combine sink).
   - Adjust the volume as needed.

4. **Route Audio to the Combined Sink**

   - In the **Playback** tab, find your audio application.
   - Click the drop-down menu and select the combined output device.

5. **Connect Your Bluetooth Devices**

   Ensure both Bluetooth audio devices are connected. Use your Bluetooth manager or command line to manage connections.

## Disabling Simultaneous Audio Output

1. **Unload the Combine Sink Module**

   Open a terminal and run:

   ```bash
   pactl unload-module module-combine-sink
   ```

2. **Set the Output Device**

   - Open `pavucontrol` again:

     ```bash
     pavucontrol
     ```

   - In the **Playback** tab, select your desired audio output device from the drop-down menu for the application.
   - In the **Output Devices** tab, make sure only the desired device is active.

3. **Restart PulseAudio**

   To ensure changes take effect, restart PulseAudio:

   ```bash
   pulseaudio -k
   pulseaudio --start
   ```

## Optional: Automatic Loading

If you added the `module-combine-sink` to your PulseAudio configuration for automatic loading, remove that line from `~/.config/pulse/default.pa`:

1. Open the configuration file:

   ```bash
   nano ~/.config/pulse/default.pa
   ```

2. Find and delete the line:

   ```plaintext
   load-module module-combine-sink
   ```

3. Save and exit (in nano, press `CTRL + X`, then `Y`, then `ENTER`).

## Conclusion

You can now easily switch between simultaneous audio output and a single audio device on your Arch Linux setup. If you encounter any issues or have questions, feel free to reach out for assistance!

--- 

Feel free to modify any part of the README to better fit your needs!

-- For Such content and updates follow @bewithsnehasish