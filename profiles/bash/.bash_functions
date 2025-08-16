#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         .bash_functions
#
# DESCRIPTION:  This file is dedicated to defining custom shell functions.
#               Separating functions into their own file makes the
#               configuration clean and easy to manage.
#
# ==============================================================================

#
# Create a directory and change into it.
#
# @param $1 The name of the directory to create.
#
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

#
# Find a file by name.
#
# @param $1 The name of the file to find.
#
function ff() {
  find . -type f -name "$1"
}
