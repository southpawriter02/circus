#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Battery and AC Power
#
# This script checks the device's battery level and whether it is connected to
# AC power. A low battery level or lack of AC power could cause the
# installation to fail if the device shuts down unexpectedly.
#
# This check is particularly important for long-running installation processes.
#
# ==============================================================================


# ------------------------------------------------------------------------------
# Functions
# ------------------------------------------------------------------------------

#
# Echo a formatted message to the console.
#
# @param string $1 The message to echo.
#
function e_msg() {
  printf " [37;1m%s[0m\n" "$1"
}

#
# Echo a success message to the console.
#
# @param string $1 The message to echo.
#
function e_success() {
  printf " [32;1m✔[0m %s\n" "$1"
}

#
# Echo an error message to the console and exit.
#
# @param string $1 The message to echo.
#
function e_error() {
  printf " [31;1m✖[0m %s\n" "$1"
}

#
# Echo a warning message to the console.
#
# @param string $1 The message to echo.
#
function e_warning() {
  printf " [33;1mWarning[0m: %s\n" "$1"
}


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

#
# CUSTOMIZATION:
# You can adjust the minimum required battery percentage by changing the value
# of MINIMUM_BATTERY_PERCENTAGE.
#
MINIMUM_BATTERY_PERCENTAGE=20

e_msg "Checking battery level and AC power..."

#
# This check is specific to macOS and uses the `pmset` command.
#
if [[ "$(uname)" == "Darwin" ]]; then

  # Get battery status from `pmset`.
  battery_info=$(pmset -g batt)

  # Check if the device is on AC power.
  if echo "$battery_info" | grep -q "AC Power"; then
    e_success "Device is connected to AC power."
    exit 0
  fi

  # If not on AC power, check the battery level.
  e_warning "Device is not connected to AC power."
  
  # Extract the battery percentage from the `pmset` output.
  battery_percentage=$(echo "$battery_info" | grep -o "[0-9]*%" | tr -d '%')

  if [[ $battery_percentage -lt $MINIMUM_BATTERY_PERCENTAGE ]]; then
    e_error "Battery level is below $MINIMUM_BATTERY_PERCENTAGE%. Please connect to AC power and try again."
    exit 1
  else
    e_success "Battery level is sufficient ($battery_percentage%)."
    exit 0
  fi
else
  e_warning "Skipping battery check on non-macOS system."
  exit 0
fi
