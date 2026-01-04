#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: iOS Simulator Configuration
#
# DESCRIPTION:
#   Configures iOS/watchOS/tvOS Simulator preferences for development.
#   Optimizes the simulator experience for app development and testing.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Xcode and Simulator installed
#   - Xcode Command Line Tools
#
# REFERENCES:
#   - Apple Developer: Simulator Help
#     https://developer.apple.com/documentation/xcode/running-your-app-in-simulator
#   - simctl man page: xcrun simctl help
#
# DOMAIN:
#   com.apple.iphonesimulator
#   com.apple.CoreSimulator
#
# NOTES:
#   - Simulator must be quit before applying settings
#   - Some settings require specific Xcode versions
#   - Screenshots and recordings are saved to Desktop by default
#
# ==============================================================================

run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Simulator preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring iOS Simulator settings..."

# ==============================================================================
# Screenshot & Recording Settings
# ==============================================================================

# --- Screenshot Save Location ---
# Key:          ScreenShotSaveLocation
# Domain:       com.apple.iphonesimulator
# Description:  Default location for Simulator screenshots.
# Default:      ~/Desktop
# Set to:       ~/Desktop/Simulator Screenshots (organized location)
run_defaults "com.apple.iphonesimulator" "ScreenShotSaveLocation" "-string" "$HOME/Desktop/Simulator Screenshots"

# Create the screenshots directory if it doesn't exist
if [ "$DRY_RUN_MODE" != true ]; then
  mkdir -p "$HOME/Desktop/Simulator Screenshots"
fi

# --- Screenshot Format ---
# Key:          ScreenShotFormat
# Domain:       com.apple.iphonesimulator
# Description:  Image format for screenshots.
# Default:      png
# Options:      png, tiff, bmp, gif, jpeg
# Set to:       png (lossless, good for documentation)
run_defaults "com.apple.iphonesimulator" "ScreenShotFormat" "-string" "png"

# --- Include Window Shadow in Screenshots ---
# Key:          ScreenShotIncludeDeviceBezel
# Domain:       com.apple.iphonesimulator
# Description:  Include the device bezel in screenshots.
# Default:      false
# Set to:       true (useful for App Store screenshots)
run_defaults "com.apple.iphonesimulator" "ScreenShotIncludeDeviceBezel" "-bool" "true"

# ==============================================================================
# Status Bar Configuration (App Store Screenshots)
# ==============================================================================

# --- Override Status Bar Time ---
# Key:          SimulatorStatusBarOverrideTime
# Domain:       com.apple.iphonesimulator
# Description:  Set a fixed time for the status bar (9:41 is Apple's iconic time).
# Default:      (current time)
# Set to:       9:41 AM (Apple's standard for marketing screenshots)
# Note:         Use `xcrun simctl status_bar` for more control
run_defaults "com.apple.iphonesimulator" "SimulatorStatusBarTime" "-string" "9:41"

# --- Full Battery in Status Bar ---
# Key:          ShowChargingForFullBattery
# Domain:       com.apple.iphonesimulator
# Description:  Show battery as fully charged in status bar.
# Default:      true
# Set to:       true (clean screenshots)
run_defaults "com.apple.iphonesimulator" "ShowChargingForFullBattery" "-bool" "true"

# ==============================================================================
# Window & Display Settings
# ==============================================================================

# --- Remember Window Position ---
# Key:          SimulatorWindowLastScale
# Domain:       com.apple.iphonesimulator
# Description:  Remember the last window scale/size used.
# Set to:       (preserved by system)
# Note:         Managed automatically, no need to set

# --- Connect Hardware Keyboard ---
# Key:          ConnectHardwareKeyboard
# Domain:       com.apple.iphonesimulator
# Description:  Use Mac keyboard for input instead of on-screen keyboard.
# Default:      true
# Set to:       true (faster typing during development)
run_defaults "com.apple.iphonesimulator" "ConnectHardwareKeyboard" "-bool" "true"

# --- Show Device Bezels ---
# Key:          ShowChrome
# Domain:       com.apple.iphonesimulator
# Description:  Display device frame around the simulator.
# Default:      true
# Set to:       false (more screen real estate during development)
run_defaults "com.apple.iphonesimulator" "ShowChrome" "-bool" "false"

# ==============================================================================
# Performance Settings
# ==============================================================================

