#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Zoom Configuration (Work Role)
#
# DESCRIPTION:
#   Work-specific Zoom settings that layer on top of global defaults.
#   Optimized for professional video conferencing and meetings.
#   Run after: defaults/applications/zoom_app.sh
#
# REQUIRES:
#   - macOS 10.13 (High Sierra) or later
#   - Zoom installed (direct download from zoom.us)
#
# REFERENCES:
#   - Zoom Support: Client settings
#     https://support.zoom.us/hc/en-us/articles/201362623
#   - Zoom Support: Audio and video settings
#     https://support.zoom.us/hc/en-us/articles/201362283
#   - Zoom Support: Recording
#     https://support.zoom.us/hc/en-us/articles/201362473
#
# DOMAIN:
#   us.zoom.xos
#
# NOTES:
#   - These settings override/extend the global Zoom defaults
#   - Professional defaults: camera/mic off when joining
#   - Zoom preferences are in ~/Library/Preferences/us.zoom.xos.plist
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Work Zoom preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Applying work-specific Zoom settings..."

# ==============================================================================
# Join Meeting Defaults (Professional Settings)
# ==============================================================================

# --- Mute Audio When Joining ---
# Key:          ZoomMuteWhenJoin
# Domain:       us.zoom.xos
# Description:  Join meetings with audio muted to avoid disruption.
# Global:       false
# Set to:       true (professional courtesy)
run_defaults "us.zoom.xos" "ZoomMuteWhenJoin" "-bool" "true"

# --- Turn Off Video When Joining ---
# Key:          ZoomVideoWhenJoin
# Domain:       us.zoom.xos
# Description:  Join with camera off, enable when ready.
# Global:       true (video on)
# Set to:       false (start with video off for privacy)
run_defaults "us.zoom.xos" "ZoomVideoWhenJoin" "-bool" "false"

# --- Always Show Meeting Controls ---
# Key:          ZoomAutoHideToolbar
# Domain:       us.zoom.xos
# Description:  Keep meeting controls visible for quick access.
# Set to:       false (don't auto-hide, always show)
run_defaults "us.zoom.xos" "ZoomAutoHideToolbar" "-bool" "false"

# ==============================================================================
# Video Settings
# ==============================================================================

# --- HD Video ---
# Key:          ZoomHDVideo
# Domain:       us.zoom.xos
# Description:  Enable high-definition video for clearer image.
# Set to:       true (better quality for professional calls)
run_defaults "us.zoom.xos" "ZoomHDVideo" "-bool" "true"

# --- Mirror Video ---
# Key:          ZoomMirrorVideo
# Domain:       us.zoom.xos
# Description:  Mirror self-view (like looking in a mirror).
# Global:       true
# Set to:       false (see yourself as others see you)
run_defaults "us.zoom.xos" "ZoomMirrorVideo" "-bool" "false"

# --- Touch Up Appearance ---
# Key:          ZoomTouchUpAppearance
# Domain:       us.zoom.xos
# Description:  Apply subtle softening filter to video.
# Set to:       true (professional appearance enhancement)
run_defaults "us.zoom.xos" "ZoomTouchUpAppearance" "-bool" "true"

# --- Low Light Adjustment ---
# Key:          ZoomAdjustForLowLight
# Domain:       us.zoom.xos
# Description:  Automatically adjust for poor lighting conditions.
# Set to:       true (improve visibility in dim environments)
run_defaults "us.zoom.xos" "ZoomAdjustForLowLight" "-bool" "true"

# --- Virtual Background ---
# Key:          ZoomUseVirtualBackground
# Domain:       us.zoom.xos
# Description:  Enable virtual backgrounds (requires good hardware).
# Set to:       true (hide home environment during calls)
run_defaults "us.zoom.xos" "ZoomUseVirtualBackground" "-bool" "true"

# ==============================================================================
# Audio Settings
# ==============================================================================

# --- Suppress Background Noise ---
# Key:          ZoomNoiseSuppressionLevel
# Domain:       us.zoom.xos
# Description:  Level of background noise suppression.
# Options:      0 = Off, 1 = Low, 2 = Medium, 3 = High, 4 = Auto
# Set to:       4 (auto - adapts to environment)
run_defaults "us.zoom.xos" "ZoomNoiseSuppressionLevel" "-int" "4"

# --- Auto-Adjust Microphone ---
# Key:          ZoomAutoAdjustMic
# Domain:       us.zoom.xos
# Description:  Automatically adjust microphone volume.
# Set to:       true (consistent audio levels)
run_defaults "us.zoom.xos" "ZoomAutoAdjustMic" "-bool" "true"

