#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Calendar Configuration (Work Role)
#
# DESCRIPTION:
#   Work-specific calendar settings that layer on top of global defaults.
#   Optimized for professional environments with meeting-heavy schedules.
#   Run after: defaults/applications/calendar.sh
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
#   - These settings override/extend the global calendar defaults
#   - Work calendar should be configured as default in iCloud settings
#   - Settings optimize for meeting-heavy professional environment
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Work Calendar preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Applying work-specific Calendar settings..."

# ==============================================================================
# Week View Settings (Work Week Focus)
# ==============================================================================

# --- First Day of Week ---
# Key:          first day of week
# Domain:       com.apple.iCal
# Description:  Work weeks typically start on Monday in professional settings.
# Global:       0 (Sunday)
# Set to:       1 (Monday - standard business week start)
run_defaults "com.apple.iCal" "first day of week" "-int" "1"

# --- Days Per Week ---
# Key:          n days of week
# Domain:       com.apple.iCal
# Description:  Show 5-day work week in week view for focused scheduling.
# Global:       7 (full week)
# Set to:       5 (work week only)
run_defaults "com.apple.iCal" "n days of week" "-int" "5"

# --- Show Week Numbers ---
# Key:          Show Week Numbers
# Domain:       com.apple.iCal
# Description:  Helpful for quarterly planning and sprint tracking.
# Global:       false
# Set to:       true (useful for planning meetings by week number)
run_defaults "com.apple.iCal" "Show Week Numbers" "-bool" "true"

# ==============================================================================
# Work Hours Configuration
# ==============================================================================

# --- Day Start Hour ---
# Key:          first minute of work hours
# Domain:       com.apple.iCal
# Description:  Standard work day start time (minutes from midnight).
# Global:       480 (8:00 AM)
# Set to:       540 (9:00 AM - typical office start)
run_defaults "com.apple.iCal" "first minute of work hours" "-int" "540"

# --- Day End Hour ---
# Key:          last minute of work hours
# Domain:       com.apple.iCal
# Description:  Standard work day end time (minutes from midnight).
# Global:       1020 (5:00 PM)
# Set to:       1020 (5:00 PM - typical office end)
run_defaults "com.apple.iCal" "last minute of work hours" "-int" "1020"

# --- Show Work Hours Only ---
# Key:          Show only work hours
# Domain:       com.apple.iCal
# Description:  Focus calendar view on work hours to reduce clutter.
# Global:       false
# Set to:       true (hide non-work hours in day/week view)
# Note:         All-day events and events outside hours still visible
run_defaults "com.apple.iCal" "Show only work hours" "-bool" "true"

# ==============================================================================
# Default Event Settings (Meeting-Optimized)
# ==============================================================================

# --- Default Event Duration ---
# Key:          Default duration in minutes for new event
# Domain:       com.apple.iCal
# Description:  Default meeting length for quick scheduling.
# Global:       60 (1 hour)
# Set to:       30 (30 minutes - encourages shorter meetings)
run_defaults "com.apple.iCal" "Default duration in minutes for new event" "-int" "30"

# --- Default All-Day Event Duration ---
# Key:          Default All Day Event duration
# Domain:       com.apple.iCal
# Description:  Duration for all-day events like out-of-office.
# Global:       1 (1 day)
# Set to:       1 (single day)
run_defaults "com.apple.iCal" "Default All Day Event duration" "-int" "1"

# ==============================================================================
# Alert Settings (Meeting Reminders)
# ==============================================================================

# --- Default Event Alert ---
# Key:          default alarm offset
# Domain:       com.apple.iCal
# Description:  Primary reminder before events (in seconds, negative = before).
# Global:       -900 (15 minutes before)
# Set to:       -900 (15 minutes - time to wrap up and transition)
run_defaults "com.apple.iCal" "default alarm offset" "-int" "-900"

# --- Second Alert ---
# Key:          CalDefaultSecondAlarmOffset
# Domain:       com.apple.iCal
# Description:  Secondary reminder for important meetings.
# Set to:       -300 (5 minutes before - final reminder)
run_defaults "com.apple.iCal" "CalDefaultSecondAlarmOffset" "-int" "-300"

# --- All-Day Event Alert ---
# Key:          default all day alarm offset
# Domain:       com.apple.iCal
# Description:  Reminder for all-day events (in seconds, negative = before).
# Global:       -32400 (9 hours before = day before at 3pm)
# Set to:       -32400 (morning of the event)
run_defaults "com.apple.iCal" "default all day alarm offset" "-int" "-32400"

# ==============================================================================
# Travel Time & Location
# ==============================================================================

# --- Show Travel Time ---
# Key:          ShowDeclinedEvents
# Domain:       com.apple.iCal
# Description:  Include travel time estimates in calendar view.
# Note:         Helps with back-to-back meeting scheduling
# Set to:       false (hide declined to reduce clutter)
run_defaults "com.apple.iCal" "ShowDeclinedEvents" "-bool" "false"

# --- Time Zone Support ---
# Key:          TimeZone support enabled
# Domain:       com.apple.iCal
# Description:  Essential for scheduling with colleagues in different zones.
# Global:       false
# Set to:       true (enable for distributed teams)
run_defaults "com.apple.iCal" "TimeZone support enabled" "-bool" "true"

# ==============================================================================
# Display Settings
# ==============================================================================

# --- Scroll in Week View ---
# Key:          scroll in week view
# Domain:       com.apple.iCal
# Description:  Auto-scroll to current time when opening week view.
# Set to:       true (jump to current time)
run_defaults "com.apple.iCal" "scroll in week view" "-bool" "true"

# --- Show Birthdays Calendar ---
# Key:          display birthdays calendar
# Domain:       com.apple.iCal
# Description:  Hide personal birthdays in work context.
# Global:       true
# Set to:       false (reduce personal info in work calendar)
run_defaults "com.apple.iCal" "display birthdays calendar" "-bool" "false"

# --- Show Holidays Calendar ---
# Key:          Show US Holidays Calendar
# Domain:       com.apple.iCal
# Description:  Show holidays for scheduling around them.
# Global:       true
# Set to:       true (useful for planning)
run_defaults "com.apple.iCal" "Show US Holidays Calendar" "-bool" "true"

# --- Siri Suggestions ---
# Key:          Add Siri Suggestions calendar
# Domain:       com.apple.iCal
# Description:  Show Siri-suggested events from email, etc.
# Global:       true
# Set to:       true (helpful for flight/hotel bookings)
run_defaults "com.apple.iCal" "Add Siri Suggestions calendar" "-bool" "true"

# ==============================================================================
# Invitations & Sharing
# ==============================================================================

# --- Auto-retrieve Invitations ---
# Key:          Warn before sending invitations
# Domain:       com.apple.iCal
# Description:  Confirm before sending meeting invitations.
# Set to:       true (prevent accidental invites)
run_defaults "com.apple.iCal" "Warn before sending invitations" "-bool" "true"

msg_success "Work Calendar settings applied."
echo ""
msg_info "Additional work calendar setup:"
echo "  1. Calendar > Settings > Accounts: Set work calendar as default"
echo "  2. Hide personal calendars during work: Uncheck in sidebar"
echo "  3. Set up calendar sharing for team visibility"
echo "  4. Configure iCloud or Exchange for work account"
