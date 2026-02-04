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

# ==============================================================================
# Stage Manager: Visual Overview
# ==============================================================================

# Stage Manager (introduced in macOS Ventura, 2022) provides an alternative
# to traditional window management with a focus on reducing clutter.
#
# TRADITIONAL DESKTOP vs STAGE MANAGER:
#
#   Traditional Desktop:
#   ┌─────────────────────────────────────────────────────────────────┐
#   │ Menu Bar                                                       │
#   ├─────────────────────────────────────────────────────────────────┤
#   │  ┌─────┐  ┌─────┐  ┌─────┐  ┌─────┐                           │
#   │  │App 1│  │App 2│  │App 3│  │App 4│   All windows visible     │
#   │  └─────┘  └─────┘  └─────┘  └─────┘   (can overlap)           │
#   └─────────────────────────────────────────────────────────────────┘
#
#   Stage Manager:
#   ┌─────────────────────────────────────────────────────────────────┐
#   │ Menu Bar                                                       │
#   ├──────┬──────────────────────────────────────────────────────────┤
#   │ ┌──┐ │                                                         │
#   │ │A1│ │         ┌─────────────────────┐                         │
#   │ └──┘ │         │                     │                         │
#   │ ┌──┐ │         │   Active Window     │  Center stage:          │
#   │ │A2│ │         │                     │  focused work           │
#   │ └──┘ │         │                     │                         │
#   │ ┌──┐ │         └─────────────────────┘                         │
#   │ │A3│ │                                                         │
#   │ └──┘ │  Recent apps on left                                    │
#   └──────┴──────────────────────────────────────────────────────────┘
#
# HOW STAGE MANAGER WORKS:
#   1. Only the active app's windows are fully visible ("on stage")
#   2. Other recent apps appear as thumbnails on the left
#   3. Click a thumbnail to bring that app to center stage
#   4. Apps can be grouped together into "stages"
#
# ACTIVATION METHODS:
#   1. Control Center > Stage Manager toggle
#   2. System Settings > Desktop & Dock > Stage Manager
#   3. Command: defaults write com.apple.WindowManager GloballyEnabled -bool true
#   4. Keyboard: No default shortcut (assign via System Settings > Keyboard)
#
# STAGE MANAGER KEY SETTINGS:
#   GloballyEnabled        Master on/off toggle
#   AutoHide               Hide/show the recent apps strip
#   HideDesktop            Show/hide desktop icons
#   AppWindowGrouping...   Group windows by app or show each separately
#   StandardHideWidgets    Hide widgets when Stage Manager active
#
# WHEN TO USE STAGE MANAGER:
#   ✓ Focused work with few apps
#   ✓ Reducing visual clutter
#   ✓ Quick app switching via thumbnails
#   ✓ Working on smaller screens (reduces overlap)
#
# WHEN TO AVOID:
#   ✗ Multi-window workflows (comparing documents side-by-side)
#   ✗ Drag-and-drop between many apps
#   ✗ Reference-heavy work (need many windows visible)
#
# Source:       https://support.apple.com/guide/mac-help/mchl534ba392/mac

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
