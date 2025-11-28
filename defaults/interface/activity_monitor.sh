#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Activity Monitor Configuration
#
# DESCRIPTION:
#   This script configures Activity Monitor, macOS's built-in process and
#   resource monitoring utility. These settings optimize it for power users
#   and developers who need detailed system information.
#
# REQUIRES:
#   - macOS 10.3 (Panther) or later
#
# REFERENCES:
#   - Apple Support: Use Activity Monitor on your Mac
#     https://support.apple.com/guide/activity-monitor/welcome/mac
#   - Apple Support: View system information using Activity Monitor
#     https://support.apple.com/en-us/102516
#
# DOMAIN:
#   com.apple.ActivityMonitor
#
# VIEW CATEGORIES:
#   100 = My Processes (processes owned by current user)
#   101 = My Processes, Hierarchically (tree view)
#   102 = All Processes (all running processes)
#   103 = All Processes, Hierarchically (all as tree view)
#   104 = Selected Processes (custom selection)
#   105 = System Processes
#   106 = Other User Processes
#   107 = Active Processes (non-idle)
#   108 = Inactive Processes (idle)
#   109 = GPU Processes (using GPU)
#   110 = Windowed Processes (with windows)
#
# TABS:
#   0 = CPU
#   1 = Memory
#   2 = Energy
#   3 = Disk
#   4 = Network
#
# NOTES:
#   - Activity Monitor is useful for diagnosing performance issues
#   - The Dock icon can show CPU/memory/network/disk activity
#   - Changes take effect after quitting and reopening Activity Monitor
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

# ==============================================================================
# Main Window & View Settings
# ==============================================================================

# --- Show All Processes ---
# Key:          ShowCategory
# Description:  Controls which processes are displayed in the main window.
#               "All Processes" shows every running process, including
#               system daemons and other users' processes (if permitted).
# Default:      100 (My Processes - only current user's processes)
# Possible:     See VIEW CATEGORIES above
# Set to:       102 (All Processes - complete system visibility)
# Reference:    View > All Processes (⌘1 through ⌘5)
run_defaults "com.apple.ActivityMonitor" "ShowCategory" "-int" "102"

# --- Sort by CPU Usage ---
# Key:          SortColumn, SortDirection
# Description:  Sets the default column to sort by and the sort direction.
#               Sorting by CPU usage shows which processes are using the
#               most processing power.
# Default:      'CPUUsage' descending
# Possible:     Column names: CPUUsage, ProcessName, PID, User, Memory, etc.
#               Direction: 0 = descending, 1 = ascending
# Set to:       CPUUsage, descending (highest CPU at top)
# Tip:          Click column headers to change sorting in the app
run_defaults "com.apple.ActivityMonitor" "SortColumn" "-string" "CPUUsage"
run_defaults "com.apple.ActivityMonitor" "SortDirection" "-int" "0"

# --- Set Default Tab ---
# Key:          SelectedTab, OpenMainWindow
# Description:  Controls which tab is active when Activity Monitor launches
#               and whether the main window opens automatically.
# Default:      0 (CPU tab), true (window opens)
# Possible:     See TABS above
# Set to:       0 (CPU - most commonly used view)
# Reference:    Tabs at the top of the Activity Monitor window
run_defaults "com.apple.ActivityMonitor" "OpenMainWindow" "-bool" "true"
run_defaults "com.apple.ActivityMonitor" "SelectedTab" "-int" "0"

# ==============================================================================
# Apply Changes
# ==============================================================================

# Changes to Activity Monitor require restarting the app to take effect.
# Note: Only quit Activity Monitor if it's running; don't launch it otherwise.
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[Dry Run] Would quit Activity Monitor to apply changes."
else
  # We use `pkill` which is more robust than `killall` if the app
  # has spaces in its name. The `-f` flag matches against the full
  # process name. The `|| true` prevents the script from failing
  # if Activity Monitor isn't running.
  pkill -f "Activity Monitor" &> /dev/null || true
fi

msg_success "Activity Monitor settings applied."