# --- Echo Cancellation ---
# Key:          ZoomEnableEchoCancellation
# Domain:       us.zoom.xos
# Description:  Prevent audio feedback loops.
# Set to:       true (essential for speaker/mic setups)
run_defaults "us.zoom.xos" "ZoomEnableEchoCancellation" "-bool" "true"

# ==============================================================================
# Recording Settings
# ==============================================================================

# --- Recording Location ---
# Key:          ZoomRecordingLocation
# Domain:       us.zoom.xos
# Description:  Default folder for local meeting recordings.
# Global:       ~/Documents/Zoom
# Set to:       ~/Documents/Zoom Recordings (organized location)
run_defaults "us.zoom.xos" "ZoomRecordingLocation" "-string" "$HOME/Documents/Zoom Recordings"

# Create the recordings directory if it doesn't exist
if [ "$DRY_RUN_MODE" != true ]; then
  mkdir -p "$HOME/Documents/Zoom Recordings"
fi

# --- Record Video During Screen Share ---
# Key:          ZoomRecordVideoInShare
# Domain:       us.zoom.xos
# Description:  Include video thumbnails in recordings.
# Set to:       true (capture participant reactions)
run_defaults "us.zoom.xos" "ZoomRecordVideoInShare" "-bool" "true"

# ==============================================================================
# Display Settings
# ==============================================================================

# --- Show Meeting Duration ---
# Key:          ZoomShowMeetingTimer
# Domain:       us.zoom.xos
# Description:  Display elapsed meeting time.
# Set to:       true (time awareness for scheduling)
run_defaults "us.zoom.xos" "ZoomShowMeetingTimer" "-bool" "true"

# --- Dual Monitor Mode ---
# Key:          ZoomUseDualMonitor
# Domain:       us.zoom.xos
# Description:  Use dual monitors for gallery and screen share.
# Set to:       true (if available, maximize workspace)
run_defaults "us.zoom.xos" "ZoomUseDualMonitor" "-bool" "true"

# --- Side-by-Side Mode ---
# Key:          ZoomSideBySideMode
# Domain:       us.zoom.xos
# Description:  Show screen share and participants side by side.
# Set to:       true (see both content and people)
run_defaults "us.zoom.xos" "ZoomSideBySideMode" "-bool" "true"

# ==============================================================================
# Performance Settings
# ==============================================================================

# --- Hardware Acceleration ---
# Key:          ZoomHardwareAcceleration
# Domain:       us.zoom.xos
# Description:  Use GPU for video processing.
# Set to:       true (better performance, less CPU usage)
run_defaults "us.zoom.xos" "ZoomHardwareAcceleration" "-bool" "true"

# --- Optimize for Video Clip ---
# Key:          ZoomOptimizeForVideoClip
# Domain:       us.zoom.xos
# Description:  Better quality when sharing video content.
# Set to:       false (default off, enable when sharing videos)
run_defaults "us.zoom.xos" "ZoomOptimizeForVideoClip" "-bool" "false"

# ==============================================================================
# Accessibility & UX
# ==============================================================================

# --- Always Show Names on Video ---
# Key:          ZoomShowNameOnVideo
# Domain:       us.zoom.xos
# Description:  Display participant names on video tiles.
# Set to:       true (easier identification in large meetings)
run_defaults "us.zoom.xos" "ZoomShowNameOnVideo" "-bool" "true"

# --- Enable Screen Reader Support ---
# Key:          ZoomEnableScreenReader
# Domain:       us.zoom.xos
# Description:  Accessibility support for screen readers.
# Set to:       false (enable if using screen reader)
run_defaults "us.zoom.xos" "ZoomEnableScreenReader" "-bool" "false"

msg_success "Work Zoom settings applied."
echo ""
msg_info "Additional work Zoom setup (in-app settings):"
echo ""
echo "  AUDIO/VIDEO:"
echo "    - Test audio/video before meetings: Settings > Audio/Video"
echo "    - Select default camera and microphone"
echo "    - Choose professional virtual background"
echo ""
echo "  SECURITY:"
echo "    - Enable waiting room for meetings you host"
echo "    - Require passcode for meetings"
echo "    - Disable 'Join before host' for sensitive meetings"
echo ""
echo "  CALENDAR INTEGRATION:"
echo "    - Connect to work calendar (Outlook/Google)"
echo "    - Enable 'Join' button from calendar"
echo ""
echo "  KEYBOARD SHORTCUTS:"
echo "    - Cmd+Shift+A: Mute/Unmute audio"
echo "    - Cmd+Shift+V: Start/Stop video"
echo "    - Cmd+Shift+S: Start/Stop screen share"
echo "    - Cmd+Shift+H: Show/Hide chat"
