#!/usr/bin/env bash

# ==============================================================================
#
# macOS Defaults: Visual Studio Code Configuration
#
# DESCRIPTION:
#   This script automates the setup of Visual Studio Code by installing a
#   curated list of extensions and symlinking a settings file from this
#   dotfiles repository. This ensures consistent VS Code configuration
#   across multiple machines.
#
# REQUIRES:
#   - Visual Studio Code installed (brew install --cask visual-studio-code)
#   - VS Code 'code' command in PATH
#     Run: Shell Command: Install 'code' command in PATH (from Command Palette)
#
# REFERENCES:
#   - VS Code Documentation
#     https://code.visualstudio.com/docs
#   - VS Code Extensions Marketplace
#     https://marketplace.visualstudio.com/vscode
#   - VS Code Settings Sync (built-in)
#     https://code.visualstudio.com/docs/editor/settings-sync
#   - VS Code Command Line Interface
#     https://code.visualstudio.com/docs/editor/command-line
#
# FILES:
#   $DOTFILES_DIR/etc/vscode/extensions.txt - List of extensions to install
#   $DOTFILES_DIR/etc/vscode/settings.json  - User settings to symlink
#
# PATHS:
#   Settings target: ~/Library/Application Support/Code/User/settings.json
#   Extensions:      ~/.vscode/extensions/
#
# NOTES:
#   - The built-in Settings Sync feature is an alternative to this approach
#   - Extensions are installed with --force to ensure latest versions
#   - Existing settings.json is backed up before symlinking
#   - The 'code' command must be installed via VS Code Command Palette
#
# ==============================================================================

main() {
  msg_info "Configuring Visual Studio Code..."

  # --- Prerequisite Check ---
  # The 'code' CLI tool must be installed for extension management.
  # Install via Command Palette: "Shell Command: Install 'code' command in PATH"
  if ! command -v code >/dev/null 2>&1; then
    msg_warning "Visual Studio Code command-line tool 'code' not found. Skipping."
    msg_info "Please ensure VS Code is installed and the 'Shell Command: Install 'code' command in PATH' has been run."
    return 1
  fi

  # --- Configuration ---
  local extensions_file="$DOTFILES_DIR/etc/vscode/extensions.txt"
  local settings_source="$DOTFILES_DIR/etc/vscode/settings.json"
  local settings_target_dir="$HOME/Library/Application Support/Code/User"
  local settings_target_file="$settings_target_dir/settings.json"

  # ==============================================================================
  # Extension Installation
  # ==============================================================================
  #
  # Extensions are read from a text file with one extension ID per line.
  # Lines starting with # are treated as comments.
  # Extension IDs can be found in the VS Code Marketplace URL or in the
  # extension's detail page.
  #
  # Example extensions.txt content:
  #   # Editor enhancements
  #   esbenp.prettier-vscode
  #   dbaeumer.vscode-eslint
  #   # Theme
  #   dracula-theme.theme-dracula

  if [ -f "$extensions_file" ]; then
    msg_info "Installing VS Code extensions from $extensions_file..."
    # Read the file line by line, ignoring comments and empty lines.
    grep -v '^\s*#' "$extensions_file" | grep -v '^\s*$' | while read -r extension; do
      if [ "$DRY_RUN_MODE" = true ]; then
        msg_info "[Dry Run] Would install extension: $extension"
      else
        # The --force flag updates extensions to their latest versions
        if code --install-extension "$extension" --force; then
          msg_success "Installed extension: $extension"
        else
          msg_error "Failed to install extension: $extension"
        fi
      fi
    done
  else
    msg_warning "VS Code extensions file not found at $extensions_file. Skipping installation."
  fi

  # ==============================================================================
  # Settings Symlinking
  # ==============================================================================
  #
  # Symlinking the settings file allows for version control of VS Code
  # settings. Changes made in VS Code are automatically saved to the
  # repository.
  #
  # Note: This is an alternative to VS Code's built-in Settings Sync feature.
  # Settings Sync uses a Microsoft account, while this approach uses git.

  msg_info "Symlinking VS Code settings..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would ensure directory exists: $settings_target_dir"
    msg_info "[Dry Run] Would back up existing settings at $settings_target_file"
    msg_info "[Dry Run] Would symlink '$settings_source' to '$settings_target_file'"
  else
    # Ensure the target directory exists (may not exist on fresh install)
    mkdir -p "$settings_target_dir"

    # Back up existing settings file if it's a regular file (not a symlink)
    # This preserves any existing settings the user may have customized
    if [ -f "$settings_target_file" ] && [ ! -L "$settings_target_file" ]; then
      mv "$settings_target_file" "${settings_target_file}.bak"
      msg_info "Backed up existing settings to ${settings_target_file}.bak"
    fi

    # Create the symlink
    # -s: Create a symbolic link
    # -f: Force (remove existing destination)
    if ln -sf "$settings_source" "$settings_target_file"; then
      msg_success "Symlinked VS Code settings file."
    else
      msg_error "Failed to symlink VS Code settings file."
    fi
  fi

  msg_success "Visual Studio Code configuration complete."
}

main
