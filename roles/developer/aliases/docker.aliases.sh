# ==============================================================================
#
# FILE:         docker.aliases.sh
#
# DESCRIPTION:  Aliases for Docker and Docker Compose.
#
# ==============================================================================

# Docker
alias dps="docker ps"
alias dpsa="docker ps -a"
alias di="docker images"
alias drun="docker run -it"
alias dexec="docker exec -it"
alias dlogs="docker logs -f"
dalias dstopall='docker stop $(docker ps -a -q)'
alias drmall='docker rm $(docker ps -a -q)'

# Docker Compose
alias dcu="docker-compose up"
alias dcd="docker-compose down"
alias dcr="docker-compose run --rm"
