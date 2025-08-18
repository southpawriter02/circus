# Architecture Guide

This document provides a deep dive into the architecture and design philosophy of the Dotfiles Flying Circus. It is intended for developers who want to understand, maintain, or extend the installer.

## Installer Design Philosophy

The installer is built on three core principles:

1.  **Staged Execution:** The installation process is broken down into a series of numbered stages (e.g., `01-`, `02-`, etc.). This makes the process predictable, repeatable, and easy to debug. The order of these stages is defined in the `INSTALL_STAGES` array in the main `install.sh` script.

2.  **Modularity:** The installer is designed to be highly modular. Instead of having one monolithic script, the logic is broken down into small, focused files. For user-configurable settings, the installer uses an orchestrator pattern with dedicated directories (`/system`, `/defaults`, `/security`). To add a new power management setting, for example, you simply edit the script in `/system`; you don't need to touch the core installer logic.

3.  **Idempotence:** The scripts are designed to be run multiple times without causing harm. They check for the existence of files, packages, and settings before attempting to create or install them. This makes the installer safe to re-run to update a system.

## Execution Flow

The installation process begins with the `install.sh` script itself.

1.  **`install.sh` (The Orchestrator):** This is the main installer. It performs the following actions:
    *   Parses command-line arguments (like `--dry-run` or `--silent`).
    *   Sources the helper and configuration libraries (`/lib`).
    *   Iterates through the `INSTALL_STAGES` array, sourcing each stage script in its logical order.

## Directory Structure

-   `bin/`: Contains the main `fc` executable for the custom CLI.
-   `docs/`: Contains all project documentation.
-   `install/`: Contains the staged installation scripts.
-   `lib/`: Contains shared shell libraries.
    -   `lib/plugins/`: Contains all the executable plugin scripts for the `fc` command.
-   `profiles/`: Contains the dotfiles themselves, organized by shell (`sh`, `bash`, `zsh`).
-   `roles/`: Contains the role-specific configurations.
-   `system/`: Contains modular scripts for base system configuration.
-   `tests/`: Contains the Bats test files for the project.

## `fc` CLI Architecture: A Plugin-Based System

The `fc` command uses a modern and highly extensible **plugin-based architecture**.

1.  The main `bin/fc` script is a pure **dispatcher**. Its only job is to find and execute the correct plugin.
2.  It scans the `lib/plugins/` directory for any **executable file**.
3.  Each executable file found in this directory is automatically registered as a subcommand. For example, the script `lib/plugins/info` is available as `fc info`.
4.  The dispatcher then transfers control to the plugin script, passing along all subsequent arguments.

This pattern makes the CLI incredibly easy to extend. To add a new command, you simply create a new executable file in the `lib/plugins/` directory. For more details, see the [Creating Plugins Guide](CREATING_PLUGINS.md).
