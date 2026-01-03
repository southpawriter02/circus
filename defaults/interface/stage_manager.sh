#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Stage Manager
#
# DESCRIPTION:
#   Configures Stage Manager window organization feature introduced in
#   macOS Ventura. Controls behavior, strip visibility, and app grouping.
#
# REQUIRES:
#   - macOS 13 (Ventura) or later
#   - Supported on Apple Silicon and Intel Macs
#
# REFERENCES:
#   - Apple Support: Use Stage Manager on your Mac
#     https://support.apple.com/guide/mac-help/mchl534ba392/mac
#
# DOMAIN:
#   com.apple.WindowManager
#
# NOTES:
#   - Stage Manager is an alternative window management mode
#   - Can be toggled from Control Center or keyboard shortcut
#
# ==============================================================================

msg_info "Configuring Stage Manager settings..."

# ==============================================================================
# Stage Manager Enable/Disable
# ==============================================================================

# --- Enable Stage Manager ---
# Key:          GloballyEnabled
# Domain:       com.apple.WindowManager
# Description:  Master toggle for Stage Manager. When enabled, windows are
#               organized into groups on the left side of the screen.
# Default:      false
# Options:      true = Enable Stage Manager
#               false = Use traditional window management
# Set to:       false (traditional window management)
# UI Location:  System Settings > Desktop & Dock > Stage Manager
run_defaults "com.apple.WindowManager" "GloballyEnabled" "-bool" "false"

# ==============================================================================
# Stage Manager Behavior
# ==============================================================================

# --- Show Recent Apps in Stage Manager ---
# Key:          AutoHide
# Domain:       com.apple.WindowManager
# Description:  Show the recent apps strip on the left side of the screen.
# Default:      true
# Options:      true = Show strip
#               false = Hide strip
# Set to:       true (show recent apps)
run_defaults "com.apple.WindowManager" "AutoHide" "-bool" "false"

# --- Show Desktop Items ---
# Key:          HideDesktop
# Domain:       com.apple.WindowManager  
# Description:  Hide desktop items when Stage Manager is active.
# Default:      false (show desktop)
# Options:      true = Hide desktop items
#               false = Show desktop items
# Set to:       false (show desktop items)
run_defaults "com.apple.WindowManager" "HideDesktop" "-bool" "false"

# --- Single App Per Stage ---
# Key:          AppWindowGroupingBehavior
# Domain:       com.apple.WindowManager
# Description:  Controls how apps are grouped in Stage Manager.
# Default:      0 (group by app)
# Options:      0 = Group by app
#               1 = Each window separate
# Set to:       0 (group windows by app)
run_defaults "com.apple.WindowManager" "AppWindowGroupingBehavior" "-int" "0"

# --- Stage Manager Strip Position ---
# Key:          StandardHideWidgets
# Domain:       com.apple.WindowManager
# Description:  Hide widget areas in Stage Manager mode.
# Default:      false
run_defaults "com.apple.WindowManager" "StandardHideWidgets" "-bool" "false"

msg_success "Stage Manager settings configured."
msg_info "Toggle Stage Manager: Control Center > Stage Manager"
