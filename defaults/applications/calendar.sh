#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Calendar Configuration
#
# DESCRIPTION:
#   This script configures Apple Calendar preferences including the first day
#   of the week, default calendar duration, time zone support, and display
#   options. Calendar syncs events across devices via iCloud.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Calendar app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Use Calendar on Mac
#     https://support.apple.com/guide/calendar/welcome/mac
#   - Apple Support: Change Calendar preferences
#     https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
#
# DOMAIN:
#   com.apple.iCal
#
# NOTES:
#   - Calendar preferences are stored in ~/Library/Preferences/com.apple.iCal.plist
#   - Event data is stored in ~/Library/Calendars/
#   - iCloud calendars sync automatically when signed in
#   - Some settings require Calendar to be restarted to take effect
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Calendar preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Calendar settings..."

# ==============================================================================
# Week Settings
# ==============================================================================

# --- First Day of Week ---
# Key:          "first day of week"
# Domain:       com.apple.iCal
# Description:  Sets which day the week starts on in Calendar views. This affects
#               both the week view and how weeks are displayed in month view.
# Default:      0 (Sunday)
# Options:      0 = Sunday
#               1 = Monday
#               2 = Tuesday
#               3 = Wednesday
#               4 = Thursday
#               5 = Friday
#               6 = Saturday
# Set to:       1 (Monday - ISO 8601 standard)
# UI Location:  Calendar > Settings > General > Start week on
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "first day of week" "-int" "1"

# --- Scroll in Week View ---
# Key:          "scroll by weeks in week view"
# Domain:       com.apple.iCal
# Description:  Controls whether scrolling in week view moves by day or by week.
#               When enabled, scrolling jumps a full week at a time.
# Default:      false (scroll by day)
# Options:      true  = Scroll by week
#               false = Scroll by day
# Set to:       true (easier navigation)
# UI Location:  Calendar > Settings > General > Scroll in week view by
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "scroll by weeks in week view" "-bool" "true"

# ==============================================================================
# Day View Settings
# ==============================================================================

# --- Day Start Time ---
# Key:          "first minute of work hours"
# Domain:       com.apple.iCal
# Description:  Sets the starting hour for the workday in day and week views.
#               Hours before this time appear compressed. Value is in minutes
#               from midnight (e.g., 480 = 8:00 AM).
# Default:      480 (8:00 AM)
# Options:      0-1439 (minutes from midnight)
#               Common values:
#               360 = 6:00 AM
#               420 = 7:00 AM
#               480 = 8:00 AM
#               540 = 9:00 AM
# Set to:       540 (9:00 AM)
# UI Location:  Calendar > Settings > General > Day starts at
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "first minute of work hours" "-int" "540"

# --- Day End Time ---
# Key:          "last minute of work hours"
# Domain:       com.apple.iCal
# Description:  Sets the ending hour for the workday in day and week views.
#               Hours after this time appear compressed. Value is in minutes
#               from midnight (e.g., 1020 = 5:00 PM).
# Default:      1020 (5:00 PM)
# Options:      0-1439 (minutes from midnight)
#               Common values:
#               1020 = 5:00 PM
#               1080 = 6:00 PM
#               1140 = 7:00 PM
# Set to:       1080 (6:00 PM)
# UI Location:  Calendar > Settings > General > Day ends at
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "last minute of work hours" "-int" "1080"

# --- Show Hours at a Time ---
# Key:          "number of hours displayed"
# Domain:       com.apple.iCal
# Description:  Controls how many hours are visible at once in day and week views
#               without scrolling.
# Default:      12
# Options:      6, 8, 10, 12, 14, 16, 18, 24
# Set to:       12 (balanced view)
# UI Location:  Calendar > Settings > General > Show X hours at a time
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "number of hours displayed" "-int" "12"

# ==============================================================================
# Event Settings
# ==============================================================================

# --- Default Event Duration ---
# Key:          "Default duration in minutes for new event"
# Domain:       com.apple.iCal
# Description:  Sets the default length for new events when created by clicking
#               on the calendar (not by dragging).
# Default:      60 (1 hour)
# Options:      15, 30, 45, 60, 90, 120 (minutes)
# Set to:       30 (shorter meetings by default)
# UI Location:  Calendar > Settings > General > Default event duration
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "Default duration in minutes for new event" "-int" "30"

# --- Show Birthdays Calendar ---
# Key:          "display birthdays calendar"
# Domain:       com.apple.iCal
# Description:  Controls whether the Birthdays calendar (pulled from Contacts)
#               appears in the calendar list.
# Default:      true
# Options:      true  = Show birthdays from Contacts
#               false = Hide birthdays calendar
# Set to:       true (useful reminder)
# UI Location:  Calendar > Settings > General > Show Birthdays calendar
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "display birthdays calendar" "-bool" "true"

# --- Show Holidays Calendar ---
# Key:          "add holiday calendar"
# Domain:       com.apple.iCal
# Description:  Controls whether the regional Holidays calendar appears in the
#               calendar list, showing public holidays for your region.
# Default:      true
# Options:      true  = Show holidays calendar
#               false = Hide holidays calendar
# Set to:       true (useful for planning)
# UI Location:  Calendar > Settings > General > Show Holidays calendar
# Source:       https://support.apple.com/guide/calendar/change-general-preferences-icl1023/mac
run_defaults "com.apple.iCal" "add holiday calendar" "-bool" "true"

# ==============================================================================
# Time Zone Settings
# ==============================================================================

# --- Time Zone Support ---
# Key:          "TimeZone support enabled"
# Domain:       com.apple.iCal
# Description:  Enables time zone support, allowing events to be set to specific
#               time zones. Useful for scheduling across time zones.
# Default:      false
# Options:      true  = Enable time zone support
#               false = Disable time zone support
# Set to:       true (important for remote work)
# UI Location:  Calendar > Settings > Advanced > Turn on time zone support
# Source:       https://support.apple.com/guide/calendar/change-advanced-preferences-icl1027/mac
run_defaults "com.apple.iCal" "TimeZone support enabled" "-bool" "true"

# ==============================================================================
# Alert Settings
# ==============================================================================

# --- Default All-Day Event Alert ---
# Key:          "DefaultAllDayEventAlert"
# Domain:       com.apple.iCal
# Description:  Sets the default alert time for all-day events. Value represents
#               when the alert fires relative to the event.
# Default:      -39600 (9:00 AM day of event, represented as seconds)
# Options:      Various negative values in seconds
# Set to:       -39600 (9:00 AM on event day)
# UI Location:  Calendar > Settings > Alerts > All-day events
# Source:       https://support.apple.com/guide/calendar/change-alerts-preferences-icl1026/mac
run_defaults "com.apple.iCal" "DefaultAllDayEventAlert" "-int" "-39600"

# --- Show Shared Calendar Messages in Notification Center ---
# Key:          "SharedCalendarNotificationsDisabled"
# Domain:       com.apple.iCal
# Description:  Controls whether shared calendar invitations and updates appear
#               in Notification Center.
# Default:      false (notifications enabled)
# Options:      true  = Disable shared calendar notifications
#               false = Enable shared calendar notifications
# Set to:       false (stay informed about shared events)
# UI Location:  Calendar > Settings > Alerts
# Source:       https://support.apple.com/guide/calendar/change-alerts-preferences-icl1026/mac
run_defaults "com.apple.iCal" "SharedCalendarNotificationsDisabled" "-bool" "false"

msg_success "Calendar settings applied."
msg_info "Restart Calendar for all settings to take effect."
