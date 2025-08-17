# Improvement Proposal: 14 - Add a `pre-commit` hook

## 1. Feature Overview

This improvement will add a `pre-commit` Git hook to the repository. This hook will automatically run quality checks—specifically `shellcheck` for static analysis and the `bats` test suite—before a commit is allowed to be created.

**User Benefit:** Enforces code quality and prevents regressions *before* they are committed to the repository. This helps to maintain a high-quality, stable codebase and reduces the need for follow-up fixes. It automates the testing process for the contributor.

## 2. Design & Modularity

*   **Pre-commit Framework:** Instead of a simple, hand-written hook, the project will adopt the `pre-commit` framework (https://pre-commit.com/). This is a more robust and flexible way to manage Git hooks.
*   **Configuration File:** A `.pre-commit-config.yaml` file will be added to the root of the repository. This file will define the hooks to be run.
*   **Hooks:**
    *   **`shellcheck`:** A pre-existing `pre-commit` hook for `shellcheck` will be used to analyze all shell scripts.
    *   **`bats`:** A custom, local hook will be created to run the `run-tests.sh` script. The hook will be configured to only run if a file in the `tests/` directory or a script in `lib/` or `bin/` has changed.

## 3. Security Considerations

*   **Third-Party Code:** The `pre-commit` framework fetches hooks from external repositories. The configuration will be set to pin the hooks to a specific commit hash or tag to prevent a malicious upstream change from being automatically pulled and executed.
*   **Local Execution:** The hooks are run locally by the developer and do not affect the production environment directly.

## 4. Documentation Plan

*   **`TESTING.md`:** The testing guide will be updated to include instructions on how to install and use the `pre-commit` framework.
*   **`README.md`:** The "Getting Started" or "Contributing" section could be updated to mention the new development dependency.

## 5. Implementation Plan

1.  **Add `pre-commit` to Brewfile:** Add `pre-commit` to the development-related `Brewfile` (e.g., in the `developer` role).
2.  **Create `.pre-commit-config.yaml`:**
    *   Add the standard `shellcheck` hook.
    *   Add a local hook definition to run the `bats` test suite.
3.  **Create Setup Script:** A small script could be added to `bin/setup-dev-environment` that runs `pre-commit install` for the user.
4.  **Testing:** The change is self-testing. Once implemented, any commit that introduces a `shellcheck` error or a failing `bats` test should be rejected by the hook.
5.  **Documentation:** Update `TESTING.md` with instructions for setting up the `pre-commit` hook.
