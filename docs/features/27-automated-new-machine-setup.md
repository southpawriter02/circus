# Feature Proposal: 27 - Automated New Machine Setup

## 1. Feature Overview

This feature introduces a new top-level command, `fc bootstrap`, designed to be the single command a user needs to run on a fresh macOS installation. It will guide the user through the entire process of setting up their machine, from installing dependencies to deploying dotfiles and installing applications.

**User Benefit:** Drastically simplifies the process of setting up a new computer. Instead of running multiple scripts and commands, the user can run a single command and let the framework handle everything, making the process faster and less error-prone.

## 2. Design & Modularity

*   **Orchestration Script:** The `fc bootstrap` command will be an orchestration script. It will not contain much logic itself, but will instead call other existing installation and configuration scripts in the correct order.
*   **Interactive Wizard:** The bootstrap process will be an interactive wizard that asks the user questions upfront (e.g., which roles to install, which applications to install). This allows for a customized setup.
*   **Configuration-driven:** The wizard can be skipped by providing a configuration file, allowing for a fully unattended setup.
*   **Phases:** The bootstrap process will be broken down into phases (e.g., "System Checks", "Installing Dependencies", "Configuring System", "Installing Apps"). This makes the process transparent to the user and easier to debug if something goes wrong.

## 3. Security Considerations

*   **User Consent:** The bootstrap command will perform many system-level changes. It will clearly state what it is about to do and ask for user consent before proceeding.
*   **Sudo Usage:** The command will need `sudo` access for certain operations. It will explain why `sudo` is needed and will use it sparingly.

## 4. Documentation Plan

*   **`README.md`:** The `fc bootstrap` command will be featured prominently in the `README.md` as the recommended way to get started.
*   **New Guide:** A `docs/BOOTSTRAP.md` guide will provide a detailed walkthrough of the bootstrap process, including how to use a configuration file for unattended setup.
*   **Inline Comments:** The `fc-bootstrap` script will be well-commented to explain the orchestration logic.

## 5. Implementation Plan

1.  **Create `fc-bootstrap` script:** Develop the new orchestration script in `lib/commands/`.
2.  **Develop Interactive Wizard:** Use `gum` or shell `read` commands to build the interactive setup wizard.
3.  **Implement Unattended Mode:** Add logic to parse a configuration file and skip the wizard if the file is present.
4.  **Orchestrate Existing Scripts:** Call the existing installation and configuration scripts in the correct sequence.
5.  **Error Handling and Resumability:** Implement robust error handling. Ideally, the process should be resumable if it fails midway.
6.  **Testing:** Testing the full bootstrap process is complex. It will likely require a dedicated testing environment or VM.
7.  **Documentation:** Create the `docs/BOOTSTRAP.md` guide and update the `README.md`.
