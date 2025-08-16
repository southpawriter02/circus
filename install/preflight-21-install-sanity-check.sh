#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Install Sanity Check
#
# This script serves as a final sanity check to ensure that all the previous
# preflight checks have passed and that the system is in a good state for the
# installation to begin.
#
# It does this by sourcing and running all the other preflight check scripts
# in the correct order.
#
# ==============================================================================


# ------------------------------------------------------------------------------
# Main Script
# ------------------------------------------------------------------------------

#
# Get the directory of the current script.
#
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

#
# An array of all the preflight check scripts in the correct order.
#
PREFLIGHT_CHECKS=(
  "preflight-01-macos-check.sh"
  "preflight-02-root-check.sh"
  "preflight-03-admin-rights-check.sh"
  "preflight-04-file-permissions-check.sh"
  "preflight-05-unset-vars-check.sh"
  "preflight-06-shell-type-version-check.sh"
  "preflight-07-locale-encoding-check.sh"
  "preflight-08-battery-check.sh"
  "preflight-09-wifi-check.sh"
  "preflight-10-xcode-cli-check.sh"
  "preflight-11-homebrew-check.sh"
  "preflight-12-dependency-check.sh"
  "preflight-13-install-integrity-check.sh"
  "preflight-14-update-check.sh"
  "preflight-15-existing-install-check.sh"
  "preflight-16-backed-up-dotfiles-check.sh"
  "preflight-17-existing-dotfiles-check.sh"
  "preflight-18-icloud-check.sh"
  "preflight-19-terminal-type-check.sh"
  "preflight-20-conflicting-processes-check.sh"
)

#
# Iterate through the preflight checks and execute them.
#
for check in "${PREFLIGHT_CHECKS[@]}"; do
  #
  # Source the preflight check script.
  #
  # The `source` command executes the script in the current shell, so that
  # any changes to the environment (e.g., exiting) will affect the main
  # script.
  #
  source "$script_dir/$check"

  #
  # Check the exit code of the preflight check.
  #
  if [ $? -ne 0 ]; then
    #
    # If the exit code is not 0, it means the check failed. In this case,
    # we exit the sanity check with an error.
    #
    exit 1
  fi
done

#
# If all the preflight checks passed, exit with a success status.
#
echo "All preflight checks passed!"
exit 0
