#!/usr/bin/env bash

# ==============================================================================
#
# Stage 5: Repository Management (Orchestrator)
#
# This script orchestrates the management of the dotfiles repository by
# sourcing a series of modular scripts from the `management/` subdirectory.
# By the time this stage runs, we are guaranteed to have Git installed and
# to be running from within a Git repository.
#
# ==============================================================================

#
# The main logic for the repository management stage.
#
main() {
  msg_info "Stage 5: Repository Management"

  # --- Configuration ----------------------------------------------------------
  local MANAGEMENT_SCRIPTS_DIR="$INSTALL_DIR/management"

  # @description: An array defining the order of the management steps.
  local MANAGEMENT_STAGES=(
    "01-check-for-uncommitted-changes.sh"
    "02-pull-latest-changes.sh"
    "03-update-submodules.sh"
  )

  # --- Execution Logic -------------------------------------------------------
  for stage_script in "${MANAGEMENT_STAGES[@]}"; do
    local script_path="$MANAGEMENT_SCRIPTS_DIR/$stage_script"
    if [ -f "$script_path" ]; then
      # The individual scripts will print their own status messages.
      source "$script_path"
    else
      msg_warning "Repository management script not found: $script_path. Skipping."
    fi
  done

  msg_success "Repository management stage complete."
}

#
# Execute the main function.
#
main
