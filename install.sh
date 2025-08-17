#!/usr/bin/env zsh
# ... (header and constants remain the same) ...

# Global state variables
DRY_RUN_MODE=false
INTERACTIVE_MODE=false
INSTALL_PROFILE=""

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

  # --- Announce Modes -------------------------------------------------------
  if [ "$DRY_RUN_MODE" = true ]; then
    msg_warning "Running in Dry Run Mode. No changes will be made to the system."
  fi
  if [ "$INTERACTIVE_MODE" = true ]; then
    msg_info "Running in Interactive Mode."
  fi
  if [ -n "$INSTALL_PROFILE" ]; then
    msg_info "Using installation profile: $INSTALL_PROFILE"
  fi

  # ... (Installation Stages logic remains the same) ...

  msg_success "All installation stages complete!"
}

# ... (script execution remains the same) ...

main "$@"
