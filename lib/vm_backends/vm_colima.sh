#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         vm_colima.sh
#
# DESCRIPTION:  Colima provider for fc vm command.
#               Provides functions to manage Colima container VMs.
#
# REQUIRES:
#   - colima installed via Homebrew
#
# REFERENCES:
#   - https://github.com/abiosoft/colima
#
# ==============================================================================

# --- Provider Check ----------------------------------------------------------

# Check if Colima is available
vm_colima_available() {
    command -v colima &>/dev/null
}

# --- VM Operations -----------------------------------------------------------

# List all Colima profiles
# Output: JSON array of profiles
vm_colima_list() {
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    colima list --json 2>/dev/null
}

# List profiles in human-readable format
vm_colima_list_pretty() {
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    colima list
}

# Start a Colima profile
# Args: $1 = profile name (optional, defaults to "default")
vm_colima_start() {
    local name="${1:-default}"
    
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    
    msg_info "Starting Colima profile '$name'..."
    
    local cmd="colima start"
    if [[ "$name" != "default" ]]; then
        cmd="colima start --profile $name"
    fi
    
    if $cmd; then
        msg_success "Colima profile '$name' started"
    else
        msg_error "Failed to start Colima profile '$name'"
        return 1
    fi
}

# Stop a Colima profile
# Args: $1 = profile name (optional, defaults to "default")
vm_colima_stop() {
    local name="${1:-default}"
    
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    
    msg_info "Stopping Colima profile '$name'..."
    
    local cmd="colima stop"
    if [[ "$name" != "default" ]]; then
        cmd="colima stop --profile $name"
    fi
    
    if $cmd; then
        msg_success "Colima profile '$name' stopped"
    else
        msg_error "Failed to stop Colima profile '$name'"
        return 1
    fi
}

# Get status of a Colima profile
# Args: $1 = profile name (optional, defaults to "default")
vm_colima_status() {
    local name="${1:-default}"
    
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    
    local cmd="colima status"
    if [[ "$name" != "default" ]]; then
        cmd="colima status --profile $name"
    fi
    
    $cmd 2>&1 || msg_warning "Profile '$name' may not exist or is not running"
}

# Open shell (SSH) in a Colima profile
# Args: $1 = profile name (optional, defaults to "default")
vm_colima_shell() {
    local name="${1:-default}"
    
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    
    msg_info "Opening shell in Colima profile '$name'..."
    
    if [[ "$name" != "default" ]]; then
        colima ssh --profile "$name"
    else
        colima ssh
    fi
}

# Delete a Colima profile
# Args: $1 = profile name (required)
vm_colima_delete() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        msg_error "Profile name required for delete operation"
        return 1
    fi
    
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    
    msg_warning "This will delete profile '$name' and all its data."
    read -r -p "Are you sure? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            msg_info "Deleting Colima profile '$name'..."
            local cmd="colima delete"
            if [[ "$name" != "default" ]]; then
                cmd="colima delete --profile $name"
            fi
            if $cmd --force; then
                msg_success "Colima profile '$name' deleted"
            else
                msg_error "Failed to delete Colima profile '$name'"
                return 1
            fi
            ;;
        *)
            msg_info "Delete cancelled"
            ;;
    esac
}

# Create a new Colima profile (starts with editor)
# Args: $1 = profile name (required)
vm_colima_create() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        msg_error "Profile name required for create operation"
        return 1
    fi
    
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    
    msg_info "Creating and starting Colima profile '$name'..."
    msg_info "Tip: Use 'colima start --edit --profile $name' to customize settings"
    
    if colima start --profile "$name"; then
        msg_success "Colima profile '$name' created and started"
    else
        msg_error "Failed to create Colima profile '$name'"
        return 1
    fi
}

# Get IP address of a Colima profile
# Args: $1 = profile name (optional, defaults to "default")
vm_colima_ip() {
    local name="${1:-default}"
    
    if ! vm_colima_available; then
        msg_error "Colima is not installed"
        return 1
    fi
    
    # Parse IP from colima list JSON output
    local json
    json=$(colima list --json 2>/dev/null)
    
    if [[ -z "$json" ]]; then
        msg_error "No Colima profiles found"
        return 1
    fi
    
    # Extract IP address from status
    local ip_address
    if [[ "$name" == "default" ]]; then
        ip_address=$(echo "$json" | grep -oE '"address":"[^"]+' | head -1 | cut -d'"' -f4)
    else
        # For named profiles, we need to filter
        ip_address=$(colima status --profile "$name" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    fi
    
    if [[ -n "$ip_address" && "$ip_address" != "127.0.0.1" ]]; then
        echo "$ip_address"
    else
        # Colima typically uses localhost with port forwarding
        msg_info "Colima uses localhost (127.0.0.1) with port forwarding"
        echo "127.0.0.1"
    fi
}

# Get provider name
vm_colima_provider_name() {
    echo "colima"
}
