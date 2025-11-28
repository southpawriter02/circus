#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Screen Saver & Screen Lock Configuration
#
# DESCRIPTION:
#   This script configures the macOS screen saver and screen lock settings.
#   These settings are critical for physical security, ensuring that an
#   unattended Mac requires authentication to access.
#
# REQUIRES:
#   - macOS 10.7 (Lion) or later for askForPassword settings
#   - macOS 10.13 (High Sierra) or later for some settings
#
# REFERENCES:
#   - Apple Support: Change your Mac's lock screen and login window
#     https://support.apple.com/guide/mac-help/change-lock-screen-settings-mchl8a3b1a59/mac
#   - Apple Security: Best practices
#     https://support.apple.com/guide/mac-help/protect-your-mac-from-malware-mh40596/mac
#
# DOMAIN:
#   com.apple.screensaver
#
# NOTES:
#   - These settings apply to the current user only
#   - Screen lock integrates with Touch ID and Apple Watch unlock
#   - Hot Corners can be configured in mission_control.sh to trigger the screensaver
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Screensaver preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Screensaver settings..."

# ==============================================================================
# Screen Lock Security Settings
# ==============================================================================

# --- Require Password Immediately ---
# Key:          askForPassword
# Description:  Controls whether a password is required to exit the screensaver
#               or wake the display. This is a critical security setting that
#               prevents unauthorized access to an unattended Mac.
# Default:      0 (false - no password required)
# Possible:     0 = No password required
#               1 = Password required
# Set to:       1 (require password for security)
# Reference:    System Preferences > Security & Privacy > General
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- Password Delay ---
# Key:          askForPasswordDelay
# Description:  Sets the grace period (in seconds) after the screensaver begins
#               before a password is required. A value of 0 means the password
#               is required immediately when the screensaver activates.
# Default:      5 (seconds)
# Possible:     Any non-negative integer (seconds)
#               Common values: 0, 5, 60, 300
# Set to:       0 (no grace period - maximum security)
# Reference:    System Preferences > Security & Privacy > General
# Security:     A delay of 0 is recommended for environments where quick
#               unattended access could be a concern.
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"


# ==============================================================================
# Screensaver Activation Settings
# ==============================================================================

# --- Idle Time Before Start ---
# Key:          idleTime
# Description:  Sets the idle time (in seconds) before the screensaver starts.
#               The screensaver activates after no keyboard or mouse activity
#               for this duration.
# Default:      1200 (20 minutes)
# Possible:     Any positive integer (seconds), or 0 to disable
#               Common values: 120 (2 min), 300 (5 min), 600 (10 min), 1200 (20 min)
# Set to:       600 (10 minutes - balanced between security and convenience)
# Reference:    System Preferences > Desktop & Screen Saver > Screen Saver
# Note:         Consider coordinating this with display sleep settings in
#               Energy Saver preferences for optimal power management.
run_defaults "com.apple.screensaver" "idleTime" "-int" "600"


msg_success "Screensaver settings applied."
