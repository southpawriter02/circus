#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Dropbox Configuration
#
# DESCRIPTION:
#   This script configures Dropbox preferences for syncing behavior, LAN sync,
#   notifications, and menu bar visibility. Dropbox is a cloud storage service
#   that syncs files across devices.
#
# REQUIRES:
#   - macOS 10.13 (High Sierra) or later
#   - Dropbox installed and signed in
#
# REFERENCES:
#   - Dropbox Help: Change Dropbox desktop app preferences
#     https://help.dropbox.com/installs/change-preferences
#   - Dropbox Help: LAN sync
#     https://help.dropbox.com/share/lan-sync
#
# DOMAIN:
#   com.getdropbox.dropbox
#
# NOTES:
#   - Dropbox stores preferences in ~/Library/Preferences/com.getdropbox.dropbox.plist
#   - Some settings require Dropbox to be restarted to take effect
#   - LAN sync speeds up syncing between devices on the same network
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Dropbox preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Dropbox settings..."

# ==============================================================================
# Menu Bar Settings
# ==============================================================================

# --- Menu Bar Icon Visibility ---
# Key:          NSStatusItem Visible Item-0
# Domain:       com.getdropbox.dropbox
# Description:  Controls whether the Dropbox icon appears in the macOS menu bar.
#               The icon provides quick access to recent files, sync status,
#               and Dropbox settings.
# Default:      true (icon visible)
# Options:      true  = Show Dropbox icon in menu bar
#               false = Hide Dropbox icon from menu bar
# Set to:       true (keep menu bar icon for easy access)
# UI Location:  Dropbox > Preferences > General > Show desktop notifications
# Source:       https://help.dropbox.com/installs/change-preferences
run_defaults "com.getdropbox.dropbox" "NSStatusItem Visible Item-0" "-bool" "true"

# ==============================================================================
# Desktop Integration
# ==============================================================================

# --- Desktop Icons ---
# Key:          DesktopIconsOff
# Domain:       com.getdropbox.dropbox
# Description:  Controls whether Dropbox adds sync status badges (checkmarks,
#               sync arrows) to files and folders in Finder. These badges
#               indicate sync status at a glance.
# Default:      false (badges enabled)
# Options:      true  = Disable sync status badges on desktop/Finder icons
#               false = Enable sync status badges (recommended)
# Set to:       false (keep badges for sync visibility)
# UI Location:  Dropbox > Preferences > Sync > Show sync status badges
# Source:       https://help.dropbox.com/installs/change-preferences
run_defaults "com.getdropbox.dropbox" "DesktopIconsOff" "-bool" "false"

# ==============================================================================
# Sync Settings
# ==============================================================================

# --- LAN Sync ---
# Key:          LAN Sync Enabled
# Domain:       com.getdropbox.dropbox
# Description:  Enables LAN sync which allows Dropbox to sync files directly
#               between devices on the same local network. This is faster than
#               syncing through the cloud and reduces bandwidth usage.
# Default:      true (LAN sync enabled)
# Options:      true  = Enable LAN sync (sync with nearby devices on same network)
#               false = Disable LAN sync (always sync through cloud)
# Set to:       true (faster syncing on local networks)
# UI Location:  Dropbox > Preferences > Bandwidth > Enable LAN sync
# Source:       https://help.dropbox.com/share/lan-sync
# Note:         LAN sync uses port 17500 for device discovery
run_defaults "com.getdropbox.dropbox" "LAN Sync Enabled" "-bool" "true"

msg_success "Dropbox settings applied."
msg_info "You may need to restart Dropbox for all settings to take effect."
