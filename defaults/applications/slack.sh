#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Slack Configuration
#
# DESCRIPTION:
#   This script configures Slack preferences including notification settings,
#   download location, and appearance options. Slack is a team communication
#   platform used for messaging, file sharing, and integrations.
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
#
# DOMAIN:
#   com.tinyspeck.slackmacgap
#
# NOTES:
#   - Slack preferences in ~/Library/Application Support/Slack/
#   - Most settings sync with your Slack account
#   - Workspace-specific settings override global defaults
#   - Downloads default to ~/Downloads/Slack
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Slack preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Slack settings..."

# ==============================================================================
# Notification Settings
# ==============================================================================

# --- Bounce Dock Icon ---
# Key:          SlackBounceEnabled
# Domain:       com.tinyspeck.slackmacgap
# Description:  Controls whether the Slack icon bounces in the Dock when you
#               receive a notification. Can be distracting during focused work.
# Default:      true
# Options:      true  = Bounce Dock icon on notifications
#               false = Don't bounce icon
# Set to:       false (less distracting)
# UI Location:  Slack > Preferences > Notifications
# Source:       https://slack.com/help/articles/201355156-Notification-preferences
run_defaults "com.tinyspeck.slackmacgap" "SlackBounceEnabled" "-bool" "false"

# ==============================================================================
# Appearance Settings
# ==============================================================================

# --- Hardware Acceleration ---
# Key:          HardwareAccelerationEnabled
# Domain:       com.tinyspeck.slackmacgap
# Description:  Enables GPU-accelerated rendering for better performance and
#               smoother animations. May cause issues on some older Macs.
# Default:      true
# Options:      true  = Enable hardware acceleration
#               false = Disable (use CPU rendering)
# Set to:       true (better performance)
# UI Location:  Not directly accessible in UI
# Source:       https://slack.com/help/articles/212681473-Troubleshoot-Slack-on-macOS
run_defaults "com.tinyspeck.slackmacgap" "HardwareAccelerationEnabled" "-bool" "true"

# ==============================================================================
# Startup Settings
# ==============================================================================

# --- Launch on Login ---
# Key:          SlackAutoLaunch
# Domain:       com.tinyspeck.slackmacgap
# Description:  Controls whether Slack starts automatically when you log in
#               to your Mac.
# Default:      false
# Options:      true  = Start Slack on login
#               false = Don't auto-start
# Set to:       true (stay connected)
# UI Location:  Slack > Preferences > Advanced > Launch on login
# Source:       https://slack.com/help/articles/201374536-Manage-your-preferences
run_defaults "com.tinyspeck.slackmacgap" "SlackAutoLaunch" "-bool" "true"

# ==============================================================================
# Window Settings
# ==============================================================================

# --- Close to Tray ---
# Key:          SlackCloseToTray
# Domain:       com.tinyspeck.slackmacgap
# Description:  When closing the window, minimize to menu bar instead of
#               quitting the application. Keeps Slack running for notifications.
# Default:      true
# Options:      true  = Close to menu bar
#               false = Quit app when window closed
# Set to:       true (stay available for messages)
# UI Location:  Implicit behavior
# Source:       https://slack.com/help/articles/201374536-Manage-your-preferences
run_defaults "com.tinyspeck.slackmacgap" "SlackCloseToTray" "-bool" "true"

# ==============================================================================
# Text & Display Settings
# ==============================================================================

# --- Zoom Level ---
# Key:          SlackZoomLevel
# Domain:       com.tinyspeck.slackmacgap
# Description:  Controls the UI zoom level for Slack. Useful for adjusting
#               text size and interface scaling.
# Default:      1.0 (100%)
# Options:      0.8 = 80%
#               0.9 = 90%
#               1.0 = 100% (default)
#               1.1 = 110%
#               1.2 = 120%
# Set to:       1.0 (standard scaling)
# UI Location:  Slack > View > Zoom In/Out (Cmd+/Cmd-)
# Source:       https://slack.com/help/articles/201374536-Manage-your-preferences
run_defaults "com.tinyspeck.slackmacgap" "SlackZoomLevel" "-float" "1.0"

# --- Spell Check ---
# Key:          SlackSpellCheckEnabled
# Domain:       com.tinyspeck.slackmacgap
# Description:  Enables spell checking in message composition. Uses macOS
#               system spell checker with red underlines for misspelled words.
# Default:      true
# Options:      true  = Enable spell check
#               false = Disable spell check
# Set to:       true (catch typos before sending)
# UI Location:  Edit > Spelling and Grammar
# Source:       https://slack.com/help/articles/201374536-Manage-your-preferences
run_defaults "com.tinyspeck.slackmacgap" "SlackSpellCheckEnabled" "-bool" "true"

# ==============================================================================
# Slack Configuration Notes
#
# Most Slack settings are configured in-app or sync via your account:
#
# NOTIFICATIONS (Preferences > Notifications):
#   - Notify me about: All new messages / Direct messages / Nothing
#   - Sound & appearance: Notification sounds, preview settings
#   - Do Not Disturb schedule
#
# SIDEBAR (Preferences > Sidebar):
#   - Show all conversations
#   - Sort conversations
#   - Theme settings
#
# ACCESSIBILITY (Preferences > Accessibility):
#   - Keyboard shortcuts
#   - Animation settings
#   - Screen reader support
#
# MESSAGES (Preferences > Messages & media):
#   - Theme (inline or compact)
#   - Emoji style
#   - Media autoplay
#
# AUDIO & VIDEO (Preferences > Audio & video):
#   - Microphone and speaker settings
#   - Camera settings for huddles/calls
#
# DOWNLOADS:
#   - Default location: ~/Downloads/Slack
#   - Configure via Slack > Preferences > Advanced
#
# ==============================================================================

msg_success "Slack settings applied."
echo ""
msg_info "Most Slack settings are configured in-app:"
echo "  1. Slack > Preferences (Cmd+,)"
echo "  2. Notifications: Set DND schedule"
echo "  3. Sidebar: Customize workspace appearance"
echo "  4. Advanced: Download location, launch on login"
