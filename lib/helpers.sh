#!/usr/bin/env zsh
# ... (header and logging functions remain the same) ...

###
# @description Wrapper functions for each log level for convenience.
###
msg_info()    { logm "INFO"    "$1"; }
msg_success() { logm "SUCCESS" "$1"; }
msg_warning() { logm "WARN"    "$1"; }
msg_error()   { logm "ERROR"   "$1" >&2; }
msg_critical(){ logm "CRITICAL""$1" >&2; }
msg_debug()   { logm "DEBUG"   "$1"; }

# ------------------------------------------------------------------------------
# SECTION: USER INTERACTION FUNCTIONS
# ------------------------------------------------------------------------------

###
# @description
#   Prompts the user to press Enter to continue. This function only has an
#   effect if the global variable INTERACTIVE_MODE is set to true.
# @param $1
#   The message to display to the user.
###
prompt_for_confirmation() {
  if [ "$INTERACTIVE_MODE" = true ]; then
    msg_info "$1"
    read -p "Press Enter to continue..."
  fi
}
