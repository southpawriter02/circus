#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Focus Modes & Do Not Disturb
#
# DESCRIPTION:
#   Configures Focus modes (formerly Do Not Disturb) settings including
#   scheduling, allowed notifications, and automation.
#
# REQUIRES:
#   - macOS 12 (Monterey) or later for Focus modes
#   - macOS 10.15 (Catalina) for legacy Do Not Disturb
#
# REFERENCES:
#   - Apple Support: Use Focus on your Mac
#     https://support.apple.com/guide/mac-help/mchl613dc43f/mac
#
# DOMAIN:
#   com.apple.ncprefs
#   com.apple.donotdisturbd
#
# NOTES:
#   - Focus modes replaced Do Not Disturb in macOS Monterey
#   - Most Focus settings are synced via iCloud
#
# ==============================================================================

msg_info "Configuring Focus/Do Not Disturb settings..."

# ==============================================================================
# Do Not Disturb (Legacy & Fallback)
# ==============================================================================

# --- Do Not Disturb When Display is Sleeping ---
# Key:          dndDisplaySleep
# Domain:       com.apple.ncprefs
# Description:  Automatically enable Do Not Disturb when the display is off.
# Default:      false
# Options:      true = DND when display sleeps
#               false = Normal notifications
# Set to:       true (no notifications when screen is off)
run_defaults "com.apple.ncprefs" "dndDisplaySleep" "-bool" "true"

# --- Do Not Disturb When Mirroring ---
# Key:          dndMirroring
# Domain:       com.apple.ncprefs
# Description:  Enable Do Not Disturb during screen mirroring (presentations).
# Default:      true
# Options:      true = DND when mirroring
#               false = Show notifications
# Set to:       true (professional presentations)
run_defaults "com.apple.ncprefs" "dndMirroring" "-bool" "true"

# --- Do Not Disturb When Screen is Locked ---
# Key:          dndDisplayLock
# Domain:       com.apple.ncprefs
# Description:  Enable Do Not Disturb when the screen is locked.
# Default:      false
# Options:      true = DND when locked
#               false = Show notifications
# Set to:       true (privacy when away)
run_defaults "com.apple.ncprefs" "dndDisplayLock" "-bool" "true"

# ==============================================================================
# Focus Mode Defaults
# ==============================================================================

# Note: Focus modes are primarily configured through System Settings UI
# or via iCloud sync. The notification center preferences database
# controls some behavior, but direct manipulation is not recommended.

# --- Scheduled Do Not Disturb ---
# Note: Schedule is configured in System Settings > Focus > Do Not Disturb
# The schedule is stored in a complex plist format

msg_info "Focus modes are best configured in System Settings > Focus"

# ==============================================================================
# Notification Behavior During Focus
# ==============================================================================

# --- Allow Repeated Calls ---
# Note: This setting is per-Focus mode and configured in System Settings

# --- Allow Time Sensitive Notifications ---
# Note: This is managed per-Focus mode in System Settings

msg_success "Focus/Do Not Disturb settings configured."
