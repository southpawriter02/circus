# Testing Strategy & Migration Log

This document outlines the process of migrating the test suite from BATS to Python/pytest and documents the challenges encountered along the way.

## 1. Initial Problem: A Brittle, macOS-Specific BATS Test Suite

The original test suite was written using BATS (Bash Automated Testing System) and was tightly coupled to a macOS environment. Key problems included:

*   **Dependency on Homebrew:** The test runner (`run-tests.sh`) and installation scripts relied exclusively on `brew` to install and locate testing libraries like `bats-core`, `bats-support`, and `bats-assert`. This made it impossible to run in a standard Linux environment.
*   **macOS-Specific Commands:** The tests themselves and the scripts they were testing used macOS-specific commands (`sw_vers`, `sysctl`, `blueutil`), causing failures on other platforms.
*   **Environment Instability:** The test suite suffered from a number of complex issues related to the shell environment, script sourcing, and the `bats-mock` library, which made it extremely difficult to debug and get to a stable state.

## 2. Unsuccessful Strategy: Fixing the BATS Test Suite

My initial strategy was to keep BATS and adapt the existing tests to be more portable. This involved a long and difficult debugging process. The following approaches were attempted and ultimately failed:

*   **`BATS_LIB_PATH` Manipulation:** My first attempts focused on fixing the test runner by setting the `BATS_LIB_PATH` environment variable to point to the correct location of the BATS helper libraries on Linux. This failed because a helper script (`tests/test_helper.bash`) was hardcoding and overriding this variable.
*   **Symlinking & Copying Helper Libraries:** To make the test suite more self-contained, I attempted to symlink and then copy the helper libraries into the `tests/helpers` directory. This solved the initial library loading issue but revealed deeper problems with the test execution environment.
*   **Debugging `bats-mock`:** The `bats-mock` library was a major source of issues. The `stub` command was not working as expected. After reading the source code, I discovered the correct syntax, but the mocks were still not being applied to the scripts under test.
*   **The `exec` vs. `source` Problem:** I eventually discovered that the main `fc` script was using `exec` to run its plugins. This was a critical finding, as `exec` replaces the current shell process, thereby destroying the mock environment set up by BATS. I changed this to `source`.
*   **The `readonly` Variable Problem:** Changing `exec` to `source` created a new problem: because scripts were being sourced multiple times, the shell was trying to redefine `readonly` variables, causing errors. I fixed this by making the variable definitions idempotent.
*   **Final Blocker:** Despite all these fixes, the tests continued to fail. The mocks were still not being applied correctly, and the shell configuration was not being loaded in the test environment. After exhausting all debugging options, I concluded that the complexity of the interacting shell scripts and the testing framework made this approach untenable.

## 3. Successful Strategy: Migration to Python & Pytest

Given the failure of the first strategy, I pivoted to a full migration of the test suite to Python using the `pytest` framework.

### 3.1. Why Python?

*   **Portability:** Python and `pytest` are cross-platform and do not have the shell-specific issues that plagued the BATS suite.
*   **Robust Mocking via Dependency Injection:** While Python's `unittest.mock` is powerful, the most reliable way to mock commands in a separate shell process is to modify the script to allow for dependency injection.
*   **Control & Maintainability:** Python gives us much more precise control over the environment and execution of the scripts under test, and the resulting test suite is easier to read and maintain.

### 3.2. The Dependency Injection Pattern

The final, successful approach was to modify the application scripts themselves to make them more testable.

1.  **Modify the Script:** A script like `lib/plugins/fc-info` was changed from this:
    ```bash
    # Hardcoded command
    echo "  Model:        $(sysctl -n hw.model)"
    ```
    to this:
    ```bash
    # Injectable command
    local sysctl_cmd=${SYSCTL_CMD:-sysctl}
    echo "  Model:        $($sysctl_cmd -n hw.model)"
    ```
2.  **Modify the Test:** The Python test can now reliably mock the command by setting the corresponding environment variable:
    ```python
    # tests_python/test_fc_commands.py
    mock_env = os.environ.copy()
    mock_env['SYSCTL_CMD'] = "/path/to/my/mock/sysctl"
    subprocess.run(['fc', 'fc-info'], env=mock_env)
    ```
This pattern is clean, reliable, and makes testing trivial. It is the recommended approach for all future tests.

## 4. Current Status

*   The BATS test suite in the `tests` directory is deprecated and should be removed.
*   A new Python test suite exists in `tests_python`.
*   The `fc_commands` tests have been almost completely reimplemented in `tests_python/test_fc_commands.py`.
*   The application scripts have been refactored to support dependency injection.
*   There is one remaining test failure in `test_sync_plugin_runs_successfully` that I was unable to solve. It fails with an "invalid variable name" error when trying to mock the `brew bundle dump` command, which I could not find a solution for.
