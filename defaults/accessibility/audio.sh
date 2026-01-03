#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Accessibility Audio Settings
#
# DESCRIPTION:
#   This script configures macOS audio accessibility settings including flash
#   screen for alerts, mono audio for hearing impairment, and audio balance
#   adjustments. These settings help users with hearing difficulties.
#
# REQUIRES:
#   - macOS 10.14 (Mojave) or later
#
# REFERENCES:
#   - Apple Support: Change Audio accessibility settings
#     https://support.apple.com/guide/mac-help/change-audio-accessibility-settings-mh18127/mac
#   - Apple Support: Accessibility features on Mac
#     https://support.apple.com/guide/mac-help/accessibility-features-mh35884/mac
#
# DOMAIN:
#   com.apple.universalaccess
#
# NOTES:
#   - Audio accessibility settings are stored in com.apple.universalaccess
#   - Some settings may require a logout to take full effect
#   - These settings are system-wide and affect all applications
#   - Hearing aid compatibility is hardware-dependent
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Accessibility preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Audio accessibility settings..."

# ==============================================================================
# Visual Alerts
# ==============================================================================

# --- Flash Screen for Alerts ---
# Key:          flashScreen
# Domain:       com.apple.universalaccess
# Description:  Flashes the screen when an alert sound plays. Provides a visual
#               cue for users who are deaf or hard of hearing, or for use in
#               quiet environments where sound is disabled.
# Default:      false (no flash)
# Options:      true  = Flash screen when alerts play
#               false = No visual flash for alerts
# Set to:       false (enable if hearing impaired or in quiet mode)
# UI Location:  System Settings > Accessibility > Audio > Flash the screen when an alert sound occurs
# Source:       https://support.apple.com/guide/mac-help/change-audio-accessibility-settings-mh18127/mac
run_defaults "com.apple.universalaccess" "flashScreen" "-bool" "false"

# ==============================================================================
# Stereo Audio Settings
# ==============================================================================

# --- Play Stereo Audio as Mono ---
# Key:          stereoAsMono
# Domain:       com.apple.universalaccess
# Description:  Combines left and right audio channels into mono. Useful for
#               users with hearing loss in one ear, ensuring no audio content
#               is missed when using both speakers/headphones.
# Default:      false (stereo audio)
# Options:      true  = Play mono audio (combined L+R)
#               false = Play stereo audio (separate L/R)
# Set to:       false (keep stereo unless needed)
# UI Location:  System Settings > Accessibility > Audio > Play stereo audio as mono
# Source:       https://support.apple.com/guide/mac-help/change-audio-accessibility-settings-mh18127/mac
run_defaults "com.apple.universalaccess" "stereoAsMono" "-bool" "false"

# ==============================================================================
# Audio Balance
# ==============================================================================

# --- Audio Balance ---
# Key:          audioBalance
# Domain:       com.apple.universalaccess
# Description:  Adjusts the left/right audio balance. Useful for users with
#               partial hearing loss in one ear to compensate for the
#               difference. Value ranges from -1.0 (left) to 1.0 (right).
# Default:      0.0 (centered)
# Options:      -1.0 = Full left
#               0.0  = Centered (balanced)
#               1.0  = Full right
# Set to:       0.0 (centered balance)
# UI Location:  System Settings > Accessibility > Audio > Audio balance slider
# Source:       https://support.apple.com/guide/mac-help/change-audio-accessibility-settings-mh18127/mac
# Note:         Using -float type for decimal values
run_defaults "com.apple.universalaccess" "audioBalance" "-float" "0.0"

# ==============================================================================
# Hearing Aids
# ==============================================================================

# --- Hearing Aid Mode ---
# Key:          HearingAidMode
# Domain:       com.apple.universalaccess
# Description:  Enables Made for iPhone (MFi) hearing aid compatibility when
#               compatible hearing aids are connected via Bluetooth. Improves
#               audio quality and enables hearing aid control from Mac.
# Default:      false
# Options:      true  = Enable hearing aid mode
#               false = Disable hearing aid mode
# Set to:       false (enable if using compatible hearing aids)
# UI Location:  System Settings > Accessibility > Hearing > Hearing Devices
# Source:       https://support.apple.com/guide/mac-help/change-audio-accessibility-settings-mh18127/mac
# Note:         Requires compatible MFi hearing aids
run_defaults "com.apple.universalaccess" "HearingAidMode" "-bool" "false"

# ==============================================================================
# Headphone Accommodations
#
# Headphone audio customization is available for AirPods and other Apple/Beats
# headphones. These settings are configured in:
#
# System Settings > Accessibility > Audio > Headphone Accommodations
#
# Options include:
# - Tune audio for: Balanced Tone, Vocal Range, Brightness
# - Soft sounds: Amplify soft sounds
# - Custom audio setup based on audiogram
#
# These are per-device settings and configured through the UI.
# ==============================================================================

# ==============================================================================
# Background Sounds
#
# Background sounds (white noise, rain, etc.) are available to mask
# environmental noise. Configured in:
#
# System Settings > Accessibility > Audio > Background Sounds
#
# Options:
# - Sound: Balanced Noise, Bright Noise, Dark Noise, Ocean, Rain, Stream
# - Volume level
# - Use when media is playing
#
# These are configured through the UI, not defaults.
# ==============================================================================

msg_success "Audio accessibility settings applied."
echo ""
msg_info "Additional audio settings in System Settings > Accessibility > Audio:"
echo "  - Headphone Accommodations: Custom audio for AirPods/Beats"
echo "  - Background Sounds: Ambient noise (rain, white noise)"
echo "  - Hearing Devices: Pair and control MFi hearing aids"
