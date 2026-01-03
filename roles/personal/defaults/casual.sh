#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Personal/Casual Settings
#
# DESCRIPTION:
#   Relaxed settings for personal machines prioritizing convenience and
#   enjoyment over strict security or corporate policies.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#
# REFERENCES:
#   - Apple Support: macOS User Guide
#     https://support.apple.com/guide/mac-help/welcome/mac
#
# DOMAIN:
#   Various
#
# NOTES:
#   - These settings are less restrictive than corporate defaults
#   - Prioritizes user experience and convenience
#   - Some security settings are relaxed for personal use
#
# ==============================================================================

msg_info "Configuring personal/casual settings..."

# ==============================================================================
# Screen Saver & Sleep
# ==============================================================================

# --- Longer Delay Before Screen Saver ---
# Key:          idleTime
# Domain:       com.apple.screensaver
# Description:  Start screen saver after idle time (in seconds).
# Default:      1200 (20 minutes)
# Set to:       1800 (30 minutes - more relaxed for personal use)
run_defaults -currentHost "com.apple.screensaver" "idleTime" "-int" "1800"

# --- Longer Password Delay ---
# Key:          askForPasswordDelay
# Domain:       com.apple.screensaver
# Description:  Delay before requiring password (in seconds).
# Default:      0 (immediately)
# Set to:       60 (1 minute delay - convenient at home)
# Note:         Adjust based on your home security situation
run_defaults "com.apple.screensaver" "askForPasswordDelay" "-int" "60"

# ==============================================================================
# Finder Convenience
# ==============================================================================

# --- Show All File Extensions ---
# Key:          AppleShowAllExtensions
# Domain:       NSGlobalDomain
# Description:  Show file extensions for all files.
# Default:      false
# Set to:       true (helpful to see what you're working with)
run_defaults "NSGlobalDomain" "AppleShowAllExtensions" "-bool" "true"

# --- Spring-Loaded Folders ---
# Key:          com.apple.springing.enabled
# Domain:       NSGlobalDomain
# Description:  Enable spring-loaded folders when dragging files.
# Default:      true
# Set to:       true (convenient feature)
run_defaults "NSGlobalDomain" "com.apple.springing.enabled" "-bool" "true"

# --- Fast Spring-Loading ---
# Key:          com.apple.springing.delay
# Domain:       NSGlobalDomain
# Description:  Delay before spring-loading activates.
# Default:      0.5
# Set to:       0.2 (faster response)
run_defaults "NSGlobalDomain" "com.apple.springing.delay" "-float" "0.2"

# --- Show Path Bar ---
# Key:          ShowPathbar
# Domain:       com.apple.finder
# Description:  Show path bar at bottom of Finder windows.
# Default:      false
# Set to:       true (useful for navigation)
run_defaults "com.apple.finder" "ShowPathbar" "-bool" "true"

# --- Show Status Bar ---
# Key:          ShowStatusBar
# Domain:       com.apple.finder
# Description:  Show status bar with item count and disk space.
# Default:      false
# Set to:       true (useful information)
run_defaults "com.apple.finder" "ShowStatusBar" "-bool" "true"

# ==============================================================================
# AirDrop & Sharing
# ==============================================================================

# --- Enable AirDrop ---
# Key:          DisableAirDrop
# Domain:       com.apple.NetworkBrowser
# Description:  Enable AirDrop for easy file sharing.
# Default:      Not set (enabled)
# Set to:       false (keep AirDrop enabled)
run_defaults "com.apple.NetworkBrowser" "DisableAirDrop" "-bool" "false"

# ==============================================================================
# Sound & Notifications
# ==============================================================================

# --- Enable UI Sound Effects ---
# Key:          com.apple.sound.uiaudio.enabled
# Domain:       NSGlobalDomain
# Description:  Play UI sound effects (satisfying clicks and sounds).
# Default:      1 (enabled)
# Set to:       1 (keep the fun sounds)
run_defaults "NSGlobalDomain" "com.apple.sound.uiaudio.enabled" "-int" "1"

