#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Zoom Configuration
#
# DESCRIPTION:
#   This script configures Zoom preferences including audio/video defaults,
#   meeting behavior, and virtual background settings. Zoom is a video
#   conferencing platform for meetings, webinars, and screen sharing.
#
# REQUIRES:
#   - macOS 10.10 (Yosemite) or later
#   - Zoom app installed
#
# REFERENCES:
#   - Zoom Help: Meeting settings
#     https://support.zoom.us/hc/en-us/articles/201362623-Meeting-settings
#   - Zoom Help: Desktop client settings
#     https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
#
# DOMAIN:
#   us.zoom.xos
#
# NOTES:
#   - Zoom preferences in ~/Library/Preferences/us.zoom.xos.plist
#   - Some settings sync with your Zoom account
#   - Meeting-specific settings may override app defaults
#   - Virtual backgrounds stored in ~/Library/Application Support/zoom.us/
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Zoom preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Zoom settings..."

# ==============================================================================
# Video Settings
# ==============================================================================

# --- Turn Off Video When Joining ---
# Key:          ZMEnableStopVideoWhenJoin
# Domain:       us.zoom.xos
# Description:  Automatically turns off your camera when joining meetings,
#               giving you time to prepare before being seen.
# Default:      false (video on when joining)
# Options:      true  = Join with video off
#               false = Join with video on
# Set to:       true (privacy - join video off)
# UI Location:  Zoom > Settings > Video > Turn off my video when joining a meeting
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnableStopVideoWhenJoin" "-bool" "true"

# --- HD Video ---
# Key:          ZMEnableHDVideo
# Domain:       us.zoom.xos
# Description:  Enables HD video quality for meetings. Requires more bandwidth
#               but provides clearer video.
# Default:      true
# Options:      true  = Enable HD video
#               false = Standard definition video
# Set to:       true (better video quality)
# UI Location:  Zoom > Settings > Video > HD
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnableHDVideo" "-bool" "true"

# --- Mirror My Video ---
# Key:          ZMMirrorVideo
# Domain:       us.zoom.xos
# Description:  Shows your video as a mirror image (like looking in a mirror).
#               Only affects your self-view; others see you normally.
# Default:      true
# Options:      true  = Mirror self-view
#               false = Don't mirror
# Set to:       true (natural self-view)
# UI Location:  Zoom > Settings > Video > Mirror my video
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMMirrorVideo" "-bool" "true"

# ==============================================================================
# Audio Settings
# ==============================================================================

# --- Mute When Joining ---
# Key:          ZMEnableMuteWhenJoin
# Domain:       us.zoom.xos
# Description:  Automatically mutes your microphone when joining meetings,
#               preventing accidental background noise.
# Default:      false (unmuted when joining)
# Options:      true  = Join muted
#               false = Join unmuted
# Set to:       true (courtesy to other participants)
# UI Location:  Zoom > Settings > Audio > Mute my microphone when joining a meeting
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnableMuteWhenJoin" "-bool" "true"

# --- Automatically Join Audio ---
# Key:          ZMEnableAutoJoinVoip
# Domain:       us.zoom.xos
# Description:  Automatically connects to meeting audio using your computer
#               instead of prompting each time.
# Default:      true
# Options:      true  = Auto-join computer audio
#               false = Prompt for audio connection method
# Set to:       true (seamless audio join)
# UI Location:  Zoom > Settings > Audio > Automatically join audio by computer
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnableAutoJoinVoip" "-bool" "true"

# ==============================================================================
# Meeting Settings
# ==============================================================================

# --- Use Dual Monitors ---
# Key:          ZMEnableDualMonitor
# Domain:       us.zoom.xos
# Description:  Enables dual monitor mode, which shows the gallery view on one
#               screen and shared content on another.
# Default:      false
# Options:      true  = Enable dual monitor mode
#               false = Single monitor mode
# Set to:       false (most users have single monitor)
# UI Location:  Zoom > Settings > General > Use dual monitors
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnableDualMonitor" "-bool" "false"

# --- Enter Full Screen When Sharing ---
# Key:          ZMEnterFullScreenWhenShare
# Domain:       us.zoom.xos
# Description:  Automatically enters full screen mode when viewing shared
#               content from other participants.
# Default:      true
# Options:      true  = Full screen on share
#               false = Keep in window
# Set to:       false (keep control of screen)
# UI Location:  Zoom > Settings > Share Screen
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnterFullScreenWhenShare" "-bool" "false"

# ==============================================================================
# Chat Settings
# ==============================================================================

# --- Show Chat Notifications ---
# Key:          ZMEnableChatNotification
# Domain:       us.zoom.xos
# Description:  Shows system notifications for chat messages during meetings.
# Default:      true
# Options:      true  = Show chat notifications
#               false = Don't show chat notifications
# Set to:       true (stay informed of messages)
# UI Location:  Zoom > Settings > General > Show notifications
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnableChatNotification" "-bool" "true"

# ==============================================================================
# Appearance Settings
# ==============================================================================

# --- Touch Up My Appearance ---
# Key:          ZMEnableTouchUpAppearance
# Domain:       us.zoom.xos
# Description:  Applies a softening effect to smooth your skin appearance on
#               camera. Can look artificial but helps with video lighting issues.
# Default:      false
# Options:      true  = Enable touch up effect
#               false = Natural appearance
# Set to:       false (natural look)
# UI Location:  Zoom > Settings > Video > Touch up my appearance
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMEnableTouchUpAppearance" "-bool" "false"

# --- Original Sound for Musicians ---
# Key:          ZMEnableOriginalSound
# Domain:       us.zoom.xos
# Description:  Disables audio processing (noise suppression, echo cancellation)
#               for better music quality. Useful for musicians and audio pros.
# Default:      false
# Options:      true  = Enable original sound (no processing)
#               false = Standard audio processing
# Set to:       false (standard processing for meetings)
# UI Location:  Zoom > Settings > Audio > Music and Professional Audio
# Source:       https://support.zoom.us/hc/en-us/articles/115003279466
run_defaults "us.zoom.xos" "ZMEnableOriginalSound" "-bool" "false"

# --- Always Show Meeting Controls ---
# Key:          ZMAlwaysShowMeetingControls
# Domain:       us.zoom.xos
# Description:  Keeps the meeting control toolbar visible at all times instead
#               of auto-hiding after a few seconds.
# Default:      false (auto-hide)
# Options:      true  = Always show controls
#               false = Auto-hide controls
# Set to:       true (easier access to controls)
# UI Location:  Zoom > Settings > General > Always show meeting controls
# Source:       https://support.zoom.us/hc/en-us/articles/201362163-Desktop-client-settings
run_defaults "us.zoom.xos" "ZMAlwaysShowMeetingControls" "-bool" "true"

msg_success "Zoom settings applied."
echo ""
msg_info "Additional Zoom settings in-app (Zoom > Settings):"
echo "  Video: Virtual background, touch up appearance"
echo "  Audio: Noise suppression, test speakers/mic"
echo "  Share Screen: Optimize for video clips"
echo "  Recording: Local recording location"
