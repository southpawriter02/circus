# Change Proposal: 16 - Refactor Installer

## 1. Feature Overview

This change involves a significant refactoring of the main `install.sh` script. The goal is to break down the monolithic script into smaller, more focused, and more modular components.

**User Benefit:** While this is primarily a developer-focused change, users will benefit from a more reliable and maintainable installer. It will be easier to debug, and new installation steps can be added with less risk of breaking existing functionality.

## 2. Design & Modularity

*   **Stage-Based Scripts:** The core of the refactoring will be to move the logic for each installation stage into its own separate script.
*   **New Directory Structure:** A new `install/` directory will be created with a structure that reflects the installation flow.
    ```
    install/
    ├── 01-preflight-checks.sh
    ├── 02-homebrew-install.sh
    ├── 03-dotfiles-deploy.sh
    └── ...
    ```
*   **Main Dispatcher:** The main `install.sh` script will be simplified to become a dispatcher. Its only job will be to source a shared environment/helper script and then execute the stage scripts in the correct order.
*   **Shared State:** Any state that needs to be shared between stages (like the chosen `INSTALL_ROLE`) will be exported as an environment variable in the main dispatcher.

## 3. Security Considerations

*   **Source Ordering:** The dispatcher script will be responsible for sourcing scripts in the correct order to ensure that dependencies are met and security checks are run before any modifications are made to the system.
*   **Atomic Stages:** Each stage script should be as atomic as possible. If a stage fails, it should not leave the system in a half-configured state.

## 4. Documentation Plan

*   **`ARCHITECTURE.md`:** The documentation on the project's architecture will be updated to reflect the new, modular installer design.
*   **Inline Comments:** The new, smaller scripts will be easier to document with clear, focused comments.

## 5. Implementation Plan

1.  **Create `install/` Directory:** Create the new directory for the installer stages.
2.  **Identify Stages:** Formally define the installation stages based on the existing `install.sh` script.
3.  **Migrate Logic (Incremental):**
    *   For each stage, create a new script in the `install/` directory.
    *   Copy the relevant logic from the old `install.sh` into the new script.
    *   Replace the old logic in `install.sh` with a call to the new script.
4.  **Refactor Main Script:** Once all logic has been moved, simplify the main `install.sh` script so that it is only a dispatcher.
5.  **Testing:** This is a high-risk refactoring. The `bats` test suite will be crucial.
    *   Tests should be created for each individual stage script.
    *   The end-to-end installer tests will need to be run repeatedly to ensure that the refactored installer behaves identically to the old one.
6.  **Documentation:** Update `ARCHITECTURE.md`.
