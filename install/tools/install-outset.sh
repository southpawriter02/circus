#!/usr/bin/env bash

# ==============================================================================
#
# Tool: Outset
#
# This script checks for the presence of Outset and installs it if it is
# missing. Outset is a script that runs at boot, login, and on-demand.
#
# ==============================================================================

#
# The main logic for installing Outset.
#
main() {
  msg_info "Checking for Outset..."

  # Check if the Outset executable already exists.
  if [ -x "/usr/local/outset/outset" ]; then
    msg_success "Outset is already installed."
    return 0
  fi

  msg_warning "Outset is not installed."
  msg_info "The installer will now download and install the latest version of Outset."

  # --- Configuration ----------------------------------------------------------
  # @description: The URL for the latest Outset package.
  # @customization: You can update this URL to a specific version if needed.
  local outset_url="https://github.com/chilcote/outset/releases/download/v3.0.1/outset-3.0.1.pkg"
  local temp_pkg="/tmp/outset.pkg"

  # --- Download and Install ---------------------------------------------------
  msg_info "Downloading Outset from $outset_url..."
  if ! curl -sL "$outset_url" -o "$temp_pkg"; then
    msg_error "Failed to download the Outset package."
    return 1
  fi

  msg_info "Installing Outset package..."
  # The `installer` command requires sudo privileges.
  if sudo installer -pkg "$temp_pkg" -target /; then
    msg_success "Outset installed successfully."
  else
    msg_error "Outset installation failed."
    msg_error "Please check the installer output above for details."
    # Clean up the downloaded package file.
    rm "$temp_pkg"
    return 1
  fi

  # --- Cleanup ----------------------------------------------------------------
  msg_info "Cleaning up temporary files..."
  rm "$temp_pkg"
}

#
# Execute the main function.
#
main
