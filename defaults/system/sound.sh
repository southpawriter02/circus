#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Sound Settings
#
# DESCRIPTION:
#   Configures system sound settings including alert sounds, UI sound effects,
#   volume feedback, and audio input/output preferences.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require logout to take effect
#
# REFERENCES:
#   - Apple Support: Change the alert sound on Mac
#     https://support.apple.com/guide/mac-help/change-the-alert-sound-mchlp2207/mac
#   - Apple Support: Adjust sound settings
#     https://support.apple.com/guide/mac-help/adjust-the-sound-on-mac-mchlp2256/mac
#
# DOMAIN:
#   com.apple.systemsound
#   com.apple.sound.beep
#   NSGlobalDomain
#
# NOTES:
#   - UI sounds include clicks, alerts, and notification sounds
#   - Volume feedback is the "pop" sound when adjusting volume
#
# ==============================================================================

msg_info "Configuring sound settings..."

# ==============================================================================
# System Alert Sounds
# ==============================================================================

# --- Alert Sound Volume ---
# Key:          com.apple.sound.beep.volume
# Domain:       NSGlobalDomain
# Description:  Controls the volume of alert sounds (beeps, notifications).
#               Value is a float between 0.0 (muted) and 1.0 (full volume).
# Default:      1.0 (full volume)
# Options:      0.0 to 1.0
# Set to:       0.5 (moderate alert volume)
# UI Location:  System Settings > Sound > Alert volume
run_defaults "NSGlobalDomain" "com.apple.sound.beep.volume" "-float" "0.5"

# --- Alert Sound Selection ---
# Key:          com.apple.sound.beep.sound
# Domain:       NSGlobalDomain
# Description:  Path to the alert sound file. Built-in sounds are in
#               /System/Library/Sounds/. Custom sounds can be placed in
#               ~/Library/Sounds/.
# Default:      /System/Library/Sounds/Tink.aiff
# Options:      Any valid .aiff file path
# Set to:       Default (Tink) - uncomment below to change
# UI Location:  System Settings > Sound > Alert sound
# Available sounds: Basso, Blow, Bottle, Frog, Funk, Glass, Hero, Morse,
#                   Ping, Pop, Purr, Sosumi, Submarine, Tink
# run_defaults "NSGlobalDomain" "com.apple.sound.beep.sound" "-string" "/System/Library/Sounds/Tink.aiff"

# ==============================================================================
# UI Sound Effects
# ==============================================================================

# --- Play UI Sound Effects ---
# Key:          com.apple.sound.uiaudio.enabled
# Domain:       NSGlobalDomain
# Description:  Enable or disable UI sound effects such as clicking sounds,
#               empty trash sound, screenshot sound, etc.
# Default:      1 (enabled)
# Options:      0 = Disabled, 1 = Enabled
# Set to:       1 (keep UI sounds for feedback)
# UI Location:  System Settings > Sound > Play user interface sound effects
run_defaults "NSGlobalDomain" "com.apple.sound.uiaudio.enabled" "-int" "1"

# --- Play Sound on Startup ---
# Key:          StartupMute
# Domain:       com.apple.systemsound
# Description:  Controls the startup chime on Intel Macs.
#               Note: Modern Macs with T2/Apple Silicon may not have a chime.
# Default:      0 (play startup sound)
# Options:      0 = Play startup sound, 1 = Mute startup sound
# Set to:       0 (play the startup sound)
# Note:         This can also be set via: sudo nvram StartupMute=%00
run_defaults "com.apple.systemsound" "com.apple.sound.beep.sound" "-int" "0"

# ==============================================================================
# Volume Feedback
# ==============================================================================

# --- Play Feedback When Volume Is Changed ---
# Key:          com.apple.sound.beep.feedback
# Domain:       NSGlobalDomain
# Description:  Play a "pop" sound when adjusting volume with keyboard keys
#               or the menu bar slider.
# Default:      1 (enabled)
# Options:      0 = Disabled (silent volume changes)
#               1 = Enabled (audible feedback)
# Set to:       0 (disable volume change feedback sound)
# UI Location:  System Settings > Sound > Play feedback when volume is changed
run_defaults "NSGlobalDomain" "com.apple.sound.beep.feedback" "-int" "0"

# ==============================================================================
# Accessibility Sound Settings
# ==============================================================================

# --- Flash Screen on Alert ---
# Key:          flashScreen
# Domain:       com.apple.universalaccess
# Description:  Flashes the screen when an alert sound plays. This visual cue
#               is useful for users who are deaf or hard of hearing, or in
#               noisy environments where audio alerts might be missed.
# Default:      false (no screen flash)
# Options:      true  = Flash screen on alert sounds
#               false = No screen flash
# Set to:       false (disabled for most users)
# UI Location:  System Settings > Accessibility > Audio > Flash the screen when an alert sound occurs
# Source:       https://support.apple.com/guide/mac-help/change-accessibility-audio-settings-mchlc8899a11/mac
run_defaults "com.apple.universalaccess" "flashScreen" "-bool" "false"

# --- Stereo Audio Balance ---
# Key:          com.apple.sound.beep.stereoPan
# Domain:       NSGlobalDomain
# Description:  Controls the left/right balance for stereo audio output.
#               Centered (0.0) provides equal volume to both channels.
#               Useful for users with hearing differences between ears.
# Default:      0.0 (centered)
# Options:      Float value from -1.0 to 1.0
#               -1.0 = Full left
#               0.0  = Centered (balanced)
#               1.0  = Full right
# Set to:       0.0 (balanced stereo output)
# UI Location:  System Settings > Sound > Output > Balance slider
# Source:       https://support.apple.com/guide/mac-help/adjust-the-sound-on-mac-mchlp2256/mac
run_defaults "NSGlobalDomain" "com.apple.sound.beep.stereoPan" "-float" "0.0"

# --- Interface Sound Effects Volume ---
# Key:          com.apple.sound.uiaudio.enabled
# Domain:       NSGlobalDomain
# Description:  Controls whether UI sound effects play (clicks, trash sounds,
#               screenshot sounds, etc.). Already configured above, but this
#               documents the full behavior. Note: The key uses integer values.
# Default:      1 (enabled)
# Options:      0 = Disabled (silent interface)
#               1 = Enabled (play UI sounds)
# Set to:       1 (keep UI sounds for feedback)
# UI Location:  System Settings > Sound > Play user interface sound effects
# Note:         This complements the alert volume setting for complete audio control.

# ==============================================================================
# Audio Input/Output
#
# NOTE: Input and output device selection is typically done through:
# - System Settings > Sound > Input/Output
# - Menu bar sound icon
# - Audio MIDI Setup.app for advanced settings
#
# These settings are hardware-specific and usually not set via defaults.
# Use the following commands to inspect audio devices:
#
# List audio devices:
#   system_profiler SPAudioDataType
#
# Get current volume:
#   osascript -e 'output volume of (get volume settings)'
#
# Set volume (0-100):
#   osascript -e 'set volume output volume 50'
#
# Mute/Unmute:
#   osascript -e 'set volume output muted true'
#   osascript -e 'set volume output muted false'
#
# ==============================================================================

# ==============================================================================
# Notification Sounds
#
# NOTE: Notification sounds for specific apps are configured in:
# System Settings > Notifications > [App Name] > Play sound for notifications
#
# These are per-app settings and cannot be bulk-configured via defaults.
# To disable all notification sounds:
#   Focus mode (Do Not Disturb) silences all notifications
#
# ==============================================================================

msg_success "Sound settings configured."
