#!/bin/sh

# ==============================================================================
#
# FILE:         .shell_functions
#
# DESCRIPTION:  This file is dedicated to defining custom shell functions that
#               are written in a POSIX-compliant way to ensure they work
#               across different shells (e.g., Bash and Zsh).
#
# ==============================================================================

#
# Create a directory and change into it.
#
# @param $1 The name of the directory to create.
#
mkcd() {
  mkdir -p "$1" && cd "$1"
}

#
# Go up N directories.
#
# @param $1 The number of directories to go up (defaults to 1).
#
up() {
  local count=${1:-1}
  local path=""
  for i in $(seq 1 $count); do
    path="$path../"
  done
  cd "$path"
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
