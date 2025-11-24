#!/usr/bin/env bash

# ==============================================================================
#
# Stage 3: Homebrew Installation & Bundle
#
# This script installs Homebrew and then uses Brewfiles to install packages.
# It supports a base Brewfile and a role-specific Brewfile for layered
# application management.
#
# ==============================================================================

#
# Helper function to run `brew bundle install` for a given Brewfile.
#
run_brew_bundle() {
  local brewfile_path=\"$1\"
  local brewfile_type=\"$2\"

  if [ -f \"$brewfile_path\" ]; then
    msg_info \"Installing packages from $brewfile_type Brewfile at $brewfile_path...\"
    if [ \"$DRY_RUN_MODE\" = true ]; then
      msg_info \"[Dry Run] Would run: brew bundle install --file=$brewfile_path\"
    else
      if brew bundle install --file=\"$brewfile_path\"; then
        msg_success \"All packages from $brewfile_type Brewfile installed successfully.\"
      else
        msg_error \"An error occurred during \`brew bundle install\` for the $brewfile_type Brewfile.\"
      fi
    fi
  else
    msg_warning \"$brewfile_type Brewfile not found at $brewfile_path. Skipping.\"
  fi
}

main() {
  msg_info \"Stage 3: Homebrew Installation & Bundle\"

  # --- Homebrew Installation Check ---
  if command -v brew >/dev/null 2>&1; then
    msg_info \"Homebrew is already installed. Updating...\"
    if [ \"$DRY_RUN_MODE\" = true ]; then
      msg_info \"[Dry Run] Would run: brew update\"
    else
      brew update
    fi
  else
    msg_info \"Homebrew not found. Installing...\"
    if [ \"$DRY_RUN_MODE\" = true ]; then
      msg_info \"[Dry Run] Would run the official Homebrew installation script.\"
    else
      /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"
      # Detect the Homebrew installation path based on the OS and architecture
      if [ -x \"/opt/homebrew/bin/brew\" ]; then
        # macOS Apple Silicon
        eval \"$(/opt/homebrew/bin/brew shellenv)\"
      elif [ -x \"/usr/local/bin/brew\" ]; then
        # macOS Intel
        eval \"$(/usr/local/bin/brew shellenv)\"
      elif [ -x \"/home/linuxbrew/.linuxbrew/bin/brew\" ]; then
        # Linux
        eval \"$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"
      else
        msg_warning \"Homebrew was installed but could not find the brew binary.\"
      fi
    fi
  fi

  # --- Homebrew Bundle Installation ---
  # 1. Install from the base Brewfile for all roles.
  local base_brewfile_path=\"$DOTFILES_ROOT/Brewfile\"
  run_brew_bundle \"$base_brewfile_path\" \"base\"

  # 2. If a role is specified, install from the role-specific Brewfile.
  if [ -n \"$INSTALL_ROLE\" ]; then
    local role_brewfile_path=\"$DOTFILES_ROOT/roles/$INSTALL_ROLE/Brewfile\"
    if [ -f \"$role_brewfile_path\" ]; then
      run_brew_bundle \"$role_brewfile_path\" \"role-specific ($INSTALL_ROLE)\"
    else
      msg_info \"No role-specific Brewfile found for role \'$INSTALL_ROLE\'. Skipping.\"
    fi
  fi

  msg_success \"Homebrew installation stage complete.\"
}

main
