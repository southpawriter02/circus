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
# Description:  Automatically enables Do Not Disturb when the display is turned
#               off or sleeping. This prevents notification sounds, banners, and
#               alerts from appearing while your Mac's screen is inactive. Useful
#               for preventing disruptions during meetings or when stepping away.
# Default:      false (notifications continue when display sleeps)
# Options:      true = Enable DND automatically when display is off/sleeping
#               false = Continue showing notifications regardless of display state
# Set to:       true (prevent notification sounds and banners when the screen
#               is off; reduces disturbances when Mac is unattended)
# UI Location:  System Settings > Focus > Do Not Disturb > Turn On Automatically >
#               When the display is sleeping
# Source:       https://support.apple.com/guide/mac-help/mchl613dc43f/mac
# See also:     https://support.apple.com/en-us/105112
run_defaults "com.apple.ncprefs" "dndDisplaySleep" "-bool" "true"

# --- Do Not Disturb When Mirroring ---
# Key:          dndMirroring
# Domain:       com.apple.ncprefs
# Description:  Automatically enables Do Not Disturb when screen mirroring is
#               active (e.g., to a projector, Apple TV, or external display in
#               mirror mode). This prevents embarrassing notification popups
#               during presentations, screen shares, or demos.
# Default:      true (DND during mirroring is enabled by default)
# Options:      true = Enable DND when mirroring/projecting screen
#               false = Show notifications during mirroring (not recommended)
# Set to:       true (professional presentations; prevents personal or
#               sensitive notifications from appearing during screen shares)
# UI Location:  System Settings > Focus > Do Not Disturb > Turn On Automatically >
#               When mirroring to TVs and projectors
# Source:       https://support.apple.com/guide/mac-help/mchl613dc43f/mac
# Note:         This is especially important for video calls where screen
#               sharing is common (Zoom, Teams, Google Meet, etc.)
run_defaults "com.apple.ncprefs" "dndMirroring" "-bool" "true"

# --- Do Not Disturb When Screen is Locked ---
# Key:          dndDisplayLock
# Domain:       com.apple.ncprefs
# Description:  Automatically enables Do Not Disturb when the screen is locked
#               (via Cmd+Ctrl+Q, hot corner, or lock screen). This prevents
#               notification content from being visible on the lock screen,
#               protecting privacy when you step away from your Mac.
# Default:      false (notifications appear on lock screen)
# Options:      true = Enable DND when screen is locked (hide notifications)
#               false = Show notification previews on lock screen
# Set to:       true (privacy when away; prevents colleagues or passersby
#               from seeing your notification content)
# UI Location:  System Settings > Focus > Do Not Disturb > Turn On Automatically >
#               When the screen is locked
# Source:       https://support.apple.com/guide/mac-help/mchl613dc43f/mac
# Security:     Enabling prevents sensitive notification content (messages,
#               emails, calendar events) from being visible to others.
run_defaults "com.apple.ncprefs" "dndDisplayLock" "-bool" "true"

# ==============================================================================
# Focus Mode Defaults
# ==============================================================================

# --- Focus Mode Configuration ---
# Description:  Focus modes (Work, Personal, Sleep, etc.) are primarily configured
#               through the System Settings UI or via iCloud sync across devices.
#               The notification center preferences database controls some behavior,
#               but direct plist manipulation is fragile and not recommended.
# UI Location:  System Settings > Focus
# Source:       https://support.apple.com/guide/mac-help/mchl613dc43f/mac
# Note:         Custom Focus modes created in System Settings sync via iCloud
#               to your iPhone, iPad, and Apple Watch automatically.

# --- Scheduled Do Not Disturb ---
# Description:  Schedule allows automatic activation of DND at specific times
#               (e.g., 10 PM to 7 AM). The schedule is stored in a complex plist
#               format within the notification center preferences.
# UI Location:  System Settings > Focus > Do Not Disturb > Set a Schedule
# Note:         Best configured via System Settings UI for reliability

msg_info "Focus modes are best configured in System Settings > Focus"

# ==============================================================================
# Notification Behavior During Focus
# ==============================================================================

# --- Allow Repeated Calls ---
# Description:  When enabled, a second call from the same person within 3 minutes
#               will not be silenced. Useful for emergencies.
# UI Location:  System Settings > Focus > [Focus Name] > Options > Allow Repeated Calls
# Note:         Configured per-Focus mode via System Settings

# --- Allow Time Sensitive Notifications ---
# Description:  Time Sensitive notifications (marked by apps as urgent) can
#               break through Focus modes. Examples include delivery updates,
#               security alerts, and two-factor authentication codes.
# UI Location:  System Settings > Focus > [Focus Name] > Options
# Note:         Managed per-Focus mode in System Settings

msg_success "Focus/Do Not Disturb settings configured."
