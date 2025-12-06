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
#               "All Processes" shows every running process on the system,
#               including system daemons, kernel tasks, and processes owned
#               by other users (where permissions allow).
# Default:      100 (My Processes - only processes owned by current user)
# Options:      100 = My Processes (current user only)
#               101 = My Processes, Hierarchically (tree view of user processes)
#               102 = All Processes (every process on the system)
#               103 = All Processes, Hierarchically (tree view of all)
#               104 = Selected Processes (custom selection)
#               105 = System Processes (macOS system processes only)
#               106 = Other User Processes (processes not owned by you or root)
#               107 = Active Processes (currently using CPU)
#               108 = Inactive Processes (sleeping/idle)
#               109 = GPU Processes (using graphics hardware)
#               110 = Windowed Processes (apps with visible windows)
# Set to:       102 (All Processes - complete system visibility for debugging)
# UI Location:  View menu > All Processes (or ⌃⌘1 through ⌃⌘0)
# Source:       https://support.apple.com/guide/activity-monitor/view-information-about-processes-actmntr1001/mac
run_defaults "com.apple.ActivityMonitor" "ShowCategory" "-int" "102"

# --- Sort by CPU Usage ---
# Key:          SortColumn
# Description:  Sets the default column to sort by when Activity Monitor opens.
#               Sorting by CPU usage immediately highlights processes consuming
#               the most processing power, useful for identifying runaway apps.
# Default:      "CPUUsage" (sorted by CPU percentage)
# Options:      Common column identifiers:
#               "CPUUsage"    = CPU percentage (most common for troubleshooting)
#               "CPUTime"     = Total CPU time consumed
#               "ProcessName" = Alphabetical by process name
#               "PID"         = Process ID (numeric order)
#               "User"        = Owner username
#               "%Mem"        = Memory percentage
#               "Threads"     = Number of threads
#               "Ports"       = Open ports
# Set to:       "CPUUsage" (quickly identify CPU-hungry processes)
# UI Location:  Click any column header in Activity Monitor to sort
# Source:       https://support.apple.com/guide/activity-monitor/view-cpu-activity-actmntr43452/mac
run_defaults "com.apple.ActivityMonitor" "SortColumn" "-string" "CPUUsage"

# Key:          SortDirection
# Description:  Controls the sort order (ascending or descending) for the
#               selected sort column. Descending puts highest values at top.
# Default:      0 (descending - highest values first)
# Options:      0 = Descending (highest to lowest, Z to A)
#               1 = Ascending (lowest to highest, A to Z)
# Set to:       0 (descending - shows highest CPU usage at top)
# UI Location:  Click column header to toggle, or click sort indicator arrow
# Source:       https://support.apple.com/guide/activity-monitor/view-cpu-activity-actmntr43452/mac
run_defaults "com.apple.ActivityMonitor" "SortDirection" "-int" "0"

# --- Open Main Window on Launch ---
# Key:          OpenMainWindow
# Description:  Controls whether the main Activity Monitor window opens
#               automatically when the app launches. When disabled, only
#               the Dock icon or menu bar displays are shown.
# Default:      true (main window opens on launch)
# Options:      true  = Open main window automatically
#               false = Start minimized (Dock/menu bar only)
# Set to:       true (always show the main window)
# UI Location:  Window > Activity Monitor (if closed)
# Source:       https://support.apple.com/guide/activity-monitor/welcome/mac
run_defaults "com.apple.ActivityMonitor" "OpenMainWindow" "-bool" "true"

# --- Default Tab Selection ---
# Key:          SelectedTab
# Description:  Controls which tab is active when Activity Monitor launches.
#               Each tab shows different system resource information with
#               specialized columns and graphs.
# Default:      0 (CPU tab)
# Options:      0 = CPU (processor usage, processes, threads)
#               1 = Memory (RAM usage, memory pressure, swap)
#               2 = Energy (power consumption, battery impact)
#               3 = Disk (read/write activity, I/O operations)
#               4 = Network (data sent/received, packets, connections)
# Set to:       0 (CPU tab - most commonly used for troubleshooting)
# UI Location:  Tab bar at the top of the Activity Monitor window
# Source:       https://support.apple.com/guide/activity-monitor/view-cpu-activity-actmntr43452/mac
# See also:     https://support.apple.com/guide/activity-monitor/welcome/mac
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
