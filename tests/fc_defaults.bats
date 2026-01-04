#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_defaults.bats
#
# DESCRIPTION:  Comprehensive test suite for the `fc defaults` plugin.
#               Tests all subcommands, flags, and error handling.
#
# COVERAGE:
#   - Subcommands: list, status, apply, reset, all
#   - Flags: --dry-run, --help
#   - Error handling: missing args, invalid tweaks, unknown subcommands
#
# ==============================================================================

# Load the unified test helper.
load 'test_helper'

# --- Test Setup ---------------------------------------------------------------
setup() {
  # Define the path to the main fc executable.
  FC_COMMAND="$PROJECT_ROOT/bin/fc"

  # Define the path to the defaults plugin directly for unit tests.
  DEFAULTS_PLUGIN="$PROJECT_ROOT/lib/plugins/fc-defaults"
}

# ==============================================================================
# HELP AND USAGE TESTS
# ==============================================================================

@test "fc defaults --help displays usage information" {
  run "$FC_COMMAND" fc-defaults --help
  assert_success
  assert_output --partial "Usage: fc defaults <subcommand>"
  assert_output --partial "Apply curated macOS defaults tweaks"
}

@test "fc defaults -h displays usage information" {
  run "$FC_COMMAND" fc-defaults -h
  assert_success
  assert_output --partial "Usage: fc defaults <subcommand>"
}

@test "fc defaults with no arguments shows usage" {
  run "$FC_COMMAND" fc-defaults
  assert_success
  assert_output --partial "Usage: fc defaults <subcommand>"
  assert_output --partial "Subcommands:"
}

@test "fc defaults --help lists all subcommands" {
  run "$FC_COMMAND" fc-defaults --help
  assert_success
  assert_output --partial "list"
  assert_output --partial "status"
  assert_output --partial "apply"
  assert_output --partial "reset"
  assert_output --partial "all"
}

@test "fc defaults --help shows --dry-run option" {
  run "$FC_COMMAND" fc-defaults --help
  assert_success
  assert_output --partial "--dry-run"
  assert_output --partial "Show what would be done without making changes"
}

@test "fc defaults --help shows example commands" {
  run "$FC_COMMAND" fc-defaults --help
  assert_success
  assert_output --partial "Examples:"
  assert_output --partial "fc defaults list"
  assert_output --partial "fc defaults apply finder.hidden-files"
}

# ==============================================================================
# LIST SUBCOMMAND TESTS
# ==============================================================================

@test "fc defaults list runs without error" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
}

@test "fc defaults list displays category headers" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "Finder:"
  assert_output --partial "Dock:"
  assert_output --partial "Screenshots:"
}

@test "fc defaults list shows Finder tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "finder.hidden-files"
  assert_output --partial "finder.path-bar"
  assert_output --partial "finder.extensions"
}

@test "fc defaults list shows Dock tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "dock.autohide"
  assert_output --partial "dock.minimize-effect"
  assert_output --partial "dock.show-recents"
}

@test "fc defaults list shows Screenshot tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "screenshot.location"
  assert_output --partial "screenshot.format"
  assert_output --partial "screenshot.shadow"
}

@test "fc defaults list shows Keyboard tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "keyboard.key-repeat"
  assert_output --partial "keyboard.initial-repeat"
  assert_output --partial "keyboard.press-and-hold"
}

@test "fc defaults list shows descriptions for each tweak" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "Show hidden files in Finder"
  assert_output --partial "Auto-hide the Dock when not in use"
  assert_output --partial "Screenshot save location"
}

@test "fc defaults list shows usage hint at the end" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "Usage: fc defaults apply <tweak-name>"
}

# ==============================================================================
# STATUS SUBCOMMAND TESTS
# ==============================================================================

@test "fc defaults status runs without error" {
  run "$FC_COMMAND" fc-defaults status
  assert_success
}

@test "fc defaults status shows column headers" {
  run "$FC_COMMAND" fc-defaults status
  assert_success
  assert_output --partial "Tweak"
  assert_output --partial "Current"
  assert_output --partial "Recommended"
}

@test "fc defaults status displays tweaks with values" {
  run "$FC_COMMAND" fc-defaults status
  assert_success
  # Should show at least some tweak names in the output
  assert_output --partial "finder."
  assert_output --partial "dock."
}

@test "fc defaults status shows On/Off for boolean tweaks" {
  run "$FC_COMMAND" fc-defaults status
  assert_success
  # Boolean tweaks should display as On or Off
  # At least one of these should appear
  [[ "$output" =~ "On" ]] || [[ "$output" =~ "Off" ]]
}

# ==============================================================================
# APPLY SUBCOMMAND TESTS
# ==============================================================================

@test "fc defaults apply without tweak name shows error" {
  run "$FC_COMMAND" fc-defaults apply
  assert_failure
  assert_output --partial "Please specify a tweak to apply"
}

@test "fc defaults apply with invalid tweak name shows error" {
  run "$FC_COMMAND" fc-defaults apply nonexistent.tweak
  assert_failure
  assert_output --partial "Unknown tweak"
  assert_output --partial "fc defaults list"
}

@test "fc defaults apply --dry-run shows what would be done" {
  run "$FC_COMMAND" fc-defaults apply finder.hidden-files --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
  assert_output --partial "defaults write"
  assert_output --partial "com.apple.finder"
  assert_output --partial "AppleShowAllFiles"
}

@test "fc defaults apply --dry-run does not require restart" {
  run "$FC_COMMAND" fc-defaults apply finder.hidden-files --dry-run
  assert_success
  assert_output --partial "[DRY-RUN] Would run: killall Finder"
}

