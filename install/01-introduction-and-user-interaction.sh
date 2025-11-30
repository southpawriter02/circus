#!/usr/bin/env bash

# ==============================================================================
#
# Stage 1: Introduction and User Interaction
#
# This script provides a user-friendly introduction to the installation
# process. It summarizes the planned actions, highlights any potentially
# destructive operations, and prompts the user for confirmation before
# proceeding. It may also allow the user to select optional features.
#
# Its responsibilities include:
#
#   1.1. Displaying an introduction and summary of changes.
#   1.2. Prompting the user for confirmation to proceed.
#   1.3. Allowing the user to select optional installation components.
#
# ==============================================================================

#
# Asks the user a yes/no question.
#
# @param string $1 The question to ask the user.
# @param string $2 The default response (optional). Should be 'Y' or 'N'.
#
# @return 0 for "yes", 1 for "no".
#
ask() {
  # If the installer is not in interactive mode, assume "yes" to all prompts.
  if [ "${INTERACTIVE_MODE:-true}" = false ]; then
    return 0
  fi

  # Use the new UI confirm function
  ui_confirm "$1" "${2:-}"
}

#
# Display the welcome screen with banner and information
#
display_welcome() {
  clear 2>/dev/null || true

  # Print the fancy ASCII art banner
  ui_print_banner

  # Display the info box with what will be installed
  ui_box_top "What This Installer Will Do" 76 "single"
  ui_box_line "" 76 "single"
  ui_box_line "  ${UI_ICON_BULLET} Install essential command-line tools via Homebrew" 76 "single"
  ui_box_line "  ${UI_ICON_BULLET} Configure macOS system and application settings" 76 "single"
  ui_box_line "  ${UI_ICON_BULLET} Deploy shell configuration files (zsh, aliases, etc.)" 76 "single"
  ui_box_line "  ${UI_ICON_BULLET} Set up development environment and tools" 76 "single"
  ui_box_line "  ${UI_ICON_BULLET} Configure Git with your preferences" 76 "single"
  ui_box_line "" 76 "single"
  ui_box_bottom 76 "single"

  echo ""

  # System info
  printf "${UI_MUTED}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S} System Information ${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_RESET}\n"
  echo ""
  ui_keyval "User" "$(whoami)" 18
  ui_keyval "Hostname" "$(hostname -s 2>/dev/null || hostname)" 18
  ui_keyval "macOS Version" "$(sw_vers -productVersion 2>/dev/null || echo 'N/A')" 18
  ui_keyval "Shell" "$SHELL" 18
  if [[ -n "${INSTALL_ROLE:-}" ]]; then
    ui_keyval "Install Role" "$INSTALL_ROLE" 18
  fi
  echo ""

  # Warning notice
  ui_notice "warning" "This script will make changes to your system. Back up your data first!"
}

#
# Display the installation mode selection
#
select_installation_mode() {
  if [ "${INTERACTIVE_MODE:-true}" = false ]; then
    return 0
  fi

  echo ""
  printf "${UI_BOLD}${UI_PRIMARY}Installation Mode${UI_RESET}\n"
  printf "${UI_MUTED}"
  printf '%*s' 50 '' | tr ' ' "$UI_BOX_H_S"
  printf "${UI_RESET}\n"
  echo ""

  if [[ "$DRY_RUN_MODE" == "true" ]]; then
    printf "  ${UI_INFO}${UI_ICON_INFO}${UI_RESET} Running in ${UI_BOLD}DRY RUN${UI_RESET} mode - no changes will be made\n"
  else
    printf "  ${UI_SUCCESS}${UI_ICON_ACTIVE}${UI_RESET} Running in ${UI_BOLD}LIVE${UI_RESET} mode - changes will be applied\n"
  fi

  if [[ "${FORCE_MODE:-false}" == "true" ]]; then
    printf "  ${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} Force mode enabled - prompts will be skipped\n"
  fi

  echo ""
}

#
# The main logic for the introduction and user interaction stage.
#
main() {
  msg_info "Stage 1: Introduction and User Interaction"

  # --- Display Welcome Screen -------------------------------------------------
  display_welcome

  # --- Display Installation Mode ----------------------------------------------
  select_installation_mode

  # --- Prompt for Confirmation ----------------------------------------------
  echo ""
  if ui_confirm "Do you want to proceed with the installation?" "N"; then
    echo ""
    printf "${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} ${UI_SUCCESS}${UI_BOLD}Installation confirmed. Let's begin!${UI_RESET}\n"
    echo ""

    # Show a brief countdown for dramatic effect (optional, can be removed)
    if [ "${INTERACTIVE_MODE:-true}" = true ] && [ "${PARANOID_MODE:-false}" = false ]; then
      printf "${UI_MUTED}Starting in: "
      for i in 3 2 1; do
        printf "${UI_PRIMARY}${UI_BOLD}%d${UI_RESET}${UI_MUTED}..." "$i"
        sleep 0.5
      done
      printf "${UI_SUCCESS}${UI_BOLD}GO!${UI_RESET}\n"
      echo ""
    fi
  else
    echo ""
    printf "${UI_ERROR}${UI_ICON_ERROR}${UI_RESET} ${UI_ERROR}Installation aborted by user.${UI_RESET}\n"
    exit 1
  fi
}

#
# Execute the main function.
#
main
