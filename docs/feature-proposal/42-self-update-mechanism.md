# Feature Proposal: 42 - Self-Update Mechanism

## 1. Feature Overview

This feature introduces a dedicated and robust command, `fc self-update`, for updating the framework itself. This is an improvement over a simple `git pull`, as it can handle potential complexities of the update process.

**User Benefit:** Provides a safe and reliable way for users to keep their framework installation up-to-date with the latest features and bug fixes. A managed self-update process can prevent issues that might arise from a simple `git pull`, such as conflicts in configuration files.

## 2. Design & Modularity

*   **Update Process:** The `fc self-update` command will perform the following steps:
    1.  Check for uncommitted changes in the repository and warn the user.
    2.  Stash any local changes if the user agrees.
    3.  Fetch the latest changes from the remote Git repository.
    4.  Check for and handle any new dependencies (e.g., run `brew bundle`).
    5.  Run any necessary migration scripts if the update involves breaking changes.
    6.  Pop the stashed local changes.
*   **Migration Scripts:** For updates that require more than just a code change (e.g., renaming a configuration file), the update process will be able to run migration scripts. These scripts will be stored in a `migrations/` directory and will be executed based on a version number.
*   **`--check` flag:** A `fc self-update --check` flag will check if an update is available without installing it.

## 3. Security Considerations

*   **Git Remote:** The update is pulled from the user's configured Git remote. The user is responsible for ensuring this remote is trusted.
*   **Migration Script Trust:** The user is trusting the framework's developers to provide safe and correct migration scripts. All migrations will be clearly documented in the release notes.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The `fc self-update` command will be documented.
*   **Release Notes:** A `CHANGELOG.md` file will be maintained to document changes in each version, including any migrations.
*   **New Guide:** A `docs/UPDATING.md` guide will explain the update process in detail.

## 5. Implementation Plan

1.  **Create `fc-self-update` script:** Develop the new command in `lib/commands/`.
2.  **Implement Update Logic:** Write the shell script logic for the update process (stash, pull, etc.).
3.  **Implement Migration System:** Design and implement the system for running version-based migration scripts.
4.  **Handle Dependencies:** Add logic to check for changes in the `Brewfile` and automatically install new dependencies.
5.  **Testing:** This is difficult to test automatically. It will require a careful manual testing process for each release.
6.  **Documentation:** Create the `docs/UPDATING.md` guide and maintain the `CHANGELOG.md`.
