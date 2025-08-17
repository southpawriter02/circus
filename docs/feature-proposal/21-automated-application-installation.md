# Feature Proposal: 21 - Automated Application Installation

## 1. Feature Overview

This feature introduces a new command, `fc install-apps`, that automates the installation of macOS applications based on a user-defined list. This allows for consistent, repeatable, and automated setup of a user's required applications, both from Homebrew Cask and the Mac App Store.

**User Benefit:** Users can define all their required applications in a single configuration file and have the framework install them with a single command. This is invaluable for setting up a new machine or ensuring a consistent environment across multiple machines.

## 2. Design & Modularity

*   **Configuration:** A new configuration file, `~/.config/circus/apps.conf`, will be introduced. This file will list applications to be installed, separated into sections for `brew_cask` and `mas`.
*   **Command Structure:**
    *   `fc install-apps`: Installs all applications from the `apps.conf` file.
    *   `fc install-apps --cask <app>`: Installs a single application via Homebrew Cask.
    *   `fc install-apps --mas <app>`: Installs a single application from the Mac App Store.
*   **Modularity:** The logic for Homebrew and `mas` installations will be kept in separate helper functions to make the code clean and maintainable.

## 3. Security Considerations

*   **Application Trust:** The user is responsible for trusting the applications they list in their `apps.conf`. The script will only install from official sources (Homebrew Cask, Mac App Store).
*   **Dependency Trust:** This feature relies on `brew` and `mas-cli`. These will be installed from trusted sources as part of the core framework setup.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc install-apps` command and its options will be documented.
*   **New Guide:** A new guide, `docs/APPLICATION_INSTALLATION.md`, will be created to explain how to create and use the `apps.conf` file.
*   **Inline Comments:** The new `fc-install-apps` script will be well-commented.

## 5. Implementation Plan

1.  **Dependency:** Ensure `mas-cli` is part of the base `Brewfile` installation.
2.  **Configuration:** Create an `apps.conf.template` file.
3.  **Create `fc-install-apps`:** Develop the new command script in `lib/commands/`.
4.  **Helper Functions:** Implement helper functions for `brew` and `mas` installation logic in `lib/helpers.sh`.
5.  **Testing:** Add `bats` tests for the new command.
6.  **Documentation:** Update `COMMANDS.md` and create the new guide.
