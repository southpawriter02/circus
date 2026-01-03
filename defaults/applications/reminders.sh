#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Reminders Configuration
#
# DESCRIPTION:
#   Documentation of Apple Reminders configuration options. Reminders is a
#   task management app that syncs across all Apple devices via iCloud.
#   Most settings are configured within the app or sync from your account.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Reminders app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Use Reminders on Mac
#     https://support.apple.com/guide/reminders/welcome/mac
#   - Apple Support: Reminders settings
#     https://support.apple.com/guide/reminders/change-settings-rem1b5cadf34/mac
#
# DOMAIN:
#   com.apple.reminders
#
# NOTES:
#   - Reminders data syncs via iCloud
#   - Most preferences are per-account, not local defaults
#   - Lists and reminders are stored in ~/Library/Reminders/
#   - Supports integration with Calendar, Siri, and Apple Watch
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Reminders preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Reminders settings..."

# ==============================================================================
# Badge Settings
# ==============================================================================

# --- Show Badge Count ---
# Key:          RemindersDebugBadge
# Domain:       com.apple.reminders
# Description:  Controls whether the Reminders app icon shows a badge with the
#               count of overdue and due-today items.
# Default:      N/A (managed by Notification settings)
# Note:         Badge settings are primarily controlled via System Settings >
#               Notifications > Reminders > Badge app icon
# UI Location:  System Settings > Notifications > Reminders
# Source:       https://support.apple.com/guide/reminders/change-settings-rem1b5cadf34/mac

# ==============================================================================
# Reminders Configuration Notes
#
# Most Reminders preferences are configured within the app:
#
# DEFAULT LIST (In-App Settings):
#   Reminders > Settings > Default List
#   - Choose which list new reminders are added to by default
#   - Affects reminders created via Siri, Quick Entry, or other apps
#
# TODAY WIDGET SETTINGS (In-App Settings):
#   - Configured via Notification Center widgets
#   - Shows reminders due today and overdue
#
# ICLOUD SYNC (System Settings):
#   System Settings > Apple ID > iCloud > Reminders
#   - Toggle iCloud sync for Reminders
#   - Syncs lists and reminders across all devices
#
# SMART LISTS (In-App):
#   - Today: Shows reminders due today
#   - Scheduled: Shows all scheduled reminders
#   - Flagged: Shows flagged reminders
#   - All: Shows all reminders across lists
#
# ==============================================================================

# ==============================================================================
# Available Defaults
# ==============================================================================

# --- Sidebar Visibility ---
# Key:          SidebarShown
# Domain:       com.apple.reminders
# Description:  Controls whether the sidebar with lists is shown or hidden.
# Default:      true (sidebar visible)
# Options:      true  = Show sidebar
#               false = Hide sidebar
# Set to:       true (easy list navigation)
# UI Location:  View > Show Sidebar (Cmd+Option+S)
# Source:       https://support.apple.com/guide/reminders/welcome/mac
run_defaults "com.apple.reminders" "SidebarShown" "-bool" "true"

msg_success "Reminders settings configured."
echo ""
msg_info "Most Reminders settings are configured in-app:"
echo "  1. Open Reminders > Settings (Cmd+,)"
echo "  2. Set your Default List for new reminders"
echo "  3. Configure iCloud sync in System Settings"
echo ""
msg_info "Notification settings:"
echo "  System Settings > Notifications > Reminders"
