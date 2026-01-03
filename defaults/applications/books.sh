#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Books Configuration
#
# DESCRIPTION:
#   This script configures Apple Books preferences including reading display
#   options, sync settings, and audiobook behavior. Books syncs your library
#   and reading progress across all Apple devices via iCloud.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#   - Books app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Use Books on Mac
#     https://support.apple.com/guide/books/welcome/mac
#   - Apple Support: Change Books settings
#     https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
#
# DOMAIN:
#   com.apple.iBooksX
#
# NOTES:
#   - Books was renamed from iBooks in macOS Mojave (10.14)
#   - Preferences stored in ~/Library/Preferences/com.apple.iBooksX.plist
#   - Books library stored in ~/Library/Containers/com.apple.iBooksX/
#   - Reading progress and annotations sync via iCloud
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Books preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Books settings..."

# ==============================================================================
# Reading Display Settings
# ==============================================================================

# --- Auto Night Theme ---
# Key:          BKAutoNightThemeEnabled
# Domain:       com.apple.iBooksX
# Description:  Automatically switches to a dark reading theme based on ambient
#               light conditions or time of day. Reduces eye strain in low light.
# Default:      false
# Options:      true  = Auto-switch to night theme
#               false = Manual theme control only
# Set to:       true (adapt to lighting conditions)
# UI Location:  Books > Settings > Reading > Auto-Night Theme
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKAutoNightThemeEnabled" "-bool" "true"

# --- Page Turn Animation ---
# Key:          BKAnimatePageTurn
# Domain:       com.apple.iBooksX
# Description:  Shows a page-turning animation when navigating between pages.
#               Disable for faster navigation.
# Default:      true
# Options:      true  = Show page turn animation
#               false = Instant page transitions
# Set to:       true (natural reading feel)
# UI Location:  View menu during reading
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKAnimatePageTurn" "-bool" "true"

# --- Show Status Bar While Reading ---
# Key:          BKShowStatusBarWhileReading
# Domain:       com.apple.iBooksX
# Description:  Controls whether the menu bar remains visible while reading
#               a book in fullscreen mode.
# Default:      false (hide for immersion)
# Options:      true  = Show status bar
#               false = Hide status bar (cleaner reading)
# Set to:       false (immersive reading)
# UI Location:  View menu while reading
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKShowStatusBarWhileReading" "-bool" "false"

# ==============================================================================
# Scrolling Settings
# ==============================================================================

# --- Scroll Direction ---
# Key:          BKScrollDirection
# Domain:       com.apple.iBooksX
# Description:  Controls the scrolling direction for paginated content.
#               Horizontal mimics physical book page turning.
# Default:      1 (horizontal)
# Options:      0 = Vertical scrolling
#               1 = Horizontal scrolling
# Set to:       1 (book-like experience)
# UI Location:  View > Scroll Direction
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKScrollDirection" "-int" "1"

# ==============================================================================
# Sync Settings
# ==============================================================================

# --- Sync Bookmarks and Highlights ---
# Key:          BKSyncBookmarksAndHighlights
# Domain:       com.apple.iBooksX
# Description:  Syncs your bookmarks, highlights, and annotations across all
#               devices signed into the same Apple ID.
# Default:      true
# Options:      true  = Sync annotations via iCloud
#               false = Keep annotations local
# Set to:       true (access annotations everywhere)
# UI Location:  Books > Settings > General > Sync bookmarks, highlights, and collections
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKSyncBookmarksAndHighlights" "-bool" "true"

# --- Sync Collections ---
# Key:          BKSyncCollections
# Domain:       com.apple.iBooksX
# Description:  Syncs your book collections (custom folders/categories) across
#               all devices via iCloud.
# Default:      true
# Options:      true  = Sync collections
#               false = Keep collections local
# Set to:       true (consistent organization)
# UI Location:  Books > Settings > General > Sync bookmarks, highlights, and collections
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKSyncCollections" "-bool" "true"

# --- Sync Reading Position ---
# Key:          BKSyncReadingPosition
# Domain:       com.apple.iBooksX
# Description:  Syncs your current reading position so you can continue reading
#               on any device from where you left off.
# Default:      true
# Options:      true  = Sync reading position
#               false = Don't sync position
# Set to:       true (seamless reading across devices)
# UI Location:  Books > Settings > General
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKSyncReadingPosition" "-bool" "true"

# ==============================================================================
# Audiobook Settings
# ==============================================================================

# --- Skip Forward Seconds (Audiobooks) ---
# Key:          BKAudiobookSkipForward
# Domain:       com.apple.iBooksX
# Description:  Number of seconds to skip forward when pressing skip forward
#               during audiobook playback.
# Default:      15
# Options:      15, 30, 45, 60 (seconds)
# Set to:       15 (quick skips)
# UI Location:  During audiobook playback
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKAudiobookSkipForward" "-int" "15"

# --- Skip Back Seconds (Audiobooks) ---
# Key:          BKAudiobookSkipBack
# Domain:       com.apple.iBooksX
# Description:  Number of seconds to skip backward when pressing skip back
#               during audiobook playback.
# Default:      15
# Options:      15, 30, 45, 60 (seconds)
# Set to:       15 (replay short segments)
# UI Location:  During audiobook playback
# Source:       https://support.apple.com/guide/books/settings-ibks1016d5f5/mac
run_defaults "com.apple.iBooksX" "BKAudiobookSkipBack" "-int" "15"

msg_success "Books settings applied."
msg_info "Restart Books for all settings to take effect."
