#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Apple Notes Settings
#
# DESCRIPTION:
#   Configures Apple Notes.app preferences including sorting, formatting,
#   and account settings.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Notes.app should be quit before running these commands
#
# REFERENCES:
#   - Apple Support: Use Notes on your Mac
#     https://support.apple.com/guide/notes/welcome/mac
#   - Apple Support: Lock notes on Mac
#     https://support.apple.com/guide/notes/lock-your-notes-apd00dc5984d/mac
#
# DOMAIN:
#   com.apple.Notes
#
# NOTES:
#   - Notes sync via iCloud
#   - Locked notes use end-to-end encryption
#   - Note formatting depends on account type
#
# ==============================================================================

msg_info "Configuring Apple Notes settings..."

# ==============================================================================
# Note Sorting
# ==============================================================================

# --- Sort Notes By ---
# Key:          NotesSortOrder
# Domain:       com.apple.Notes
# Description:  How notes are sorted in the note list.
# Default:      1 (Date Edited)
# Options:      1 = Date Edited (most recent first)
#               2 = Date Created
#               3 = Title
# Set to:       1 (sort by last edited)
# UI Location:  Notes > Settings > Sort Notes By
run_defaults "com.apple.Notes" "NotesSortOrder" "-int" "1"

# --- Sort Folders By ---
# Key:          FoldersSortOrder
# Domain:       com.apple.Notes
# Description:  How folders are sorted in the sidebar.
# Default:      1 (manually)
# Options:      1 = Manually
#               2 = Name (A-Z)
#               3 = Name (Z-A)
# Set to:       1 (manual arrangement)
# UI Location:  Sidebar sorting is done by drag-and-drop
run_defaults "com.apple.Notes" "FoldersSortOrder" "-int" "1"

# ==============================================================================
# Display Settings
# ==============================================================================

# --- Enable Dark Mode for Notes ---
# Key:          NSAppAppearance
# Domain:       com.apple.Notes
# Description:  Force specific appearance for Notes app.
# Default:      System default
# Options:      NSAppearanceNameAqua = Light mode
#               NSAppearanceNameDarkAqua = Dark mode
# Set to:       (not set - follow system)
# Note:         Uncomment to force specific appearance
# run_defaults "com.apple.Notes" "NSAppAppearance" "-string" "NSAppearanceNameDarkAqua"

# --- Group Notes By Date ---
# Key:          GroupNotesByDate
# Domain:       com.apple.Notes
# Description:  Group notes by time periods (Today, Yesterday, etc.).
# Default:      true
# Options:      true = Group by date
#               false = Flat list
# Set to:       true (group by date for organization)
# UI Location:  View > Group Notes By Date
run_defaults "com.apple.Notes" "GroupNotesByDate" "-bool" "true"

# ==============================================================================
# New Note Settings
# ==============================================================================

# --- Default Text Size ---
# Key:          DefaultFontSize
# Domain:       com.apple.Notes
# Description:  Default text size for new notes.
# Default:      16
# Options:      10-36 (points)
# Set to:       16 (comfortable reading size)
# UI Location:  Notes > Settings > Default Text Size
run_defaults "com.apple.Notes" "DefaultFontSize" "-int" "16"

# --- Start New Notes With ---
# Key:          NewNoteBodyStyle
# Domain:       com.apple.Notes
# Description:  Initial formatting for new notes.
# Default:      0 (Title)
# Options:      0 = Title
#               1 = Heading
#               2 = Subheading
#               3 = Body
# Set to:       0 (start with title)
# UI Location:  Notes > Settings > New Notes Start With
run_defaults "com.apple.Notes" "NewNoteBodyStyle" "-int" "0"

# ==============================================================================
# Default Account
#
# NOTE: The default account for new notes is set in:
# Notes > Settings > Default Account
#
# Options typically include:
# - iCloud (syncs across devices)
# - On My Mac (local only)
# - Other accounts (Gmail, Exchange, etc.)
#
# This cannot be reliably set via defaults as it depends on
# configured accounts.
#
# ==============================================================================

# ==============================================================================
# Sharing & Collaboration
#
# Notes collaboration settings:
# - Share notes with others via iCloud
# - Collaborate in real-time
# - Mention people in shared notes (@name)
#
# Settings are configured per-note via the Share button.
#
# ==============================================================================

# ==============================================================================
# Quick Notes
#
# Quick Note is a floating note window activated by:
# - Hot Corner (set in System Settings > Desktop & Dock > Hot Corners)
# - Globe + Q keyboard shortcut
# - Clicking in bottom-right corner of screen
#
# Quick Note preferences are in:
# Notes > Settings > Quick Note
#
# ==============================================================================

# ==============================================================================
# Locked Notes
#
# Locked notes provide end-to-end encryption.
# Configure in: Notes > Settings > Password
#
# Options:
# - Use iPhone passcode (syncs across devices)
# - Create custom password
# - Use Touch ID / Face ID to unlock
#
# To lock a note: Right-click > Lock Note
#
# ==============================================================================

# ==============================================================================
# Smart Folders
#
# Smart Folders automatically collect notes based on criteria:
# - Tags
# - Attachments
# - Checklists
# - Mentions
# - Created/Modified date
#
# Create via: File > New Smart Folder
#
# ==============================================================================

msg_success "Apple Notes settings configured."

# ==============================================================================
# Troubleshooting
#
# Re-sync Notes with iCloud:
#   1. Notes > Settings > Accounts
#   2. Disable and re-enable iCloud Notes
#
# Export notes:
#   File > Export as PDF (individual note)
#   Or use AppleScript for bulk export
#
# Note data location:
#   iCloud: ~/Library/Group Containers/group.com.apple.notes/
#   Local: ~/Library/Containers/com.apple.Notes/
#
# ==============================================================================
