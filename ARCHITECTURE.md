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
