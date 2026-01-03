# ==============================================================================
# Go Configuration
#
# Environment variables for Go development.
# ==============================================================================

# --- Go Workspace -------------------------------------------------------------

# Go workspace directory
export GOPATH="${GOPATH:-$HOME/go}"

# Go binaries directory
export GOBIN="${GOBIN:-$GOPATH/bin}"

# --- Go Modules ---------------------------------------------------------------

# Enable Go modules (default since Go 1.16)
export GO111MODULE=on

# Go module proxy (faster downloads, better reliability)
# Use direct for private repos: GOPRIVATE=github.com/mycompany/*
export GOPROXY="https://proxy.golang.org,direct"

# Go checksum database
export GOSUMDB="sum.golang.org"

# --- Private Modules ----------------------------------------------------------

# Uncomment and customize for private module paths
# Comma-separated list of glob patterns for private modules
# export GOPRIVATE="github.com/mycompany/*,gitlab.company.com/*"

# --- Build Configuration ------------------------------------------------------

# Enable CGO by default (needed for some packages)
# export CGO_ENABLED=1

# Cross-compilation targets (uncomment as needed)
# export GOOS=linux
# export GOARCH=amd64

# --- Editor Integration -------------------------------------------------------

# Go tools directory (used by gopls, dlv, etc.)
export GOMODCACHE="${GOMODCACHE:-$GOPATH/pkg/mod}"
