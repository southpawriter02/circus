# Architecture Guide

This document provides a deep dive into the architecture and design philosophy of the Dotfiles Flying Circus. It is intended for developers who want to understand, maintain, or extend the installer.

## Installer Design Philosophy

The installer is built on three core principles:

1.  **Staged Execution:** The installation process is broken down into a series of numbered stages (e.g., `01-`, `02-`, etc.). This makes the process predictable, repeatable, and easy to debug. The order of these stages is defined in the `INSTALL_STAGES` array in the main `install.sh` script.

2.  **Modularity:** The installer is designed to be highly modular. Instead of having one monolithic script, the logic is broken down into small, focused files. For user-configurable settings, the installer uses an orchestrator pattern with dedicated directories (`/system`, `/defaults`, `/security`). To add a new power management setting, for example, you simply edit the script in `/system`; you don't need to touch the core installer logic.

3.  **Idempotence:** The scripts are designed to be run multiple times without causing harm. They check for the existence of files, packages, and settings before attempting to create or install them. This makes the installer safe to re-run to update a system.

## Execution Flow

The installation process begins with the `init.sh` script, which provides a crucial safety layer.

1.  **`init.sh` (The Safety Wrapper):** This script's only job is to make the main `install.sh` script executable, run it, and then use a `trap` to guarantee that `install.sh` is returned to a non-executable state upon exit. This prevents accidental runs.

2.  **`install.sh` (The Orchestrator):** This is the main installer. It performs the following actions:
    *   Parses command-line arguments (like `--dry-run`).
    *   Sources the helper and configuration libraries (`/lib`).
    *   Iterates through the `INSTALL_STAGES` array, sourcing each stage script in its logical order.

## Directory Structure

-   `bin/`: Contains the main `fc` executable for the custom CLI.
-   `defaults/`: Contains scripts that configure macOS application and system preferences using the `defaults` command.
-   `etc/`: Contains static configuration files, most importantly the `Brewfile`.
-   `install/`: Contains the staged installation scripts.
    -   `install/management/`: Modular scripts for Git repository management (Stage 5).
    -   `install/tools/`: Scripts for installing individual software packages.
    -   `install/tools/homebrew/`: Modular scripts for the Homebrew setup process.
-   `lib/`: Contains shared shell libraries.
    -   `lib/commands/`: The individual subcommand scripts for the `fc` CLI.
    -   `lib/installer_source/`: Scripts sourced by the installer to add functions/aliases to its own environment.
-   `profiles/`: Contains the dotfiles themselves, organized by shell (`sh`, `bash`, `zsh`).
-   `security/`: Contains scripts that apply security-focused configurations.
-   `system/`: Contains scripts that apply low-level system settings using commands like `pmset`.
-   `tests/`: Contains the Bats test files for the project.

## `fc` CLI Architecture

The `fc` command uses a classic **dispatcher pattern**.

1.  The main `bin/fc` script is the entry point. It does not contain any command logic itself.
2.  It inspects the first argument (e.g., `bluetooth`).
3.  It then searches for and executes a corresponding script in the `lib/commands/` directory (e.g., `lib/commands/fc-bluetooth`).
4.  All subsequent arguments are passed directly to the subcommand script.

This pattern makes the CLI incredibly easy to extend. To add a new command, you simply create a new `fc-*` file in the `lib/commands/` directory.
