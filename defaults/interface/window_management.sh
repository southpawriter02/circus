#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Window Management
#
# DESCRIPTION:
#   Configures window behavior settings including double-click actions,
#   minimize effects, and window snap behavior.
#
# REQUIRES:
#   - macOS 10.15 (Catalina) or later
#
# REFERENCES:
#   - Apple Support: Change Dock and window behavior
#     https://support.apple.com/guide/mac-help/change-dock-preferences-mh35859/mac
#
# DOMAIN:
#   NSGlobalDomain
#   com.apple.dock
#
# NOTES:
#   - Some settings require Dock restart: killall Dock
#   - Window tiling was added in macOS Sequoia
#
# ==============================================================================

# ==============================================================================
# Window Management Architecture
# ==============================================================================

# macOS window management has evolved significantly, with major features
# added in Sequoia (macOS 15, 2024).
#
# WINDOW MANAGEMENT COMPONENTS:
#
#   COMPONENT          │ ROLE
#   ───────────────────┼──────────────────────────────────────────
#   WindowServer       │ Core window compositing (runs as root)
#   Dock               │ Minimize, app switching, Stage Manager
#   Mission Control    │ Spaces, window overview
#   Window Manager     │ Stage Manager, tiling (Sequoia+)
#
# KEYBOARD SHORTCUTS FOR WINDOWS:
#
#   SHORTCUT    │ ACTION
#   ────────────┼────────────────────────────
#   ⌘M          │ Minimize window
#   ⌘H          │ Hide application
#   ⌘⌥H         │ Hide others
#   ⌘W          │ Close window
#   ⌘Q          │ Quit application
#   ⌘`          │ Cycle windows of current app
#   ⌘Tab        │ App switcher
#   ^↓          │ App Exposé
#   ⌃⌘F         │ Toggle fullscreen
#   ^⌘← / →     │ Tile left/right (Sequoia+)
#
# WINDOW TILING (macOS Sequoia+):
#
#   macOS Sequoia introduced native window tiling:
#   
#   ┌─────────────────┬─────────────────┐
#   │                 │                 │
#   │  Left Half      │  Right Half     │   ← Drag to edge or use shortcut
#   │  (50%)          │  (50%)          │
#   │                 │                 │
#   └─────────────────┴─────────────────┘
#
#   Tiling options:
#   - Drag window to screen edge
#   - Hold window title bar, options appear
#   - Keyboard: ⌃⌘← (left half), ⌃⌘→ (right half)
#   - Window menu > Move & Resize
#
# THIRD-PARTY WINDOW MANAGERS:
#   For more powerful tiling, consider:
#   - Rectangle (free): rectangleapp.com
#   - Magnet (paid): App Store
#   - Amethyst (free, tiling WM): github.com/ianyh/Amethyst
#   - yabai (advanced): github.com/koekeishiya/yabai
#
# MINIMIZE EFFECTS COMPARISON:
#
#   EFFECT   │ SPEED    │ VISUAL
#   ─────────┼──────────┼─────────────────────
#   genie    │ Slower   │ Classic, morphs into Dock
#   scale    │ Faster   │ Simple shrink animation
#   suck     │ Fast     │ Hidden, dramatic suction effect
#
#   The "suck" effect is hidden but cool:
#   defaults write com.apple.dock mineffect -string "suck"; killall Dock
#
# Source:       https://support.apple.com/guide/mac-help/change-dock-preferences-mh35859/mac

msg_info "Configuring window management settings..."

# ==============================================================================
# Title Bar Double-Click
# ==============================================================================

# --- Double-Click Title Bar Action ---
# Key:          AppleActionOnDoubleClick
# Domain:       NSGlobalDomain
# Description:  Controls what happens when you double-click a window's title bar.
# Default:      Maximize (fills available space)
# Options:      Maximize = Fill available space
#               Minimize = Minimize to Dock
#               None = No action
# Set to:       Maximize
# UI Location:  System Settings > Desktop & Dock > Double-click window's title bar
run_defaults "NSGlobalDomain" "AppleActionOnDoubleClick" "-string" "Maximize"

# ==============================================================================
# Minimize Effect
# ==============================================================================

# --- Window Minimize Effect ---
# Key:          mineffect
# Domain:       com.apple.dock
# Description:  Animation effect when minimizing windows to the Dock.
# Default:      genie
# Options:      genie = Genie effect (default)
#               scale = Scale effect (faster)
#               suck = Suck effect (hidden option)
# Set to:       scale (faster animation)
# UI Location:  System Settings > Desktop & Dock > Minimize windows using
run_defaults "com.apple.dock" "mineffect" "-string" "scale"

# --- Minimize to Application Icon ---
# Key:          minimize-to-application
# Domain:       com.apple.dock
# Description:  Minimize windows into their application icon in the Dock
#               instead of a separate minimized window section.
# Default:      false
# Options:      true = Minimize to app icon
#               false = Minimize to Dock section
# Set to:       true (cleaner Dock)
run_defaults "com.apple.dock" "minimize-to-application" "-bool" "true"

# ==============================================================================
# Window Behavior
# ==============================================================================

# --- Close Windows When Quitting App ---
# Key:          NSQuitAlwaysKeepsWindows
# Domain:       NSGlobalDomain
# Description:  Remember open windows when quitting and restore them on launch.
# Default:      false
# Options:      true = Close and forget windows
#               false = Remember and restore windows
# Set to:       false (remember windows)
run_defaults "NSGlobalDomain" "NSQuitAlwaysKeepsWindows" "-bool" "false"

# --- Prefer Tabs When Opening Documents ---
# Key:          AppleWindowTabbingMode
# Domain:       NSGlobalDomain
# Description:  Controls when to open documents in tabs vs new windows.
# Default:      fullscreen (tabs only in fullscreen)
# Options:      always = Always open in tabs
#               fullscreen = Tabs in fullscreen only
#               manual = Never auto-tab
# Set to:       fullscreen
run_defaults "NSGlobalDomain" "AppleWindowTabbingMode" "-string" "fullscreen"

# ==============================================================================
# Window Animations
# ==============================================================================

# --- Opening Window Animation ---
# Key:          NSAutomaticWindowAnimationsEnabled
# Domain:       NSGlobalDomain
# Description:  Enable or disable window opening/closing animations.
# Default:      true
# Options:      true = Animations enabled
#               false = Instant windows
# Set to:       true (keep animations)
run_defaults "NSGlobalDomain" "NSAutomaticWindowAnimationsEnabled" "-bool" "true"

msg_success "Window management settings configured."
msg_info "Run 'killall Dock' to apply Dock-related changes."
