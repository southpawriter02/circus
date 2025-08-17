#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Activity Monitor Configuration
#
# This script configures settings for the Activity Monitor application.
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
    msg_info "[Dry Run] Would set Activity Monitor preference: '$key' to '$value'"
  else
    defaults write "$domain" "$key" "$type" "$value"
  fi
}

msg_info "Configuring Activity Monitor settings..."

# ------------------------------------------------------------------------------
# Main Window & View Settings
# ------------------------------------------------------------------------------

# --- Show All Processes ---
# Description:  Changes the default view to show all processes, not just user-owned ones.
# Default:      100 (My Processes)
# Possible:     100 (My Processes), 101 (My Processes, Hierarchically),
#               102 (All Processes), 103 (All Processes, Hierarchically)
# Set to:       102 (All Processes)
run_defaults "com.apple.ActivityMonitor" "ShowCategory" "-int" "102"

# --- Sort by CPU Usage ---
# Description:  Sets the default sort column to CPU usage.
# Default:      '%CPU'
# Possible:     A string representing the column name (e.g., 'ProcessName', '%CPU').
# Set to:       '%CPU' (no change from default, but explicit is good)
run_defaults "com.apple.ActivityMonitor" "SortColumn" "-string" "CPUUsage"
run_defaults "com.apple.ActivityMonitor" "SortDirection" "-int" "0" # 0 for descending

# --- Set Default Tab ---
# Description:  Sets the active tab when Activity Monitor is launched.
# Default:      0 (CPU)
# Possible:     0 (CPU), 1 (Memory), 2 (Energy), 3 (Disk), 4 (Network)
# Set to:       0 (CPU)
run_defaults "com.apple.ActivityMonitor" "OpenMainWindow" "-bool" "true"
run_defaults "com.apple.ActivityMonitor" "SelectedTab" "-int" "0"

# ------------------------------------------------------------------------------
# Apply Changes
# ------------------------------------------------------------------------------

# Changes to Activity Monitor require restarting the app to take effect.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would quit Activity Monitor to apply changes."
else
  # We use `pkill` which is more robust than `killall` if the app has spaces in its name.
  # The `-f` flag matches against the full process name.
  pkill -f "Activity Monitor" &> /dev/null || true
fi

msg_success "Activity Monitor settings applied."
