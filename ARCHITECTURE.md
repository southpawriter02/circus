# Project Architecture

This document provides a high-level overview of the architecture for the Dotfiles Flying Circus, covering both the interactive shell environment and the `fc` command-line utility.

## Shell Configuration

The shell environment is built upon the **Oh My Zsh** framework, providing a robust and community-maintained foundation. All custom configurations are encapsulated within a dedicated plugin and a role-based system.

### Core Components

*   **Oh My Zsh:** The core framework that manages the Zsh configuration, including plugins and themes. It is installed by the main installer into `~/.oh-my-zsh`.
*   **`.zshrc`:** The main Zsh configuration file, located at `~/.zshrc`. This file is a simple stub that is responsible for loading the Oh My Zsh framework and enabling the necessary plugins. It is managed via a symlink to `profiles/zsh/zshrc.symlink` in this repository.
*   **`circus` Plugin:** A custom Oh My Zsh plugin that contains all the core, non-role-specific shell configurations. This includes common aliases, environment variables, and shell functions. It is located in `profiles/zsh/oh-my-zsh-custom/circus` and is symlinked into the Oh My Zsh custom plugins directory during installation.

### Role-Based Configuration

To support different machine setups (e.g., `developer`, `personal`), the system uses a role-based architecture.

1.  **State File:** After a successful installation, the installer records the chosen role in a state file at `~/.circus/role`. It also records the path to the dotfiles repository in `~/.circus/root`.
2.  **Dynamic Loading:** The `circus` plugin reads these state files at shell startup.
3.  **Sourcing:** If a role is defined, the plugin will source all the `.sh` files from the corresponding `roles/<role_name>/aliases/` and `roles/<role_name>/env/` directories.

This approach keeps the core shell configuration clean and allows for easy extension and customization for different contexts.

## `fc` Command-Line Utility

The `fc` command is an extensible utility for managing various aspects of the system.

### Core Dispatcher: `bin/fc`

The main entry point for all functionality is the `bin/fc` script. This script is designed as a **dispatcher**. Its primary responsibilities are:

1.  **Initialization:** It sources a global `lib/init.sh` script to set up a consistent environment, including loading helper functions and configuration variables.
2.  **Plugin Discovery:** It scans the `lib/plugins/` directory for executable files. Each executable file in this directory is treated as a subcommand.
3.  **Command Execution:** It identifies the requested subcommand, validates that a corresponding plugin exists, and then executes the plugin script, passing along all subsequent arguments.
4.  **Help Generation:** It dynamically generates the main help message (`fc --help`) by listing the available plugins.

### Plugin-Based Commands

All subcommands for `fc` are implemented as **plugins**. A plugin is simply an executable script located in the `lib/plugins/` directory. This makes the system highly extensible.

## Installer Architecture

The main installer (`install.sh`) uses a stage-based architecture for modular, maintainable installation logic.

### Stage-Based Design

The installer executes a sequence of independent stage scripts from the `install/` directory. Each stage is responsible for a specific aspect of the installation and can be tested in isolation.

```
install.sh (orchestrator)
    ├── 00-preflight-checks.sh      → System readiness verification
    ├── 01-introduction.sh          → Welcome and user preferences
    ├── 02-logging-setup.sh         → Log file configuration
    ├── 03-homebrew-installation.sh → Homebrew and packages
    ├── 04-macos-system-settings.sh → System preferences
    ├── 05-oh-my-zsh-installation.sh→ Shell framework
    ├── 06-repository-management.sh → Git sync and submodules
    ├── 09-dotfiles-deployment.sh   → Symlink configuration files
    ├── 10-git-configuration.sh     → Git preferences
    ├── 11-defaults-and-additional.sh → Additional settings
    ├── 14-cleanup.sh               → Temporary file removal
    ├── 15-finalization.sh          → Installation report
    ├── 16-jetbrains-configuration.sh → IDE setup
    ├── 17-secrets-management.sh    → Credential setup
    └── 18-privacy-and-security.sh  → Security settings
```

### Stage Execution Flow

1. **Argument Parsing:** Command-line flags (`--role`, `--dry-run`, `--log-level`, etc.) are parsed.
2. **Stage Iteration:** The `INSTALL_STAGES` array defines the execution order.
3. **Per-Stage Execution:**
   - Display stage header with progress indicator
   - Source the stage script
   - Record timing and completion status
4. **State Recording:** After success, installation state is saved to `~/.circus/`.

### Preflight Checks System

Stage 00 runs 21 modular preflight checks from `install/preflight/`:

