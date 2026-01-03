#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Display Accessibility Settings
#
# DESCRIPTION:
#   Configures display accessibility options including reduce motion,
#   reduce transparency, contrast settings, and color filters.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#   - Some settings require logout to take effect
#
# REFERENCES:
#   - Apple Support: Change Display preferences for accessibility
#     https://support.apple.com/guide/mac-help/change-display-preferences-mchlp1108/mac
#   - Apple Support: Accessibility features on Mac
#     https://support.apple.com/guide/mac-help/accessibility-features-mh35884/mac
#
# DOMAIN:
#   com.apple.universalaccess
#   com.apple.Accessibility
#   NSGlobalDomain
#
# NOTES:
#   - These settings can improve performance on older hardware
#   - Color filters can help users with color vision deficiencies
#   - Reduce motion helps users who experience motion sickness
#
# ==============================================================================

msg_info "Configuring display accessibility settings..."

# ==============================================================================
# Motion & Animation
# ==============================================================================

# --- Reduce Motion ---
# Key:          reduceMotion
# Domain:       com.apple.universalaccess
# Description:  Reduces motion effects like parallax on the desktop,
#               app opening/closing animations, and other motion effects.
# Default:      false
# Options:      true = Reduce motion (simpler animations)
#               false = Full animations
# Set to:       false (keep animations for modern feel)
# UI Location:  System Settings > Accessibility > Display > Reduce motion
# Note:         Enabling can improve performance on older Macs
run_defaults "com.apple.universalaccess" "reduceMotion" "-bool" "false"

# --- Auto-Play Animated Images ---
# Key:          AutoPlayAnimatedImages
# Domain:       com.apple.universalaccess
# Description:  Controls whether animated images (GIFs) play automatically
#               in Safari and other apps.
# Default:      true
# Options:      true = Auto-play animations
#               false = Pause animations
# Set to:       true (auto-play by default)
# UI Location:  System Settings > Accessibility > Display > Auto-play animated images
# Note:         Set to false if animations are distracting
run_defaults "com.apple.universalaccess" "AutoPlayAnimatedImages" "-bool" "true"

# ==============================================================================
# Transparency & Contrast
# ==============================================================================

# --- Reduce Transparency ---
# Key:          reduceTransparency
# Domain:       com.apple.universalaccess
# Description:  Reduces transparency effects in windows, menu bars,
#               and the Dock for improved readability.
# Default:      false
# Options:      true = Reduce transparency (more solid)
#               false = Normal transparency effects
# Set to:       false (keep transparency for visual appeal)
# UI Location:  System Settings > Accessibility > Display > Reduce transparency
# Note:         Enabling can improve performance
run_defaults "com.apple.universalaccess" "reduceTransparency" "-bool" "false"

# --- Increase Contrast ---
# Key:          increaseContrast
# Domain:       com.apple.universalaccess
# Description:  Increases contrast to make text and elements stand out more.
#               Adds borders around buttons and other UI elements.
# Default:      false
# Options:      true = High contrast mode
#               false = Normal contrast
# Set to:       false (use normal contrast)
# UI Location:  System Settings > Accessibility > Display > Increase contrast
run_defaults "com.apple.universalaccess" "increaseContrast" "-bool" "false"

# --- Differentiate Without Color ---
# Key:          differentiateWithoutColor
# Domain:       com.apple.universalaccess
# Description:  Adds shapes to items that use color to convey information,
#               helping users who are colorblind.
# Default:      false
# Options:      true = Add shapes to colored items
#               false = Color only
# Set to:       false (use color)
# UI Location:  System Settings > Accessibility > Display > Differentiate without color
run_defaults "com.apple.universalaccess" "differentiateWithoutColor" "-bool" "false"

# ==============================================================================
# Display Options
# ==============================================================================

# --- Invert Colors ---
# Key:          whiteOnBlack
# Domain:       com.apple.universalaccess
# Description:  Inverts the colors on the screen (white becomes black, etc.).
#               Classic Invert reverses all colors.
# Default:      false
# Options:      true = Invert colors
#               false = Normal colors
# Set to:       false (normal colors)
# UI Location:  System Settings > Accessibility > Display > Invert colors
run_defaults "com.apple.universalaccess" "whiteOnBlack" "-bool" "false"

# --- Smart Invert (Available in Display settings) ---
# Smart Invert inverts colors except for images, media, and apps
# that use dark color styles. This is controlled via the UI.

# ==============================================================================
# Color Filters
# ==============================================================================

# --- Enable Color Filters ---
# Key:          colorFilterEnabled
# Domain:       com.apple.universalaccess
# Description:  Enables color filters to help with color blindness.
# Default:      false
# Options:      true = Enable color filters
#               false = Disable color filters
# Set to:       false (disable unless needed)
# UI Location:  System Settings > Accessibility > Display > Color Filters
run_defaults "com.apple.universalaccess" "colorFilterEnabled" "-bool" "false"

# --- Color Filter Type ---
# Key:          colorFilterType
# Domain:       com.apple.universalaccess
# Description:  Selects which color filter to apply.
# Default:      0 (Grayscale)
# Options:      0 = Grayscale
#               1 = Red/Green filter (Protanopia)
#               2 = Green/Red filter (Deuteranopia)
#               3 = Blue/Yellow filter (Tritanopia)
#               4 = Color Tint
# Set to:       Not set (use when colorFilterEnabled is true)
# UI Location:  System Settings > Accessibility > Display > Color Filters
# run_defaults "com.apple.universalaccess" "colorFilterType" "-int" "0"

# ==============================================================================
# Text & Cursor
# ==============================================================================

# --- Cursor Size ---
# Key:          mouseDriverCursorSize
# Domain:       com.apple.universalaccess
# Description:  Size of the mouse cursor. Normal is 1.0.
# Default:      1.0
# Options:      1.0 to 4.0
# Set to:       1.0 (normal size)
# UI Location:  System Settings > Accessibility > Display > Pointer > Pointer size
# Note:         See pointer.sh for more cursor settings
run_defaults "com.apple.universalaccess" "mouseDriverCursorSize" "-float" "1.0"

# ==============================================================================
# Menu Bar Size
# ==============================================================================

# --- Large Text in Menu Bar ---
# Key:          AppleMenuBarFontSize
# Domain:       NSGlobalDomain
# Description:  Increases font size in the menu bar.
# Default:      14
# Options:      Integer value (14-18 typical)
# Set to:       Not set (use system default)
# Note:         This may not work on all macOS versions
# run_defaults "NSGlobalDomain" "AppleMenuBarFontSize" "-int" "14"

msg_success "Display accessibility settings configured."

# ==============================================================================
# Additional Notes
#
# Night Shift (not accessibility, but display-related):
# - System Settings > Displays > Night Shift
# - Reduces blue light in the evening
# - Cannot be configured via defaults (uses Core Location)
#
# True Tone:
# - System Settings > Displays
# - Adapts display to ambient lighting
# - Hardware-dependent setting
#
# Display Resolution:
# - System Settings > Displays
# - Use "displayplacer" CLI tool for scripted resolution changes
#   brew install jakehilborn/jakehilborn/displayplacer
#
# ==============================================================================
