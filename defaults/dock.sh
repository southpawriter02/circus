#!/usr/bin/env bash

# ==============================================================================
#
# Defaults: Dock Configuration
#
# This script uses the `dockutil` tool to create a clean, organized Dock
# with a curated list of applications.
#
# ==============================================================================

main() {
  msg_info "Configuring the Dock..."

  # --- Prerequisite Check ---
  if ! command -v dockutil >/dev/null 2>&1; then
    msg_warning "`dockutil` command not found. Skipping Dock configuration."
    msg_info "Please ensure `dockutil` is installed, for example by adding it to the Brewfile."
    return 1
  fi

  # --- Configuration ---
  # A list of applications to add to the Dock, in order.
  # Note: The path must be to the actual .app bundle.
  local apps_to_add=(
    "/System/Applications/Finder.app"
    "/System/Applications/System Settings.app"
    "/Applications/iTerm.app"
    "/Applications/Visual Studio Code.app"
    "/Applications/Google Chrome.app"
  )

  # --- Dock Management ---

  # 1. Clear the Dock
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would clear all items from the Dock."
  else
    dockutil --remove all --no-restart
    msg_info "Cleared the Dock."
  fi

  # 2. Add Applications
  msg_info "Adding applications to the Dock..."
  for app_path in "${apps_to_add[@]}"; do
    if [ "$DRY_RUN_MODE" = true ]; then
      msg_info "[Dry Run] Would add '$app_path' to the Dock."
    else
      if [ -d "$app_path" ]; then
        if dockutil --add "$app_path" --no-restart; then
          msg_success "Added $(basename "$app_path") to the Dock."
        else
          msg_error "Failed to add $(basename "$app_path") to the Dock."
        fi
      else
        msg_warning "Application not found at $app_path. Skipping."
      fi
    fi
  done

  # 3. Add Downloads Folder
  msg_info "Adding Downloads folder to the Dock..."
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would add the Downloads folder to the Dock."
  else
    if dockutil --add '~/Downloads' --view grid --display folder --sort dateadded --no-restart; then
      msg_success "Added Downloads folder to the Dock."
    else
      msg_error "Failed to add Downloads folder to the Dock."
    fi
  fi

  # 4. Restart the Dock to apply all changes at once.
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_info "[Dry Run] Would restart the Dock."
  else
    msg_info "Restarting the Dock to apply changes..."
    killall Dock
  fi

  msg_success "Dock configuration complete."
}

main
