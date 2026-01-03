#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Disk Utility Configuration
#
# DESCRIPTION:
#   This script configures Apple Disk Utility preferences including advanced
#   mode settings, sidebar options, and debug menu access. Disk Utility is
#   used for managing disks, partitions, and disk images on macOS.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Disk Utility app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Disk Utility User Guide
#     https://support.apple.com/guide/disk-utility/welcome/mac
#   - Apple Support: Partition a disk
#     https://support.apple.com/guide/disk-utility/partition-a-physical-disk-dskutl14027/mac
#
# DOMAIN:
#   com.apple.DiskUtility
#
# NOTES:
#   - Disk Utility is a system application in /Applications/Utilities/
#   - Preferences stored in ~/Library/Preferences/com.apple.DiskUtility.plist
#   - Some operations require administrator privileges
#   - Debug menu provides advanced disk operations
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Disk Utility preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Disk Utility settings..."

# ==============================================================================
# Sidebar Settings
# ==============================================================================

# --- Show All Devices ---
# Key:          SidebarShowAllDevices
# Domain:       com.apple.DiskUtility
# Description:  Shows all devices in the sidebar including container disks,
#               physical disks, and volumes. When disabled, only volumes are
#               shown which can hide important disk structure information.
# Default:      false (show only volumes)
# Options:      true  = Show all devices (containers, disks, volumes)
#               false = Show only volumes
# Set to:       true (see full disk hierarchy)
# UI Location:  View > Show All Devices
# Source:       https://support.apple.com/guide/disk-utility/view-volumes-containers-devices-dskua4e0e60f/mac
run_defaults "com.apple.DiskUtility" "SidebarShowAllDevices" "-bool" "true"

# ==============================================================================
# Advanced Settings
# ==============================================================================

# --- Advanced Image Options ---
# Key:          advanced-image-options
# Domain:       com.apple.DiskUtility
# Description:  Enables advanced options when creating disk images, such as
#               custom partition schemes and encryption options.
# Default:      false
# Options:      true  = Show advanced image options
#               false = Hide advanced options
# Set to:       true (full control over disk images)
# UI Location:  Affects File > New Image dialogs
# Source:       https://support.apple.com/guide/disk-utility/welcome/mac
run_defaults "com.apple.DiskUtility" "advanced-image-options" "-bool" "true"

# ==============================================================================
# Debug Menu
# ==============================================================================

# --- Enable Debug Menu ---
# Key:          DUDebugMenuEnabled
# Domain:       com.apple.DiskUtility
# Description:  Enables the hidden Debug menu which provides access to advanced
#               disk operations and diagnostic tools. Use with caution as some
#               operations can cause data loss.
# Default:      false (debug menu hidden)
# Options:      true  = Show Debug menu
#               false = Hide Debug menu
# Set to:       true (access advanced features)
# UI Location:  Adds Debug menu to menu bar
# Source:       https://support.apple.com/guide/disk-utility/welcome/mac
# WARNING:      Use Debug menu options carefully - some can destroy data!
run_defaults "com.apple.DiskUtility" "DUDebugMenuEnabled" "-bool" "true"

# ==============================================================================
# Window Settings
# ==============================================================================

# --- Show APFS Snapshots ---
# Key:          DUShowAPFSSnapshots
# Domain:       com.apple.DiskUtility
# Description:  Shows APFS snapshots in the sidebar when available. Snapshots
#               are point-in-time copies of the file system created by Time
#               Machine and other backup systems.
# Default:      false
# Options:      true  = Show APFS snapshots
#               false = Hide APFS snapshots
# Set to:       true (see all snapshots)
# UI Location:  View menu (when enabled)
# Source:       https://support.apple.com/guide/disk-utility/welcome/mac
run_defaults "com.apple.DiskUtility" "DUShowAPFSSnapshots" "-bool" "true"

# --- Confirm Erase Operations ---
# Key:          DUAskBeforeErase
# Domain:       com.apple.DiskUtility
# Description:  Shows a confirmation dialog before erasing disks or volumes.
#               Essential safety feature to prevent accidental data loss.
# Default:      true
# Options:      true  = Ask before erasing
#               false = Erase without confirmation
# Set to:       true (prevent accidents)
# UI Location:  Implicit behavior
# Source:       https://support.apple.com/guide/disk-utility/welcome/mac
run_defaults "com.apple.DiskUtility" "DUAskBeforeErase" "-bool" "true"

msg_success "Disk Utility settings applied."
msg_info "Restart Disk Utility for all settings to take effect."
echo ""
msg_info "Debug menu provides advanced options (use with caution):"
echo "  - Show every partition"
echo "  - Refresh all volumes"
echo "  - Unmount protected volumes"
