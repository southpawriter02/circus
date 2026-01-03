#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Music Configuration
#
# DESCRIPTION:
#   This script configures Apple Music preferences including audio quality,
#   playback behavior, library settings, and sync options. Music is the default
#   audio player for macOS, replacing iTunes.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Music app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Use the Music app on Mac
#     https://support.apple.com/guide/music/welcome/mac
#   - Apple Support: Change Music preferences
#     https://support.apple.com/guide/music/change-preferences-mus78eb53b1b/mac
#
# DOMAIN:
#   com.apple.Music
#
# NOTES:
#   - Music replaced iTunes in macOS Catalina (10.15)
#   - Preferences stored in ~/Library/Preferences/com.apple.Music.plist
#   - Music library stored in ~/Music/Music/
#   - Apple Music subscription adds streaming features
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Music preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Music settings..."

# ==============================================================================
# Playback Settings
# ==============================================================================

# --- Crossfade Songs ---
# Key:          crossfadeEnabled
# Domain:       com.apple.Music
# Description:  Enables crossfading between songs, creating smooth transitions
#               by fading out the ending song while fading in the next.
# Default:      false (no crossfade)
# Options:      true  = Enable crossfade
#               false = Disable crossfade (gap between songs)
# Set to:       false (preserve song endings)
# UI Location:  Music > Settings > Playback > Crossfade Songs
# Source:       https://support.apple.com/guide/music/change-playback-preferences-mus7a8b90c6/mac
run_defaults "com.apple.Music" "crossfadeEnabled" "-bool" "false"

# --- Sound Enhancer ---
# Key:          soundEnhancerEnabled
# Domain:       com.apple.Music
# Description:  Adds depth and presence to your music by applying audio
#               enhancement processing. Modifies the original audio.
# Default:      false
# Options:      true  = Enable sound enhancement
#               false = Play audio as recorded
# Set to:       false (preserve original audio quality)
# UI Location:  Music > Settings > Playback > Sound Enhancer
# Source:       https://support.apple.com/guide/music/change-playback-preferences-mus7a8b90c6/mac
run_defaults "com.apple.Music" "soundEnhancerEnabled" "-bool" "false"

# --- Sound Check (Volume Normalization) ---
# Key:          normalizeVolume
# Domain:       com.apple.Music
# Description:  Automatically adjusts song playback volume to the same level,
#               preventing jarring volume changes between quiet and loud tracks.
# Default:      false
# Options:      true  = Normalize volume across songs
#               false = Play at original recorded volume
# Set to:       true (consistent listening experience)
# UI Location:  Music > Settings > Playback > Sound Check
# Source:       https://support.apple.com/guide/music/change-playback-preferences-mus7a8b90c6/mac
run_defaults "com.apple.Music" "normalizeVolume" "-bool" "true"

# ==============================================================================
# Audio Quality Settings
# ==============================================================================

# --- Lossless Audio ---
# Key:          losslessEnabled
# Domain:       com.apple.Music
# Description:  Enables lossless audio quality for Apple Music streaming and
#               downloads. Requires Apple Music subscription. Uses more bandwidth
#               and storage.
# Default:      false
# Options:      true  = Enable lossless audio (ALAC)
#               false = Use AAC compression
# Set to:       true (highest quality with Apple Music)
# UI Location:  Music > Settings > Playback > Audio Quality > Lossless Audio
# Source:       https://support.apple.com/guide/music/change-playback-preferences-mus7a8b90c6/mac
# Note:         Requires Apple Music subscription
run_defaults "com.apple.Music" "losslessEnabled" "-bool" "true"

# --- Dolby Atmos ---
# Key:          dolbyAtmosEnabled
# Domain:       com.apple.Music
# Description:  Enables Dolby Atmos spatial audio for supported tracks. Creates
#               an immersive 3D sound experience.
# Default:      true (when available)
# Options:      true  = Enable Dolby Atmos for supported content
#               false = Use stereo playback
# Set to:       true (immersive audio when available)
# UI Location:  Music > Settings > Playback > Dolby Atmos
# Source:       https://support.apple.com/guide/music/change-playback-preferences-mus7a8b90c6/mac
run_defaults "com.apple.Music" "dolbyAtmosEnabled" "-bool" "true"

# ==============================================================================
# Library Settings
# ==============================================================================

# --- Add Songs to Library When Adding to Playlist ---
# Key:          addSongsToLibrary
# Domain:       com.apple.Music
# Description:  When adding Apple Music songs to a playlist, also add them to
#               your library automatically.
# Default:      true
# Options:      true  = Add to library when adding to playlist
#               false = Only add to playlist, not library
# Set to:       true (build your library)
# UI Location:  Music > Settings > General > Add songs to Library when adding to playlists
# Source:       https://support.apple.com/guide/music/change-general-preferences-mus7a8b90c5/mac
run_defaults "com.apple.Music" "addSongsToLibrary" "-bool" "true"

# --- Show Apple Music ---
# Key:          showAppleMusic
# Domain:       com.apple.Music
# Description:  Controls whether Apple Music content (Browse, For You, Radio)
#               appears in the sidebar. Disable if you only use local library.
# Default:      true
# Options:      true  = Show Apple Music content
#               false = Hide Apple Music (local library only)
# Set to:       true (access streaming content)
# UI Location:  Music > Settings > General > Show Apple Music
# Source:       https://support.apple.com/guide/music/change-general-preferences-mus7a8b90c5/mac
run_defaults "com.apple.Music" "showAppleMusic" "-bool" "true"

# --- Automatic Downloads ---
# Key:          automaticDownloadsEnabled
# Domain:       com.apple.Music
# Description:  Automatically downloads new music additions to your library.
#               Useful for offline listening but uses storage space.
# Default:      false
# Options:      true  = Auto-download new library additions
#               false = Manual downloads only
# Set to:       false (save storage, download manually)
# UI Location:  Music > Settings > General > Automatic Downloads
# Source:       https://support.apple.com/guide/music/change-general-preferences-mus7a8b90c5/mac
run_defaults "com.apple.Music" "automaticDownloadsEnabled" "-bool" "false"

# --- Show Star Ratings ---
# Key:          showStarRatings
# Domain:       com.apple.Music
# Description:  Displays the classic 5-star rating controls in the library view.
#               Allows manual rating of songs for smart playlist creation.
# Default:      false (hidden in modern Music app)
# Options:      true  = Show star rating controls
#               false = Hide star ratings
# Set to:       true (classic rating system)
# UI Location:  Music > Settings > General > Show Star Ratings
# Source:       https://support.apple.com/guide/music/change-general-preferences-mus7a8b90c5/mac
run_defaults "com.apple.Music" "showStarRatings" "-bool" "true"

# ==============================================================================
# Notification Settings
# ==============================================================================

# --- Show Notifications ---
# Key:          userWantsNotifications
# Domain:       com.apple.Music
# Description:  Controls whether Music shows notifications when the song changes
#               and the app is in the background.
# Default:      true
# Options:      true  = Show song change notifications
#               false = No notifications
# Set to:       false (reduce notification noise)
# UI Location:  Music > Settings > General > Notifications
# Source:       https://support.apple.com/guide/music/change-general-preferences-mus7a8b90c5/mac
run_defaults "com.apple.Music" "userWantsNotifications" "-bool" "false"

msg_success "Music settings applied."
msg_info "Restart Music for all settings to take effect."
