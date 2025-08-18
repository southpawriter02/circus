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
# TODO:         The original script failed in non-macOS environments because
#               it relied on `brew` to set the `BATS_LIB_PATH`. This has been
#               updated to be OS-aware. The next step is to address any
#               macOS-specific commands within the tests themselves.
#
# ==============================================================================

#
# Set BATS_LIB_PATH to ensure bats can find helper libraries.
# This approach is OS-aware, checking for macOS (Darwin) and assuming a
# Linux-like environment otherwise.
#
if [[ "$(uname)" == "Darwin" ]]; then
  # For macOS, use Homebrew to find the library path.
  export BATS_LIB_PATH
  BATS_LIB_PATH="$(brew --prefix)/lib"
else
  # For Linux/other systems, assume libraries are in /usr/lib/bats.
  export BATS_LIB_PATH="/usr/lib/bats"
fi

#
# Run the bats command on the tests directory.
# The `bats` command will automatically discover and run all `.bats` files
# within that directory and its subdirectories.
#
bats tests
