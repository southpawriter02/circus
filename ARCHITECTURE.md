# Project Architecture

This document provides a high-level overview of the architecture for the `fc` command-line utility and its related components.

## Core Dispatcher: `bin/fc`

The main entry point for all functionality is the `bin/fc` script. This script is designed as a **dispatcher**. Its primary responsibilities are:

1.  **Initialization:** It sources a global `lib/init.sh` script to set up a consistent environment, including loading helper functions and configuration variables.
2.  **Plugin Discovery:** It scans the `lib/plugins/` directory for executable files. Each executable file in this directory is treated as a subcommand.
3.  **Command Execution:** It identifies the requested subcommand, validates that a corresponding plugin exists, and then executes the plugin script, passing along all subsequent arguments.
4.  **Help Generation:** It dynamically generates the main help message (`fc --help`) by listing the available plugins.

## Plugin-Based Commands

All subcommands for `fc` are implemented as **plugins**. A plugin is simply an executable script located in the `lib/plugins/` directory.

### Key Characteristics:

*   **Standalone:** Each plugin is a self-contained script responsible for a single piece of functionality (e.g., `fc-wifi`, `fc-backup`).
*   **Permissions:** A file is only recognized as a plugin if it has execute permissions (`+x`).
*   **Naming:** By convention, plugins are named `fc-<command_name>`. The dispatcher is executed as `fc <command_name>`.

This architecture makes the system highly extensible. New commands can be added by simply creating a new executable file in the `lib/plugins/` directory, with no modification to the core dispatcher required.

## Helper Scripts and Configuration

*   **`lib/helpers.sh`:** A collection of reusable shell functions (e.g., for logging, user prompts, and validation) that can be sourced and used by any plugin.
*   **`lib/config.sh`:** Defines global configuration variables and settings.
*   **`lib/init.sh`:** A script sourced by the dispatcher and potentially by plugins to ensure a consistent environment. It loads helpers, configuration, and performs any necessary setup.

## Testing

The project uses `bats-core` for testing. Tests are located in the `tests/` directory. The primary test suite for the `fc` command and its plugins is `tests/fc_commands.bats`.
