# ==============================================================================
#
# FILE:         networking.aliases.sh
#
# DESCRIPTION:  Aliases for networking commands.
#
# ==============================================================================

# Get public IP address
alias pubip="dig +short myip.opendns.com @resolver1.opendns.com"

# Get local IP address
alias localip="ipconfig getifaddr en0"

# List all open ports
alias openports='lsof -i -P -n | grep LISTEN'

# Start a simple web server in the current directory
alias server="python -m SimpleHTTPServer 8000"
