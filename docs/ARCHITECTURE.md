# Architecture Guide

This document provides a deep dive into the architecture and design philosophy of the Dotfiles Flying Circus. It is intended for developers who want to understand, maintain, or extend the installer.

## Installer Design Philosophy

The installer is built on three core principles:

1.  **Staged Execution:** The installation process is broken down into a series of numbered stages (e.g., `01-`, `02-`, etc.). This makes the process predictable, repeatable, and easy to debug. The order of these stages is defined in the `INSTALL_STAGES` array in the main `install.sh` script.

2.  **Modularity:** The installer is designed to be highly modular. Instead of having one monolithic script, the logic is broken down into small, focused files. For user-configurable settings, the installer uses an orchestrator pattern with dedicated directories (`/system`, `/defaults`, `/security`).

3.  **Idempotence:** The scripts are designed to be run multiple times without causing harm. They check for the existence of files, packages, and settings before attempting to create or install them. This makes the installer safe to re-run to update a system.

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

The shell environment is built upon **Oh My Zsh**, a popular and robust framework for managing Zsh configuration. This provides several key advantages:

*   **Extensibility:** We gain access to a massive ecosystem of community-developed plugins and themes.
*   **Stability:** The core of the shell environment is maintained by the large Oh My Zsh community.
*   **Clean Customization:** All of this project's custom aliases, environment variables, and functions are neatly encapsulated in a single custom plugin named `circus`, which is located in `profiles/zsh/oh-my-zsh-custom/circus`.

The installation process automatically clones the Oh My Zsh repository, symlinks the custom `circus` plugin into place, and deploys the `.zshrc` file that activates it.

## `fc` CLI Architecture: A Plugin-Based System

The `fc` command uses a modern and highly extensible **plugin-based architecture**.

1.  The main `bin/fc` script is a pure **dispatcher**. Its only job is to find and execute the correct plugin.
2.  It scans the `lib/plugins/` directory for any **executable file**.
3.  Each executable file found in this directory is automatically registered as a subcommand. For example, the script `lib/plugins/info` is available as `fc info`.
4.  The dispatcher then transfers control to the plugin script, passing along all subsequent arguments.

This pattern makes the CLI incredibly easy to extend. To add a new command, you simply create a new executable file in the `lib/plugins/` directory. For more details, see the [Creating Plugins Guide](CREATING_PLUGINS.md).
