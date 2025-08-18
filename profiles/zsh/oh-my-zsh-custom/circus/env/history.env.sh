# ==============================================================================
#
# FILE:         history.env.sh
#
# DESCRIPTION:  Environment variables for shell history.
#
# ==============================================================================

# Set the location of the history file.
HISTFILE=~/.zsh_history

# Set the maximum number of lines to save in the history file.
HISTSIZE=10000

# Set the maximum number of lines to save in the internal history list.
SAVEHIST=10000

# History options (Zsh specific)
if [ -n "$ZSH_VERSION" ]; then
  setopt APPEND_HISTORY       # Append to the history file, don't overwrite
  setopt EXTENDED_HISTORY     # Save timestamp and duration
  setopt HIST_IGNORE_ALL_DUPS # Don't save duplicate commands
  setopt HIST_REDUCE_BLANKS   # Remove superfluous blanks
fi
