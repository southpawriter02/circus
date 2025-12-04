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

# --- Require Password After Sleep or Screen Saver ---
# Key:          askForPassword
# Description:  Controls whether a password is required to exit the screensaver
#               or wake the display from sleep. This is a critical security
#               setting that prevents unauthorized access to an unattended Mac.
#               When enabled, the login password (or Touch ID/Apple Watch) is
#               required to unlock.
# Default:      0 (disabled - no password required to wake)
# Options:      0 = Disabled (no authentication required to unlock)
#               1 = Enabled (password/Touch ID required to unlock)
# Set to:       1 (require password for security)
# UI Location:  System Settings > Lock Screen > Require password after screen
#               saver begins or display is turned off
# Source:       https://support.apple.com/guide/mac-help/require-a-password-after-waking-your-mac-mchlp2270/mac
# Security:     Essential for protecting data on shared or portable Macs.
#               Combine with a short password delay (see below) for maximum security.
run_defaults "com.apple.screensaver" "askForPassword" "-int" "1"

# --- Password Delay (Grace Period) ---
# Key:          askForPasswordDelay
# Description:  Sets the grace period (in seconds) after the screensaver begins
#               or display sleeps before a password is required. During this
#               window, the Mac can be woken without authentication. A value
#               of 0 means authentication is required immediately.
# Default:      5 (5 seconds grace period)
# Options:      Integer value in seconds:
#               0   = Immediately (no grace period, maximum security)
#               5   = 5 seconds (Apple's default)
#               60  = 1 minute
#               300 = 5 minutes
#               Any non-negative integer is accepted
# Set to:       0 (no grace period - maximum security)
# UI Location:  System Settings > Lock Screen > Require password after screen
#               saver begins or display is turned off (dropdown menu)
# Source:       https://support.apple.com/guide/mac-help/require-a-password-after-waking-your-mac-mchlp2270/mac
# Security:     A delay of 0 is strongly recommended for:
#               - Laptops used in public spaces
#               - Shared work environments
#               - Any Mac with sensitive data
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "0"


# ==============================================================================
# Screensaver Activation Settings
# ==============================================================================

# --- Idle Time Before Screen Saver Starts ---
# Key:          idleTime
# Description:  Sets the idle time (in seconds) before the screensaver starts.
#               The screensaver activates after no keyboard, mouse, or trackpad
#               activity for this duration. Video playback and presentations
#               typically prevent the screensaver from activating.
# Default:      1200 (20 minutes)
# Options:      Integer value in seconds:
#               0    = Never start screen saver (disabled)
#               60   = 1 minute
#               120  = 2 minutes
#               300  = 5 minutes
#               600  = 10 minutes
#               1200 = 20 minutes (Apple's default)
#               Any positive integer is accepted
# Set to:       600 (10 minutes - balanced between security and convenience)
# UI Location:  System Settings > Screen Saver > Start after (slider)
# Source:       https://support.apple.com/guide/mac-help/use-a-screen-saver-mchl4b68853d/mac
# See also:     https://support.apple.com/guide/mac-help/change-screen-saver-settings-mchlp1227/mac
# Note:         Coordinate this with display sleep settings in System Settings >
#               Energy Saver (or Battery on laptops) for optimal power management.
#               The display sleep time should typically be >= screensaver time.
run_defaults "com.apple.screensaver" "idleTime" "-int" "600"


msg_success "Screensaver settings applied."
