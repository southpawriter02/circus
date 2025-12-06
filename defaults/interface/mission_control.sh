#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Mission Control, Spaces & Hot Corners Configuration
#
# DESCRIPTION:
#   This script configures Mission Control, virtual desktops (Spaces), and
#   Hot Corners. These features help organize windows and provide quick access
#   to common actions by moving the mouse to screen corners.
#
# REQUIRES:
#   - macOS 10.7 (Lion) or later for Spaces
#   - macOS 10.3 (Panther) or later for Hot Corners
#
# REFERENCES:
#   - Apple Support: Use Mission Control on Mac
#     https://support.apple.com/en-us/102556
#   - Apple Support: Use Hot Corners on your Mac
#     https://support.apple.com/guide/mac-help/use-hot-corners-mchlp3000/mac
#   - Apple Support: Work in multiple spaces on Mac
#     https://support.apple.com/guide/mac-help/work-in-multiple-spaces-mh14112/mac
#
# DOMAINS:
#   com.apple.dock       - Dock, Mission Control, and Hot Corners
#   com.apple.dashboard  - Dashboard settings (legacy, deprecated)
#
# HOT CORNER VALUES:
#    0 = No action (disabled)
#    2 = Mission Control
#    3 = Application Windows (show all windows for current app)
#    4 = Desktop (reveal)
#    5 = Start Screen Saver
#    6 = Disable Screen Saver
#    7 = Dashboard (legacy, deprecated)
#   10 = Put Display to Sleep
#   11 = Launchpad
#   12 = Notification Center
#   13 = Lock Screen (macOS 10.13+)
#   14 = Quick Note (macOS 12+)
#
# NOTES:
#   - Hot Corners require the Dock to be restarted to take effect
#   - Modifier keys can be required with Hot Corners for accidental activation prevention
#   - Spaces order can be preserved with the mru-spaces setting
#
# ==============================================================================

