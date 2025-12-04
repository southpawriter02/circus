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
# Get role description based on role name
#
get_role_description() {
  local role="$1"
  case "$role" in
    developer)
      echo "Full development environment with IDEs, databases, and dev tools"
      ;;
    personal)
      echo "Personal computing setup with productivity and entertainment apps"
      ;;
    work)
      echo "Work-focused setup with business and collaboration tools"
      ;;
    *)
      echo "Custom role configuration"
      ;;
  esac
}

#
# Count packages in a Brewfile
#
count_brewfile_packages() {
  local brewfile="$1"
  if [[ -f "$brewfile" ]]; then
    grep -c "^brew\|^cask\|^mas" "$brewfile" 2>/dev/null || echo "0"
  else
    echo "0"
  fi
}

#
# Display role details/preview
#
display_role_preview() {
  local role="$1"
  local role_dir="$DOTFILES_ROOT/roles/$role"
  local brewfile="$role_dir/Brewfile"

  echo ""
  ui_box_top "Role: $role" 60 "single"
  ui_box_line "" 60 "single"
  ui_box_line "  $(get_role_description "$role")" 60 "single"
  ui_box_line "" 60 "single"

  if [[ -f "$brewfile" ]]; then
    local pkg_count
    pkg_count=$(count_brewfile_packages "$brewfile")
    ui_box_line "  ${UI_ICON_BULLET} Packages to install: $pkg_count" 60 "single"

    # Show a few example packages
    ui_box_line "" 60 "single"
    ui_box_line "  Sample packages:" 60 "single"
    local count=0
    while IFS= read -r line; do
      if [[ "$line" =~ ^(brew|cask)\ \"([^\"]+)\" ]]; then
        local pkg_name="${BASH_REMATCH[2]}"
        ui_box_line "    ${UI_ICON_ARROW} $pkg_name" 60 "single"
        count=$((count + 1))
        [[ $count -ge 5 ]] && break
      fi
    done < "$brewfile"

    if [[ $pkg_count -gt 5 ]]; then
      ui_box_line "    ${UI_MUTED}... and $((pkg_count - 5)) more${UI_RESET}" 60 "single"
    fi
  fi

  # Check for other role components
  ui_box_line "" 60 "single"
  ui_box_line "  Includes:" 60 "single"
  [[ -d "$role_dir/aliases" ]] && ui_box_line "    ${UI_ICON_SUCCESS} Custom shell aliases" 60 "single"
  [[ -d "$role_dir/defaults" ]] && ui_box_line "    ${UI_ICON_SUCCESS} macOS default settings" 60 "single"
  [[ -d "$role_dir/env" ]] && ui_box_line "    ${UI_ICON_SUCCESS} Environment variables" 60 "single"

  ui_box_line "" 60 "single"
  ui_box_bottom 60 "single"
}

#
# Interactive role selection
#
select_role_interactive() {
  # Skip if not in interactive mode or role already specified
  if [[ "${INTERACTIVE_MODE:-true}" == "false" ]]; then
    return 0
  fi

  # If role was specified via CLI, show it and continue
  if [[ -n "${INSTALL_ROLE:-}" ]]; then
    printf "${UI_INFO}${UI_ICON_INFO}${UI_RESET} Role specified via command line: ${UI_BOLD}$INSTALL_ROLE${UI_RESET}\n"
    return 0
  fi

  echo ""
  printf "${UI_BOLD}${UI_PRIMARY}Role Selection${UI_RESET}\n"
  printf "${UI_MUTED}"
  printf '%*s' 60 '' | tr ' ' "$UI_BOX_H_S"
  printf "${UI_RESET}\n"
  echo ""

  printf "${UI_MUTED}Roles customize your installation with specific packages,${UI_RESET}\n"
  printf "${UI_MUTED}settings, and configurations for different use cases.${UI_RESET}\n"
  echo ""

  # Get available roles
  local roles_dir="$DOTFILES_ROOT/roles"
  local available_roles=()
  local role_options=()

  for role_path in "$roles_dir"/*/; do
    if [[ -d "$role_path" ]]; then
      local role_name
      role_name=$(basename "$role_path")
      # Skip hidden directories and placeholders
      [[ "$role_name" == .* ]] && continue
      available_roles+=("$role_name")
      local desc
      desc=$(get_role_description "$role_name")
      role_options+=("$role_name - $desc")
    fi
  done

  # Add "None" option
  role_options+=("none - Base installation only (no role-specific packages)")

  if [[ ${#available_roles[@]} -eq 0 ]]; then
    printf "${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} No roles found in $roles_dir\n"
    return 0
  fi

  # Use ui_select for role selection
  local selected
  selected=$(ui_select "Select an installation role:" "${role_options[@]}")

  # Extract role name from selection
  local selected_role
  selected_role=$(echo "$selected" | cut -d' ' -f1)

  if [[ "$selected_role" == "none" ]]; then
    printf "\n${UI_INFO}${UI_ICON_INFO}${UI_RESET} Installing without a specific role.\n"
    INSTALL_ROLE=""
  else
    INSTALL_ROLE="$selected_role"
    export INSTALL_ROLE

    # Show preview of selected role
    display_role_preview "$INSTALL_ROLE"

    printf "${UI_SUCCESS}${UI_ICON_SUCCESS}${UI_RESET} Selected role: ${UI_BOLD}$INSTALL_ROLE${UI_RESET}\n"
  fi
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

  # --- Interactive Role Selection -------------------------------------------
  select_role_interactive

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
