#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: System Setup Configuration
#
# This script uses the `systemsetup` command to configure core system-level
# settings for security and stability.
# It requires administrative privileges.
#
# ==============================================================================

# --- Sudo Check & Re-invocation ---------------------------------------------
if [ "$EUID" -ne 0 ] && [ "$DRY_RUN_MODE" = false ]; then
  msg_info "System setup requires administrative privileges."
  sudo "$0" "$@"
  exit $?
fi

# --- Main Logic -------------------------------------------------------------

msg_info "Configuring core system settings with systemsetup..."

# A helper function to run `systemsetup` commands or print them in dry run mode.
run_systemsetup() {
  local command_args=("$@")
  local description="${command_args[0]}"

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: systemsetup ${command_args[*]}"
  else
    if systemsetup "${command_args[@]}"; then
      msg_success "System setting configured: ${description}"
    else
      msg_error "Failed to configure system setting: ${description}"
    fi
  fi
}

# --- Network Time Protocol (NTP) Settings ---
run_systemsetup "-setnetworktimeserver" "time.apple.com"
run_systemsetup "-setusingnetworktime" "on"

# --- Timezone Settings ---
# Use location services to set the timezone automatically.
run_systemsetup "-setusinglocationservices" "on"

# --- Security Settings ---
# Disable remote login (SSH) unless explicitly needed.
run_systemsetup "-setremotelogin" "off"

# --- Stability Settings ---
# Restart automatically if the computer freezes.
run_systemsetup "-setrestartfreeze" "on"

msg_success "Core system settings configuration complete."
