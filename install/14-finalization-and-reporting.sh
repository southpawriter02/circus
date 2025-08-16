#!/usr/bin/env bash

# ==============================================================================
#
# Stage 14: Finalization and Reporting
#
# This script handles the final steps of the installation process. It provides
# a summary of the actions taken, displays important information to the user,
# and performs any final tasks like saving logs.
#
# Its responsibilities include:
#
#   14.1. Printing a summary of all actions taken.
#   14.2. Displaying a completion message and any necessary next steps.
#   14.3. Saving logs to a persistent location.
#   14.4. Printing the location of logs and backups.
#   14.5. Optionally emailing or uploading logs.
#
# ==============================================================================

#
# The main logic for the finalization and reporting stage.
#
main() {
  msg_info "Stage 14: Finalization and Reporting"

  # --- Summary of Actions -----------------------------------------------------
  # TODO: Implement a mechanism to collect a summary of actions taken throughout
  # the installation and display it here.
  msg_info "A summary of all actions taken will be displayed here."

  # --- Display Completion Message and Next Steps ------------------------------
  msg_success "The Dotfiles Flying Circus installation is complete!"
  msg_info "Please take the following next steps to ensure all changes are applied:"
  msg_info "  1. Restart your shell session.
  msg_info "  2. For some system-level changes to take effect, a full system reboot is recommended."

  # --- Report Log and Backup Locations --------------------------------------
  local DATE
  DATE=$(date "+%Y-%m-%d")
  local LOG_FILE="$LOG_FILE_BASE-$DATE.log"

  msg_info "An installation log has been saved to: $LOG_FILE"

  # The `$backup_dir` variable is set in Stage 10 if backups were made.
  if [ -n "${backup_dir:-}" ] && [ -d "${backup_dir:-}" ]; then
    msg_info "Your original dotfiles have been backed up to: ${backup_dir}"
  fi

  # --- Advanced Reporting -----------------------------------------------------
  # TODO: Add logic to email or upload logs if configured to do so.

  msg_success "Finalization and reporting complete."
}

#
# Execute the main function.
#
main
