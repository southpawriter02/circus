#!/usr/bin/env zsh
# ... (header and constants remain the same) ...

# Global state variables
DRY_RUN_MODE=false
INTERACTIVE_MODE=false
INSTALL_PROFILE=""
FORCE_MODE=false

# ... (library sourcing remains the same) ...

# ... (usage function remains the same) ...

main() {
  # ... (argument parsing remains the same) ...

  # --- Announce Modes ---
  # ... (announcements remain the same) ...

  # --- Setup Receipt Directory ---
  local receipt_dir="$HOME/.circus/receipts"
  if [ "$DRY_RUN_MODE" = false ]; then
    mkdir -p "$receipt_dir"
  fi

  # --- Installation Stages ---
  msg_info "Starting Dotfiles Flying Circus setup..."
  prompt_for_confirmation "Ready to begin the installation."

  local INSTALL_STAGES=(
    "01-introduction-and-user-interaction.sh"
    "02-logging-setup.sh"
    "03-homebrew-installation.sh"
    "09-dotfiles-deployment.sh"
    "10-git-configuration.sh"
    "11-defaults-and-additional-configuration.sh"
    "12-aliases-configuration.sh"
    "13-env-configuration.sh"
    "14-cleanup.sh"
    "15-finalization-and-reporting.sh"
  )

  for stage_script in "${INSTALL_STAGES[@]}"; do
    local stage_path="$INSTALL_DIR/$stage_script"
    local receipt_file="$receipt_dir/$(basename "$stage_script" .sh).receipt"

    if [ -f "$receipt_file" ] && [ "$FORCE_MODE" = false ]; then
      msg_info "Stage '$(basename "$stage_script" .sh)' already completed. Skipping."
      continue
    fi

    if [[ -f "$stage_path" ]]; then
      prompt_for_confirmation "Press Enter to run stage: $stage_script"
      if source "$stage_path"; then
        if [ "$DRY_RUN_MODE" = false ]; then
          touch "$receipt_file"
        fi
      else
        msg_error "Stage '$stage_script' failed. Aborting installation."
        exit 1
      fi
    else
      msg_error "Installation stage script not found: $stage_path"
      exit 1
    fi
  done

  msg_success "All installation stages complete!"
}

main "$@"
