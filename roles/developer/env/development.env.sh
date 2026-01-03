# ==============================================================================
# Development Environment Variables
#
# Core environment settings for developer workflow including editor preferences,
# project directories, and development tool configurations.
#
# USAGE:
#   These variables are automatically set when the developer role is active.
# ==============================================================================

# --- Editor Configuration -----------------------------------------------------

# Default editor for git, command-line tools, etc.
# Options: nvim, vim, code, cursor, nano, emacs
export EDITOR="${EDITOR:-nvim}"
export VISUAL="${VISUAL:-$EDITOR}"

# Git editor (inherits from EDITOR if not set)
export GIT_EDITOR="${GIT_EDITOR:-$EDITOR}"

# Sudo editor (for sudoedit/visudo)
export SUDO_EDITOR="${SUDO_EDITOR:-$EDITOR}"

# --- Project Directories ------------------------------------------------------

# Base directory for projects
export PROJECTS_DIR="${PROJECTS_DIR:-$HOME/Projects}"

# GitHub repositories
export GITHUB_DIR="${GITHUB_DIR:-$HOME/Documents/GitHub}"

# Work projects (if separate)
export WORK_DIR="${WORK_DIR:-$HOME/Work}"

# Create directories if they don't exist
[[ -d "$PROJECTS_DIR" ]] || mkdir -p "$PROJECTS_DIR"
[[ -d "$GITHUB_DIR" ]] || mkdir -p "$GITHUB_DIR"

# --- Code Quality Tools -------------------------------------------------------

# ESLint: Show config location warnings
export ESLINT_USE_FLAT_CONFIG="${ESLINT_USE_FLAT_CONFIG:-true}"

# Prettier: Default configuration
export PRETTIER_DEFAULT_PARSER="${PRETTIER_DEFAULT_PARSER:-babel}"

# --- Build Tool Settings ------------------------------------------------------

# Make: Parallel jobs (use all available cores)
export MAKEFLAGS="${MAKEFLAGS:--j$(sysctl -n hw.ncpu)}"

# CMake: Default generator
export CMAKE_GENERATOR="${CMAKE_GENERATOR:-Ninja}"

# Ninja: Parallel jobs
export NINJA_JOBS="${NINJA_JOBS:-$(sysctl -n hw.ncpu)}"

# --- Terminal Settings --------------------------------------------------------

# Force 256 colors in terminal
export TERM="${TERM:-xterm-256color}"

# Enable colored GCC output
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# --- Git Behavior -------------------------------------------------------------

# Default branch name for new repos
export GIT_DEFAULT_BRANCH="${GIT_DEFAULT_BRANCH:-main}"

# Enable Git column output
export GIT_PAGER="${GIT_PAGER:-less}"

# --- Debugging Helpers --------------------------------------------------------

# Bash: Print commands as they execute (uncomment for debugging)
# set -x

# Trace command execution time (uncomment for debugging)
# export PS4='+$(date "+%s.%N")\011 '

# --- Language Server Protocol (LSP) ------------------------------------------

# Enable LSP logging (useful for debugging editor integrations)
# export NVIM_LSP_LOG_LEVEL="${NVIM_LSP_LOG_LEVEL:-warn}"

# --- Miscellaneous Development Settings ---------------------------------------

# Homebrew: No auto-update during installs (faster)
export HOMEBREW_NO_AUTO_UPDATE="${HOMEBREW_NO_AUTO_UPDATE:-1}"

# Homebrew: Disable analytics (already in telemetry.env.sh but ensure for dev)
export HOMEBREW_NO_ANALYTICS="${HOMEBREW_NO_ANALYTICS:-1}"

# Disable hints for zsh
export ZSH_DISABLE_COMPFIX="${ZSH_DISABLE_COMPFIX:-true}"
