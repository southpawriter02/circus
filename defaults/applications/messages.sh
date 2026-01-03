#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Apple Messages Settings
#
# DESCRIPTION:
#   Documentation of Apple Messages.app settings. Most Messages settings
#   are stored in secure containers or sync via iCloud and cannot be
#   configured via defaults commands.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Messages.app should be quit before running these commands
#
# REFERENCES:
#   - Apple Support: Use Messages on your Mac
#     https://support.apple.com/guide/messages/welcome/mac
#   - Apple Support: Messages settings
#     https://support.apple.com/guide/messages/change-messages-preferences-icht491d3b70/mac
#
# DOMAIN:
#   com.apple.MobileSMS
#   com.apple.iChat
#
# NOTES:
#   - Many Messages settings sync via iCloud
#   - Privacy-sensitive settings are in secure storage
#   - iMessage activation requires manual setup
#
# ==============================================================================

msg_info "Configuring Messages settings..."

# ==============================================================================
# Messages Settings Overview
#
# Messages settings are primarily configured through:
# - Messages > Settings (Cmd + ,)
#
# Key settings that CANNOT be set via defaults:
# - iMessage account activation
# - Send & Receive addresses
# - Phone number forwarding
# - End-to-end encryption keys
#
# ==============================================================================

# ==============================================================================
# General Settings (Limited defaults access)
# ==============================================================================

# --- Save History When Conversations Are Closed ---
# Key:          SaveConversationsOnClose
# Domain:       com.apple.MobileSMS
# Description:  Keep message history when closing conversation windows.
# Default:      true
# Options:      true = Save history, false = Don't save
# Set to:       true (preserve conversations)
# UI Location:  Messages > Settings > General > Save history when closed
run_defaults "com.apple.MobileSMS" "SaveConversationsOnClose" "-bool" "true"

# --- Automatically Play Message Effects ---
# Key:          EnableMessageEffects
# Domain:       com.apple.MobileSMS
# Description:  Play bubble and screen effects automatically.
# Default:      true
# Options:      true = Play effects, false = Disable effects
# Set to:       true (enable effects)
# UI Location:  Messages > Settings > General > Message effects
run_defaults "com.apple.MobileSMS" "EnableMessageEffects" "-bool" "true"

# ==============================================================================
# Audio & Video Settings
# ==============================================================================

# NOTE: Camera, microphone, and speaker settings for Messages are
# configured through System Settings > Sound and Privacy settings.

# ==============================================================================
# Notification Settings
#
# Messages notification settings are configured in:
# System Settings > Notifications > Messages
#
# Options available:
# - Allow notifications
# - Alert style (Banners/Alerts)
# - Show previews
# - Play sound
# - Badge app icon
# - Show in Notification Center
# - Show on lock screen
#
# These cannot be set via defaults for security reasons.
#
# ==============================================================================

# ==============================================================================
# Text Replacement & Keyboard
#
# Text replacements are configured in:
# System Settings > Keyboard > Text Replacements
#
# These sync via iCloud and apply to Messages and other apps.
# Use `defaults read -g NSUserDictionaryReplacementItems` to view.
#
# ==============================================================================

# ==============================================================================
# Shared With You Settings
#
# "Shared with You" is configured in:
# Messages > Settings > Shared with You
#
# Controls which content types appear in other apps:
# - Photos
# - Links/Safari
# - Music
# - TV
# - Podcasts
# - News
#
# These settings cannot be configured via defaults.
#
# ==============================================================================

# ==============================================================================
# iMessage Settings (Manual Configuration Required)
#
# The following settings MUST be configured manually in Messages > Settings:
#
# iMessage Tab:
# - Enable Messages in iCloud (sync across devices)
# - Send & Receive addresses
# - Start new conversations from (phone/email)
#
# General Tab:
# - Keep messages: Forever / 1 Year / 30 Days
# - Application to open with messages (default: Messages)
#
# Message forwarding requires:
# 1. iPhone and Mac on same Apple ID
# 2. iPhone: Settings > Messages > Text Message Forwarding
#
# ==============================================================================

# ==============================================================================
# Privacy & Security Notes
#
# Messages uses end-to-end encryption for iMessage conversations.
# Settings that affect privacy:
#
# - Read Receipts: Messages > Settings > iMessage > Send Read Receipts
#   This lets senders know when you've read their message.
#
# - Share Name and Photo: Controlled in Settings > Messages
#   Share your profile with contacts.
#
# - Filter Unknown Senders:
#   Messages > Settings > General > Filter Unknown Senders
#   Moves messages from unknown numbers to a separate list.
#
# - Block contacts: Messages menu > Block Person
#   Blocked contacts cannot send messages.
#
# ==============================================================================

msg_success "Messages settings configured."
msg_info "Note: Most Messages settings require manual configuration in the app."

# ==============================================================================
# Troubleshooting
#
# Reset Messages caches:
#   rm -rf ~/Library/Messages/Archive
#   rm -rf ~/Library/Messages/*.db*
#
# Re-sync iMessage:
#   1. Messages > Settings > iMessage
#   2. Disable "Enable Messages in iCloud"
#   3. Re-enable after a moment
#
# Note: Deleting message databases will remove local history.
#
# ==============================================================================
