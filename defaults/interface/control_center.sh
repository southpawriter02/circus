#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Control Center Settings
#
# DESCRIPTION:
#   Configures which items appear in Control Center and the menu bar.
#   Control Center was introduced in macOS Big Sur as a centralized
#   location for system toggles and settings.
#
# REQUIRES:
#   - macOS 11.0 (Big Sur) or later
#   - Some settings require logout to take effect
#
# REFERENCES:
#   - Apple Support: Use Control Center on Mac
#     https://support.apple.com/guide/mac-help/control-center-mchl50f94f8f/mac
#   - Apple Support: Customize Control Center and menu bar
#     https://support.apple.com/guide/mac-help/customize-control-center-mchlcc81ad61/mac
#
# DOMAIN:
#   com.apple.controlcenter
#
# NOTES:
#   - Each module has a visibility value controlling where it appears
#   - Third-party menu bar items are not controlled by Control Center
#   - Some modules are always in Control Center (WiFi, Bluetooth, etc.)
#
# ==============================================================================

msg_info "Configuring Control Center settings..."

# ==============================================================================
# Module Visibility Values
#
# Each Control Center module can have one of these visibility settings:
#   0  = Not in menu bar or Control Center (disabled)
#   2  = Always show in menu bar
#   8  = Show in menu bar when active/in-use
#   18 = Show in Control Center only (default for most)
#   24 = Don't show anywhere
#
# Some modules are always visible in Control Center regardless of setting.
#
# ==============================================================================

# ==============================================================================
# Connectivity Modules
# ==============================================================================

# --- WiFi ---
# Key:          WiFi
# Description:  WiFi status and quick toggle.
# Default:      2 (always in menu bar)
# Set to:       2 (always visible in menu bar)
# UI Location:  System Settings > Control Center > Wi-Fi
run_defaults "com.apple.controlcenter" "WiFi" "-int" "2"

# --- Bluetooth ---
# Key:          Bluetooth
# Description:  Bluetooth status, toggle, and device list.
# Default:      18 (Control Center only)
# Set to:       2 (always show in menu bar for quick access)
# UI Location:  System Settings > Control Center > Bluetooth
run_defaults "com.apple.controlcenter" "Bluetooth" "-int" "2"

# --- AirDrop ---
# Key:          AirDrop
# Description:  AirDrop receiving settings (Off, Contacts Only, Everyone).
# Default:      18 (Control Center only)
# Set to:       18 (keep in Control Center only)
# UI Location:  System Settings > Control Center > AirDrop
run_defaults "com.apple.controlcenter" "AirDrop" "-int" "18"

# ==============================================================================
# Focus & Notifications
# ==============================================================================

# --- Focus / Do Not Disturb ---
# Key:          FocusModes
# Description:  Focus mode status and quick toggle.
# Default:      18 (Control Center only)
# Set to:       18 (access via Control Center when needed)
# UI Location:  System Settings > Control Center > Focus
run_defaults "com.apple.controlcenter" "FocusModes" "-int" "18"

# ==============================================================================
# Display & Sound
# ==============================================================================

# --- Display ---
# Key:          Display
# Description:  Brightness, Night Shift, True Tone, AirPlay Display.
# Default:      18 (Control Center only)
# Set to:       18 (keep in Control Center)
# UI Location:  System Settings > Control Center > Display
run_defaults "com.apple.controlcenter" "Display" "-int" "18"

# --- Sound ---
# Key:          Sound
# Description:  Volume control and output device selection.
# Default:      18 (Control Center only)
# Set to:       2 (always show in menu bar for quick volume access)
# UI Location:  System Settings > Control Center > Sound
run_defaults "com.apple.controlcenter" "Sound" "-int" "2"

# --- Now Playing ---
# Key:          NowPlaying
# Description:  Shows currently playing media with playback controls.
# Default:      8 (show when active)
# Set to:       8 (show when media is playing)
# UI Location:  System Settings > Control Center > Now Playing
run_defaults "com.apple.controlcenter" "NowPlaying" "-int" "8"

# ==============================================================================
# Battery & Power
# ==============================================================================

# --- Battery ---
# Key:          Battery
# Description:  Battery level, charging status, and power preferences.
# Default:      2 (always in menu bar on laptops)
# Set to:       2 (always show on laptops)
# UI Location:  System Settings > Control Center > Battery
# Note:         Only appears on laptops/with UPS
run_defaults "com.apple.controlcenter" "Battery" "-int" "2"

# ==============================================================================
# Productivity
# ==============================================================================

# --- Screen Mirroring ---
# Key:          ScreenMirroring
# Description:  AirPlay to external displays or Apple TV.
# Default:      8 (show when active)
# Set to:       8 (show when mirroring)
# UI Location:  System Settings > Control Center > Screen Mirroring
run_defaults "com.apple.controlcenter" "ScreenMirroring" "-int" "8"

# --- Stage Manager ---
# Key:          StageManager
# Description:  Toggle Stage Manager window management.
# Default:      18 (Control Center only)
# Set to:       18 (access via Control Center)
# UI Location:  System Settings > Control Center > Stage Manager
# Note:         Only available on macOS Ventura and later
run_defaults "com.apple.controlcenter" "StageManager" "-int" "18"

# ==============================================================================
# Accessibility
# ==============================================================================

# --- Accessibility Shortcuts ---
# Key:          AccessibilityShortcuts
# Description:  Quick access to accessibility features.
# Default:      18 (Control Center only)
# Set to:       18 (access via Control Center when needed)
# UI Location:  System Settings > Control Center > Accessibility Shortcuts
run_defaults "com.apple.controlcenter" "AccessibilityShortcuts" "-int" "18"

# --- Hearing ---
# Key:          Hearing
# Description:  Hearing accessibility controls including Live Listen.
# Default:      18 (Control Center only)
# Set to:       18 (access via Control Center)
# UI Location:  System Settings > Control Center > Hearing
run_defaults "com.apple.controlcenter" "Hearing" "-int" "18"

# ==============================================================================
# User & Account
# ==============================================================================

# --- Fast User Switching ---
# Key:          UserSwitcher
# Description:  Quick switch between user accounts.
# Default:      18 (Control Center only)
# Set to:       18 (access via Control Center, menu bar gets crowded)
# UI Location:  System Settings > Control Center > Fast User Switching
run_defaults "com.apple.controlcenter" "UserSwitcher" "-int" "18"

# ==============================================================================
# Keyboard & Input
# ==============================================================================

# --- Keyboard Brightness ---
# Key:          KeyboardBrightness
# Description:  Adjust backlit keyboard brightness.
# Default:      18 (Control Center only)
# Set to:       18 (access via Control Center)
# UI Location:  System Settings > Control Center > Keyboard Brightness
# Note:         Only on Macs with backlit keyboards
run_defaults "com.apple.controlcenter" "KeyboardBrightness" "-int" "18"

msg_success "Control Center settings configured."

# ==============================================================================
# Restart Control Center
#
# Control Center changes typically require logging out and back in,
# or restarting the ControlCenter process:
#   killall ControlCenter
#
# Note: Some menu bar items are managed by SystemUIServer:
#   killall SystemUIServer
#
# ==============================================================================
