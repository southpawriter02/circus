# Testing Guide

This document outlines the testing procedures for this project, including how to run the test suite and how to use the `pre-commit` framework to ensure code quality.

## Running the Test Suite

The test suite is built using the [BATS (Bash Automated Testing System)](https://github.com/bats-core/bats-core). The tests are located in the `tests/` directory.

To run the test suite, execute the following script from the root of the repository:

```bash
./run-tests.sh
```

This script will automatically find and run all `.bats` test files.

## Pre-Commit Hooks

This project uses the [`pre-commit`](https://pre-commit.com/) framework to automatically run quality checks before each commit. The hooks are configured in the `.pre-commit-config.yaml` file.

### Setup

To use the pre-commit hooks, you must first have `pre-commit` installed. If you used the main `./install.sh` script with the `developer` role, this will already be done for you.

Once `pre-commit` is installed, run the following command to install the hooks into your local `.git` directory:

```bash
bin/setup-dev
```

This will install the hooks, and they will run automatically every time you run `git commit`.

### Configured Hooks

The following hooks are configured:

*   **`shellcheck`**: Statically analyzes all shell scripts for common errors and bugs.
*   **`shfmt`**: Automatically formats all shell scripts to a consistent style.
*   **`bats-tests`**: Runs the BATS test suite to ensure that no regressions have been introduced.

---

## Developer's Log: Modernizing the Test Suite

**Author:** Jules
**Date:** 2025-08-18

This section documents the investigation and necessary steps to make the test suite functional. The test suite was not functional in its original state due to a combination of bugs, outdated practices, and platform incompatibilities.

### Summary of Issues

1.  **Outdated Test Libraries:** The project's `Brewfile` listed `bats-support` and `bats-assert` as dependencies. These libraries are no longer distributed via Homebrew and are now intended to be included as `git` submodules.
2.  **macOS-Specific Dependencies:** The `Brewfile` included `dockutil`, a macOS-only utility, which prevents the dependencies from being installed on other platforms like Linux.
3.  **Installer Bugs:** The main `./install.sh` script contained several bugs that prevented it from running correctly even when platform issues were mocked. These included:
    *   An incorrect execution order for installation stages.
    *   The use of an incorrect environment variable (`$DOTFILES_DIR` instead of `$DOTFILES_ROOT`).
    *   Hardcoded paths to the macOS Homebrew installation directory.

### Recommended Steps to Fix the Test Suite

The following is a high-level outline of the changes required to get the tests running and the pre-commit hook fully functional.

**Step 1: Clean up the Brewfile**

The dependencies for the test libraries should be removed from the main `Brewfile` to make the test setup self-contained.

*   In `Brewfile`, remove the following lines:
    ```diff
    - brew "bats-core"
    - brew "bats-support"
    - brew "bats-assert"
    - brew "dockutil"
    ```

**Step 2: Add Bats Libraries as Git Submodules**

The modern way to include `bats` helper libraries is via `git submodule`. This ensures that the project has a known-good version of the test libraries.

*   Run the following commands from the repository root:
    ```bash
    git submodule add https://github.com/bats-core/bats-core.git tests/helpers/bats-core
    git submodule add https://github.com/bats-core/bats-support.git tests/helpers/bats-support
    git submodule add https://github.com/bats-core/bats-assert.git tests/helpers/bats-assert
    ```

**Step 3: Update the Test Helper**

The test helper script needs to be updated to load the libraries from their new locations.

*   In `tests/test_helper.bash`, modify the loading section to look like this:
    ```bash
    # Load support and assert libraries.
    load 'helpers/bats-support/load.bash'
    load 'helpers/bats-assert/load.bash'
    ```

**Step 4: Fix the Installer (Optional but Recommended)**

To ensure a smooth experience for new developers, the bugs in the installer should be fixed.

1.  **Correct the Stage Order:** In `install.sh`, move stage `11-defaults-and-additional-configuration.sh` to be *before* stage `04-macos-system-settings.sh`.
2.  **Fix Incorrect Variable:** In `install/11-defaults-and-additional-configuration.sh` and `install/03-homebrew-installation.sh`, replace all instances of the incorrect `$DOTFILES_DIR` variable with the correct `$DOTFILES_ROOT` variable.
3.  **Make Homebrew Path Agnostic:** In `install/03-homebrew-installation.sh`, make the script aware of both the macOS (`/opt/homebrew`) and Linux (`/home/linuxbrew/.linuxbrew`) Homebrew paths to correctly set up the environment.

After these changes are implemented, the test suite should be fully functional, and the `pre-commit` hook will work as intended.
