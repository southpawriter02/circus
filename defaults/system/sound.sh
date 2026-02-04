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

# ==============================================================================
# macOS Audio Architecture
# ==============================================================================

# macOS uses CoreAudio as its low-level audio framework. System sounds are
# handled separately from application audio.
#
# AUDIO LAYERS:
#
#   Application Audio
#        ↓
#   AVFoundation / AudioToolbox
#        ↓
#   Audio Units (effects, processing)
#        ↓
#   CoreAudio (HAL - Hardware Abstraction Layer)
#        ↓
#   Audio Hardware (speakers, headphones, etc.)
#
# SYSTEM SOUND CATEGORIES:
#
#   1. ALERT SOUNDS (beeps)
#      - Domain: NSGlobalDomain, com.apple.sound.beep.*
#      - Used for: Errors, warnings, empty trash, notifications
#      - Can have separate volume from system audio
#
#   2. UI SOUNDS
#      - Domain: NSGlobalDomain, com.apple.sound.uiaudio.*
#      - Used for: Clicks, navigation, screenshot sounds
#      - Toggle on/off separately from alerts
#
#   3. STARTUP SOUND
#      - Domain: com.apple.systemsound, NVRAM
#      - The classic Mac chime (or lack thereof on modern Macs)
#
# SOUND FILE LOCATIONS:
#   /System/Library/Sounds/        # Built-in system sounds (read-only)
#   ~/Library/Sounds/              # Custom user sounds (add yours here)
#   /Library/Sounds/               # System-wide custom sounds
#
# ADDING CUSTOM ALERT SOUNDS:
#   1. Convert audio to .aiff format (44.1kHz, 16-bit recommended)
#   2. Copy to ~/Library/Sounds/
#   3. Sound appears in System Settings > Sound > Alert sound
#
# Source:       https://developer.apple.com/documentation/coreaudio

msg_info "Configuring sound settings..."

# ==============================================================================
# System Alert Sounds
# ==============================================================================

# --- Alert Sound Volume ---
# Key:          com.apple.sound.beep.volume
# Domain:       NSGlobalDomain
# Description:  Controls the volume level for system alert sounds. This is
#               independent of the main system volume, allowing you to have
#               quiet alerts while music plays at full volume, or vice versa.
#
#               Value Range:
#               0.0 = Completely muted (no alert sounds)
#               0.5 = Half volume (a good default)
#               1.0 = Full volume (matches output volume slider)
#
# Default:      1.0 (full volume relative to system volume)
# Options:      Float from 0.0 (muted) to 1.0 (max)
# Set to:       0.5 (moderate - audible but not startling)
# UI Location:  System Settings > Sound > Alert volume slider
# Note:         This scales the alert relative to your output volume.
#               At 0.5, alerts play at 50% of your current volume setting.
run_defaults "NSGlobalDomain" "com.apple.sound.beep.volume" "-float" "0.5"

# --- Alert Sound Selection ---
# Key:          com.apple.sound.beep.sound
# Domain:       NSGlobalDomain
# Description:  Path to the audio file used for system alerts. macOS includes
#               several built-in sounds, and you can add custom sounds by
#               placing .aiff files in ~/Library/Sounds/.
#
#               Built-in Sounds (in /System/Library/Sounds/):
#               ┌─────────────┬────────────────────────────────────┐
#               │ Sound       │ Character                          │
#               ├─────────────┼────────────────────────────────────┤
#               │ Basso       │ Deep, ominous                      │
#               │ Blow        │ Soft, airy                         │
#               │ Bottle      │ Hollow pop                         │
#               │ Frog        │ Ribbit                             │
#               │ Funk        │ Funky bass hit                     │
#               │ Glass       │ Bright, crystalline                │
#               │ Hero        │ Triumphant fanfare                 │
#               │ Morse       │ Morse code beep                    │
#               │ Ping        │ Clean, minimal                     │
#               │ Pop         │ Quick bubble pop                   │
#               │ Purr        │ Soft vibration                     │
#               │ Sosumi      │ Classic Mac "So sue me" (historic) │
#               │ Submarine   │ Sonar ping                         │
#               │ Tink        │ Light tap (default)                │
#               └─────────────┴────────────────────────────────────┘
#
# Default:      /System/Library/Sounds/Tink.aiff
# Options:      Path to any valid .aiff sound file
# Set to:       Default (Tink) - uncomment and modify to change
# UI Location:  System Settings > Sound > Alert sound
# Note:         Custom sounds must be in AIFF format. Convert with:
#               afconvert input.mp3 -o ~/Library/Sounds/custom.aiff -f AIFF
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