| Check | Purpose | Critical |
|-------|---------|----------|
| preflight-01-macos-check.sh | Verify running on macOS | Yes |
| preflight-02-root-check.sh | Not running as root | Yes |
| preflight-03-admin-rights-check.sh | Admin privileges available | Yes |
| preflight-04-file-permissions-check.sh | Installer permissions | No |
| preflight-05-unset-vars-check.sh | Environment sanity | No |
| preflight-06-shell-type-version-check.sh | Bash/Zsh version | No |
| preflight-07-locale-encoding-check.sh | UTF-8 encoding | No |
| preflight-08-battery-check.sh | Adequate power | No |
| preflight-09-wifi-check.sh | Network connectivity | No |
| preflight-10-xcode-cli-check.sh | Xcode CLI tools installed | Yes |
| preflight-11-homebrew-check.sh | Homebrew status | No |
| preflight-12-dependency-check.sh | Required dependencies | No |
| preflight-13-install-integrity-check.sh | Repository integrity | Yes |
| preflight-14-update-check.sh | Update availability | No |
| preflight-15-existing-install-check.sh | Previous installation | No |
| preflight-16-backed-up-dotfiles-check.sh | Backup status | No |
| preflight-17-existing-dotfiles-check.sh | Conflict detection | No |
| preflight-18-icloud-check.sh | iCloud sync status | No |
| preflight-19-terminal-type-check.sh | Terminal compatibility | No |
| preflight-20-conflicting-processes-check.sh | Process conflicts | No |
| preflight-21-install-sanity-check.sh | Final sanity check | Yes |

Critical checks must pass; non-critical checks produce warnings but don't block installation.

### Role System

Roles define machine-specific configurations:

- **developer:** Full development environment with all tools
- **personal:** Personal machine with consumer apps
- **work:** Work environment with corporate tools

Role selection is stored in `~/.circus/role` and used by the shell configuration to load role-specific aliases and environment variables.

### State Management

Installation state is persisted in `~/.circus/`:

| File | Purpose |
|------|---------|
| `~/.circus/root` | Path to dotfiles repository |
| `~/.circus/role` | Installed role (developer/personal/work) |
| `~/.circus/privacy_profile` | Privacy level (standard/privacy/lockdown) |

### Dry-Run Mode

When `--dry-run` is passed, stages can check `$DRY_RUN_MODE` to skip destructive operations:

```bash
if [ "$DRY_RUN_MODE" = true ]; then
  msg_info "[DRY-RUN] Would install packages..."
else
  brew bundle install
fi
```

### Adding New Stages

1. Create a new script in `install/` with appropriate numbering
2. Add an entry to the `INSTALL_STAGES` array in `install.sh`
3. Implement a `main()` function that respects `DRY_RUN_MODE`
4. Add tests to `tests/installer_stages.bats`

## Testing

The project uses `bats-core` for testing. Tests are located in the `tests/` directory.

*   **`tests/shell_config.bats`:** Tests the interactive shell environment, including the `circus` plugin, aliases, functions, and role loading.
*   **`tests/fc_commands.bats`:** Tests the `fc` command and its plugins.
*   **`tests/installer_stages.bats`:** Tests all 15 installer stages in dry-run mode.
*   **`tests/preflight_checks.bats`:** Tests all 21 preflight check scripts.

## Centralized Script Initialization

To ensure consistency and robustness across all shell scripts in this project, we have established a centralized initialization process.

### The `lib/init.sh` Entry Point

All executable scripts (in `bin/`, `install/`, `lib/plugins/`, etc.) **must** source the main initialization script at `lib/init.sh` as their first action. This script is the single entry point for setting up a consistent shell environment.

Sourcing `lib/init.sh` provides the following:

1.  **Global Constants:** Defines critical environment variables like `DOTFILES_ROOT`, providing a reliable anchor for pathing.
2.  **Configuration Loading:** Sources `lib/config.sh` to load role-based configurations.
3.  **Helper Library:** Sources `lib/helpers.sh`, which provides:
    *   **Robustness (`set -eo pipefail`):** Scripts will exit immediately if a command fails.
    *   **Global Error Trap:** A global `trap` is set on the `ERR` signal to catch and report unexpected errors with context (script name and line number).
    *   **Standardized Logging Functions:** A suite of `msg_*` functions (`msg_info`, `msg_success`, `msg_error`, etc.) for consistent, color-coded logging.
    *   **The `die` command:** A function to immediately terminate the script with a clear error message.

### Scripting Best Practices

When writing or modifying scripts, please adhere to the following principles:

1.  **Source `lib/init.sh` First:** Every executable script must begin by sourcing `lib/init.sh`:
    ```bash
    source "$(dirname "${BASH_SOURCE[0]}")/path/to/lib/init.sh"
    ```
2.  **Use `die` for Fatal Errors:** For any condition that should halt the script, use `die "A clear error message."`. Do not use `msg_error "..."` followed by `exit 1`.
3.  **Check Preconditions:** Before performing an action, check that the necessary conditions are met (e.g., required commands or files exist).
4.  **Provide Context:** Error messages should be clear and helpful.
