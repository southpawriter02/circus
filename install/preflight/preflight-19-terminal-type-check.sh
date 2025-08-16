#!/usr/bin/env bash

# ==============================================================================
#
# Preflight Check: Terminal Type
#
# This script checks the user's terminal emulator. Some dotfile setups are
# optimized for specific terminal emulators, such as iTerm2. This check can
# be used to provide recommendations to the user.
#
# ==============================================================================

#
# The main logic of the script.
#
main() {
  #
  # CUSTOMIZATION:
  # You can change the recommended terminal by modifying the
  # RECOMMENDED_TERMINAL variable.
  #
  local RECOMMENDED_TERMINAL="iTerm.app"

  msg_info "Checking terminal type..."

  # The `TERM_PROGRAM` environment variable usually contains the name of the
  # terminal emulator.
  if [ "${TERM_PROGRAM:-}" == "$RECOMMENDED_TERMINAL" ]; then
    msg_success "Terminal is $TERM_PROGRAM."
  else
    msg_warning "Terminal is ${TERM_PROGRAM:-unknown}. For the best experience, it is recommended to use $RECOMMENDED_TERMINAL."
  fi

  # This check is informational, so we always return success.
  return 0
}

#
# Execute the main function.
#
main
