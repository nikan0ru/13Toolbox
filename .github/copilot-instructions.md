# Ubuntu System Automation Utility

## Project Overview
This is a bash-based automation suite (`script.sh`) that streamlines Ubuntu 20.04 system configuration and maintenance. The project focuses on user-level operations without requiring sudo privileges.

## Core Architecture

### Main Entry Point
- `script.sh` - Single script with modular functions for different system operations
- Uses command-line flags for specific operations or runs default settings when no args provided
- Functions are organized by system area: bluetooth, display, themes, applications, brightness

### Key Functions & Usage Patterns
```bash
# Individual operations
./script.sh -bth    # Remove all paired Bluetooth devices
./script.sh -d      # Set display to 2560x1440 + Win10Sur icons
./script.sh -t      # Auto theme switching based on time (dark 8PM-7AM)
./script.sh -u      # Update favorite apps (Firefox, Spotify, VSCode)
./script.sh -s      # Fix Spotify Wayland issues
./script.sh -b      # Set brightness level
```

## Configuration Files & Data
- `userData.json` - User preferences and state tracking (FreshStart flag, theme preferences, etc.)
- `app_list` - Live flatpak application inventory (system-level installations)
- `Theme_list.txt` - Available GTK themes mapping (light/dark pairs)
- `display_resolutions_list` - Supported display resolutions with refresh rates
- `icons_list` - Available icon themes

## Environment Specifics
- **Package Management**: Exclusively uses Flatpak for application management
- **Display System**: Uses `xrandr` for resolution changes and `gsettings` for GNOME configuration
- **Theme System**: GNOME/GTK themes with automatic light/dark switching based on time
- **No Sudo Required**: All operations work at user-level (flatpak user overrides, gsettings, etc.)

## Development Patterns
- Functions use `declare` for typed variables and arrays
- Color codes defined globally for consistent terminal output
- Error handling with conditional returns and user feedback
- JSON manipulation using `jq` with `sponge` for in-place editing
- Array-based batch operations (especially for Bluetooth device removal)

## Integration Points
- **Flatpak**: Primary software distribution method - check `app_list` for available applications
- **GNOME Settings**: Theme, icon, and color-scheme management via `gsettings`
- **Bluetooth**: Uses `bluetoothctl` for device management
- **Display**: `xrandr` for resolution, brightness control
- **Time-based Logic**: Theme switching uses `date +"%H:%M"` comparison

## Common Workflows
1. **Adding New Apps**: Update `APPLICATIONS` array in `update_favourites()` function
2. **Theme Management**: Modify time thresholds in `theme_switcher()` or add new themes from `Theme_list.txt`
3. **Display Configs**: Reference `display_resolutions_list` for supported resolutions
4. **Bluetooth Operations**: Extend `bluetooth_mangler()` for additional device management

When extending functionality, follow the existing pattern of discrete functions with clear command-line flag mapping in `main()`.
