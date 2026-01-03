# ==============================================================================
# Personal Environment Variables
#
# Environment settings for personal use, including preferences for
# personal projects, media, and casual computing.
#
# USAGE:
#   These variables are set when the personal role is active.
# ==============================================================================

# --- Personal Directories -----------------------------------------------------

# Personal projects
export PERSONAL_PROJECTS="${PERSONAL_PROJECTS:-$HOME/Projects/personal}"

# Downloads organization
export DOWNLOADS_DIR="${DOWNLOADS_DIR:-$HOME/Downloads}"

# Media directories
export MUSIC_DIR="${MUSIC_DIR:-$HOME/Music}"
export MOVIES_DIR="${MOVIES_DIR:-$HOME/Movies}"
export PICTURES_DIR="${PICTURES_DIR:-$HOME/Pictures}"

# Create directories if they don't exist
[[ -d "$PERSONAL_PROJECTS" ]] || mkdir -p "$PERSONAL_PROJECTS"

# --- Default Applications -----------------------------------------------------

# Preferred browser for personal use
export BROWSER="${BROWSER:-open}"

# Default media player
export VIDEO_PLAYER="${VIDEO_PLAYER:-IINA}"

# --- Gaming & Entertainment ---------------------------------------------------

# Steam (if installed)
export STEAM_DIR="${STEAM_DIR:-$HOME/Library/Application Support/Steam}"

# --- Less Strict Security Settings --------------------------------------------

# Longer session timeout (or disable) for personal machines
unset TMOUT

# --- Personal Cloud Storage ---------------------------------------------------

# iCloud Drive
export ICLOUD_DRIVE="$HOME/Library/Mobile Documents/com~apple~CloudDocs"

# Dropbox (if installed)
export DROPBOX_DIR="${DROPBOX_DIR:-$HOME/Dropbox}"

# Google Drive (if installed)
export GOOGLE_DRIVE="${GOOGLE_DRIVE:-$HOME/Google Drive}"

# --- Media Tools Configuration ------------------------------------------------

# yt-dlp output directory
export YTDLP_OUTPUT_DIR="${YTDLP_OUTPUT_DIR:-$HOME/Downloads/Videos}"

# Preferred video format for yt-dlp
export YTDLP_FORMAT="${YTDLP_FORMAT:-bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best}"

# --- Personal Git Configuration -----------------------------------------------

# Personal GitHub username (for quick cloning)
# export GITHUB_USER="your-username"

# Personal email for git (can override work email)
# export GIT_AUTHOR_EMAIL="personal@email.com"
# export GIT_COMMITTER_EMAIL="personal@email.com"

# --- Homebrew for Personal Use ------------------------------------------------

# Allow analytics on personal machine (optional, supports open source)
# unset HOMEBREW_NO_ANALYTICS

# Auto-update is fine on personal machine
unset HOMEBREW_NO_AUTO_UPDATE

# --- Language/Locale ----------------------------------------------------------

# Personal locale settings (adjust as needed)
# export LANG="en_US.UTF-8"
# export LC_ALL="en_US.UTF-8"

# --- Relaxed Development Settings ---------------------------------------------

# Python: Allow pip install without venv on personal machine
# unset PIP_REQUIRE_VIRTUALENV

# Node: Development mode
export NODE_ENV="${NODE_ENV:-development}"

# --- Personal API Keys (loaded from secure storage) --------------------------

# Load personal API keys from secure file if it exists
# NEVER commit API keys to version control!
PERSONAL_SECRETS="$HOME/.config/circus/personal-secrets.env"
if [[ -f "$PERSONAL_SECRETS" ]]; then
    # shellcheck source=/dev/null
    source "$PERSONAL_SECRETS"
fi

# --- Fun Stuff ----------------------------------------------------------------

# Fortune on new shell (if installed)
# if command -v fortune &>/dev/null; then
#     fortune
# fi

# Cowsay greeting (if installed)
# if command -v cowsay &>/dev/null; then
#     echo "Welcome back!" | cowsay -f tux
# fi
