# ==============================================================================
#
# FILE:         circus.plugin.zsh
#
# DESCRIPTION:  This is the main plugin file for the Dotfiles Flying Circus.
#               It sources all the custom aliases, environment variables, and
#               functions that make up your shell environment.
#
# ==============================================================================

# Get the directory of the current script.
# This allows us to source other files relative to this one.
local circus_plugin_dir="${0:A:h}"

# Source all alias files.
for alias_file in "$circus_plugin_dir"/aliases/*.sh; do
  source "$alias_file"
done

# Source all environment files.
for env_file in "$circus_plugin_dir"/env/*.sh; do
  source "$env_file"
done

# You can add custom functions here in the future.
# For example:
# my_function() {
#   echo "Hello from the circus plugin!"
# }
