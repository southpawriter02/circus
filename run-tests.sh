#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         run-tests.sh
#
# DESCRIPTION:  This script is a simple test runner that finds and executes
#               all test files ending with the `.bats` extension within the
#               `tests` directory.
#
# USAGE:        ./run-tests.sh
#
# TODO:         The test suite is currently failing due to a persistent issue
#               with the test environment. The `bats` executable does not seem
#               to correctly load helper libraries (like `bats-support`) in
#               the current execution environment, failing with an error like:
#               `bats_load_safe: Could not find '/lib/bats-support/load.bash'`.
#               This seems to be caused by `brew --prefix` returning an empty
#               string in the `bats` execution context. This needs to be
#               investigated and fixed.
#
# ==============================================================================

#
# Set the BATS_LIB_PATH to include the Homebrew library directory.
# This ensures that bats can find the support and assert libraries.
#
export BATS_LIB_PATH="$(brew --prefix)/lib"
echo "BATS_LIB_PATH is set to: $BATS_LIB_PATH"

#
# Run the bats command on the tests directory.
# The `bats` command will automatically discover and run all `.bats` files
# within that directory and its subdirectories.
#
bats tests
