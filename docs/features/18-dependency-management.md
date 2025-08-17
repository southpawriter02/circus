# Change Proposal: 18 - Dependency Management

## 1. Feature Overview

This change suggests improving how the shell scripts in the repository manage their dependencies on each other. The current system of manually `source`ing the necessary helper files at the top of each script can be fragile and lead to duplication. This proposal is to create a single, centralized entry point for loading all necessary libraries.

**User Benefit:** This is a developer-focused change that improves the robustness and maintainability of the codebase. It makes it easier to write new scripts without needing to worry about the correct order for sourcing dependencies.

## 2. Design & Modularity

*   **Central `init.sh`:** A new script, `lib/init.sh`, will be created. This script will be responsible for:
    1.  Setting global options (e.g., `set -o pipefail`).
    2.  Defining global constants (e.g., paths to key directories).
    3.  Sourcing all helper libraries (`lib/helpers.sh`, etc.) in the correct order.
*   **Simplified Script Headers:** All other scripts in the repository (`fc` commands, installer stages) will have their headers simplified. Instead of a list of `source` commands, they will only need to have a single line: `source "$(dirname "${BASH_SOURCE[0]}")/../lib/init.sh"`.

## 3. Security Considerations

*   **Centralized Control:** By centralizing the dependency loading, it's easier to audit and ensure that scripts are loaded in a secure and consistent manner.
*   **Pathing:** The `source` line uses `dirname` and `${BASH_SOURCE[0]}` to create a robust, absolute path to the `init.sh` script, which prevents issues with running scripts from different working directories.

## 4. Documentation Plan

*   **`ARCHITECTURE.md`:** The architecture guide will be updated to explain the new initialization process.
*   **Developer Guide:** A guide for developers will be updated to state that all new scripts must source `lib/init.sh` at the beginning.

## 5. Implementation Plan

1.  **Create `lib/init.sh`:**
    *   Create the new file.
    *   Move all common setup logic (options, constants, sourcing helpers) from other scripts into this file.
2.  **Refactor Scripts:**
    *   Go through every executable script in the repository.
    *   Replace the block of `source` commands at the top with the single `source .../lib/init.sh` line.
3.  **Testing:**
    *   This is a low-risk but wide-ranging change.
    *   The full `bats` test suite must be run after the refactoring to ensure that all scripts still have access to the functions and variables they need.
4.  **Documentation:** Update developer documentation.
