# Architecture Guide

This document provides a deep dive into the architecture and design philosophy of the Dotfiles Flying Circus. It is intended for developers who want to understand, maintain, or extend the installer.

## Core Design Philosophy

1.  **Staged Execution:** The installation process is broken down into a series of numbered stages (e.g., `01-`, `02-`, etc.). This makes the process predictable, repeatable, and easy to debug.

2.  **Modularity:** The installer is designed to be highly modular. Instead of having one monolithic script, the logic is broken down into small, focused files for different concerns (e.g., `system/`, `roles/`, `lib/plugins/`).

3.  **Idempotence:** The scripts are designed to be run multiple times without causing harm. They check for the existence of files, packages, and settings before attempting to create or install them.

4.  **Robustness:** The entire system is built with a "fail-fast" mentality. Scripts are designed to exit immediately and provide clear, helpful error messages when something goes wrong.

## Centralized Initialization

To ensure consistency and robustness, every executable script in the project begins by sourcing the centralized initialization script: `lib/init.sh`.

This single script is responsible for setting up the entire shell environment. It performs the following critical tasks in order:

1.  **Defines `DOTFILES_ROOT`:** It establishes the absolute path to the root of the repository, providing a reliable anchor for all other scripts.
2.  **Sources `lib/helpers.sh`:** It loads the core library that provides the logging and error-handling systems.
3.  **Sources `lib/config.sh`:** It loads the library responsible for managing role-based configurations.

This centralized approach means that every script operates in a consistent, predictable, and robust environment.

## Error Handling & Robustness

The project uses a centralized error-handling system, which is loaded by `lib/init.sh`. This system provides two key features:

1.  **Fail-Fast Mode:** The `set -eo pipefail` command ensures that any script will exit automatically if a command fails, preventing unexpected behavior and cascading errors.

2.  **Global Error Trap:** A global `trap` is set on the `ERR` signal. If any command fails unexpectedly, this trap calls a custom `error_handler` function that prints a detailed report, including the script name and the line number where the error occurred.

3.  **Graceful Exits with `die()`:** For *expected* errors (e.g., a missing dependency), scripts use the `die "message"` function to print a clean, user-friendly error message and exit gracefully.

## Logging System

The project features a powerful and flexible logging system, which is also loaded by `lib/init.sh`. This system is designed to provide deep insight into the execution flow and make debugging straightforward.

Key features include:

1.  **Log Levels:** A numerical hierarchy of log levels (`DEBUG`, `INFO`, `SUCCESS`, `WARN`, `ERROR`, `CRITICAL`) provides fine-grained control over what is displayed.
2.  **File Logging:** The `--log-file <path>` flag can be used to write all log messages to a specified file with timestamps.
3.  **Console Verbosity Control:** The `--log-level <level>` flag allows the user to control the verbosity of the console output.

## Directory Structure

-   `bin/`: Contains the main `fc` executable and other setup scripts.
-   `docs/`: Contains all project documentation.
-   `install/`: Contains the staged installation scripts.
-   `lib/`: Contains shared shell libraries, including `init.sh`.
-   `profiles/`: Contains the dotfiles and shell configuration.
-   `roles/`: Contains the role-specific configurations.
-   `system/`: Contains modular scripts for base system configuration.
-   `tests/`: Contains the Bats test files for the project.

## Shell Environment: Oh My Zsh

The shell environment is built upon **Oh My Zsh**, a popular and robust framework for managing Zsh configuration. All custom aliases, environment variables, and functions are neatly encapsulated in a single custom plugin named `circus`.

## `fc` CLI Architecture: A Plugin-Based System

The `fc` command uses a modern and highly extensible **plugin-based architecture**. The main `bin/fc` script is a pure dispatcher that discovers and executes any executable file in the `lib/plugins/` directory. For more details, see the [Creating Plugins Guide](docs/CREATING_PLUGINS.md).
