# ==============================================================================
# Pager Configuration
#
# Configure less, man, and other pagers for better readability.
# ==============================================================================

# --- Less Options -------------------------------------------------------------

# -R : Output raw control characters (enables colors)
# -F : Quit if content fits on one screen
# -X : Don't clear screen on exit
# -S : Chop long lines (don't wrap)
# -i : Ignore case in searches (unless uppercase used)
# -M : Long prompt (shows percentage through file)
# -x4: Set tab stops to 4 spaces
export LESS="-RFXSiMx4"

# --- Less Input Preprocessor --------------------------------------------------

# Use lesspipe for viewing compressed files, archives, etc.
# Install with: brew install lesspipe
if [[ -x /opt/homebrew/bin/lesspipe.sh ]]; then
    export LESSOPEN="|/opt/homebrew/bin/lesspipe.sh %s"
elif [[ -x /usr/local/bin/lesspipe.sh ]]; then
    export LESSOPEN="|/usr/local/bin/lesspipe.sh %s"
fi

# --- Less History -------------------------------------------------------------

# Store less search history
export LESSHISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/less/history"

# Create directory if it doesn't exist
[[ -d "${XDG_STATE_HOME:-$HOME/.local/state}/less" ]] || mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/less"

# --- Man Pages Pager ----------------------------------------------------------

# Use less with specific options for man pages
export MANPAGER="less -X"

# Alternative: Use bat as man pager (if installed)
# if command -v bat &>/dev/null; then
#     export MANPAGER="sh -c 'col -bx | bat -l man -p'"
# fi

# --- Bat Configuration (cat replacement) -------------------------------------

# Theme for bat (cat replacement with syntax highlighting)
# Popular themes: TwoDark, Dracula, GitHub, Monokai Extended
export BAT_THEME="TwoDark"

# Style options: numbers, changes, header, grid, snip, full
export BAT_STYLE="numbers,changes,header"

# Use bat as cat if available
if command -v bat &>/dev/null; then
    alias cat='bat --paging=never'
fi
