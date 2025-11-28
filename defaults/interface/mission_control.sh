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
# Description:  Controls whether macOS automatically reorders your virtual
#               desktops (Spaces) based on which one you used most recently.
#               Disabling this preserves your spatial memory and keeps
#               workspaces in a consistent, predictable order.
# Default:      true (Spaces reorder automatically)
# Possible:     true (reorder based on usage), false (maintain manual order)
# Set to:       false (preserve consistent ordering)
# Reference:    System Preferences > Mission Control > Automatically rearrange Spaces
# Tip:          This is especially useful if you associate specific apps
#               with specific Spaces (e.g., Space 1 = Browser, Space 2 = Code)
run_defaults "com.apple.dock" "mru-spaces" "-bool" "false"

# --- Disable Dashboard ---
# Key:          mcx-disabled
# Domain:       com.apple.dashboard
# Description:  Dashboard was a feature for running widgets (weather, calculator,
#               etc.). It was deprecated and removed in macOS Catalina (10.15).
#               This setting ensures it's disabled on older systems.
# Default:      false (Dashboard enabled on older macOS)
# Possible:     true (disabled), false (enabled)
# Set to:       true (disable - it's deprecated)
# Note:         This setting has no effect on macOS Catalina and later
run_defaults "com.apple.dashboard" "mcx-disabled" "-bool" "true"

# ==============================================================================
# Hot Corners Configuration
# ==============================================================================
#
# Hot Corners allow you to trigger actions by moving the mouse cursor to
# screen corners. Each corner has two settings:
#   - wvous-XX-corner:   The action to perform (see values above)
#   - wvous-XX-modifier: Modifier key required (0 = none)
#
# Modifier values:
#   0 = No modifier required
#   131072 = Shift
#   262144 = Control
#   524288 = Option
#   1048576 = Command
#
# Corner abbreviations:
#   tl = Top Left
#   tr = Top Right
#   bl = Bottom Left
#   br = Bottom Right

# --- Top Left Hot Corner: Start Screen Saver ---
# Action:       5 (Start Screen Saver)
# Use case:     Quickly lock your Mac by triggering the screen saver
#               (when combined with password requirement on wake)
run_defaults "com.apple.dock" "wvous-tl-corner" "-int" "5"
run_defaults "com.apple.dock" "wvous-tl-modifier" "-int" "0"

# --- Top Right Hot Corner: Show Desktop ---
# Action:       4 (Desktop)
# Use case:     Quickly reveal the desktop to access files or temporarily
#               hide all windows
run_defaults "com.apple.dock" "wvous-tr-corner" "-int" "4"
run_defaults "com.apple.dock" "wvous-tr-modifier" "-int" "0"

# --- Bottom Left Hot Corner: Mission Control ---
# Action:       2 (Mission Control)
# Use case:     Get an overview of all open windows and Spaces for
#               easy navigation
run_defaults "com.apple.dock" "wvous-bl-corner" "-int" "2"
run_defaults "com.apple.dock" "wvous-bl-modifier" "-int" "0"

# --- Bottom Right Hot Corner: Disabled ---
# Action:       0 (No action)
# Rationale:    The bottom-right corner is prone to accidental activation
#               when using the mouse, so it's left disabled by default.
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