# --- Slow Animations ---
# Key:          SlowMotionAnimation
# Domain:       com.apple.iphonesimulator
# Description:  Play animations in slow motion for debugging.
# Default:      false
# Set to:       false (normal speed, toggle via Debug menu when needed)
run_defaults "com.apple.iphonesimulator" "SlowMotionAnimation" "-bool" "false"

# --- Graphics Quality ---
# Key:          GraphicsQualityOverride
# Domain:       com.apple.CoreSimulator
# Description:  Override graphics quality for performance.
# Default:      (automatic)
# Options:      0 = Automatic, 1 = Low, 2 = High
# Set to:       0 (automatic based on system)
run_defaults "com.apple.CoreSimulator" "GraphicsQualityOverride" "-int" "0"

# ==============================================================================
# Audio Settings
# ==============================================================================

# --- Route Audio to Mac ---
# Key:          AudioRouting
# Domain:       com.apple.iphonesimulator
# Description:  Play simulator audio through Mac speakers.
# Default:      true
# Set to:       true (hear app sounds during development)
run_defaults "com.apple.iphonesimulator" "AudioRouting" "-bool" "true"

# ==============================================================================
# CoreSimulator Settings
# ==============================================================================

# --- Simulator Boot Timeout ---
# Key:          SimulatorBootTimeout
# Domain:       com.apple.CoreSimulator
# Description:  Maximum time to wait for simulator to boot (seconds).
# Default:      180
# Set to:       300 (5 minutes for slower machines)
run_defaults "com.apple.CoreSimulator" "SimulatorBootTimeout" "-int" "300"

# --- Disable Simulator Telemetry ---
# Key:          DisableTelemetry
# Domain:       com.apple.CoreSimulator
# Description:  Don't send simulator usage data to Apple.
# Set to:       true (privacy)
run_defaults "com.apple.CoreSimulator" "DisableTelemetry" "-bool" "true"

# --- Enable Metal Validation ---
# Key:          EnableMetalValidation
# Domain:       com.apple.CoreSimulator
# Description:  Enable Metal API validation for debugging GPU issues.
# Default:      false
# Set to:       false (enable when debugging Metal code)
run_defaults "com.apple.CoreSimulator" "EnableMetalValidation" "-bool" "false"

# ==============================================================================
# Location Simulation
# ==============================================================================

# --- Default Simulated Location ---
# Key:          SimulatedLocationDefaultLatitude
# Key:          SimulatedLocationDefaultLongitude
# Domain:       com.apple.iphonesimulator
# Description:  Default location when simulating GPS.
# Set to:       Apple Park coordinates (37.3349, -122.0090)
run_defaults "com.apple.iphonesimulator" "SimulatedLocationDefaultLatitude" "-float" "37.3349"
run_defaults "com.apple.iphonesimulator" "SimulatedLocationDefaultLongitude" "-float" "-122.0090"

# ==============================================================================
# Debugging & Development
# ==============================================================================

# --- Enable Debug Overlays ---
# Key:          ShowDebugOverlays
# Domain:       com.apple.iphonesimulator
# Description:  Show debug overlays (frame rate, etc.).
# Default:      false
# Set to:       false (enable via Debug menu when needed)
run_defaults "com.apple.iphonesimulator" "ShowDebugOverlays" "-bool" "false"

# --- Log Level ---
# Key:          LogLevel
# Domain:       com.apple.CoreSimulator
# Description:  Verbosity of simulator logs.
# Options:      0 = Default, 1 = Info, 2 = Debug
# Set to:       0 (default, increase for troubleshooting)
run_defaults "com.apple.CoreSimulator" "LogLevel" "-int" "0"

msg_success "iOS Simulator settings applied."
echo ""
msg_info "Useful Simulator commands:"
echo ""
echo "  List available devices:"
echo "    xcrun simctl list devices"
echo ""
echo "  Boot a specific device:"
echo "    xcrun simctl boot 'iPhone 15 Pro'"
echo ""
echo "  Override status bar for screenshots:"
echo "    xcrun simctl status_bar booted override --time '9:41' --batteryLevel 100"
echo ""
echo "  Reset a simulator:"
echo "    xcrun simctl erase <device-udid>"
echo ""
echo "  Open Simulator app:"
echo "    open -a Simulator"
echo ""
echo "  Take screenshot:"
echo "    xcrun simctl io booted screenshot ~/Desktop/screenshot.png"
echo ""
echo "  Record video:"
echo "    xcrun simctl io booted recordVideo ~/Desktop/recording.mp4"
