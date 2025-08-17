# Dotfiles Guide

This document explains the purpose of the various dotfiles used in this repository and the order in which they are loaded by the Zsh shell.

## Zsh Startup & Shutdown Order

Understanding the Zsh startup sequence is crucial for knowing where to place your configurations. Zsh sources a series of files upon startup, and the type of shell (login vs. interactive) determines which files are read.

Here is the order of execution for a **login shell** (the kind you get when you first open a new terminal window):

1.  **`.zshenv`**: Sourced on **all** shell invocations, both login and interactive. It is the most reliable place to define environment variables (like `$EDITOR` or `$PATH`) that need to be available to all programs, including those run non-interactively.

2.  **`.zprofile`**: Sourced for **login shells only**, after `.zshenv`. It is traditionally used for commands that should be executed only once at the beginning of a session, such as starting services or printing system information.

3.  **`.zshrc`**: Sourced for **interactive shells only**, after `.zprofile`. This is where you should define settings that are specific to the interactive experience, such as aliases, functions, key bindings, and your shell prompt.

4.  **`.zlogin`**: Sourced for **login shells only**, after `.zshrc`. It is similar to `.zprofile` but runs later. It's a good place for a welcome message or other commands to run at the very end of the startup process.

5.  **`.zlogout`**: Sourced when a **login shell exits**. This is the place for any cleanup commands, such as clearing the screen or deleting temporary files.

## File-by-File Purpose

This repository organizes dotfiles into the `profiles/` directory, with subdirectories for each shell.

### Generic Shell (`profiles/sh`)

These files are POSIX-compliant and are designed to be sourced by both Bash and Zsh.

-   **`.profile`**: A fallback file, typically sourced by Bash for login shells.
-   **`.shenv`**: Sourced by both Bash and Zsh to set environment variables.
-   **`.shell_aliases`**: Contains aliases that are common to both shells.
-   **`.shell_functions`**: Contains functions that are common to both shells.
-   **`.shell_paths`**: Manages the `$PATH` environment variable.

### Zsh (`profiles/zsh`)

These files contain Zsh-specific configurations.

-   **`.zshenv`**: Sets the `$DOTFILES_DIR` variable and sources the generic `.shenv`.
-   **`.zshrc`**: The main entry point for interactive shells. It sources the generic shell files and the other Zsh-specific files.
-   **`.zprofile`**: Sourced for login shells. Can be used for session-specific tasks.
-   **`.zlogin`**: Sourced at the end of the login process. We use it to display a welcome message.
-   **`.zlogout`**: Sourced on shell exit.
-   **`.zoptions`**: Contains Zsh-specific shell options (e.g., history settings, completion options).
-   **`.zprompt`**: Contains the configuration for the shell prompt.
