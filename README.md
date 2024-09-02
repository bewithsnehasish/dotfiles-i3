# My i3 Window Manager Configuration

This repository contains my personal i3 window manager configuration. It's designed to provide a sleek, efficient, and customizable desktop environment.

## Table of Contents

1. [Features](#features)
2. [Dependencies](#dependencies)
3. [Installation](#installation)
4. [Keybindings](#keybindings)
5. [Workspace Management](#workspace-management)
6. [Aesthetics](#aesthetics)
7. [Status Bar](#status-bar)
8. [Custom Scripts](#custom-scripts)
9. [Autostart Applications](#autostart-applications)
10. [Customization](#customization)
11. [Troubleshooting](#troubleshooting)
12. [Contributing](#contributing)
13. [License](#license)


## Features

- **Custom Keybindings**: Optimized for productivity and ease of use
- **Workspace Management**: Pre-configured workspaces with specific application assignments
- **Aesthetics**: 
  - Custom color scheme
  - Gap and border settings for a modern look
  - Random wallpaper selection
- **Status Bar**: Customized i3bar with i3status-rs
- **Application Launchers**: 
  - dmenu for quick program launching
  - Rofi for an enhanced application menu
- **Multimedia Controls**: Keybindings for volume and media playback
- **Screen Locking**: Custom lock screen configuration
- **Brightness Control**: Keybindings for adjusting screen brightness
- **Screenshot Utility**: Flameshot integration for powerful screenshot capabilities
- **Color Temperature Adjustment**: Redshift integration for eye comfort


## Dependencies

Ensure you have the following installed:

- i3-gaps
- i3status-rs
- Rofi
- Feh
- Flameshot
- Redshift
- Playerctl
- Brightnessctl
- FiraCode Nerd Font
- Kitty terminal emulator
- Vivaldi browser

## Installation

1. Clone this repository:
   ```
   git clone https://github.com/bewithsnehasish/dotfiles-i3.git ~/.config/i3
   ```
2. Install dependencies (method may vary based on your distribution)
3. Log out and log back in, selecting i3 as your window manager


## Keybindings

Note: `$mod` is set to the Windows key (Mod4) or whatever key you want to make it as your Hot key.

### Basic Controls

| Keybinding | Action |
|------------|--------|
| `$mod + Enter` | Open terminal (Kitty) |
| `$mod + q` | Kill focused window |
| `$mod + d` | Launch dmenu |
| `Mod1 + space` | Launch Rofi |
| `$mod + Shift + c` | Reload i3 configuration |
| `$mod + Shift + r` | Restart i3 |
| `$mod + Shift + e` | Exit i3 (with confirmation) |
| `Ctrl + Shift + e` | Launch wlogout |

### Window Management

| Keybinding | Action |
|------------|--------|
| `$mod + j` | Focus left |
| `$mod + k` | Focus down |
| `$mod + l` | Focus up |
| `$mod + semicolon` | Focus right |
| `$mod + Shift + j` | Move window left |
| `$mod + Shift + k` | Move window down |
| `$mod + Shift + l` | Move window up |
| `$mod + Shift + semicolon` | Move window right |
| `$mod + h` | Split horizontally |
| `$mod + v` | Split vertically |
| `$mod + f` | Toggle fullscreen |
| `$mod + s` | Change container layout to stacked |
| `$mod + w` | Change container layout to tabbed |
| `$mod + e` | Change container layout to toggle split |
| `$mod + Shift + space` | Toggle floating |
| `$mod + a` | Focus parent container |

### Workspace Management

| Keybinding | Action |
|------------|--------|
| `$mod + 1-9,0` | Switch to workspace 1-10 |
| `$mod + Shift + 1-9,0` | Move container to workspace 1-10 |
| `$mod + Alt + Left` | Move to previous workspace |
| `$mod + Alt + Right` | Move to next workspace |
| `$mod + Alt + h` | Move to previous workspace |
| `$mod + Alt + l` | Move to next workspace |

### Resizing

| Keybinding | Action |
|------------|--------|
| `$mod + r` | Enter resize mode |
| In resize mode: `j` | Shrink width |
| In resize mode: `k` | Grow height |
| In resize mode: `l` | Shrink height |
| In resize mode: `semicolon` | Grow width |
| In resize mode: `Left` | Shrink width |
| In resize mode: `Down` | Grow height |
| In resize mode: `Up` | Shrink height |
| In resize mode: `Right` | Grow width |
| In resize mode: `Enter/Escape/$mod + r` | Exit resize mode |

### Multimedia

> 💡 **Note/Tip:** This mulemdia X86Audio and any other functions all these are handled using the inbuilt function buttons with the **Fn** function key of the computer.

| Keybinding | Action |
|------------|--------|
| `XF86AudioRaiseVolume` | Increase volume |
| `XF86AudioLowerVolume` | Decrease volume |
| `XF86AudioMute` | Toggle mute |
| `XF86AudioPlay` | Play/Pause |
| `XF86AudioNext` | Next track |
| `XF86AudioPrev` | Previous track |

### Screen

| Keybinding | Action |
|------------|--------|
| `XF86MonBrightnessUp` | Increase brightness |
| `XF86MonBrightnessDown` | Decrease brightness |
| `$mod + x` | Lock screen |
| `Print` | Take screenshot with Flameshot |

### Applications

| Keybinding | Action |
|------------|--------|
| `$mod + b` | Launch Vivaldi browser |
| `Mod1 + b` | Launch Bluetooth settings with Rofi |


## Status Bar

Uses i3bar with i3status-rs for a customized status display.

## Custom Scripts

- Random wallpaper script: `~/.config/i3/random_wallpaper.sh`
- Lock screen script: `/home/$USER/.config/scripts/lock`

## Autostart Applications

- NetworkManager applet
- Redshift (set to 6500K)
- Brave browser

## Customization

Feel free to modify the config file (`~/.config/i3/config`) to suit your needs. Common customizations include:

- Changing keybindings
- Modifying workspace names and assignments
- Adjusting the color scheme
- Adding or removing autostart applications

## Troubleshooting

If you encounter issues:

1. Check the i3 log: `~/.xsession-errors`
2. Ensure all dependencies are installed
3. Verify your config syntax: `i3 -C`

## Contributing

If you have suggestions for improving this configuration, please open an issue or submit a pull request.

## License

This i3 configuration is released under the MIT License. See the [LICENSE](LICENSE) file for more details.