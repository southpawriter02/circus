# ==============================================================================
# Terminal Colors
#
# Configure color output for various command-line tools.
# ==============================================================================

# --- Enable Colors Globally ---------------------------------------------------

# BSD/macOS: Enable colored output for ls and other commands
export CLICOLOR=1

# Force color even when output is not a terminal (useful for piping)
# Uncomment if needed:
# export CLICOLOR_FORCE=1

# --- ls Colors ----------------------------------------------------------------

# BSD ls colors (used by macOS ls)
# Format: directory, symlink, socket, pipe, executable, block special,
#         character special, setuid, setgid, sticky+other-writable, other-writable
# Colors: a=black, b=red, c=green, d=brown, e=blue, f=magenta, g=cyan, h=white
#         A-H for bold versions, x=default
export LSCOLORS="exfxcxdxbxegedabagacad"

# GNU ls colors (for GNU coreutils if installed)
# This is a colon-separated list of file types and their colors
export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# --- Grep Colors --------------------------------------------------------------

# Default grep match highlighting
# ms = matching text, mc = matching text in context
# sl = selected line, cx = context line
# fn = filename, ln = line number, bn = byte offset, se = separator
export GREP_COLORS='ms=01;31:mc=01;31:sl=:cx=:fn=35:ln=32:bn=32:se=36'

# Enable grep color by default (--color=auto)
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# --- GCC Colors ---------------------------------------------------------------

# Colorize GCC compiler output (errors, warnings, notes)
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# --- diff Colors --------------------------------------------------------------

# Use colordiff if available
if command -v colordiff &>/dev/null; then
    alias diff='colordiff'
fi

# --- ip Command Colors (if iproute2 is installed) -----------------------------

# Color output for ip command
alias ip='ip --color=auto'
