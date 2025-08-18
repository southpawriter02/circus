# Feature Roadmap

This roadmap organizes the proposed features from the `docs/features/` directory into a logical sequence of four phases. Each phase builds on the last, ensuring that foundational work is completed before more complex features are attempted.

---

## Phase 1: Building the Foundation

**Goal:** To establish a robust, extensible, and maintainable architecture for the entire system. This phase is critical for the long-term health of the project.

*   **Key Features:**
    *   **Architecture:**
        *   `06-plugin-system-for-fc-command`: The highest priority. Refactor the core to be a simple plugin dispatcher. This will simplify all future command development.
        *   `19-adopt-a-shell-framework`: Standardize shell scripting practices (e.g., using a framework like `bash-it` or `oh-my-zsh` helpers) to ensure consistency.
    *   **Developer Experience & Stability:**
        *   `13-better-error-handling`: Implement a consistent error handling and reporting mechanism.
        *   `15-improve-logging`: Add a structured logging system to aid in debugging.
        *   `14-add-a-pre-commit-hook`: Enforce code quality standards automatically.
    *   **Installation and Updates:**
        *   `18-dependency-management`: Create a clear and reliable way to manage third-party dependencies (e.g., Homebrew packages).
        *   `16-refactor-installer`: Rework the main installer to be more robust and to handle the new plugin architecture.
        *   `42-self-update-mechanism`: Provide a simple `fc update` command for users to get the latest version.
    *   **Configuration:**
        *   `09-externalize-fc-sync-configuration`: Refactor configuration handling to be more modular, starting with the `sync` command.

---

## Phase 2: Delivering Core User Value

**Goal:** To implement the most critical, user-facing features that solve the primary problems the tool is designed to address.

*   **Key Features:**
    *   **Dotfile Management:**
        *   `03-dotfile-management-command`: The core command for managing dotfiles.
        *   `30-dotfile-profiles`: Add support for different dotfile profiles (e.g., "work" vs. "home").
    *   **Backup and Restore:**
        *   `02-scheduled-backups`: Implement automated, scheduled backups using `launchd`.
    *   **System & Application Management:**
        *   `21-automated-application-installation`: A robust command to install applications from a `Brewfile`.
        *   `22-system-update-command`: A single command to update `brew`, `mas`, and the OS.
        *   `41-system-maintenance-command`: A general-purpose command for common maintenance tasks.
        *   `04-application-cleaner`: A utility to remove unused applications and files.
    *   **Utilities:**
        *   `12-more-fc-commands`: Implement the smaller, high-value utilities like `fc wifi` and `fc dns`.
        *   `08-ssh-key-management`: A simple command to manage SSH keys.
        *   `05-system-health-check`: A quick way to check the system's status.

---

## Phase 3: Advanced Functionality and Integrations

**Goal:** To build upon the core features with more advanced capabilities and integrations with other tools and services.

*   **Key Features:**
    *   **Advanced Backups:**
        *   `01-remote-backup-storage`: The top priority for this phase. Add support for backing up to S3 or other cloud providers.
        *   `10-multiple-backup-backends`: Allow users to configure and use multiple backup destinations.
    *   **Automation:**
        *   `27-automated-new-machine-setup`: A meta-command that runs a series of other commands to fully provision a new machine.
    *   **Integrations:**
        *   `20-secrets-management-integration`: Integrate with a secrets manager like HashiCorp Vault or macOS Keychain.
        *   `26-1password-cli-integration`: A specific, high-value integration for 1Password users.
        *   `31-vscode-settings-sync`: A dedicated command for syncing VS Code settings.
        *   `39-alfred-workflow-integration`: Provide Alfred workflows for common `fc` commands.
    *   **Power-User Features:**
        *   `45-vm-management`: Add commands to manage virtualization (e.g., `lima`, `colima`).

---

## Phase 4: The "Big Picture" and Polishing the User Experience

**Goal:** To focus on ambitious, long-term projects and on refining the user experience to make the tool more accessible and pleasant to use.

*   **Key Features:**
    *   **Major New Interfaces:**
        *   `24-web-ui-dashboard`: A major undertaking to create a graphical interface for the tool.
        *   `25-cross-platform-support`: A very significant effort to abstract away macOS-specific commands and add support for Linux.
    *   **Enhanced Interactivity:**
        *   `23-interactive-fc-command`: Add an interactive mode (e.g., using `fzf`) to guide users through commands.
        *   `11-interactive-role-creation`: A specific interactive helper for creating new roles.
    *   **Quality-of-Life Improvements:**
        *   `43-macos-notification-integration`: Use macOS notifications for long-running tasks.
        *   `35-enhanced-fc-info`: Improve the output of the `fc info` command.
        *   And many of the other smaller utilities and enhancements (`theme-management`, `focus-mode`, etc.).

---

## Roadmap Management Strategy

A great roadmap is only useful if it's visible and actionable. Here are the recommended approaches for managing this feature roadmap:

1.  **GitHub Projects (Most Recommended):** This is the ideal solution. It allows you to create a Kanban-style board directly within your repository. You can turn each feature proposal into a GitHub Issue and place it on the board. This tightly integrates the roadmap with your development workflow, providing excellent visibility and automation opportunities.

2.  **A `ROADMAP.md` File (This File!):** A simple and transparent solution. The roadmap lives as a version-controlled Markdown file in the repository. It's easy to access and update via pull requests, giving you a version-controlled history of the roadmap.

3.  **Third-Party Project Management Tool (e.g., Trello, Linear, Jira):** These tools offer powerful features for tracking complex projects, but come at the cost of being disconnected from the code and potentially introducing subscription fees.