@test "fc defaults --dry-run apply works (flag before subcommand)" {
  run "$FC_COMMAND" fc-defaults --dry-run apply finder.hidden-files
  assert_success
  assert_output --partial "[DRY-RUN]"
}

@test "fc defaults apply --dry-run shows description" {
  run "$FC_COMMAND" fc-defaults apply dock.autohide --dry-run
  assert_success
  assert_output --partial "Auto-hide the Dock"
}

@test "fc defaults apply --dry-run for dock tweak mentions Dock restart" {
  run "$FC_COMMAND" fc-defaults apply dock.autohide --dry-run
  assert_success
  assert_output --partial "killall Dock"
}

@test "fc defaults apply --dry-run for keyboard tweak has no restart" {
  run "$FC_COMMAND" fc-defaults apply keyboard.key-repeat --dry-run
  assert_success
  # keyboard.key-repeat has no restart command
  refute_output --partial "killall"
}

# ==============================================================================
# RESET SUBCOMMAND TESTS
# ==============================================================================

@test "fc defaults reset without tweak name shows error" {
  run "$FC_COMMAND" fc-defaults reset
  assert_failure
  assert_output --partial "Please specify a tweak to reset"
}

@test "fc defaults reset with invalid tweak name shows error" {
  run "$FC_COMMAND" fc-defaults reset fake.tweak.name
  assert_failure
  assert_output --partial "Unknown tweak"
}

@test "fc defaults reset --dry-run shows what would be done" {
  run "$FC_COMMAND" fc-defaults reset finder.hidden-files --dry-run
  assert_success
  assert_output --partial "[DRY-RUN]"
  assert_output --partial "defaults write"
  assert_output --partial "Resetting to macOS default"
}

@test "fc defaults reset --dry-run shows restart command" {
  run "$FC_COMMAND" fc-defaults reset dock.icon-size --dry-run
  assert_success
  assert_output --partial "[DRY-RUN] Would run: killall Dock"
}

# ==============================================================================
# ALL SUBCOMMAND TESTS
# ==============================================================================

@test "fc defaults all --dry-run runs without error" {
  run "$FC_COMMAND" fc-defaults all --dry-run
  assert_success
}

@test "fc defaults all --dry-run lists all tweaks" {
  run "$FC_COMMAND" fc-defaults all --dry-run
  assert_success
  assert_output --partial "[DRY-RUN] finder.hidden-files"
  assert_output --partial "[DRY-RUN] dock.autohide"
  assert_output --partial "[DRY-RUN] screenshot.format"
}

@test "fc defaults all --dry-run shows count of tweaks" {
  run "$FC_COMMAND" fc-defaults all --dry-run
  assert_success
  assert_output --partial "[DRY-RUN] Would apply"
  assert_output --partial "tweaks"
}

@test "fc defaults all --dry-run mentions status command" {
  run "$FC_COMMAND" fc-defaults all --dry-run
  assert_success
  assert_output --partial "fc defaults status"
}

@test "fc defaults --dry-run all works (flag before subcommand)" {
  run "$FC_COMMAND" fc-defaults --dry-run all
  assert_success
  assert_output --partial "[DRY-RUN]"
}

# ==============================================================================
# ERROR HANDLING TESTS
# ==============================================================================

@test "fc defaults with unknown subcommand fails" {
  run "$FC_COMMAND" fc-defaults invalid-subcommand
  assert_failure
  assert_output --partial "Unknown subcommand: invalid-subcommand"
}

@test "fc defaults with unknown subcommand suggests help" {
  run "$FC_COMMAND" fc-defaults foobar
  assert_failure
  assert_output --partial "fc defaults --help"
}

# ==============================================================================
# TWEAK DEFINITION COVERAGE TESTS
# ==============================================================================

@test "fc defaults list includes Safari tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "safari.develop-menu"
  assert_output --partial "safari.full-url"
}

@test "fc defaults list includes System tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "system.animations"
  assert_output --partial "system.crash-reporter"
}

@test "fc defaults list includes Terminal tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "terminal.secure-keyboard"
}

@test "fc defaults list includes Text Input tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "text.autocorrect"
  assert_output --partial "text.smart-quotes"
}

@test "fc defaults list includes Trackpad tweaks" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "trackpad.tap-to-click"
  assert_output --partial "trackpad.three-finger-drag"
}

# ==============================================================================
# TWEAK TYPE COVERAGE TESTS
# ==============================================================================

@test "fc defaults apply --dry-run handles bool type correctly" {
  run "$FC_COMMAND" fc-defaults apply finder.hidden-files --dry-run
  assert_success
  assert_output --partial "-bool"
  assert_output --partial "true"
}

@test "fc defaults apply --dry-run handles int type correctly" {
  run "$FC_COMMAND" fc-defaults apply keyboard.key-repeat --dry-run
  assert_success
  assert_output --partial "-int"
}

@test "fc defaults apply --dry-run handles float type correctly" {
  run "$FC_COMMAND" fc-defaults apply dock.autohide-delay --dry-run
  assert_success
  assert_output --partial "-float"
}

@test "fc defaults apply --dry-run handles string type correctly" {
  run "$FC_COMMAND" fc-defaults apply dock.minimize-effect --dry-run
  assert_success
  assert_output --partial "-string"
  assert_output --partial "scale"
}

# ==============================================================================
# INTEGRATION WITH FC DISPATCHER
# ==============================================================================

@test "fc shows defaults in available commands" {
  run "$FC_COMMAND"
  assert_success
  # The fc dispatcher strips the 'fc-' prefix when displaying commands
  assert_output --partial "defaults"
}

@test "fc defaults can be invoked via dispatcher" {
  run "$FC_COMMAND" fc-defaults list
  assert_success
  assert_output --partial "Available macOS Defaults Tweaks"
}
