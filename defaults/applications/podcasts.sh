#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Podcasts Configuration
#
# DESCRIPTION:
#   This script configures Apple Podcasts preferences including download
#   behavior, episode management, playback settings, and sync options.
#   Podcasts syncs subscriptions and listening progress across Apple devices.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Podcasts app (included with macOS)
#
# REFERENCES:
#   - Apple Support: Use Podcasts on Mac
#     https://support.apple.com/guide/podcasts/welcome/mac
#   - Apple Support: Change Podcasts settings
#     https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
#
# DOMAIN:
#   com.apple.podcasts
#
# NOTES:
#   - Podcasts was separated from iTunes in macOS Catalina (10.15)
#   - Preferences stored in ~/Library/Preferences/com.apple.podcasts.plist
#   - Downloaded episodes stored in ~/Library/Group Containers/
#   - Subscriptions and progress sync via iCloud
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Podcasts preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Podcasts settings..."

# ==============================================================================
# Playback Settings
# ==============================================================================

# --- Skip Forward Seconds ---
# Key:          skipForwardTime
# Domain:       com.apple.podcasts
# Description:  Number of seconds to skip forward when pressing the skip forward
#               button during playback.
# Default:      30
# Options:      10, 15, 30, 45, 60 (seconds)
# Set to:       30 (standard skip length)
# UI Location:  Podcasts > Settings > Playback > Skip Forward
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "skipForwardTime" "-int" "30"

# --- Skip Back Seconds ---
# Key:          skipBackTime
# Domain:       com.apple.podcasts
# Description:  Number of seconds to skip backward when pressing the skip back
#               button during playback.
# Default:      15
# Options:      10, 15, 30, 45, 60 (seconds)
# Set to:       15 (replay short segments)
# UI Location:  Podcasts > Settings > Playback > Skip Back
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "skipBackTime" "-int" "15"

# --- Continuous Playback ---
# Key:          continuousPlaybackEnabled
# Domain:       com.apple.podcasts
# Description:  Controls whether the next episode automatically plays when the
#               current episode ends.
# Default:      true
# Options:      true  = Auto-play next episode
#               false = Stop after current episode
# Set to:       true (continuous listening)
# UI Location:  Podcasts > Settings > Playback > Continuous Playback
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "continuousPlaybackEnabled" "-bool" "true"

# --- Headphone Controls ---
# Key:          headphoneControlsNextEpisode
# Domain:       com.apple.podcasts
# Description:  Controls whether double-pressing the headphone button skips to
#               the next episode instead of skipping forward.
# Default:      false
# Options:      true  = Double-press skips to next episode
#               false = Double-press skips forward
# Set to:       false (skip forward, not next episode)
# UI Location:  Podcasts > Settings > Playback > Headphone Controls
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "headphoneControlsNextEpisode" "-bool" "false"

# ==============================================================================
# Download Settings
# ==============================================================================

# --- Download Episodes ---
# Key:          downloadNewEpisodes
# Domain:       com.apple.podcasts
# Description:  Controls whether new episodes are automatically downloaded when
#               available. Per-show setting can override this default.
# Default:      true
# Options:      true  = Download new episodes automatically
#               false = Stream only (download manually)
# Set to:       true (offline listening)
# UI Location:  Podcasts > Settings > General > Download Episodes
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "downloadNewEpisodes" "-bool" "true"

# --- Remove Played Episodes ---
# Key:          removePlayedEpisodes
# Domain:       com.apple.podcasts
# Description:  Automatically removes downloaded episodes after they've been
#               played to save storage space.
# Default:      true
# Options:      true  = Remove after playing
#               false = Keep all downloaded episodes
# Set to:       true (save storage)
# UI Location:  Podcasts > Settings > General > Remove Played Downloads
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "removePlayedEpisodes" "-bool" "true"

# ==============================================================================
# Episode Management
# ==============================================================================

# --- Episode Limit ---
# Key:          episodeLimit
# Domain:       com.apple.podcasts
# Description:  Maximum number of episodes to keep per podcast. Older episodes
#               beyond this limit are automatically removed.
# Default:      0 (no limit)
# Options:      0  = No limit (keep all)
#               1  = Most recent episode only
#               3  = Last 3 episodes
#               5  = Last 5 episodes
#               10 = Last 10 episodes
# Set to:       10 (balance storage and availability)
# UI Location:  Podcasts > Settings > General > Limit Episodes
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "episodeLimit" "-int" "10"

# ==============================================================================
# Sync Settings
# ==============================================================================

# --- Sync Podcasts ---
# Key:          syncPodcasts
# Domain:       com.apple.podcasts
# Description:  Enables syncing podcast subscriptions and listening progress
#               across all devices signed into the same Apple ID.
# Default:      true
# Options:      true  = Sync subscriptions and progress
#               false = Keep podcasts local to this device
# Set to:       true (seamless multi-device experience)
# UI Location:  Podcasts > Settings > General > Sync Podcasts
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "syncPodcasts" "-bool" "true"

# --- Sync Listening History ---
# Key:          syncListeningHistory
# Domain:       com.apple.podcasts
# Description:  Syncs played/unplayed status and playback position across
#               devices. Continue listening where you left off.
# Default:      true
# Options:      true  = Sync listening progress
#               false = Don't sync progress
# Set to:       true (continue on any device)
# UI Location:  Podcasts > Settings > General
# Source:       https://support.apple.com/guide/podcasts/change-settings-podb804dc5bd/mac
run_defaults "com.apple.podcasts" "syncListeningHistory" "-bool" "true"

msg_success "Podcasts settings applied."
msg_info "Restart Podcasts for all settings to take effect."
