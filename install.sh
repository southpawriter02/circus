#!/usr/bin/env zsh
# ... (header and constants remain the same) ...

# Global state variables
DRY_RUN_MODE=false
INTERACTIVE_MODE=false
INSTALL_PROFILE=""
FORCE_MODE=false

# ... (library sourcing remains the same) ...

###
# @description
#   Prints a usage message for the script and exits.
###
usage() {
  cat << EOF
Usage: $SCRIPT_NAME [options]

Automates the setup of a new macOS device.

OPTIONS:
   -h, --help           Show this help message and exit.
   -f, --force          Force re-installation of all stages, ignoring receipts.
   -i, --interactive    Run in interactive mode, pausing for confirmation.
   -p, --profile <name> Apply a specific installation profile (e.g., 'work').
   --no-op, --dry-run   Perform a dry run; show what would be done.

EOF
  exit 1
}

###
# @description
#   This is the main function where the script's primary logic resides.
###
main() {
  # --- Argument Parsing ---
  while [[ $# -gt 0 ]]; do
    local key="$1"
    case "$key" in
      -h|--help)
        usage
        ;;
      -f|--force)
        FORCE_MODE=true
        shift # past argument
        ;;
      -i|--interactive)
        INTERACTIVE_MODE=true
        shift # past argument
        ;;
      -p|--profile)
        INSTALL_PROFILE="$2"
        shift # past argument
        shift # past value
        ;;
      --no-op|--dry-run)
        DRY_RUN_MODE=true
        shift # past argument
        ;;
      *)
        echo "Error: Unknown option '$1'" >&2
        usage
        ;;
    esac
  done

  # --- Announce Modes ---
  # ... (announcements for dry-run, interactive, profile remain the same) ...
  if [ "$FORCE_MODE" = true ]; then
    msg_warning "Running in Force Mode. All stages will be re-run."
  fi

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
    "11-defaults-and-additional-configuration.sh"
    "14-finalization-and-reporting.sh"
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
        # Create receipt on successful execution
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
