#!/usr/bin/env bash

# ==============================================================================
#
# Stage 6: Tool Installation
#
# This script handles the installation of all required command-line tools and
# applications. It ensures that the system has the necessary software to
# support the dotfiles and the user's development workflow.
#
# This script acts as an orchestrator, sourcing individual installation
# scripts from the `install/tools` directory.
#
# ==============================================================================

#
# The main logic for the tool installation stage.
#
main() {
  msg_info "Stage 6: Tool Installation"

  # --- Configuration ----------------------------------------------------------
  # @description: The directory where individual tool installation scripts are stored.
  local TOOLS_DIR="$INSTALL_DIR/tools"

  # @description: An array defining the order of tool installations.
  # @customization: Add or remove scripts from this list to control which
  #                tools are installed. The order is important, as some tools
  #                may depend on others (e.g., most tools depend on Homebrew).
  local TOOL_SCRIPTS=(
    "install-xcode-cli.sh"
    "install-homebrew.sh"
    "install-oh-my-zsh.sh"
    "install-dorothy.sh"
    "install-mac-cli.sh"
    "install-mas-cli.sh"
    "install-m-cli.sh"
    # "update-homebrew.sh" # TODO: Implement
    # "install-outset.sh" # TODO: Implement
    # "install-redis.sh" # TODO: Implement
  )

  # --- Installation Logic ---------------------------------------------------
  msg_info "Beginning tool installation process..."

  for tool_script in "${TOOL_SCRIPTS[@]}"; do
    local script_path="$TOOLS_DIR/$tool_script"
    if [ -f "$script_path" ]; then
      # shellcheck source=/dev/null
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
