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

# ==============================================================================
# Wallpaper Architecture
# ==============================================================================

# Unlike most macOS preferences, wallpaper settings are stored in a
# SQLite database, NOT in plist files or defaults.
#
# WALLPAPER DATA STORAGE:
#
#   DATABASE LOCATION:
#   ~/Library/Application Support/Dock/desktoppicture.db
#
#   This is a SQLite database containing:
#   - data: Image path and settings per display/Space
#   - displays: Display identifiers
#   - pictures: Wallpaper configurations
#   - spaces: Per-Space wallpaper associations
#
# VIEW DATABASE CONTENTS:
#   sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db ".schema"
#   sqlite3 ~/Library/Application\ Support/Dock/desktoppicture.db "SELECT * FROM data"
#
# WALLPAPER SET METHODS (by reliability):
#
#   METHOD                      │ RELIABILITY │ NOTES
#   ────────────────────────────┼─────────────┼──────────────────────────
#   System Settings GUI         │ ★★★★★       │ Most reliable, per-Space
#   osascript (System Events)   │ ★★★★☆       │ Works well, see examples
#   Direct database edit        │ ★★★☆☆       │ Requires Dock restart
#   defaults write              │ ★★☆☆☆       │ Often doesn't persist
#
# MULTI-DISPLAY HANDLING:
#   - Each display can have different wallpaper
#   - Each Space can have different wallpaper
#   - Settings are per display UUID in the database
#
# DYNAMIC WALLPAPER (HEIC FORMAT):
#
#   Dynamic Desktop wallpapers use HEIC files with multiple images and
#   metadata specifying when each frame should appear.
#
#   HEIC Structure for Dynamic Wallpapers:
#   ┌─────────────────────────────────────────────────────────────────┐
#   │ HEIC Container (.heic file)                                    │
#   ├─────────────────────────────────────────────────────────────────┤
#   │ Frame 0 (Dawn - 5:00 AM)                                       │
#   │ Frame 1 (Morning - 8:00 AM)                                    │
#   │ Frame 2 (Midday - 12:00 PM)                                    │
#   │ Frame 3 (Afternoon - 3:00 PM)                                  │
#   │ Frame 4 (Sunset - 6:00 PM)                                     │
#   │ Frame 5 (Night - 9:00 PM)                                      │
#   │ ... (16 frames typical for Apple's dynamic wallpapers)         │
#   ├─────────────────────────────────────────────────────────────────┤
#   │ Metadata: solar position or time-based triggers                │
#   └─────────────────────────────────────────────────────────────────┘
#
#   Dynamic wallpapers can be:
#   - Time-based: Change at specific times
#   - Solar-based: Change based on sun position (requires location)
#   - Appearance-based: Light/Dark variants only
#
# SONOMA FEATURES (macOS 14+):
#   - Slow-motion video wallpapers (aerial views, abstract, etc.)
#   - Shuffle wallpapers on a schedule
#   - Photo library integration
#
# Source:       https://support.apple.com/guide/mac-help/mchlp3013/mac

msg_info "Configuring wallpaper settings..."

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
