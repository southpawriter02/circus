#!/usr/bin/env zsh
# ... (header and constants remain the same) ...

# Global state variables
DRY_RUN_MODE=false
INTERACTIVE_MODE=false
INSTALL_ROLE=""
FORCE_MODE=false
PARANOID_MODE=false

# ... (library sourcing remains the same) ...

# Update usage function to include the new flag
usage() {
  echo "Usage: ./install.sh [options]"
  echo ""
  echo "Options:"
  echo "  --role <name>      Specify the role to install (e.g., developer)."
  echo "  --dry-run          Run the installer without making any changes."
  echo "  --force            Force re-running of already completed stages."
  echo "  --non-interactive  Run the installer without prompting for confirmation."
  echo "  --silent           Run the installer with minimal output to protect privacy."
  echo "  --help             Display this help message."
  exit 1
}

main() {
  # Argument parsing
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --role)
        INSTALL_ROLE="$2"
        shift 2
        ;;
      --dry-run)
        DRY_RUN_MODE=true
        shift
        ;;
      --force)
        FORCE_MODE=true
        shift
        ;;
      --non-interactive)
        INTERACTIVE_MODE=false
        shift
        ;;
      --silent)
        PARANOID_MODE=true
        shift
        ;;
      --help)
        usage
        ;;
      *)
        usage
        ;;
    esac
  done

  # Export the PARANOID_MODE so it's available to all sourced scripts
  export PARANOID_MODE

  # ... (rest of the script remains the same) ...

  # --- Installation Stages ---
  # ...
}

main "$@"
