# ==============================================================================
# Node.js Configuration
#
# Environment variables for Node.js and npm development.
# ==============================================================================

# --- Node.js Runtime ----------------------------------------------------------

# Increase Node.js memory limit (default 512MB is often too low)
# Adjust based on your system's available memory
export NODE_OPTIONS="--max-old-space-size=4096"

# Enable experimental features if needed
# export NODE_OPTIONS="$NODE_OPTIONS --experimental-vm-modules"

# --- npm Configuration --------------------------------------------------------

# npm global prefix (avoid system directories)
export NPM_CONFIG_PREFIX="${NPM_CONFIG_PREFIX:-$HOME/.npm-global}"

# Disable npm update notifier (annoying in scripts)
export NO_UPDATE_NOTIFIER=1

# --- Node REPL ----------------------------------------------------------------

# Node REPL history file
export NODE_REPL_HISTORY="${XDG_STATE_HOME:-$HOME/.local/state}/node/repl_history"

# Maximum REPL history entries
export NODE_REPL_HISTORY_SIZE=10000

# --- pnpm Configuration -------------------------------------------------------

# pnpm home directory
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"

# --- Yarn Configuration -------------------------------------------------------

# Yarn global folder
export YARN_GLOBAL_FOLDER="${XDG_DATA_HOME:-$HOME/.local/share}/yarn/global"

# --- Bun Configuration --------------------------------------------------------

# Bun install directory
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"

# --- nvm Configuration --------------------------------------------------------

# nvm directory
export NVM_DIR="${NVM_DIR:-$HOME/.nvm}"

# Load nvm if installed (lazy loading for faster shell startup)
# Note: Full nvm loading is handled in the nvm defaults script
# This just sets the variable for scripts that need it
