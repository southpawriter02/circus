#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Notification Settings
#
# DESCRIPTION:
#   Configures system-wide notification behavior including preview settings,
#   grouping, and Do Not Disturb scheduling. Per-app notification settings
#   must be configured through System Settings.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require notification center restart
#
# REFERENCES:
#   - Apple Support: Change Notifications preferences on Mac
#     https://support.apple.com/guide/mac-help/change-notifications-preferences-mh40583/mac
#   - Apple Support: Use Focus on your Mac
#     https://support.apple.com/guide/mac-help/turn-a-focus-on-or-off-mchl613dc43f/mac
#   - Apple Developer: UNUserNotificationCenter
#     https://developer.apple.com/documentation/usernotifications/unusernotificationcenter
#
# DOMAIN:
#   com.apple.ncprefs
#   com.apple.notificationcenterui
#
# NOTES:
#   - Per-app notification settings are stored in a database and cannot
#     be easily configured via defaults
#   - Focus (Do Not Disturb) can be controlled via Control Center or Shortcuts
#   - Notification Center history is stored in a database
#
# ==============================================================================

# ==============================================================================
# Notification Center Architecture
# ==============================================================================

# macOS notifications are managed by several components:
#
# PROCESSES:
#   - usernoted: User notification daemon (manages delivery)
#   - NotificationCenter: The UI for viewing notifications
#   - UserNotificationCenter: Framework for apps to post notifications
#
# NOTIFICATION FLOW:
#
#   ┌──────────────┐    ┌──────────────┐    ┌──────────────────┐
#   │     App      │───▶│   usernoted  │───▶│ NotificationCenter│
#   │ (posts note) │    │ (routes/stores)│   │ (displays banner) │
#   └──────────────┘    └──────────────┘    └──────────────────┘
#                              │
#                              ▼
#                       ┌────────────┐
#                       │  Database  │
#                       │ (history)  │
#                       └────────────┘
#
# DATA LOCATIONS:
#   ~/Library/Preferences/com.apple.ncprefs.plist
#     - Notification preferences
#
#   ~/Library/Application Support/NotificationCenter/
#     - Notification history database
#
#   ~/Library/DoNotDisturb/DB/
#     - Focus (DND) state and assertions
#
#   ~/Library/Group Containers/group.com.apple.usernoted/
#     - User notification daemon data
#
# NOTIFICATION TYPES:
#   BANNER    Appears at top right, auto-dismisses
#   ALERT     Appears at top right, requires action
#   BADGE     App icon badge (number)
#   SOUND     Audio notification
#   NONE      Silent delivery to Notification Center
#
# DEBUGGING COMMANDS:
#
#   # View notification database (requires Full Disk Access)
#   sqlite3 ~/Library/Group\ Containers/group.com.apple.usernoted/db2/db
#
#   # Check Focus (DND) status
#   plutil -p ~/Library/DoNotDisturb/DB/Assertions.json 2>/dev/null
#
#   # Clear notification history
#   rm -rf ~/Library/Application\ Support/NotificationCenter/*
#   killall NotificationCenter
#
#   # Test notification from command line
#   osascript -e 'display notification "Test message" with title "Test"'
#
#   # List apps with notification permissions
#   defaults read com.apple.ncprefs apps
#
# FOCUS MODES (macOS Monterey+):
#   Focus modes (Do Not Disturb, Work, Personal, etc.) are synced via
#   iCloud and stored in complex plist/database structures that aren't
#   easily modified via defaults. Use System Settings or Shortcuts.
#
# Source:       https://developer.apple.com/documentation/usernotifications

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Notification preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring notification settings..."

# ==============================================================================
# Notification Previews
# ==============================================================================

# --- Show Previews ---
# Key:          content_visibility
# Domain:       com.apple.ncprefs
# Description:  Controls when notification content (message text, etc.) is shown
#               in notification banners and the notification center.
# Default:      1 (always)
# Options:      0 = Never show previews
#               1 = Always show previews
#               2 = When unlocked only
# Set to:       2 (show previews only when unlocked for privacy)
# UI Location:  System Settings > Notifications > Show Previews
# Security:     Setting to "When unlocked" prevents others from seeing your
#               notification content on the lock screen
run_defaults "com.apple.ncprefs" "content_visibility" "-int" "2"

# ==============================================================================
# Notification Center UI
# ==============================================================================

# --- Notification Banner Duration ---
# Key:          bannerTime
# Domain:       com.apple.notificationcenterui
# Description:  How long notification banners stay on screen (in seconds).
# Default:      5
# Options:      Integer value (seconds)
# Set to:       5 (default duration)
# Note:         This may not work on all macOS versions
run_defaults "com.apple.notificationcenterui" "bannerTime" "-int" "5"

# ==============================================================================
# Notification Sounds
#
# NOTE: Notification sounds are configured per-app in:
# System Settings > Notifications > [App Name] > Play sound
#
# There is no system-wide "mute all notification sounds" default.
# Use Focus mode (Do Not Disturb) to silence notifications.
#
# ==============================================================================

# ==============================================================================
# Focus / Do Not Disturb
#
# Focus modes (including Do Not Disturb) are managed through:
# - Control Center > Focus
# - System Settings > Focus
# - Shortcuts app automation
#
# The settings are complex and stored in CloudKit for cross-device sync.
# They cannot be reliably configured via defaults commands.
#
# Key Focus features:
# - Schedule Do Not Disturb times
# - Allow calls from specific contacts
# - Allow time-sensitive notifications
# - Share Focus status with contacts
#
# Command line control:
#   # Check if Focus is on
#   plutil -p ~/Library/DoNotDisturb/DB/Assertions.json
#
#   # Quick toggle using Shortcuts (create a shortcut first)
#   shortcuts run "Toggle Do Not Disturb"
#
# ==============================================================================

# ==============================================================================
# Notification Grouping
#
# NOTE: Notification grouping is configured per-app in:
# System Settings > Notifications > [App Name] > Group notifications
#
# Options:
# - Automatic: Group by app and conversation
# - By App: Group all notifications from an app together
# - Off: Each notification appears separately
#
# This cannot be set globally via defaults.
#
# ==============================================================================

# ==============================================================================
# Widget Settings
# ==============================================================================

# --- Show Widgets on Desktop ---
# Key:          ShowOnDesktop
# Domain:       com.apple.WindowManager
# Description:  Controls whether widgets are shown on the desktop.
#               (macOS Sonoma and later)
# Default:      true
# Options:      true = Show widgets on desktop
#               false = Hide widgets from desktop
# Set to:       true (show widgets on desktop)
# UI Location:  System Settings > Desktop & Dock > Widgets > Show Widgets
run_defaults "com.apple.WindowManager" "ShowOnDesktop" "-bool" "true"

# --- Widget Style ---
# Key:          WidgetConfiguration
# Domain:       com.apple.notificationcenterui
# Description:  Widget appearance settings (stored as data blob).
# Note:         Widgets are best configured through the GUI:
#               Click date/time in menu bar > Edit Widgets
# ==============================================================================

msg_success "Notification settings configured."

# ==============================================================================
# Restart Notification Center
#
# Some notification changes require restarting the notification center:
#   killall NotificationCenter
#
# Or log out and back in for all changes to take effect.
#
# Clear notification history:
#   rm -rf ~/Library/Application\ Support/NotificationCenter/*
#   killall NotificationCenter
#
# ==============================================================================
