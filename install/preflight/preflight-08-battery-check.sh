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

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # You can adjust the minimum required battery percentage by changing the value
  # of MINIMUM_BATTERY_PERCENTAGE.
  #
  local MINIMUM_BATTERY_PERCENTAGE=20

  msg_info "Checking battery level and AC power..."

  # This check is specific to macOS and uses the `pmset` command.
  if [[ "$(uname)" == "Darwin" ]]; then

    # Get battery status from `pmset`.
    local battery_info
    battery_info=$(pmset -g batt)

    # Check if the device is on AC power.
    if echo "$battery_info" | grep -q "AC Power"; then
      msg_success "Device is connected to AC power."
      return 0
    fi

    # If not on AC power, check the battery level.
    msg_warning "Device is not connected to AC power."
    
    # Extract the battery percentage from the `pmset` output.
    local battery_percentage
    battery_percentage=$(echo "$battery_info" | grep -o "[0-9]*%" | tr -d '%')

    if [[ $battery_percentage -lt $MINIMUM_BATTERY_PERCENTAGE ]]; then
      msg_error "Battery level is below $MINIMUM_BATTERY_PERCENTAGE%. Please connect to AC power and try again."
      return 1
    else
      msg_success "Battery level is sufficient ($battery_percentage%)."
      return 0
    fi
  else
    msg_warning "Skipping battery check on non-macOS system."
    return 0
  fi
}

#
# Execute the main function.
#
main
