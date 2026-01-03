#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Spotify Configuration
#
# DESCRIPTION:
#   Documentation of Spotify configuration options. Spotify uses its own
#   preferences system stored in its application support folder rather than
#   macOS defaults. This script provides guidance on configuring Spotify
#   for audio quality and performance.
#
# REQUIRES:
#   - macOS 10.13 (High Sierra) or later
#   - Spotify installed
#
# REFERENCES:
#   - Spotify Support: Audio settings
#     https://support.spotify.com/us/article/audio-settings/
#   - Spotify Support: Desktop settings
#     https://support.spotify.com/us/article/desktop-settings/
#
# DOMAIN:
#   com.spotify.client
#
# NOTES:
#   - Spotify preferences in ~/Library/Application Support/Spotify/
#   - Settings stored in prefs file (JSON format)
#   - Most settings sync with your Spotify account
#   - Premium subscription unlocks higher audio quality
#
# ==============================================================================

msg_info "Configuring Spotify settings..."

# ==============================================================================
# Spotify Configuration Notes
#
# Spotify stores preferences in its own format, not macOS defaults.
# Settings are configured in-app via Spotify > Settings.
#
# AUDIO QUALITY (Settings > Audio quality):
#
#   Streaming quality (Premium only):
#   - Low: ~24 kbps (saves data)
#   - Normal: ~96 kbps
#   - High: ~160 kbps
#   - Very High: ~320 kbps (best quality)
#
#   Download quality (Premium only):
#   - Low through Very High, same as streaming
#
#   Auto adjust quality:
#   - Automatically adjusts based on network conditions
#
#   Normalize volume:
#   - Equalizes volume across tracks for consistent listening
#
# PLAYBACK (Settings > Playback):
#
#   Crossfade:
#   - 0-12 seconds overlap between tracks
#   - Set to 0 for gapless playback
#
#   Gapless playback:
#   - Eliminates silence between tracks on albums
#
#   Automix:
#   - Smooth transitions in playlists
#
# DISPLAY (Settings > Display):
#
#   Show desktop notifications:
#   - Now playing notifications when track changes
#
#   Show friend activity:
#   - See what friends are listening to
#
# STARTUP (Settings > Startup and window behavior):
#
#   Open Spotify automatically after you log into the computer:
#   - Yes, No, or Minimized
#
#   Close button should minimize the Spotify window:
#   - Keep Spotify running in background
#
# SOCIAL (Settings > Social):
#
#   Share what I listen to:
#   - Publish activity to followers
#
#   Show my recently played artists:
#   - Display on profile
#
# LOCAL FILES (Settings > Local files):
#
#   Show local files:
#   - Include local music library in Spotify
#
#   Source folders:
#   - Directories to scan for local music
#
# ==============================================================================

# ==============================================================================
# Command Line Preferences (if any)
# ==============================================================================

# Spotify has limited macOS defaults support. The main user-facing preference:

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Spotify preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

# --- Expanded Print Dialog ---
# Key:          PMPrintingExpandedStateForPrint2
# Domain:       com.spotify.client
# Description:  Shows the expanded print dialog when printing lyrics or other
#               content from Spotify.
# Default:      false
# Options:      true  = Show expanded print dialog
#               false = Show collapsed print dialog
# Set to:       true (see all print options)
# UI Location:  Print dialog
# Source:       macOS standard preference
run_defaults "com.spotify.client" "PMPrintingExpandedStateForPrint2" "-bool" "true"

msg_success "Spotify configuration notes displayed."
echo ""
msg_info "Spotify settings are configured in-app:"
echo "  1. Open Spotify > Settings (Cmd+,)"
echo "  2. Audio quality: Set streaming/download quality"
echo "  3. Playback: Crossfade, gapless, normalize volume"
echo "  4. Startup: Open automatically, minimize behavior"
echo ""
msg_info "Recommended settings for best quality (Premium):"
echo "  - Streaming quality: Very High (320 kbps)"
echo "  - Normalize volume: On"
echo "  - Gapless playback: On"
echo "  - Crossfade: 0 seconds (for albums)"
