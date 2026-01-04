#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Slack Configuration (Work Role)
#
# DESCRIPTION:
#   Work-specific Slack settings that layer on top of global defaults.
#   Optimized for professional communication with reduced distractions.
#   Run after: defaults/applications/slack.sh
#
# REQUIRES:
#   - macOS 10.13 (High Sierra) or later
#   - Slack installed (App Store or direct download)
#
# REFERENCES:
#   - Slack Help: Manage your preferences
#     https://slack.com/help/articles/201374536-Manage-your-preferences
#   - Slack Help: Notification preferences
#     https://slack.com/help/articles/201355156-Notification-preferences
#   - Slack Help: Set your status
#     https://slack.com/help/articles/201864558-Set-your-status
#
# DOMAIN:
#   com.tinyspeck.slackmacgap
#
# NOTES:
#   - These settings override/extend the global Slack defaults
#   - DND schedule respects work hours for work-life balance
#   - Most Slack settings sync with your Slack account
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Work Slack preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Applying work-specific Slack settings..."

# ==============================================================================
# Notification Settings (Work-Focused)
# ==============================================================================

# --- Disable Dock Bounce ---
# Key:          SlackBounceEnabled
# Domain:       com.tinyspeck.slackmacgap
# Description:  Prevent distracting Dock icon bounce during work.
# Global:       false
# Set to:       false (less distracting during focus time)
run_defaults "com.tinyspeck.slackmacgap" "SlackBounceEnabled" "-bool" "false"

# --- Notification Sound ---
# Key:          SlackSoundsEnabled
# Domain:       com.tinyspeck.slackmacgap
# Description:  Enable sounds for important notifications.
# Global:       true
# Set to:       true (keep enabled for DMs and mentions)
run_defaults "com.tinyspeck.slackmacgap" "SlackSoundsEnabled" "-bool" "true"

# --- Show Badge Count ---
# Key:          SlackShowBadgeCount
# Domain:       com.tinyspeck.slackmacgap
# Description:  Display unread count on Dock icon.
# Set to:       true (stay aware of pending messages)
run_defaults "com.tinyspeck.slackmacgap" "SlackShowBadgeCount" "-bool" "true"

# ==============================================================================
# Window & Display Settings
# ==============================================================================

# --- Close to Menu Bar ---
# Key:          SlackCloseToTray
# Domain:       com.tinyspeck.slackmacgap
# Description:  Keep Slack running for notifications when window closed.
# Global:       true
# Set to:       true (stay available for work messages)
run_defaults "com.tinyspeck.slackmacgap" "SlackCloseToTray" "-bool" "true"

# --- Show in Menu Bar ---
# Key:          SlackShowMenuBar
# Domain:       com.tinyspeck.slackmacgap
# Description:  Quick access to Slack status from menu bar.
# Set to:       true (easy status updates during meetings)
run_defaults "com.tinyspeck.slackmacgap" "SlackShowMenuBar" "-bool" "true"

# --- Launch on Login ---
# Key:          SlackAutoLaunch
# Domain:       com.tinyspeck.slackmacgap
# Description:  Start Slack when logging in for work.
# Global:       true
# Set to:       true (ready for work communication)
run_defaults "com.tinyspeck.slackmacgap" "SlackAutoLaunch" "-bool" "true"

# --- Remember Window Size ---
# Key:          SlackRememberWindowSize
# Domain:       com.tinyspeck.slackmacgap
# Description:  Maintain consistent window layout.
# Set to:       true (persist window preferences)
run_defaults "com.tinyspeck.slackmacgap" "SlackRememberWindowSize" "-bool" "true"

# ==============================================================================
# Text & Input Settings
# ==============================================================================

# --- Spell Check ---
# Key:          SlackSpellCheckEnabled
# Domain:       com.tinyspeck.slackmacgap
# Description:  Professional communication requires spell checking.
# Global:       true
# Set to:       true (catch typos before sending)
run_defaults "com.tinyspeck.slackmacgap" "SlackSpellCheckEnabled" "-bool" "true"

# --- Zoom Level ---
# Key:          SlackZoomLevel
# Domain:       com.tinyspeck.slackmacgap
# Description:  Comfortable reading size for long work sessions.
# Global:       1.0
# Set to:       1.0 (standard scaling, adjust as needed)
run_defaults "com.tinyspeck.slackmacgap" "SlackZoomLevel" "-float" "1.0"

# ==============================================================================
# Performance Settings
# ==============================================================================

# --- Hardware Acceleration ---
# Key:          HardwareAccelerationEnabled
# Domain:       com.tinyspeck.slackmacgap
# Description:  GPU rendering for better performance.
# Global:       true
# Set to:       true (smoother experience)
run_defaults "com.tinyspeck.slackmacgap" "HardwareAccelerationEnabled" "-bool" "true"

# --- Reduce Motion ---
# Key:          SlackReduceMotion
# Domain:       com.tinyspeck.slackmacgap
# Description:  Follow system accessibility settings.
# Set to:       false (use system preference)
# Note:         Respects System Settings > Accessibility > Display > Reduce motion
run_defaults "com.tinyspeck.slackmacgap" "SlackReduceMotion" "-bool" "false"

# ==============================================================================
# Downloads & Files
# ==============================================================================

# --- Download Location ---
# Key:          SlackDownloadPath
# Domain:       com.tinyspeck.slackmacgap
# Description:  Separate work downloads from personal.
# Global:       ~/Downloads
# Set to:       ~/Downloads/Slack-Work (organized work files)
run_defaults "com.tinyspeck.slackmacgap" "SlackDownloadPath" "-string" "$HOME/Downloads/Slack-Work"

# Create the downloads directory if it doesn't exist
if [ "$DRY_RUN_MODE" != true ]; then
  mkdir -p "$HOME/Downloads/Slack-Work"
fi

msg_success "Work Slack settings applied."
echo ""
msg_info "Additional work Slack setup (in-app settings):"
echo ""
echo "  NOTIFICATIONS (Slack > Preferences > Notifications):"
echo "    - Set DND schedule: 6:00 PM - 9:00 AM (protect personal time)"
echo "    - Notify about: Direct messages, mentions & keywords"
echo "    - Keywords: Add your team/project names"
echo ""
echo "  SIDEBAR (Slack > Preferences > Sidebar):"
echo "    - Organize channels by priority"
echo "    - Star important work channels"
echo "    - Mute high-volume channels"
echo ""
echo "  STATUS:"
echo "    - Set 'In a meeting' status during calendar events"
echo "    - Use 'Focusing' status during deep work"
echo "    - Configure status sync with calendar"
echo ""
echo "  PRODUCTIVITY:"
echo "    - Enable keyboard shortcuts (Cmd+K for quick switch)"
echo "    - Set up saved searches for common queries"
echo "    - Configure workflow automations for common tasks"
