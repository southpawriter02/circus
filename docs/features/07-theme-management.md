# Feature: 07 - Theme Management

## 1. Feature Overview

This feature will add a new `fc theme` command to manage and switch between different shell and editor themes. It would work by managing a collection of theme files and creating the necessary symlinks to activate a chosen theme.

**User Benefit:** Allows users to easily customize the look and feel of their environment and switch between different themes (e.g., a "light" theme for daytime and a "dark" theme for nighttime) with a single command.

## 2. Design & Modularity

*   **Theme Directory:** A new top-level `themes/` directory will be created. Each subdirectory within `themes/` will represent a single theme (e.g., `themes/solarized-dark/`).
*   **Theme Structure:** Each theme directory will contain configuration files for different applications (e.g., `zshrc`, `vimrc`, `itermcolors`).
*   **Symlink-Based Activation:** The `fc theme apply` command will symlink the files from the chosen theme's directory to their target locations (e.g., `~/.zshrc.theme`, which would then be sourced by the main `.zshrc`).
*   **Command Structure:**
    *   `fc theme list`: Shows available themes.
    *   `fc theme apply <theme-name>`: Activates the specified theme.
    *   `fc theme status`: Shows the currently active theme.

## 3. Security Considerations

*   **Theme Content:** Themes are just configuration files, so the security risk is low. However, the documentation will advise users to only install themes from trusted sources, as they could potentially contain malicious shell commands.
*   **File Overwrites:** The `apply` command will not overwrite user's main configuration files. Instead, it will manage theme-specific partial files (e.g., `.zshrc.theme`) that are sourced by the user's main configs.

## 4. Documentation Plan

*   **`COMMANDS.md`:** A new section for `fc theme` will be added.
*   **New Guide:** A new `docs/THEMES.md` guide will be created to explain how to use the theme manager and how to create new themes.
*   **Inline Comments:** The `fc-theme` script will be well-commented.

## 5. Implementation Plan

1.  **Create `themes/` Directory:** Create the directory and populate it with one or two example themes.
2.  **Command Script:** Create the `lib/commands/fc-theme` script.
3.  **Implement `list`:** Logic to scan the `themes/` directory.
4.  **Implement `apply`:** Logic to create the necessary symlinks for a given theme.
5.  **Implement `status`:** Logic to check the current symlinks and determine the active theme.
6.  **Modify Shell Configs:** Update the main `.zshrc` and `.bashrc` to source the theme-specific file if it exists.
7.  **Testing:** Add `bats` tests to verify that themes are applied correctly.
8.  **Documentation:** Update `COMMANDS.md` and create `docs/THEMES.md`.
