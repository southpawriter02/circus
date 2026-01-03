#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         interactive.sh
#
# DESCRIPTION:  Interactive mode support for the fc command.
#               Provides fzf-powered command discovery and navigation.
#
# ==============================================================================

# Check if fzf is available
has_fzf() {
  command -v fzf &>/dev/null
}

# Get command description from a plugin file
# Extracts the DESCRIPTION field from the header comment
get_plugin_description() {
  local plugin_file="$1"
  local desc=""
  
  # Extract DESCRIPTION line from the file header
  desc=$(grep -m1 "^# DESCRIPTION:" "$plugin_file" 2>/dev/null | sed 's/^# DESCRIPTION:[[:space:]]*//')
  
  if [[ -z "$desc" ]]; then
    # Try alternate format
    desc=$(grep -A1 "^#.*DESCRIPTION" "$plugin_file" 2>/dev/null | tail -1 | sed 's/^#[[:space:]]*//')
  fi
  
  # Truncate to 50 chars
  if [[ ${#desc} -gt 50 ]]; then
    desc="${desc:0:47}..."
  fi
  
  echo "${desc:-No description}"
}

# Get all commands with descriptions
get_all_commands() {
  local plugin_dir="$1"
  
  for plugin in "$plugin_dir"/fc-*; do
    [[ -x "$plugin" ]] || continue
    local name
    name=$(basename "$plugin")
    # Remove fc- prefix for display
    local short_name="${name#fc-}"
    local desc
    desc=$(get_plugin_description "$plugin")
    printf "%-15s %s\n" "$short_name" "$desc"
  done
}

# Get subcommands/actions from a plugin's help
get_plugin_actions() {
  local plugin_file="$1"
  local actions=""
  
  # Try to extract actions from ACTIONS section in header
  actions=$(awk '/^# ACTIONS:/,/^# [A-Z]/' "$plugin_file" 2>/dev/null | \
            grep -E "^#[[:space:]]+[a-z]+" | \
            sed 's/^#[[:space:]]*//' | \
            head -10)
  
  if [[ -z "$actions" ]]; then
    # Fallback: try to find case statements for actions
    actions=$(grep -E "^[[:space:]]+(on|off|status|start|stop|list|show|get|set|add|remove|clear|backup|restore|help)\)" "$plugin_file" 2>/dev/null | \
              sed 's/[[:space:]]*)//' | \
              sed 's/^[[:space:]]*//' | \
              sort -u)
  fi
  
  echo "$actions"
}

# Interactive command selection
interactive_select_command() {
  local plugin_dir="$1"
  
  if ! has_fzf; then
    msg_error "fzf is required for interactive mode."
    msg_info "Install with: brew install fzf"
    return 1
  fi
  
  local selection
  selection=$(get_all_commands "$plugin_dir" | \
    fzf --height=50% \
        --layout=reverse \
        --border=rounded \
        --prompt="fc > " \
        --header="Select a command (ESC to cancel)" \
        --preview="$DOTFILES_ROOT/bin/fc {1} --help 2>/dev/null | head -30" \
        --preview-window=right:50%:wrap)
  
  if [[ -z "$selection" ]]; then
    return 1
  fi
  
  # Extract command name (first word)
  local cmd
  cmd=$(echo "$selection" | awk '{print $1}')
  
  echo "$cmd"
}

# Interactive action selection for a command
interactive_select_action() {
  local plugin_dir="$1"
  local command="$2"
  local plugin_file="$plugin_dir/fc-$command"
  
  if [[ ! -x "$plugin_file" ]]; then
    return 1
  fi
  
  # Get help output for preview
  local help_output
  help_output=$("$DOTFILES_ROOT/bin/fc" "$command" --help 2>/dev/null)
  
  # Extract actions from help
  local actions
  actions=$(echo "$help_output" | grep -E "^  [a-z]+" | head -15)
  
  if [[ -z "$actions" ]]; then
    # No actions found, just run the command
    echo ""
    return 0
  fi
  
  local selection
  selection=$(echo "$actions" | \
    fzf --height=40% \
        --layout=reverse \
        --border=rounded \
        --prompt="fc $command > " \
        --header="Select an action (ESC to go back)")
  
  if [[ -z "$selection" ]]; then
    return 1
  fi
  
  # Extract action name (first word)
  local action
  action=$(echo "$selection" | awk '{print $1}')
  
  echo "$action"
}

# Main interactive mode function
run_interactive_mode() {
  local plugin_dir="$1"
  
  msg_info "Interactive mode - use arrow keys to navigate, Enter to select"
  echo ""
  
  # Select command
  local cmd
  cmd=$(interactive_select_command "$plugin_dir")
  
  if [[ -z "$cmd" ]]; then
    msg_info "Cancelled."
    return 0
  fi
  
  # Select action
  local action
  action=$(interactive_select_action "$plugin_dir" "$cmd")
  
  if [[ $? -ne 0 ]]; then
    # User cancelled action selection, go back to command selection
    run_interactive_mode "$plugin_dir"
    return
  fi
  
  # Execute the command
  echo ""
  if [[ -n "$action" ]]; then
    msg_info "Running: fc $cmd $action"
    echo ""
    "$DOTFILES_ROOT/bin/fc" "$cmd" "$action"
  else
    msg_info "Running: fc $cmd"
    echo ""
    "$DOTFILES_ROOT/bin/fc" "$cmd"
  fi
}

# Simple fallback for when fzf is not available
run_simple_interactive() {
  local plugin_dir="$1"
  
  msg_info "Available commands:"
  echo ""
  get_all_commands "$plugin_dir"
  echo ""
  msg_info "Enter command name (or 'q' to quit):"
  read -r cmd
  
  if [[ "$cmd" == "q" ]] || [[ -z "$cmd" ]]; then
    return 0
  fi
  
  local plugin_file="$plugin_dir/fc-$cmd"
  if [[ -x "$plugin_file" ]]; then
    "$DOTFILES_ROOT/bin/fc" "$cmd" --help
    echo ""
    msg_info "Enter action (or press Enter to skip):"
    read -r action
    
    if [[ -n "$action" ]]; then
      "$DOTFILES_ROOT/bin/fc" "$cmd" "$action"
    fi
  else
    msg_error "Unknown command: $cmd"
  fi
}