# --- Normal Alert Volume ---
# Key:          com.apple.sound.beep.volume
# Domain:       NSGlobalDomain
# Description:  Alert sound volume.
# Default:      1.0 (full volume)
# Set to:       0.7 (comfortable but audible)
run_defaults "NSGlobalDomain" "com.apple.sound.beep.volume" "-float" "0.7"

# ==============================================================================
# Animations & Effects
# ==============================================================================

# --- Keep Animations (enjoyable experience) ---
# Key:          reduceMotion
# Domain:       com.apple.universalaccess
# Description:  Don't reduce motion effects.
# Default:      false
# Set to:       false (enjoy the animations)
run_defaults "com.apple.universalaccess" "reduceMotion" "-bool" "false"

# --- Keep Transparency (beautiful UI) ---
# Key:          reduceTransparency
# Domain:       com.apple.universalaccess
# Description:  Don't reduce transparency.
# Default:      false
# Set to:       false (enjoy the visual effects)
run_defaults "com.apple.universalaccess" "reduceTransparency" "-bool" "false"

# --- Auto-Play Animated Images ---
# Key:          AutoPlayAnimatedImages
# Domain:       com.apple.universalaccess
# Description:  Auto-play GIFs and animated images.
# Default:      true
# Set to:       true (fun!)
run_defaults "com.apple.universalaccess" "AutoPlayAnimatedImages" "-bool" "true"

# ==============================================================================
# Dock & Desktop
# ==============================================================================

# --- Dock Magnification ---
# Key:          magnification
# Domain:       com.apple.dock
# Description:  Enable Dock icon magnification on hover.
# Default:      false
# Set to:       true (fun visual effect)
run_defaults "com.apple.dock" "magnification" "-bool" "true"

# --- Dock Magnification Size ---
# Key:          largesize
# Domain:       com.apple.dock
# Description:  Maximum magnified icon size.
# Default:      128
# Set to:       80 (noticeable but not overwhelming)
run_defaults "com.apple.dock" "largesize" "-int" "80"

# --- Dock Animation Speed ---
# Key:          autohide-time-modifier
# Domain:       com.apple.dock
# Description:  Dock show/hide animation speed.
# Default:      0.5
# Set to:       0.3 (quick but visible animation)
run_defaults "com.apple.dock" "autohide-time-modifier" "-float" "0.3"

# ==============================================================================
# Safari (Relaxed Browsing)
# ==============================================================================

# --- Enable Plugins ---
# Key:          WebKitPluginsEnabled
# Domain:       com.apple.Safari
# Description:  Enable browser plugins.
# Default:      true
# Set to:       true (needed for some content)
run_defaults "com.apple.Safari" "WebKitPluginsEnabled" "-bool" "true"

# --- AutoFill for Personal Info ---
# Key:          AutoFillFromAddressBook
# Domain:       com.apple.Safari
# Description:  AutoFill using contact info.
# Default:      true
# Set to:       true (convenient for forms)
run_defaults "com.apple.Safari" "AutoFillFromAddressBook" "-bool" "true"

# --- Remember Passwords ---
# Key:          AutoFillPasswords
# Domain:       com.apple.Safari
# Description:  AutoFill passwords.
# Default:      true
# Set to:       true (use Keychain for password management)
run_defaults "com.apple.Safari" "AutoFillPasswords" "-bool" "true"

# ==============================================================================
# Hot Corners (Optional Fun Feature)
# ==============================================================================

# Hot corners can be set to:
# 0 = No action
# 2 = Mission Control
# 3 = Application Windows
# 4 = Desktop
# 5 = Start Screen Saver
# 6 = Disable Screen Saver
# 7 = Dashboard (deprecated)
# 10 = Put Display to Sleep
# 11 = Launchpad
# 12 = Notification Center
# 13 = Lock Screen
# 14 = Quick Note

# Example: Bottom right corner = Quick Note
# run_defaults "com.apple.dock" "wvous-br-corner" "-int" "14"
# run_defaults "com.apple.dock" "wvous-br-modifier" "-int" "0"

msg_success "Personal/casual settings configured."

# ==============================================================================
# Restart Affected Services
#
# Apply Finder changes:
#   killall Finder
#
# Apply Dock changes:
#   killall Dock
#
# ==============================================================================
