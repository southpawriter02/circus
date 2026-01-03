#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Apple Photos Settings
#
# DESCRIPTION:
#   Configures Apple Photos.app preferences including iCloud sync,
#   metadata handling, and viewing options.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Photos.app should be quit before running these commands
#
# REFERENCES:
#   - Apple Support: Use Photos on your Mac
#     https://support.apple.com/guide/photos/welcome/mac
#   - Apple Support: Use iCloud Photos
#     https://support.apple.com/en-us/HT204264
#
# DOMAIN:
#   com.apple.Photos
#   com.apple.photoanalysisd
#
# NOTES:
#   - iCloud Photos settings sync across devices
#   - Photo library can be large; settings affect storage usage
#   - Some settings require Apple ID / iCloud configuration
#
# ==============================================================================

msg_info "Configuring Apple Photos settings..."

# ==============================================================================
# iCloud Photos Settings
#
# NOTE: iCloud Photos settings are primarily configured via:
# Photos > Settings > iCloud
#
# Key options:
# - iCloud Photos: Sync full library to iCloud
# - Optimize Mac Storage: Keep smaller versions locally
# - Download Originals: Keep full-resolution on Mac
# - Shared Albums: Enable photo sharing with others
#
# These settings sync with your Apple ID and cannot be reliably
# set via defaults commands.
#
# To enable iCloud Photos via command line (requires sign-in):
# This is not recommended; use System Settings instead.
#
# ==============================================================================

# ==============================================================================
# Viewing Preferences
# ==============================================================================

# --- Show Metadata Overlay ---
# Key:          IPXShowMetadataInfo
# Domain:       com.apple.Photos
# Description:  Show photo metadata (date, location) in viewer.
# Default:      false
# Options:      true = Show metadata overlay
#               false = Hide metadata overlay
# Set to:       true (show metadata for context)
# UI Location:  View > Metadata > Show Metadata
run_defaults "com.apple.Photos" "IPXShowMetadataInfo" "-bool" "true"

# --- Show Hidden Photo Album ---
# Key:          IPXDefaultsShowHiddenAlbum
# Domain:       com.apple.Photos
# Description:  Show or hide the Hidden album in the sidebar.
# Default:      true
# Options:      true = Show Hidden album
#               false = Hide the Hidden album from view
# Set to:       true (show hidden album for access)
# UI Location:  View > Show Hidden Photo Album
run_defaults "com.apple.Photos" "IPXDefaultsShowHiddenAlbum" "-bool" "true"

# ==============================================================================
# Import Settings
# ==============================================================================

# --- Open Photos When Device Connects ---
# Key:          IPXDefaultsOpenPhotosForDevice
# Domain:       com.apple.Photos
# Description:  Automatically open Photos when a camera or device is connected.
# Default:      true
# Options:      true = Open automatically
#               false = Don't open automatically
# Set to:       false (don't auto-open; can be annoying)
# UI Location:  Photos > Settings > General > Open Photos for
run_defaults "com.apple.Photos" "IPXDefaultsOpenPhotosForDevice" "-bool" "false"

# --- Delete Items After Import ---
# Key:          IPXDefaultsDeleteAfterImport
# Domain:       com.apple.Photos
# Description:  Delete photos from device after importing to Photos.
# Default:      false
# Options:      true = Delete after import
#               false = Keep on device
# Set to:       false (keep originals on device as backup)
# Note:         Be careful with this setting!
run_defaults "com.apple.Photos" "IPXDefaultsDeleteAfterImport" "-bool" "false"

# ==============================================================================
# Photo Analysis (AI Features)
# ==============================================================================

# --- Enable People & Pets Recognition ---
# Key:          GraphEngineDaemonEnabled
# Domain:       com.apple.photoanalysisd
# Description:  Enable face recognition and people identification.
#               This powers People album and photo search.
# Default:      true
# Options:      true = Enable recognition
#               false = Disable recognition
# Set to:       true (enable for People album)
# Privacy:      Processing is done on-device, not in cloud
# UI Location:  Photos > Settings > General > People & Pets
run_defaults "com.apple.photoanalysisd" "GraphEngineDaemonEnabled" "-bool" "true"

# ==============================================================================
# Memories & Featured Photos
#
# Memories settings are configured in:
# Photos > Settings > Memories
#
# Options:
# - Show Featured Content: Display curated photos/memories
# - Show Memories: Enable auto-generated memory collections
# - Show Featured Photos: Show on widget and lock screen
#
# To disable completely (more privacy):
# - Uncheck all options in Memories settings
#
# ==============================================================================

# ==============================================================================
# Shared Albums
#
# Shared Albums are configured in:
# Photos > Settings > iCloud > Shared Albums
#
# Features:
# - Create albums to share with others
# - Subscribe to albums shared with you
# - Comment and like shared photos
#
# Note: Requires iCloud and Apple ID.
#
# ==============================================================================

# ==============================================================================
# Photo Library Location
#
# The default Photos library is at:
# ~/Pictures/Photos Library.photoslibrary
#
# To use a different library:
# 1. Hold Option while opening Photos
# 2. Select "Other Library" or "Create New"
#
# To set as System Photo Library (for iCloud sync):
# Photos > Settings > General > Use as System Photo Library
#
# ==============================================================================

msg_success "Apple Photos settings configured."

# ==============================================================================
# Troubleshooting
#
# Repair Photo Library:
#   1. Hold Option + Command while opening Photos
#   2. Select "Repair" when prompted
#
# Rebuild thumbnails:
#   The repair process also rebuilds thumbnails
#
# Re-analyze photos for People:
#   rm -rf ~/Library/Containers/com.apple.photolibraryd/Data/Library/Caches
#   (Restart Photos; may take time to re-scan)
#
# View library size:
#   ls -lh ~/Pictures/Photos\ Library.photoslibrary
#
# ==============================================================================