# A helper function to run `defaults write` commands or print them in dry run mode.
run_defaults() {
  local domain="$1"
  local key="$2"
  local type="$3"
  local value="$4"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would set Mission Control preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Mission Control, Spaces, and Hot Corners settings..."

# ==============================================================================
# Mission Control & Spaces Behavior
# ==============================================================================

# --- Disable Automatic Rearranging of Spaces ---
# Key:          mru-spaces
# Domain:       com.apple.dock
# Description:  Controls whether macOS automatically reorders your virtual
#               desktops (Spaces) based on which one you used most recently.
#               When enabled, Spaces shift positions based on usage patterns.
#               Disabling this preserves your spatial memory and keeps
#               workspaces in a consistent, predictable order.
# Default:      true (Spaces reorder automatically based on recent use)
# Options:      true  = Reorder Spaces based on most recent use
#               false = Maintain manual/fixed Space ordering
# Set to:       false (preserve consistent ordering for muscle memory)
# UI Location:  System Settings > Desktop & Dock > Mission Control >
#               Automatically rearrange Spaces based on most recent use
# Source:       https://support.apple.com/guide/mac-help/work-in-multiple-spaces-mh14112/mac
# Note:         Disabling this is especially useful if you associate specific
#               apps with specific Spaces (e.g., Space 1 = Browser, Space 2 = Code).
#               Use Control+Number to jump directly to a Space.
run_defaults "com.apple.dock" "mru-spaces" "-bool" "false"

# --- Disable Dashboard ---
# Key:          mcx-disabled
# Domain:       com.apple.dashboard
# Description:  Dashboard was a feature for running widgets (weather, calculator,
#               etc.). It was deprecated in macOS Catalina (10.15) and replaced
#               by Notification Center widgets. This setting ensures it's
#               disabled on older systems where it still exists.
# Default:      false (Dashboard enabled on older macOS versions)
# Options:      true  = Disable Dashboard entirely
#               false = Enable Dashboard
# Set to:       true (disable deprecated feature)
# UI Location:  System Preferences > Mission Control > Dashboard (pre-Catalina)
# Source:       https://support.apple.com/en-us/102556
# Note:         This setting has no effect on macOS Catalina (10.15) and later,
#               as Dashboard was completely removed from the system.
run_defaults "com.apple.dashboard" "mcx-disabled" "-bool" "true"

# ==============================================================================
# Hot Corners Configuration
# ==============================================================================
#
# Hot Corners allow you to trigger actions by moving the mouse cursor to
# screen corners. Each corner has two settings:
#   - wvous-XX-corner:   The action to perform (see HOT CORNER VALUES above)
#   - wvous-XX-modifier: Modifier key required (0 = none)
#
# UI Location:  System Settings > Desktop & Dock > Hot Corners... (button)
# Source:       https://support.apple.com/guide/mac-help/use-hot-corners-mchlp3000/mac
#
# Modifier values (bitmask):
#   0       = No modifier required
#   131072  = Shift (⇧)
#   262144  = Control (⌃)
#   524288  = Option (⌥)
#   1048576 = Command (⌘)
#
# Corner abbreviations:
#   tl = Top Left
#   tr = Top Right
#   bl = Bottom Left
#   br = Bottom Right

# --- Top Left Hot Corner: Start Screen Saver ---
# Key:          wvous-tl-corner
# Domain:       com.apple.dock
# Description:  Configures the action triggered when the mouse cursor
#               moves to the top-left corner of the screen.
# Default:      0 (no action)
# Options:      See HOT CORNER VALUES in header (0-14)
# Set to:       5 (Start Screen Saver)
# UI Location:  System Settings > Desktop & Dock > Hot Corners... > Top Left
# Source:       https://support.apple.com/guide/mac-help/use-hot-corners-mchlp3000/mac
# Note:         Combined with password-on-wake, this provides a quick way
#               to lock your Mac. Just flick the cursor to the corner.
run_defaults "com.apple.dock" "wvous-tl-corner" "-int" "5"
run_defaults "com.apple.dock" "wvous-tl-modifier" "-int" "0"

# --- Top Right Hot Corner: Show Desktop ---
# Key:          wvous-tr-corner
# Domain:       com.apple.dock
# Description:  Configures the action triggered when the mouse cursor
#               moves to the top-right corner of the screen.
# Default:      0 (no action)
# Options:      See HOT CORNER VALUES in header (0-14)
# Set to:       4 (Show Desktop - reveal desktop by moving windows aside)
# UI Location:  System Settings > Desktop & Dock > Hot Corners... > Top Right
# Source:       https://support.apple.com/guide/mac-help/use-hot-corners-mchlp3000/mac
# Note:         Useful for quickly accessing files on the desktop or
#               temporarily hiding all windows. Move cursor away to restore.
run_defaults "com.apple.dock" "wvous-tr-corner" "-int" "4"
run_defaults "com.apple.dock" "wvous-tr-modifier" "-int" "0"

# --- Bottom Left Hot Corner: Mission Control ---
# Key:          wvous-bl-corner
# Domain:       com.apple.dock
# Description:  Configures the action triggered when the mouse cursor
#               moves to the bottom-left corner of the screen.
# Default:      0 (no action)
# Options:      See HOT CORNER VALUES in header (0-14)
# Set to:       2 (Mission Control - overview of all windows and Spaces)
# UI Location:  System Settings > Desktop & Dock > Hot Corners... > Bottom Left
# Source:       https://support.apple.com/guide/mac-help/use-hot-corners-mchlp3000/mac
# Note:         Provides quick access to window management and Space switching
#               without keyboard shortcuts.
run_defaults "com.apple.dock" "wvous-bl-corner" "-int" "2"
run_defaults "com.apple.dock" "wvous-bl-modifier" "-int" "0"

# --- Bottom Right Hot Corner: Disabled ---
# Key:          wvous-br-corner
# Domain:       com.apple.dock
# Description:  Configures the action triggered when the mouse cursor
#               moves to the bottom-right corner of the screen.
# Default:      0 (no action)
# Options:      See HOT CORNER VALUES in header (0-14)
# Set to:       0 (No action - disabled)
# UI Location:  System Settings > Desktop & Dock > Hot Corners... > Bottom Right
# Source:       https://support.apple.com/guide/mac-help/use-hot-corners-mchlp3000/mac
# Note:         The bottom-right corner is prone to accidental activation
#               when using the scroll bar or window resize handles. Leaving
#               it disabled prevents unwanted triggering.
run_defaults "com.apple.dock" "wvous-br-corner" "-int" "0"
run_defaults "com.apple.dock" "wvous-br-modifier" "-int" "0"


# ==============================================================================
# Apply Changes
# ==============================================================================

# Changes to the Dock and Mission Control require restarting the Dock process.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would restart the Dock to apply changes."
else
  msg_info "Restarting the Dock to apply changes..."
  killall Dock
fi

msg_success "Mission Control settings applied."
