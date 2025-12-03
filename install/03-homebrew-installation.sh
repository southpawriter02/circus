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
# Count the number of packages in a Brewfile
#
count_packages_in_brewfile() {
  local brewfile="$1"
  if [[ -f "$brewfile" ]]; then
    grep -c "^brew\|^cask\|^mas\|^tap" "$brewfile" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

#
# Parse Brewfile and return package list
#
get_packages_from_brewfile() {
  local brewfile="$1"
  if [[ -f "$brewfile" ]]; then
    grep "^brew\|^cask\|^mas" "$brewfile" | \
      sed -E 's/^(brew|cask|mas) "([^"]+)".*/\2/' 2>/dev/null
  fi
}

#
# Display Brewfile summary before installation
#
display_brewfile_summary() {
  local brewfile_path="$1"
  local brewfile_type="$2"

  if [[ ! -f "$brewfile_path" ]]; then
    return 1
  fi

  local total_packages
  total_packages=$(count_packages_in_brewfile "$brewfile_path")

  local brew_count cask_count tap_count mas_count
  brew_count=$(grep -c "^brew " "$brewfile_path" 2>/dev/null || echo "0")
  cask_count=$(grep -c "^cask " "$brewfile_path" 2>/dev/null || echo "0")
  tap_count=$(grep -c "^tap " "$brewfile_path" 2>/dev/null || echo "0")
  mas_count=$(grep -c "^mas " "$brewfile_path" 2>/dev/null || echo "0")

  echo ""
  ui_box_top "$brewfile_type Brewfile" 60 "single"
  ui_box_line "" 60 "single"
  ui_box_line "  ${UI_ICON_BULLET} Total items: $total_packages" 60 "single"
  ui_box_line "" 60 "single"

  [[ $tap_count -gt 0 ]] && ui_box_line "    ${UI_MUTED}Taps:${UI_RESET}      $tap_count" 60 "single"
  [[ $brew_count -gt 0 ]] && ui_box_line "    ${UI_MUTED}Formulae:${UI_RESET}  $brew_count" 60 "single"
  [[ $cask_count -gt 0 ]] && ui_box_line "    ${UI_MUTED}Casks:${UI_RESET}     $cask_count" 60 "single"
  [[ $mas_count -gt 0 ]] && ui_box_line "    ${UI_MUTED}Mac Apps:${UI_RESET}  $mas_count" 60 "single"

  ui_box_line "" 60 "single"
  ui_box_bottom 60 "single"

  return 0
}

#
# Helper function to run `brew bundle install` for a given Brewfile with progress.
#
run_brew_bundle() {
  local brewfile_path="$1"
  local brewfile_type="$2"

  if [ ! -f "$brewfile_path" ]; then
    msg_warning "$brewfile_type Brewfile not found at $brewfile_path. Skipping."
    return 0
  fi

  # Display summary
  display_brewfile_summary "$brewfile_path" "$brewfile_type"

  local total_packages
  total_packages=$(count_packages_in_brewfile "$brewfile_path")

  msg_info "Installing packages from $brewfile_type Brewfile..."

  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would run: brew bundle install --file=$brewfile_path"
    # Simulate progress for dry run
    echo ""
    local i=0
    while [[ $i -le $total_packages ]]; do
      ui_progress_bar "$i" "$total_packages" 40 "Simulating"
      ((i++))
      sleep 0.05
    done
    ui_progress_bar_done
    printf "${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} [Dry Run] Would install $total_packages packages\n"
  else
    # Run brew bundle with verbose output and parse progress
    echo ""
    local installed=0

    # Use brew bundle with --verbose to track progress
    # We'll run it and count the installations
    ui_spinner_start "Installing $total_packages packages from $brewfile_type Brewfile..."

    local bundle_output
    local bundle_result
    bundle_output=$(brew bundle install --file="$brewfile_path" --verbose 2>&1)
    bundle_result=$?

    ui_spinner_stop "info" "Processing complete"

    if [[ $bundle_result -eq 0 ]]; then
      # Count successful installations from output
      local using_count
      using_count=$(echo "$bundle_output" | grep -c "Using\|Installing\|Downloading" || echo "0")

      echo ""
      # Show completion progress bar at 100%
      ui_progress_bar "$total_packages" "$total_packages" 40 "Complete"
      ui_progress_bar_done
      echo ""

      printf "${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} All packages from $brewfile_type Brewfile installed successfully.\n"

      # Show summary of what happened
      local already_installed
      already_installed=$(echo "$bundle_output" | grep -c "Using" || echo "0")
      local newly_installed
      newly_installed=$(echo "$bundle_output" | grep -c "Installing\|Downloading" || echo "0")

      if [[ $already_installed -gt 0 ]] || [[ $newly_installed -gt 0 ]]; then
        printf "${UI_MUTED}  ${UI_ICON_ARROW} Already installed: $already_installed${UI_RESET}\n"
        printf "${UI_MUTED}  ${UI_ICON_ARROW} Newly installed: $newly_installed${UI_RESET}\n"
      fi
    else
      echo ""
      ui_progress_bar "$total_packages" "$total_packages" 40 "Error"
      ui_progress_bar_done
      echo ""

      printf "${UI_ERROR}${UI_ICON_ERROR}${UI_RESET} An error occurred during brew bundle install for the $brewfile_type Brewfile.\n"
      printf "${UI_MUTED}Check the output above for details.${UI_RESET}\n"

      # Show any error lines from output
      local errors
      errors=$(echo "$bundle_output" | grep -i "error\|failed\|cannot" | head -5)
      if [[ -n "$errors" ]]; then
        echo ""
        printf "${UI_ERROR}Errors:${UI_RESET}\n"
        echo "$errors" | while read -r line; do
          printf "  ${UI_MUTED}${UI_ICON_BULLET}${UI_RESET} %s\n" "$line"
        done
      fi

      return 1
    fi
  fi
}

main() {
  msg_info "Stage 3: Homebrew Installation & Bundle"

  # --- Homebrew Installation Check ---
  echo ""
  if command -v brew >/dev/null 2>&1; then
    printf "${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} Homebrew is already installed.\n"

    # Update Homebrew
    if [ "$DRY_RUN_MODE" = true ]; then
      printf "${UI_INFO}${UI_ICON_INFO}${UI_RESET} [Dry Run] Would run: brew update\n"
    else
      ui_spinner_start "Updating Homebrew..."
      local update_output
      update_output=$(brew update 2>&1)
      local update_result=$?

      if [[ $update_result -eq 0 ]]; then
        ui_spinner_stop "success" "Homebrew updated successfully"
      else
        ui_spinner_stop "warning" "Homebrew update completed with warnings"
      fi
    fi
  else
    printf "${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} Homebrew not found.\n"

    if [ "$DRY_RUN_MODE" = true ]; then
      printf "${UI_INFO}${UI_ICON_INFO}${UI_RESET} [Dry Run] Would install Homebrew from official script.\n"
    else
      ui_spinner_start "Installing Homebrew (this may take a few minutes)..."

      # Run Homebrew installation
      local install_output
      install_output=$(/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" 2>&1)
      local install_result=$?

      if [[ $install_result -eq 0 ]]; then
        ui_spinner_stop "success" "Homebrew installed successfully"

        # Detect the Homebrew installation path based on the OS and architecture
        if [ -x "/opt/homebrew/bin/brew" ]; then
          # macOS Apple Silicon
          eval "$(/opt/homebrew/bin/brew shellenv)"
          printf "${UI_MUTED}  ${UI_ICON_ARROW} Detected Apple Silicon installation${UI_RESET}\n"
        elif [ -x "/usr/local/bin/brew" ]; then
          # macOS Intel
          eval "$(/usr/local/bin/brew shellenv)"
          printf "${UI_MUTED}  ${UI_ICON_ARROW} Detected Intel Mac installation${UI_RESET}\n"
        elif [ -x "/home/linuxbrew/.linuxbrew/bin/brew" ]; then
          # Linux
          eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
          printf "${UI_MUTED}  ${UI_ICON_ARROW} Detected Linux installation${UI_RESET}\n"
        else
          ui_spinner_stop "warning" "Homebrew installed but brew binary not found in expected locations"
        fi
      else
        ui_spinner_stop "error" "Homebrew installation failed"
        printf "${UI_ERROR}Please install Homebrew manually and re-run the installer.${UI_RESET}\n"
        return 1
      fi
    fi
  fi

  # --- Homebrew Bundle Installation ---
  # 1. Install from the base Brewfile for all roles.
  local base_brewfile_path="$DOTFILES_ROOT/Brewfile"
  run_brew_bundle "$base_brewfile_path" "base"

  # 2. If a role is specified, install from the role-specific Brewfile.
  if [ -n "$INSTALL_ROLE" ]; then
    local role_brewfile_path="$DOTFILES_ROOT/roles/$INSTALL_ROLE/Brewfile"
    if [ -f "$role_brewfile_path" ]; then
      run_brew_bundle "$role_brewfile_path" "role-specific ($INSTALL_ROLE)"
    else
      msg_info "No role-specific Brewfile found for role '$INSTALL_ROLE'. Skipping."
    fi
  fi

  msg_success "Homebrew installation stage complete."
}

main
