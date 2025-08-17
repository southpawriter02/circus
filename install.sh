#!/usr/bin/env zsh
# ... (header and constants remain the same) ...

# Global state variables
DRY_RUN_MODE=false
INTERACTIVE_MODE=false

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
   -h, --help         Show this help message and exit.
   -i, --interactive  Run in interactive mode, pausing for confirmation
                        before each major stage.
   --no-op, --dry-run   Perform a dry run; show what would be done without
                        making any changes.

EOF
  exit 1
}

###
# @description
#   This is the main function where the script's primary logic resides.
###
main() {
  # ----------------------------------------------------------------------------
  # SUB-SECTION: Argument Parsing
  # ----------------------------------------------------------------------------
  while [[ $# -gt 0 ]]; do
    local key="$1"
    case "$key" in
      -h|--help)
        usage
        ;;
      -i|--interactive)
        INTERACTIVE_MODE=true
        ;;
      --no-op|--dry-run)
        DRY_RUN_MODE=true
        ;;
      *)
        echo "Error: Unknown option '$1'" >&2
        usage
        ;;
    esac
    shift
  done

  # --- Announce Modes -------------------------------------------------------
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_warning "Running in Dry Run Mode. No changes will be made to the system."
  fi
  if [ "$INTERACTIVE_MODE" = true ]; then
    msg_info "Running in Interactive Mode."
  fi

  # ----------------------------------------------------------------------------
  # SUB-SECTION: Installation Stages
  # ----------------------------------------------------------------------------
  msg_info "Starting Dotfiles Flying Circus setup..."
  prompt_for_confirmation "Ready to begin the installation."

  # Define all installation stages.
  local INSTALL_STAGES=(
    "01-introduction-and-user-interaction.sh"
    "02-logging-setup.sh"
    "03-homebrew-installation.sh"
    # ... (other stages) ...
    "09-dotfiles-deployment.sh"
    "11-defaults-and-additional-configuration.sh"
    # ... (other stages) ...
    "14-finalization-and-reporting.sh"
  )

  # Iterate through the installation stages and execute them.
  for stage_script in "${INSTALL_STAGES[@]}"; do
    local stage_path="$INSTALL_DIR/$stage_script"
    if [[ -f "$stage_path" ]]; then
      prompt_for_confirmation "Press Enter to run stage: $stage_script"
      # shellcheck source=/dev/null
      source "$stage_path"
    else
      msg_error "Installation stage script not found: $stage_path"
      exit 1
    fi
  done

  msg_success "All installation stages complete!"
}

# ... (script execution remains the same) ...

main "$@"
