#!/usr/bin/env bash

# ==============================================================================
#
# Stage 3: Preflight System Checks
#
# This script performs a series of checks to ensure the system is in a suitable
# state for installation. It sets a series of global state variables that can
# be used by subsequent stages to alter their behavior.
#
# ==============================================================================

#
# The main logic for the preflight system checks stage.
#
main() {
  msg_info "Stage 3: Preflight System Checks"

  # --- State Variable Initialization ------------------------------------------
  # Initialize global state variables. These will be updated by the checks below.
  export SYSTEM_HAS_INTERNET=false
  export SYSTEM_HAS_XCODE_CLI=false
  export SYSTEM_HAS_HOMEBREW=false
  export SYSTEM_HAS_GIT=false

  # --- Check 1: macOS Operating System (Hard Fail) --------------------------
  msg_info "Checking operating system..."
  if [[ "$(uname)" == "Darwin" ]]; then
    msg_success "Operating system is macOS. Check passed."
  else
    msg_error "This installer is designed for macOS only."
    msg_error "Installation cannot proceed. Aborting."
    exit 1
  fi

  # --- Check 2: Internet Connectivity (Soft Fail) ---------------------------
  msg_info "Checking internet connectivity..."
  # We ping a reliable, fast-to-resolve DNS server.
  # -c 1: Send only one packet.
  # -t 2: Wait a maximum of 2 seconds for a reply.
  if ping -c 1 -t 2 "8.8.8.8" > /dev/null 2>&1; then
    msg_success "Internet connection found."
    SYSTEM_HAS_INTERNET=true
  else
    msg_warning "No internet connection found."
    msg_warning "The installer will attempt to continue, but may fail."
  fi

  # --- Check 3: Xcode Command Line Tools ------------------------------------
  msg_info "Checking for Xcode Command Line Tools..."
  # The `xcode-select -p` command returns the active developer directory.
  # If it fails, the tools are not installed.
  if xcode-select -p > /dev/null 2>&1; then
    msg_success "Xcode Command Line Tools are installed."
    SYSTEM_HAS_XCODE_CLI=true
  else
    msg_warning "Xcode Command Line Tools are not installed."
  fi

  # --- Check 4: Homebrew ----------------------------------------------------
  msg_info "Checking for Homebrew..."
  if command -v "brew" > /dev/null 2>&1; then
    msg_success "Homebrew is installed."
    SYSTEM_HAS_HOMEBREW=true
  else
    msg_warning "Homebrew is not installed."
  fi

  # --- Check 5: Git ---------------------------------------------------------
  msg_info "Checking for Git..."
  if command -v "git" > /dev/null 2>&1; then
    msg_success "Git is installed."
    SYSTEM_HAS_GIT=true
  else
    msg_warning "Git is not installed."
  fi

  msg_success "Preflight checks complete."
}

#
# Execute the main function.
#
main
