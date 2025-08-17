#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Mission Control & Hot Corners Configuration
#
# This script configures settings for Mission Control, Spaces, and Hot Corners.
# It is sourced by Stage 11 of the main installer. It supports Dry Run mode.
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

# ------------------------------------------------------------------------------
# Mission Control & Spaces Behavior
# ------------------------------------------------------------------------------

# --- Disable Automatic Rearranging of Spaces ---
# Description:  Prevents macOS from automatically reordering your virtual desktops (Spaces)
#               based on which one you used most recently. This is essential for users
#               who rely on a consistent spatial memory for their workspaces.
# Default:      true
# Possible:     true, false
# Set to:       false
run_defaults "com.apple.dock" "mru-spaces" "-bool" "false"


# --- Disable Dashboard ---
# Description:  The Dashboard is a legacy feature and is disabled in modern macOS.
#               This setting ensures it is formally turned off.
# Default:      false
# Possible:     true, false
# Set to:       true (to disable)
run_defaults "com.apple.dashboard" "mcx-disabled" "-bool" "true"

# ------------------------------------------------------------------------------
# Hot Corners Configuration
# ------------------------------------------------------------------------------
# Possible values for Hot Corners:
#  0: No-op (disabled)
#  2: Mission Control
#  3: Show Application Windows
#  4: Show Desktop
#  5: Start Screen Saver
#  6: Disable Screen Saver
#  7: Show Dashboard (legacy)
# 10: Put Display to Sleep
# 11: Launchpad
# 12: Notification Center

# --- Top Left Hot Corner: Start Screen Saver ---
run_defaults "com.apple.dock" "wvous-tl-corner" "-int" "5"
run_defaults "com.apple.dock" "wvous-tl-modifier" "-int" "0"

# --- Top Right Hot Corner: Show Desktop ---
run_defaults "com.apple.dock" "wvous-tr-corner" "-int" "4"
run_defaults "com.apple.dock" "wvous-tr-modifier" "-int" "0"

# --- Bottom Left Hot Corner: Mission Control ---
run_defaults "com.apple.dock" "wvous-bl-corner" "-int" "2"
run_defaults "com.apple.dock" "wvous-bl-modifier" "-int" "0"

# --- Bottom Right Hot Corner: Disabled ---
run_defaults "com.apple.dock" "wvous-br-corner" "-int" "0"
run_defaults "com.apple.dock" "wvous-br-modifier" "-int" "0"


# ------------------------------------------------------------------------------
# Apply Changes
# ------------------------------------------------------------------------------

# Changes to the Dock and Mission Control require restarting the Dock process.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would restart the Dock to apply changes."
else
  msg_info "Restarting the Dock to apply changes..."
  killall Dock
fi

msg_success "Mission Control settings applied."
