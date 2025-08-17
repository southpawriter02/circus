# Feature Proposal: 30 - Dotfile Profiles

## 1. Feature Overview

This feature introduces the concept of "dotfile profiles," allowing a user to switch between different sets of configurations quickly. For example, a user could have a `work` profile with their corporate git configuration and a `personal` profile for their own projects.

**User Benefit:** Eliminates the need for complex, conditional logic within dotfiles (e.g., `if [ "$HOSTNAME" = "work-laptop" ]`). It provides a clean and explicit way to manage context-specific configurations, making it easy to switch between different work environments.

## 2. Design & Modularity

*   **Profile Directory Structure:** A new top-level directory, `profiles/`, will be created. Inside, sub-directories for each profile (e.g., `profiles/work/`, `profiles/personal/`) will contain the configuration files specific to that profile.
*   **`fc profile switch <name>` command:** This new command will be the primary way to switch profiles. When executed, it will:
    1.  Read the current profile from a state file (e.g., `~/.config/circus/current_profile`).
    2.  Symlink the dotfiles from the new profile's directory into the user's home directory, overwriting the previous profile's symlinks.
*   **Layered Configurations:** The system will support layered configurations. A `profiles/base/` directory will contain settings common to all profiles. When switching to a profile, the `base` configuration is applied first, and then the specific profile's configuration is applied on top, overwriting any conflicting files.
*   **Role Integration:** This concept is similar to "roles" but more dynamic. A profile could be a combination of multiple roles.

## 3. Security Considerations

*   **Sensitive Data:** Users must be careful not to commit sensitive data (e.g., work credentials) into the dotfiles repository, even in a separate profile. The use of a secrets manager is still the recommended approach for this.
*   **File Permissions:** The `fc profile switch` command will need to ensure that all created symlinks have the correct permissions.

## 4. Documentation Plan

*   **New Guide:** A new, detailed guide, `docs/PROFILES.md`, will be created to explain the concept of profiles, how to create them, and how to use them.
*   **`COMMANDS.md`:** The new `fc profile` command will be documented.
*   **`README.md`:** The concept of profiles will be introduced in the main `README.md`.

## 5. Implementation Plan

1.  **Directory Structure:** Reorganize the repository to create the `profiles/` directory and a `profiles/base/` directory with the common dotfiles.
2.  **Create `fc-profile` command:** Develop the new command in `lib/commands/`.
3.  **Implement Switch Logic:** Write the core logic for the `switch` sub-command, which handles the symlinking of the dotfiles.
4.  **State Management:** Implement a way to track the currently active profile.
5.  **Refactor Existing Dotfiles:** Move existing dotfiles into the `profiles/base/` directory and create example `work` and `personal` profiles.
6.  **Testing:** Add `bats` tests to verify that switching profiles correctly creates and updates symlinks.
7.  **Documentation:** Create the `docs/PROFILES.md` guide and update other documentation.
