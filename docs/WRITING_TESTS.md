# Testing Guide

This document provides a guide to understanding, running, and writing tests for the Dotfiles Flying Circus project. The goal of this testing suite is to ensure the reliability and stability of the installation scripts and helper functions.

## Overview

This project uses **Bats (Bash Automated Testing System)** as its testing framework. Bats provides a simple, clean syntax for testing shell scripts and is ideal for a project of this nature. It allows us to write unit tests for individual functions, ensuring they behave as expected and preventing regressions as the project grows.

## Dependencies

The testing framework itself, `bats-core`, is a development dependency of this project. The main `install.sh` script is configured to automatically install `bats-core` via Homebrew (see `install/tools/install-bats-core.sh`). You do not need to install it manually.

## First-Time Setup

Before you can run the tests for the first time, you need to make the test runner script executable. This is a **one-time action**.

```sh
chmod +x run-tests.sh
```

## How to Run Tests

A simple test runner script, `run-tests.sh`, is provided in the root of the project. To run the entire test suite, simply execute this script:

```sh
./run-tests.sh
```

The script will automatically discover and run all files ending in `.bats` within the `tests/` directory and will print the results to the console.

## How to Write Tests

Writing tests with Bats is straightforward. All test files should be placed in the `tests/` directory and should have a `.bats` extension.

Here is a breakdown of the core concepts, using `tests/helpers.bats` as an example:

### 1. Test File Structure

A Bats test file is just a shell script with a special syntax.

```bash
#!/usr/bin/env bats

# Test setup and test cases go here...
```

### 2. The `setup()` Function (Optional)

The `setup()` function is a special function that Bats runs before each test case in the file. It's the perfect place to load the script you want to test.

```bash
setup() {
  # The `load` command is a Bats helper that sources a script file.
  load '../lib/helpers.sh'
}
```

### 3. Defining a Test Case with `@test`

Each test case is a standard shell function decorated with the `@test` annotation. The string following `@test` is the description of the test.

```bash
@test "logm() should print an INFO message correctly" {
  # Test logic goes here...
}
```

### 4. Running a Command with `run`

The `run` command is the heart of a Bats test. It executes the command you provide and captures its exit status and output into special variables.

```bash
@test "logm() should print an INFO message correctly" {
  run logm "INFO" "This is an info message."
  # ... assertions go here ...
}
```

### 5. Making Assertions

After running a command, you use standard shell `if` statements or `[[ ... ]]` expressions to check the results. If an assertion fails, the test case fails.

Bats provides the following special variables to help you make assertions:

-   `$status`: The exit status of the command that was run.
-   `$output`: The combined standard output (stdout) of the command.
-   `$stderr`: The combined standard error (stderr) of the command.

```bash
@test "logm() should print an INFO message correctly" {
  run logm "INFO" "This is an info message."

  # Assert that the command executed successfully (exit status 0).
  [ "$status" -eq 0 ]

  # Assert that the output contains the correct log level string.
  [[ "$output" == *"[INFO]"* ]]

  # Assert that the output contains the correct message body.
  [[ "$output" == *"This is an info message."* ]]
}
```

By following this structure, you can easily add new tests to verify the functionality of any script or helper function in this project.
