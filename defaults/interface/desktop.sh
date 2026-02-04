#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Desktop Settings
#
# DESCRIPTION:
#   Configures desktop behavior including icon display, grid spacing, stacks,
#   and desktop management options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require Finder restart to take effect
#
# REFERENCES:
#   - Apple Support: Organize files in folders on Mac
#     https://support.apple.com/guide/mac-help/organize-files-in-folders-mh26885/mac
#   - Apple Support: Use desktop stacks on Mac
#     https://support.apple.com/guide/mac-help/use-desktop-stacks-mh35851/mac
#
# DOMAIN:
#   com.apple.finder
#   com.apple.desktop
#   com.apple.WindowManager
#
# NOTES:
#   - Desktop is managed by Finder, so many settings are in com.apple.finder
#   - Stage Manager settings affect desktop visibility
#
# ==============================================================================

# ==============================================================================
# Desktop Architecture
# ==============================================================================

# The macOS desktop is a special Finder window that displays ~/Desktop.
# It's deeply integrated with Finder, not a separate process.
#
# DESKTOP = FINDER:
#   - Desktop icons are rendered by Finder.app
#   - ~/Desktop folder appears both in Finder and on screen
#   - Desktop preferences are stored in com.apple.finder.plist
#
# DESKTOP LAYERS:
#   ┌─────────────────────────────────────────────────────────────────┐
#   │ Menu Bar                                                       │
#   ├─────────────────────────────────────────────────────────────────┤
#   │                                                                 │
#   │           Wallpaper (managed by desktoppicture.db)             │
#   │                                                                 │
#   │     ┌──────┐  ┌──────┐  ┌──────┐                              │
#   │     │ Icon │  │ Icon │  │Stack │  ← Desktop icons (Finder)     │
#   │     └──────┘  └──────┘  └──────┘                              │
#   │                                                                 │
#   │           Windows (WindowServer)                               │
#   │                                                                 │
#   ├─────────────────────────────────────────────────────────────────┤
#   │ Dock                                                           │
#   └─────────────────────────────────────────────────────────────────┘
#
# STACKS (macOS Mojave+):
#   Stacks automatically group desktop files by type, date, or tag.
#   
#   Enable via: Right-click Desktop > Use Stacks
#   
#   Stack grouping options:
#   - Kind: Group by file type (Documents, Images, Screenshots, etc.)
#   - Date Last Opened: Group by when you last opened them
#   - Date Added: Group by when they appeared on desktop
#   - Date Modified: Group by when they were last changed
#   - Date Created: Group by creation date
#   - Tags: Group by Finder tags
#
# WALLPAPER APIs:
#   macOS stores wallpaper preferences in:
#   ~/Library/Application Support/Dock/desktoppicture.db (SQLite)
#   
#   Set wallpaper via Terminal:
#   # Set static image
#   osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/path/to/image.jpg"'
#   
#   # Set for specific display (requires more complex AppleScript)
#   # For per-Space wallpapers, use System Settings
#   
#   # Read current wallpaper
#   osascript -e 'tell application "Finder" to get POSIX path of (desktop picture as alias)'
#
# DYNAMIC WALLPAPERS:
#   .heic files can contain multiple images for time-of-day changes.
#   Located in: /System/Library/Desktop Pictures/
#   Custom dynamic wallpapers require special HEIC metadata.
#
# Source:       https://support.apple.com/guide/mac-help/use-desktop-stacks-mh35851/mac

msg_info "Configuring desktop settings..."

# ==============================================================================
# Desktop Icons
# ==============================================================================

# --- Show Icons on Desktop ---
# Key:          CreateDesktop
# Domain:       com.apple.finder
# Description:  Controls whether any icons are shown on the desktop.
#               When disabled, the desktop is completely empty.
# Default:      true (show icons)
# Options:      true = Show desktop icons
#               false = Hide all desktop icons
# Set to:       true (show icons on desktop)
# Note:         Useful to disable for clean screenshots or minimalist setup
run_defaults "com.apple.finder" "CreateDesktop" "-bool" "true"

# --- Show Hard Drives on Desktop ---
# Key:          ShowHardDrivesOnDesktop
# Domain:       com.apple.finder
# Description:  Show internal hard drive icons on the desktop.
# Default:      false
# Options:      true = Show hard drives, false = Hide hard drives
# Set to:       false (keep desktop clean)
# UI Location:  Finder > Settings > General > Show these items on the desktop
run_defaults "com.apple.finder" "ShowHardDrivesOnDesktop" "-bool" "false"

# --- Show External Drives on Desktop ---
# Key:          ShowExternalHardDrivesOnDesktop
# Domain:       com.apple.finder
# Description:  Show external drive icons (USB, Thunderbolt) on the desktop.
# Default:      true
# Options:      true = Show external drives, false = Hide external drives
# Set to:       true (show external drives for easy access)
# UI Location:  Finder > Settings > General > Show these items on the desktop
run_defaults "com.apple.finder" "ShowExternalHardDrivesOnDesktop" "-bool" "true"

# --- Show Removable Media on Desktop ---
# Key:          ShowRemovableMediaOnDesktop
# Domain:       com.apple.finder
# Description:  Show removable media (CDs, DVDs, iPods) on the desktop.
# Default:      true
# Options:      true = Show removable media, false = Hide removable media
# Set to:       true (show for easy ejection)
# UI Location:  Finder > Settings > General > Show these items on the desktop
run_defaults "com.apple.finder" "ShowRemovableMediaOnDesktop" "-bool" "true"

