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

# --- Modern JavaScript Runtimes -----------------------------------------------

# pnpm: Fast, disk space efficient package manager
export PNPM_HOME="${PNPM_HOME:-$HOME/.local/share/pnpm}"
[[ -d "$PNPM_HOME" ]] && [[ ":$PATH:" != *":$PNPM_HOME:"* ]] && export PATH="$PNPM_HOME:$PATH"

# Bun: Fast all-in-one JavaScript runtime
export BUN_INSTALL="${BUN_INSTALL:-$HOME/.bun}"
[[ -d "$BUN_INSTALL/bin" ]] && [[ ":$PATH:" != *":$BUN_INSTALL/bin:"* ]] && export PATH="$BUN_INSTALL/bin:$PATH"

# Deno: Secure JavaScript/TypeScript runtime
export DENO_INSTALL_ROOT="${DENO_INSTALL_ROOT:-$HOME/.deno}"
[[ -d "$DENO_INSTALL_ROOT/bin" ]] && [[ ":$PATH:" != *":$DENO_INSTALL_ROOT/bin:"* ]] && export PATH="$DENO_INSTALL_ROOT/bin:$PATH"

# --- Framework Telemetry (Opt-out) -------------------------------------------
# Disable telemetry for common JavaScript/TypeScript frameworks

# Turborepo: Monorepo build system
export TURBO_TELEMETRY_DISABLED="${TURBO_TELEMETRY_DISABLED:-1}"

# Next.js: React framework
export NEXT_TELEMETRY_DISABLED="${NEXT_TELEMETRY_DISABLED:-1}"

# Gatsby: Static site generator
export GATSBY_TELEMETRY_DISABLED="${GATSBY_TELEMETRY_DISABLED:-1}"

# Storybook: UI component development
export STORYBOOK_DISABLE_TELEMETRY="${STORYBOOK_DISABLE_TELEMETRY:-1}"

# Astro: Content-focused web framework
export ASTRO_TELEMETRY_DISABLED="${ASTRO_TELEMETRY_DISABLED:-1}"

# Angular CLI
export NG_CLI_ANALYTICS="${NG_CLI_ANALYTICS:-false}"

# Nuxt: Vue.js framework
export NUXT_TELEMETRY_DISABLED="${NUXT_TELEMETRY_DISABLED:-1}"

# Expo: React Native tooling
export EXPO_NO_TELEMETRY="${EXPO_NO_TELEMETRY:-1}"

# --- Build Optimization -------------------------------------------------------

# Vite: Suppress CJS compatibility warnings
export VITE_CJS_IGNORE_WARNING="${VITE_CJS_IGNORE_WARNING:-true}"

# TypeScript: Use efficient file watching
# Options: useFsEvents, useFsEventsOnParentDirectory, dynamicPriorityPolling
export TSC_WATCHFILE="${TSC_WATCHFILE:-useFsEvents}"

# esbuild: Thread count for parallel builds
export ESBUILD_WORKERS="${ESBUILD_WORKERS:-$(sysctl -n hw.ncpu)}"

# --- Git Hooks ----------------------------------------------------------------

# Husky: Git hooks framework
# Set to 0 to skip hooks (useful for scripts that commit)
# export HUSKY="${HUSKY:-1}"

# Skip Husky install in CI environments
export HUSKY_SKIP_INSTALL="${HUSKY_SKIP_INSTALL:-${CI:-0}}"

# --- Package Manager Settings -------------------------------------------------

# npm: Prefer offline packages when available
export NPM_CONFIG_PREFER_OFFLINE="${NPM_CONFIG_PREFER_OFFLINE:-true}"

# Yarn: Enable plug'n'play by default (if using Yarn 2+)
# export YARN_ENABLE_IMMUTABLE_INSTALLS="${YARN_ENABLE_IMMUTABLE_INSTALLS:-false}"

# pnpm: Disable update notifications
export PNPM_NO_UPDATE_NOTIFIER="${PNPM_NO_UPDATE_NOTIFIER:-1}"

# --- Code Generation ----------------------------------------------------------

# OpenAPI Generator: Java options for better performance
export JAVA_OPTS_OPENAPI="${JAVA_OPTS_OPENAPI:--Xmx512M}"

# GraphQL Codegen: Disable telemetry
export GRAPHQL_CODEGEN_DISABLE_TELEMETRY="${GRAPHQL_CODEGEN_DISABLE_TELEMETRY:-1}"

# --- Monorepo Tools -----------------------------------------------------------

# Nx: Disable telemetry and daemon
export NX_DAEMON="${NX_DAEMON:-true}"
export NX_SKIP_NX_CACHE="${NX_SKIP_NX_CACHE:-false}"

# Lerna: Use Nx for task running
export LERNA_USE_NX="${LERNA_USE_NX:-true}"

# --- CI/CD Detection ----------------------------------------------------------

# Allow tools to detect local development vs CI
# These are typically set by CI providers, but we ensure they're not set locally
# export CI=""
# export CONTINUOUS_INTEGRATION=""
# export BUILD_ID=""
