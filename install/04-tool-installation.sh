#!/usr/bin/env bash

# ==============================================================================
#
# Stage 4: Tool Installation
#
# This script handles the installation of all required command-line tools and
# applications. It intelligently uses the state variables set by the preflight
# checks in Stage 3 to determine which tools need to be installed.
#
# ==============================================================================

#
# The main logic for the tool installation stage.
#
main() {
  msg_info "Stage 4: Tool Installation"

  # --- Configuration ----------------------------------------------------------
  local TOOLS_DIR="$INSTALL_DIR/tools"

  # --- Xcode Command Line Tools ---------------------------------------------
  # The preflight check in Stage 3 determined if the tools were installed.
  # We only run the installer if they are missing.
  if [ "$SYSTEM_HAS_XCODE_CLI" = false ]; then
    source "$TOOLS_DIR/install-xcode-cli.sh"
  else
    msg_info "Skipping Xcode Command Line Tools installation (already present)."
  fi

  # --- Homebrew ---------------------------------------------------------------
  # We only run the Homebrew installer if it was not found in Stage 3.
  if [ "$SYSTEM_HAS_HOMEBREW" = false ]; then
    source "$TOOLS_DIR/install-homebrew.sh"
  else
    msg_info "Skipping Homebrew installation (already present)."
  fi

  # --- Other Tools (Dependent on Homebrew, Pip, etc.) -----------------------
  # Now that we have attempted to install the core dependencies, we can
  # proceed with the other tools. Their individual scripts contain their own
  # idempotency checks.
  msg_info "Proceeding with installation of additional tools..."

  local additional_tools=(
    "install-oh-my-zsh.sh"
    "install-dorothy.sh"
    "install-mac-cli.sh"
    "install-mas-cli.sh"
    "install-m-cli.sh"
    "install-outset.sh"
    "install-redis.sh"
    "install-bats-core.sh"
  )

  for tool_script in "${additional_tools[@]}"; do
    local script_path="$TOOLS_DIR/$tool_script"
    if [ -f "$script_path" ]; then
      # The individual scripts will print their own status messages.
      source "$script_path"
    else
      msg_warning "Tool installation script not found: $script_path. Skipping."
    fi
  done

  msg_success "Tool installation stage complete."
}

#
# Execute the main function.
#
main
