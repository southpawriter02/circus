#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: iCloud
#
# This script checks if the user is logged into an iCloud account. Some dotfile
# setups rely on iCloud Drive for syncing files and settings across devices.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  msg_info "Checking for iCloud login..."

  # This check is specific to macOS.
  if [[ "$(uname)" == "Darwin" ]]; then

    # The presence of the MobileMeAccounts.plist file is a good indicator that
    # an iCloud account is configured on the system.
    if [ -f "$HOME/Library/Preferences/MobileMeAccounts.plist" ]; then
      msg_success "User is logged into iCloud."
    else
      msg_warning "User is not logged into iCloud. Some features may not work as expected."
    fi
  else
    msg_warning "Skipping iCloud check on non-macOS system."
  fi

  # This check is informational, so we always return success.
  return 0
}

#
# Execute the main function.
#
main
