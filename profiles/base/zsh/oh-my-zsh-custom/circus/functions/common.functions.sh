# shellcheck shell=bash

# ==============================================================================
#
# FILE:         common.functions.sh
#
# DESCRIPTION:  Custom shell functions loaded into interactive shells by
#               circus.plugin.zsh.
#
# NOTE:         This file is SOURCED, never executed — it is not executable and
#               deliberately has no shebang. It previously carried `#!/bin/sh`
#               and claimed POSIX compliance, which was inaccurate: the
#               functions use `local`, which is not POSIX. The shells that
#               actually load this file (zsh, and bash for the tests) both
#               support it, so the directive above tells shellcheck to analyse
#               it as bash rather than warn on every `local`.
#
# ==============================================================================

#
# Create a directory and change into it.
#
# @param $1 The name of the directory to create.
#
mkcd() {
  mkdir -p "$1" && cd "$1" || return 1
}

#
# Go up N directories.
#
# @param $1 The number of directories to go up (defaults to 1).
#
up() {
  # NOT named `path`, and no `seq`.
  #
  # This file is loaded by zsh, where `path` is the array tied to $PATH — so
  # `local path=""` blanked PATH for the duration of the function, and the very
  # next command (`seq`, which is not on macOS anyway) failed with "command not
  # found". The function never moved anywhere. It worked only under bash.
  local levels="${1:-1}"
  local target=""
  local i=1

  case "$levels" in
    ''|*[!0-9]*)
      echo "up: argument must be a positive integer" >&2
      return 1
      ;;
  esac

  while [ "$i" -le "$levels" ]; do
    target="${target}../"
    i=$((i + 1))
  done

  cd "$target" || return 1
}

#
# Universal archive extractor.
# Handles .zip, .tar.gz, .tar.bz2, .tar.xz, etc.
#
# @param $1 The archive file to extract.
#
extract() {
  if [ -z "$1" ]; then
    echo "Usage: extract <file>"
    return 1
  fi

  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2) tar xjf "$1" ;; 
      *.tar.gz)  tar xzf "$1" ;; 
      *.tar.xz)  tar xf "$1"  ;; 
      *.bz2)     bunzip2 "$1" ;; 
      *.rar)     unrar x "$1" ;; 
      *.gz)      gunzip "$1"  ;; 
      *.tar)     tar xf "$1"  ;; 
      *.tbz2)    tar xjf "$1" ;; 
      *.tgz)     tar xzf "$1" ;; 
      *.zip)     unzip "$1"   ;; 
      *.Z)       uncompress "$1" ;; 
      *.7z)      7z x "$1"    ;; 
      *)         echo "\`extract\`: '$1' - unknown archive format" ;; 
    esac
  else
    echo "\`extract\`: '$1' - file not found"
  fi
}

#
# Display local and public IP addresses.
#
myip() {
  echo "Local IP:  $(ipconfig getifaddr en0)"
  echo "Public IP: $(curl -s https://ipinfo.io/ip)"
}
