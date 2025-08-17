# Feature Proposal: 22 - System Update Command

## 1. Feature Overview

This feature introduces a new command, `fc update`, to provide a unified and automated way to keep the system and the framework itself up-to-date. This command will handle updating macOS, Homebrew packages (formulae and casks), and the dotfiles repository.

**User Benefit:** Simplifies system maintenance by consolidating multiple update commands into a single, easy-to-use command. It helps ensure the user's environment is always running the latest and most secure software versions.

## 2. Design & Modularity

*   **Command Structure:**
    *   `fc update`: Runs all update tasks in a predefined order (e.g., repo, Homebrew, macOS).
    *   `fc update --os`: Specifically checks for and initiates macOS updates.
    *   `fc update --packages`: Updates all Homebrew formulae and casks.
    *   `fc update --self`: Pulls the latest changes for the dotfiles repository.
*   **Modularity:** Each update task (macOS, Homebrew, repo) will be implemented in its own helper function for clarity and maintainability.
*   **Configuration:** Users can configure the behavior of `fc update` in `~/.config/circus/update.conf`, for example, to exclude certain packages from being updated.

## 3. Security Considerations

*   **Update Sources:** All updates will be pulled from official and trusted sources (Apple's software update servers, Homebrew's official repositories, the user's own dotfiles git remote).
*   **User Confirmation:** For major macOS upgrades, the script will prompt the user for confirmation before proceeding.

## 4. Documentation Plan

*   **`COMMANDS.md`:** The new `fc update` command and its flags will be documented.
*   **New Guide:** A `docs/SYSTEM_UPDATES.md` guide will explain the update process, configuration options, and best practices.
*   **Inline Comments:** The `fc-update` script will be thoroughly commented.

## 5. Implementation Plan

1.  **Create `fc-update` script:** Develop the new command in `lib/commands/`.
2.  **Implement Helper Functions:** Create separate functions for each update type within the script or in `lib/helpers.sh`.
3.  **macOS Update Logic:** Use the built-in `softwareupdate` command-line tool to manage macOS updates.
4.  **Homebrew Update Logic:** Use `brew update` and `brew upgrade` to manage package updates.
5.  **Repository Update Logic:** Use `git pull` to update the dotfiles repository.
6.  **Testing:** Add `bats` tests, mocking the actual update commands.
7.  **Documentation:** Update `COMMANDS.md` and create the new guide.
