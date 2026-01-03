# ==============================================================================
# Python Configuration
#
# Environment variables for Python development.
# ==============================================================================

# --- Bytecode & Output --------------------------------------------------------

# Don't write .pyc bytecode files
# Reduces disk clutter in development
export PYTHONDONTWRITEBYTECODE=1

# Force unbuffered stdout/stderr
# Useful for Docker, logging, and real-time output
export PYTHONUNBUFFERED=1

# --- pip Configuration --------------------------------------------------------

# Require virtual environment for pip install
# Prevents accidental global package installation
export PIP_REQUIRE_VIRTUALENV=true

# Disable pip version check (reduces startup time)
export PIP_DISABLE_PIP_VERSION_CHECK=1

# --- Virtual Environment Display ----------------------------------------------

# Let the shell prompt handle virtualenv display
# Prevents duplicate virtualenv indicators
export VIRTUAL_ENV_DISABLE_PROMPT=1

# --- Pipenv -------------------------------------------------------------------

# Create virtualenv in project directory (.venv)
export PIPENV_VENV_IN_PROJECT=1

# Disable Pipenv's loading bar
export PIPENV_HIDE_EMOJIS=1

# --- Poetry -------------------------------------------------------------------

# Create virtualenv in project directory
export POETRY_VIRTUALENVS_IN_PROJECT=true

# Don't ask for confirmation
export POETRY_NO_INTERACTION=1

# --- Python History -----------------------------------------------------------

# Custom Python REPL startup file
export PYTHONSTARTUP="${PYTHONSTARTUP:-$HOME/.pythonrc}"

# --- pyenv Configuration ------------------------------------------------------

# pyenv root directory
export PYENV_ROOT="${PYENV_ROOT:-$HOME/.pyenv}"

# Initialize pyenv if installed
if command -v pyenv &>/dev/null; then
    eval "$(pyenv init -)"
fi
