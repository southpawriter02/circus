#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Wallpaper
#
# DESCRIPTION:
#   Configures desktop wallpaper settings including image path,
#   display mode, and dynamic wallpaper options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some features require macOS 14 (Sonoma) or later
#
# REFERENCES:
#   - Apple Support: Change your desktop picture
#     https://support.apple.com/guide/mac-help/mchlp3013/mac
#
# DOMAIN:
#   com.apple.desktop
#   com.apple.desktoppicture
#
# NOTES:
#   - Use osascript for more reliable wallpaper changes
#   - Dynamic wallpapers require .heic files
#
# ==============================================================================

msg_info "Configuring wallpaper settings..."

# ==============================================================================
# Wallpaper Setting Methods
# ==============================================================================

# Note: The most reliable way to set wallpaper is via osascript or
# the desktoppicture database. Direct defaults are less reliable.

# --- Set Wallpaper via osascript (Recommended) ---
# To set wallpaper programmatically:
#
# osascript -e 'tell application "System Events" to tell every desktop to set picture to "/path/to/image.jpg"'
#
# Or for a specific desktop:
# osascript -e 'tell application "System Events" to tell desktop 1 to set picture to "/path/to/image.jpg"'

msg_info "To set wallpaper, use:"
msg_info "  osascript -e 'tell application \"System Events\" to tell every desktop to set picture to \"/path/to/image.jpg\"'"

# ==============================================================================
# Default Wallpaper Locations
# ==============================================================================

# System wallpapers:
#   /System/Library/Desktop Pictures/
#
# Dynamic wallpapers (macOS Mojave+):
#   /System/Library/Desktop Pictures/*.heic
#
# User wallpapers:
#   ~/Pictures/
#
# Sonoma Dynamic wallpapers:
#   /System/Library/AssetsV2/com_apple_MobileAsset_OSXWallpaper/

# ==============================================================================
# Wallpaper Display Options
# ==============================================================================

# --- Picture Positioning ---
# Key:          display-mode
# Domain:       com.apple.desktoppicture
# Description:  How the wallpaper image is positioned on the desktop.
# Default:      0 (fill screen)
# Options:      0 = Fill Screen
#               1 = Fit to Screen
#               2 = Stretch to Fill
#               3 = Center
#               4 = Tile
# Note:         This is stored in a SQLite database, not defaults

msg_info "Wallpaper positioning is configured in System Settings > Wallpaper"

# ==============================================================================
# Dynamic Wallpaper
# ==============================================================================

# --- Dynamic Desktop ---
# Dynamic wallpapers change based on time of day
# They use .heic files with embedded time metadata
# 
# Options in System Settings:
#   - Dynamic: Changes throughout the day
#   - Light (Still): Static light version
#   - Dark (Still): Static dark version

# ==============================================================================
# Screen Saver as Wallpaper (macOS Sonoma+)
# ==============================================================================

# macOS Sonoma introduced the ability to use slow-motion screen savers
# as desktop wallpapers. This is configured in System Settings > Wallpaper

msg_success "Wallpaper settings information displayed."
msg_info "Set wallpaper via: System Settings > Wallpaper"
