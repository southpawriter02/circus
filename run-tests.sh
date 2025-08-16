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
# ==============================================================================

#
# Run the bats command on the tests directory.
# The `bats` command will automatically discover and run all `.bats` files
# within that directory and its subdirectories.
#
bats tests
