#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Date & Time
#
# DESCRIPTION:
#   Configures date, time, and timezone settings including NTP servers,
#   automatic timezone detection, and clock display options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require admin privileges
#
# REFERENCES:
#   - Apple Support: Set the date and time on your Mac
#     https://support.apple.com/guide/mac-help/mchlp2996/mac
#
# DOMAIN:
#   com.apple.menuextra.clock
#   com.apple.timed
#
# NOTES:
#   - NTP settings are typically managed via systemsetup
#   - Clock format is configured with DateFormat key
#
# ==============================================================================

msg_info "Configuring date and time settings..."

# ==============================================================================
# Clock Display (Menu Bar)
# ==============================================================================

# --- Clock Format ---
# Key:          DateFormat
# Domain:       com.apple.menuextra.clock
# Description:  Controls the format of the clock in the menu bar.
#               Uses Unicode date format patterns.
# Default:      "EEE MMM d  h:mm a" (e.g., "Thu Jan 2  9:30 AM")
# Examples:     "EEE MMM d  h:mm:ss a" = Include seconds
#               "EEE d MMM  HH:mm" = 24-hour format
#               "h:mm a" = Time only
# Set to:       Include date and use 24-hour format
# UI Location:  System Settings > Control Center > Clock
run_defaults "com.apple.menuextra.clock" "DateFormat" "-string" "EEE d MMM  HH:mm"

# --- Show AM/PM ---
# Key:          Show24Hour
# Domain:       com.apple.menuextra.clock
# Description:  Use 24-hour time format instead of 12-hour with AM/PM.
# Default:      false (12-hour)
# Options:      true = 24-hour format
#               false = 12-hour with AM/PM
# Set to:       true (24-hour format)
run_defaults "com.apple.menuextra.clock" "Show24Hour" "-bool" "true"

# --- Show Seconds ---
# Key:          ShowSeconds
# Domain:       com.apple.menuextra.clock
# Description:  Display seconds in the menu bar clock.
# Default:      false
# Options:      true = Show seconds
#               false = Hide seconds
# Set to:       false (cleaner look)
run_defaults "com.apple.menuextra.clock" "ShowSeconds" "-bool" "false"

# --- Flash Time Separators ---
# Key:          FlashDateSeparators
# Domain:       com.apple.menuextra.clock
# Description:  Flash the colon separators between hours and minutes.
# Default:      false
# Options:      true = Flash separators
#               false = Static display
# Set to:       false (static display)
run_defaults "com.apple.menuextra.clock" "FlashDateSeparators" "-bool" "false"

# --- Analog vs Digital ---
# Key:          IsAnalog
# Domain:       com.apple.menuextra.clock
# Description:  Show analog clock face instead of digital time.
# Default:      false (digital)
# Options:      true = Analog clock
#               false = Digital clock
# Set to:       false (digital)
run_defaults "com.apple.menuextra.clock" "IsAnalog" "-bool" "false"

# ==============================================================================
# Time Zone & NTP
# ==============================================================================

# --- Automatic Timezone ---
# Note: Timezone settings are managed via:
#   sudo systemsetup -setusingnetworktime on
#   sudo systemsetup -settimezone "America/Denver"

msg_info "Timezone: Use 'sudo systemsetup -settimezone <zone>'"
msg_info "NTP: Use 'sudo systemsetup -setusingnetworktime on'"

msg_success "Date and time settings configured."
