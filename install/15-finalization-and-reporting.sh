#!/usr/bin/env bash

# ==============================================================================
#
# Stage 15: Finalization and Reporting
#
# This is the final stage of the installation process. It provides a summary
# of the actions taken and instructs the user on any required next steps.
#
# ==============================================================================

main() {
  msg_info "Stage 15: Finalization and Reporting"

  # --- Dry Run Summary --------------------------------------------------------
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_success "Dry Run Complete."
    msg_info "No changes were made to your system."
    msg_info "You can review the output above to see what the installer would have done."
    return 0
  fi

  # --- Installation Summary -------------------------------------------------
  msg_info ""
  msg_success "=============================================================================="
  msg_success " Dotfiles Flying Circus Installation Complete!"
  msg_success "=============================================================================="
  msg_info ""

  # --- Role-Specific Summary ---
  if [ -n "$INSTALL_ROLE" ]; then
    local role_dir="$DOTFILES_ROOT/roles/$INSTALL_ROLE"
    msg_info "Role-Specific Configuration Summary for '$INSTALL_ROLE':"

    [ -f "$role_dir/Brewfile" ] && msg_info "  - Applied role-specific Brewfile."
    [ -d "$role_dir/aliases" ] && msg_info "  - Applied role-specific aliases."
    [ -d "$role_dir/env" ] && msg_info "  - Applied role-specific environment variables."
    [ -d "$role_dir/defaults" ] && msg_info "  - Applied role-specific defaults scripts."
    msg_info ""
  fi

  msg_info "The log file for this session is located at: $LOG_FILE_PATH"

  # --- Required Next Steps --------------------------------------------------
  msg_info "" # Add a spacer line for readability
  msg_warning "To ensure all changes take effect, please do one of the following:"
  msg_warning "  1. Quit and restart your Terminal application."
  msg_warning "  2. Restart your computer."

  msg_info "" # Add a final spacer line
  msg_info "Thank you for using the Dotfiles Flying Circus!"
}

main
