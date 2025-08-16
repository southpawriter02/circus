#!/usr/bin/env bash

# ==============================================================================
#
# Stage 3: Preflight System Checks
#
# This script orchestrates a comprehensive series of preflight checks to ensure
# the system is in a suitable state for the installation to proceed. It sources
# the main sanity check script, which in turn runs all individual checks.
#
# The specific checks are detailed in the `install/preflight` directory and
# cover everything from OS type and shell version to network connectivity and
# required dependencies.
#
# ==============================================================================

msg_info "Stage 3: Preflight System Checks"

# Get the directory of the main install script to locate the preflight checks.
local preflight_dir="${INSTALL_DIR}/preflight"
local sanity_check_script="${preflight_dir}/preflight-21-install-sanity-check.sh"

if [[ -f "$sanity_check_script" ]]; then
  # The pre-flight checks have their own detailed messaging, so we just source it.
  # shellcheck source=/dev/null
  source "$sanity_check_script"
else
  msg_error "Sanity check script not found at $sanity_check_script"
  msg_error "Please ensure the repository is complete."
  exit 1
fi
