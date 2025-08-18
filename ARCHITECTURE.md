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

## Testing

The project uses `bats-core` for testing. Tests are located in the `tests/` directory.

*   **`tests/shell_config.bats`:** Tests the interactive shell environment, including the `circus` plugin, aliases, functions, and role loading.
*   **`tests/fc_commands.bats`:** Tests the `fc` command and its plugins.

## Scripting Standards and Helpers

To ensure consistency and robustness across all shell scripts in this project, we have established a set of standards and a centralized helper library.

### The Helper Library: `lib/helpers.sh`

All executable scripts (in `bin/`, `install/`, `lib/plugins/`, etc.) should source the main initialization script at `lib/init.sh`. This script, in turn, sources `lib/helpers.sh`, which provides the following key features:

1.  **Robustness (`set -eo pipefail`):** All scripts automatically run with settings that cause them to exit immediately if a command fails (`set -e`) or if a command in a pipeline fails (`set -o pipefail`). This "fail-fast" approach prevents scripts from continuing in an unpredictable state.

2.  **Global Error Trap:** A global `trap` is set on the `ERR` signal. If any command fails, it will trigger the `error_handler` function in `lib/helpers.sh`, which logs a critical error message with the script name and line number before exiting.

3.  **Standardized Logging Functions:** Instead of using `echo`, all scripts should use the following standardized logging functions. These functions provide color-coded, prefixed output and can be configured to write to a log file via the `LOG_FILE_PATH` environment variable.
    *   `msg_info "message"`: For general informational messages (blue).
    *   `msg_success "message"`: For success messages (green).
    *   `msg_warning "message"`: For warnings that don't stop execution (yellow).
    *   `msg_error "message"`: For fatal errors. Note: this does not exit the script.
    *   `die "message"`: For fatal errors. This function prints the message and immediately terminates the script with a non-zero exit code.

### Error Handling Best Practices

When writing or modifying scripts, please adhere to the following principles:

1.  **Source `lib/init.sh`:** Every executable script must source `lib/init.sh` at the beginning to inherit the helper functions and environment.
2.  **Use `die` for Fatal Errors:** For any condition that should halt the script, use `die "A clear error message."`. Do not use `msg_error "..."` followed by `exit 1`.
3.  **Check Preconditions:** Before performing an action, check that the necessary conditions are met. For example:
    *   Check for the existence of required commands with `if ! command -v "command" >/dev/null 2>&1; then die "..."; fi`.
    *   Check for the existence of required files or directories with `if [ ! -f "path" ]; then die "..."; fi`.
4.  **Provide Context:** Error messages should be clear and helpful. Explain what the script was trying to do, what went wrong, and, if possible, how the user can fix it.
