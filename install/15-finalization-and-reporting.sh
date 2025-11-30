#!/usr/bin/env bash

# ==============================================================================
#
# Stage 15: Finalization and Reporting
#
# This is the final stage of the installation process. It provides a summary
# of the actions taken and instructs the user on any required next steps.
#
# ==============================================================================

#
# Print the completion banner
#
print_completion_banner() {
  echo ""
  printf "${UI_SUCCESS}${UI_BOLD}"
  cat << 'EOF'
   _____                      _      _       _
  / ____|                    | |    | |     | |
 | |     ___  _ __ ___  _ __ | | ___| |_ ___| |
 | |    / _ \| '_ ` _ \| '_ \| |/ _ \ __/ _ \ |
 | |___| (_) | | | | | | |_) | |  __/ ||  __/_|
  \_____\___/|_| |_| |_| .__/|_|\___|\__\___(_)
                       | |
                       |_|
EOF
  printf "${UI_RESET}"
  echo ""
}

#
# Print the mini completion header
#
print_completion_header() {
  echo ""
  ui_box_top "" 76 "double"
  printf "${UI_PRIMARY}${UI_BOX_V}${UI_RESET}"
  printf "${UI_SUCCESS}${UI_BOLD}       ${UI_ICON_STAR} DOTFILES FLYING CIRCUS ${UI_ICON_STAR}       ${UI_RESET}"
  printf "                      ${UI_PRIMARY}${UI_BOX_V}${UI_RESET}\n"
  printf "${UI_PRIMARY}${UI_BOX_V}${UI_RESET}"
  printf "              ${UI_BOLD}Installation Complete!${UI_RESET}              "
  printf "            ${UI_PRIMARY}${UI_BOX_V}${UI_RESET}\n"
  ui_box_bottom 76 "double"
  echo ""
}

#
# Display installation summary as a table
#
display_summary_table() {
  local role="${1:-}"

  printf "${UI_BOLD}${UI_PRIMARY}Installation Summary${UI_RESET}\n"
  printf "${UI_MUTED}"
  printf '%*s' 60 '' | tr ' ' "$UI_BOX_H_S"
  printf "${UI_RESET}\n"
  echo ""

  # Build summary rows based on what was installed
  local rows=()

  # Core components (always installed)
  rows+=("Homebrew & Packages,${UI_ICON_SUCCESS} Complete")
  rows+=("macOS System Settings,${UI_ICON_SUCCESS} Complete")
  rows+=("Oh-My-Zsh & Plugins,${UI_ICON_SUCCESS} Complete")
  rows+=("Dotfiles Deployment,${UI_ICON_SUCCESS} Complete")
  rows+=("Git Configuration,${UI_ICON_SUCCESS} Complete")

  # Role-specific summary
  if [ -n "$role" ]; then
    local role_dir="$DOTFILES_ROOT/roles/$role"
    if [ -f "$role_dir/Brewfile" ]; then
      rows+=("Role Brewfile ($role),${UI_ICON_SUCCESS} Applied")
    fi
    if [ -d "$role_dir/defaults" ]; then
      rows+=("Role Defaults ($role),${UI_ICON_SUCCESS} Applied")
    fi
  fi

  # Optional components
  if [ -d "$HOME/.config/jb" ] || [ -d "$HOME/Library/Application Support/JetBrains" ]; then
    rows+=("JetBrains Configuration,${UI_ICON_SUCCESS} Complete")
  fi

  # Print the table
  ui_table "40,18" "Component,Status" "${rows[@]}"
  echo ""
}

#
# Display next steps
#
display_next_steps() {
  printf "${UI_BOLD}${UI_WARNING}Next Steps${UI_RESET}\n"
  printf "${UI_MUTED}"
  printf '%*s' 60 '' | tr ' ' "$UI_BOX_H_S"
  printf "${UI_RESET}\n"
  echo ""

  printf "  ${UI_WARNING}${UI_ICON_WARNING}${UI_RESET} To ensure all changes take effect:\n"
  echo ""
  printf "     ${UI_PRIMARY}1.${UI_RESET} ${UI_BOLD}Restart your Terminal${UI_RESET} application\n"
  printf "        ${UI_MUTED}or${UI_RESET}\n"
  printf "     ${UI_PRIMARY}2.${UI_RESET} ${UI_BOLD}Restart your computer${UI_RESET} for full effect\n"
  echo ""
}

#
# Display session info
#
display_session_info() {
  printf "${UI_MUTED}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S} Session Details ${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_BOX_H_S}${UI_RESET}\n"
  echo ""

  if [ -n "${LOG_FILE_PATH:-}" ]; then
    ui_keyval "Log File" "$LOG_FILE_PATH" 14
  fi
  ui_keyval "Completed" "$(date '+%Y-%m-%d %H:%M:%S')" 14

  echo ""
}

#
# Display the farewell message
#
display_farewell() {
  ui_notice "success" "Thank you for using the Dotfiles Flying Circus!"

  printf "${UI_MUTED}For help, documentation, or to report issues:${UI_RESET}\n"
  printf "  ${UI_INFO}${UI_ICON_ARROW}${UI_RESET} ${UI_UNDERLINE}https://github.com/southpawriter02/circus${UI_RESET}\n"
  echo ""

  # Fun sign-off
  printf "${UI_SECONDARY}${UI_ITALIC}\"And now for something completely different...\"${UI_RESET}\n"
  printf "${UI_MUTED}  — Monty Python's Flying Circus${UI_RESET}\n"
  echo ""
}

main() {
  msg_info "Stage 15: Finalization and Reporting"

  # --- Dry Run Summary --------------------------------------------------------
  if [ "$DRY_RUN_MODE" = true ]; then
    echo ""
    ui_box_top "DRY RUN COMPLETE" 60 "single"
    ui_box_line "" 60 "single"
    ui_box_line "  ${UI_ICON_INFO} No changes were made to your system." 60 "single"
    ui_box_line "" 60 "single"
    ui_box_line "  Review the output above to see what the" 60 "single"
    ui_box_line "  installer would have done in a live run." 60 "single"
    ui_box_line "" 60 "single"
    ui_box_bottom 60 "single"
    echo ""
    return 0
  fi

  # --- Installation Complete ---------------------------------------------------

  # Print fancy completion banner or header based on terminal width
  if [[ ${UI_TERM_WIDTH:-80} -ge 70 ]]; then
    print_completion_banner
  fi
  print_completion_header

  # Display the summary table
  display_summary_table "$INSTALL_ROLE"

  # Display next steps
  display_next_steps

  # Display session info
  display_session_info

  # Display farewell
  display_farewell
}

main
