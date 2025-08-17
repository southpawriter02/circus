#!/usr/bin/env bash

# ==============================================================================
#
# Stage 4: Tool Installation
#
# This script handles the installation of all required command-line tools and
# applications. It intelligently uses the state variables set by the preflight
# checks in Stage 3 to determine which core tools need to be installed.
#
# ==============================================================================

#
# The main logic for the tool installation stage.
#
main() {
  msg_info "Stage 4: Tool Installation"

  local TOOLS_DIR="$INSTALL_DIR/tools"

  # --- Xcode Command Line Tools ---------------------------------------------
  # We only run the installer if the preflight check determined they are missing.
  if [ "$SYSTEM_HAS_XCODE_CLI" = false ]; then
    source "$TOOLS_DIR/install-xcode-cli.sh"
  else
    msg_info "Skipping Xcode Command Line Tools installation (already present)."
  fi

  # --- Homebrew & Brewfile Dependencies -------------------------------------
  # We always run the Homebrew orchestrator. It is smart enough to install
  # Homebrew if it's missing, and then use `brew bundle` to ensure all
  # dependencies from the Brewfile are installed.
  source "$TOOLS_DIR/install-homebrew.sh"

  # --- Other Tools (Pip, Gem, etc.) -----------------------------------------
  msg_info "Proceeding with installation of remaining tools..."

  local additional_tools=(
    "install-oh-my-zsh.sh"
    "install-dorothy.sh"
    "install-mac-cli.sh"
  )

  for tool_script in "${additional_tools[@]}"; do
    local script_path="$TOOLS_DIR/$tool_script"
    if [ -f "$script_path" ]; then
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