# --- Show Connected Servers on Desktop ---
# Key:          ShowMountedServersOnDesktop
# Domain:       com.apple.finder
# Description:  Show network server mount icons on the desktop.
# Default:      false
# Options:      true = Show servers, false = Hide servers
# Set to:       false (access via Finder sidebar instead)
# UI Location:  Finder > Settings > General > Show these items on the desktop
run_defaults "com.apple.finder" "ShowMountedServersOnDesktop" "-bool" "false"

# ==============================================================================
# Desktop Stacks
# ==============================================================================

# --- Enable Desktop Stacks ---
# Key:          _FXSortFoldersFirstOnDesktop
# Domain:       com.apple.finder
# Description:  Note: Stacks are controlled via View menu or right-click desktop.
#               This setting controls whether folders appear first in sort order.
# Default:      false
# Options:      true = Folders first, false = Mixed with files
# Set to:       true (keep folders organized at top)
run_defaults "com.apple.finder" "_FXSortFoldersFirstOnDesktop" "-bool" "true"

# ==============================================================================
# Desktop View Options
# ==============================================================================

# --- Desktop Icon Size ---
# Key:          DesktopViewSettings:IconViewSettings:iconSize
# Domain:       com.apple.finder
# Description:  Size of icons on the desktop in pixels.
# Default:      64
# Options:      16-128 (pixels)
# Set to:       64 (default comfortable size)
# UI Location:  Right-click Desktop > Show View Options > Icon size
# Note:         This is set via Finder view options, stored as plist data

# --- Desktop Grid Spacing ---
# Key:          DesktopViewSettings:IconViewSettings:gridSpacing
# Domain:       com.apple.finder
# Description:  Spacing between desktop icons.
# Default:      54
# Options:      Integer value
# UI Location:  Right-click Desktop > Show View Options > Grid spacing

# --- Desktop Text Size ---
# Key:          DesktopViewSettings:IconViewSettings:textSize
# Domain:       com.apple.finder
# Description:  Font size for desktop icon labels.
# Default:      12
# Options:      10-16
# UI Location:  Right-click Desktop > Show View Options > Text size

# --- Desktop Label Position ---
# Key:          DesktopViewSettings:IconViewSettings:labelOnBottom
# Domain:       com.apple.finder
# Description:  Position of icon labels.
# Default:      true (labels below icons)
# Options:      true = Bottom, false = Right
# UI Location:  Right-click Desktop > Show View Options > Label position

# NOTE: The above settings are stored in ~/Library/Preferences/com.apple.finder.plist
# as nested dictionaries. They're best set through the Finder GUI:
# 1. Right-click on Desktop
# 2. Select "Show View Options"
# 3. Adjust settings
# 4. Click "Use as Defaults"

# ==============================================================================
# Desktop Background
#
# NOTE: Desktop wallpaper is set via:
# - System Settings > Wallpaper
# - Right-click Desktop > Change Wallpaper
# - osascript commands
#
# Set wallpaper via command line:
#   osascript -e 'tell application "Finder" to set desktop picture to POSIX file "/path/to/image.jpg"'
#
# Dynamic wallpapers (.heic files) require special handling.
#
# ==============================================================================

# ==============================================================================
# Stage Manager (macOS Ventura+)
# ==============================================================================

# --- Enable Stage Manager ---
# Key:          GloballyEnabled
# Domain:       com.apple.WindowManager
# Description:  Enable or disable Stage Manager window management feature.
# Default:      false
# Options:      true = Enable Stage Manager
#               false = Disable Stage Manager (traditional desktop)
# Set to:       false (use traditional desktop)
# UI Location:  System Settings > Desktop & Dock > Stage Manager
run_defaults "com.apple.WindowManager" "GloballyEnabled" "-bool" "false"

# --- Show Desktop Items with Stage Manager ---
# Key:          StandardHideDesktopIcons
# Domain:       com.apple.WindowManager
# Description:  When Stage Manager is enabled, controls whether desktop
#               icons are visible or hidden.
# Default:      false (show icons)
# Options:      true = Hide desktop icons, false = Show desktop icons
# Set to:       false (show icons if Stage Manager is used)
# UI Location:  System Settings > Desktop & Dock > Stage Manager settings
run_defaults "com.apple.WindowManager" "StandardHideDesktopIcons" "-bool" "false"

# --- Hide Desktop When Clicking Wallpaper ---
# Key:          EnableStandardClickToShowDesktop
# Domain:       com.apple.WindowManager
# Description:  Click wallpaper to show desktop (hides all windows temporarily).
# Default:      true
# Options:      true = Click wallpaper shows desktop
#               false = Click wallpaper does nothing
# Set to:       true (useful shortcut to see desktop)
# UI Location:  System Settings > Desktop & Dock > Click wallpaper to show desktop
run_defaults "com.apple.WindowManager" "EnableStandardClickToShowDesktop" "-bool" "true"

msg_success "Desktop settings configured."

# ==============================================================================
# Restart Finder
#
# Desktop settings require restarting Finder:
#   killall Finder
#
# Or log out and back in for all changes to take effect.
#
# ==============================================================================
