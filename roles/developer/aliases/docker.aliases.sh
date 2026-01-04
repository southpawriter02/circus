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
alias dstopall='docker stop $(docker ps -a -q)'
alias drmall='docker rm $(docker ps -a -q)'

# Docker Compose
alias dcu="docker-compose up"
alias dcud="docker-compose up -d"
alias dcd="docker-compose down"
alias dcr="docker-compose run --rm"
alias dcl="docker-compose logs -f"
alias dcps="docker-compose ps"
alias dcb="docker-compose build"
alias dcbn="docker-compose build --no-cache"
alias dcrestart="docker-compose restart"
alias dcpull="docker-compose pull"

# --- Docker Build & Images ---------------------------------------------------

# Build with default tag
alias dbuild="docker build -t"

# Build with no cache
alias dbuildn="docker build --no-cache -t"

# Pull latest image
alias dpull="docker pull"

# Tag an image
alias dtag="docker tag"

# Push to registry
alias dpush="docker push"

# Save image to tar
alias dsave="docker save -o"

# Load image from tar
alias dload="docker load -i"

# --- Docker Cleanup -----------------------------------------------------------

# Full system prune (remove everything unused)
alias dprune="docker system prune -af"

# Prune volumes (be careful!)
alias dvolprune="docker volume prune -f"

# Prune unused images
alias dimgprune="docker image prune -af"

# Prune unused networks
alias dnetprune="docker network prune -f"

# Prune build cache
alias dbuildprune="docker builder prune -af"

# Nuclear cleanup (remove absolutely everything)
dnuke() {
    echo "This will remove ALL Docker resources (containers, images, volumes, networks)!"
    read -r "?Are you sure? [y/N] " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        docker stop $(docker ps -aq) 2>/dev/null
        docker rm $(docker ps -aq) 2>/dev/null
        docker rmi $(docker images -q) -f 2>/dev/null
        docker volume rm $(docker volume ls -q) 2>/dev/null
        docker network prune -f
        docker system prune -af --volumes
    fi
}

# --- Docker Stats & Info ------------------------------------------------------

# Container stats with formatting
alias dstats="docker stats --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}'"

# Show disk usage
alias ddf="docker system df"

# Show detailed disk usage
alias ddfv="docker system df -v"

# Inspect a container
alias dinspect="docker inspect"

# Show container IP address
dip() {
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "$1"
}

# --- Docker Networks ----------------------------------------------------------

# List networks
alias dnetls="docker network ls"

# Create network
alias dnetcreate="docker network create"

# Remove network
alias dnetrm="docker network rm"

# --- Docker Volumes -----------------------------------------------------------

# List volumes
alias dvols="docker volume ls"

# Create volume
alias dvolcreate="docker volume create"

# Remove volume
alias dvolrm="docker volume rm"

# Inspect volume
alias dvolinspect="docker volume inspect"

# --- Docker Exec Shortcuts ----------------------------------------------------

# Shell into container
alias dsh="docker exec -it"

# Bash into container
dbash() {
    docker exec -it "$1" /bin/bash
}

# SH into container (for Alpine/minimal images)
dshell() {
    docker exec -it "$1" /bin/sh
}

# --- Docker Logs --------------------------------------------------------------

# Tail last 100 lines
alias dlogt="docker logs --tail 100"

# Follow logs with timestamp
alias dlogts="docker logs -f --timestamps"

# Follow logs for all compose services
alias dclogs="docker-compose logs -f --tail=100"

# --- Docker Container Management ----------------------------------------------

# Restart container
alias drestart="docker restart"

# Pause container
alias dpause="docker pause"

# Unpause container
alias dunpause="docker unpause"

# Update container (resources)
alias dupdate="docker update"

# Rename container
alias drename="docker rename"

# --- Docker Registry ----------------------------------------------------------

# Login to Docker Hub
alias dlogin="docker login"

# Login to custom registry
dloginr() {
    docker login "$1"
}

# Search Docker Hub
alias dsearch="docker search"

# --- Useful Docker Functions --------------------------------------------------

# Run a one-off container and remove after exit
drunrm() {
    docker run --rm -it "$@"
}

# Run container with current directory mounted
drunmount() {
    docker run --rm -it -v "$(pwd):/app" -w /app "$@"
}

# Get container logs by name pattern
dlogsp() {
    docker logs -f "$(docker ps --format '{{.Names}}' | grep "$1" | head -1)"
}

# Follow compose logs for specific service
dclogss() {
    docker-compose logs -f "$1"
}

# Stop and remove specific compose service
dcstop() {
    docker-compose stop "$1" && docker-compose rm -f "$1"
}

# Rebuild and restart specific compose service
dcrebuild() {
    docker-compose up -d --no-deps --build "$1"
}

# Enter running compose service container
dcexec() {
    docker-compose exec "$1" /bin/sh
}

# Show Docker aliases
dalias() {
    echo "=== Docker Aliases ==="
    alias | grep -E "^(d[a-z]+|dc[a-z]+)=" | sed "s/=/ = /" | sort
}
