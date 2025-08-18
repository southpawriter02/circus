# Architecture Guide

This document provides a deep dive into the architecture and design philosophy of the Dotfiles Flying Circus. It is intended for developers who want to understand, maintain, or extend the installer.

## Core Design Philosophy

1.  **Staged Execution:** The installation process is broken down into a series of numbered stages (e.g., `01-`, `02-`, etc.). This makes the process predictable, repeatable, and easy to debug.

2.  **Modularity:** The installer is designed to be highly modular. Instead of having one monolithic script, the logic is broken down into small, focused files for different concerns (e.g., `system/`, `roles/`, `lib/plugins/`).

3.  **Idempotence:** The scripts are designed to be run multiple times without causing harm. They check for the existence of files, packages, and settings before attempting to create or install them.

4.  **Robustness:** The entire system is built with a "fail-fast" mentality. Scripts are designed to exit immediately and provide clear, helpful error messages when something goes wrong.

## Error Handling & Robustness

The project uses a centralized and robust error-handling system, implemented in `lib/helpers.sh`. This library is sourced by all major scripts and provides two key features:

1.  **Fail-Fast Mode:** The library immediately runs `set -eo pipefail`. This ensures that any script will exit automatically if a command fails, preventing unexpected behavior and cascading errors.

2.  **Global Error Trap:** The library sets a global `trap` on the `ERR` signal. If any command fails unexpectedly, this trap calls a custom `error_handler` function that prints a detailed report, including the script name and the line number where the error occurred. This makes debugging dramatically easier.

3.  **Graceful Exits with `die()`:** For *expected* errors (e.g., a missing dependency), scripts use the `die "message"` function. This prints a clean, user-friendly error message and immediately terminates the script, providing a better user experience than a raw, unexpected error.

## Directory Structure

-   `bin/`: Contains the main `fc` executable for the custom CLI.
-   `docs/`: Contains all project documentation.
-   `install/`: Contains the staged installation scripts.
-   `lib/`: Contains shared shell libraries.
    -   `lib/plugins/`: Contains all the executable plugin scripts for the `fc` command.
-   `profiles/`: Contains the dotfiles themselves.
    -   `profiles/zsh/zshrc.symlink`: The main `.zshrc` file that loads and configures Oh My Zsh.
    -   `profiles/zsh/oh-my-zsh-custom/`: The source for our custom Oh My Zsh plugin.
-   `roles/`: Contains the role-specific configurations.
-   `system/`: Contains modular scripts for base system configuration.
-   `tests/`: Contains the Bats test files for the project.

## Shell Environment: Oh My Zsh

The shell environment is built upon **Oh My Zsh**, a popular and robust framework for managing Zsh configuration. All custom aliases, environment variables, and functions are neatly encapsulated in a single custom plugin named `circus`.

## `fc` CLI Architecture: A Plugin-Based System

The `fc` command uses a modern and highly extensible **plugin-based architecture**. The main `bin/fc` script is a pure dispatcher that discovers and executes any executable file in the `lib/plugins/` directory. For more details, see the [Creating Plugins Guide](docs/CREATING_PLUGINS.md).
