#!/usr/bin/env bash

# ==============================================================================
#
# System Config: Power Management
#
# This script configures the system's power management settings using the
# `pmset` command. It is sourced by Stage 10 of the main installer.
#
# It supports Dry Run mode.
#
# ==============================================================================

# A helper function to run pmset commands or print them in dry run mode.
run_pmset() {
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: sudo pmset -a $1 $2"
  else
    # pmset requires sudo to change settings.
    sudo pmset -a "$1" "$2"
  fi
}

msg_info "Configuring power management settings..."

# ------------------------------------------------------------------------------
# Sleep and Display Settings
# ------------------------------------------------------------------------------

# Set the display to sleep after 15 minutes of inactivity.
# The `-a` flag applies the setting to all power modes (battery and charger).
# `displaysleep` is the time in minutes.
run_pmset "displaysleep" 15

# Set the computer to sleep after 30 minutes of inactivity.
# `sleep` is the time in minutes.
run_pmset "sleep" 30

# ------------------------------------------------------------------------------
# Other Power Settings
# ------------------------------------------------------------------------------

# Disable the setting that allows the power button to sleep the computer.
# This prevents accidental sleeps.
run_pmset "powerbutton" 0

# Disable wake on network access. This can save power by preventing the
# computer from waking up for minor network traffic.
run_pmset "womp" 0

# Enable auto power off, which is a form of standby mode.
run_pmset "autopoweroff" 1

# Set the delay for auto power off to 8 hours (28800 seconds).
run_pmset "autopoweroffdelay" 28800

msg_success "Power management settings applied."
