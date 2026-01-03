#!/usr/bin/env bash

# ==============================================================================
#
# FILE:         vm_lima.sh
#
# DESCRIPTION:  Lima (limactl) provider for fc vm command.
#               Provides functions to manage Lima VMs.
#
# REQUIRES:
#   - lima (limactl) installed via Homebrew
#
# REFERENCES:
#   - https://lima-vm.io/
#   - man limactl
#
# ==============================================================================

# --- Provider Check ----------------------------------------------------------

# Check if Lima is available
vm_lima_available() {
    command -v limactl &>/dev/null
}

# --- VM Operations -----------------------------------------------------------

# List all Lima VMs
# Output: JSON array of VMs
vm_lima_list() {
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    limactl list --json 2>/dev/null
}

# List VMs in human-readable format
vm_lima_list_pretty() {
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    limactl list
}

# Start a Lima VM
# Args: $1 = VM name (optional, defaults to "default")
vm_lima_start() {
    local name="${1:-default}"
    
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    
    msg_info "Starting Lima VM '$name'..."
    if limactl start "$name"; then
        msg_success "Lima VM '$name' started"
    else
        msg_error "Failed to start Lima VM '$name'"
        return 1
    fi
}

# Stop a Lima VM
# Args: $1 = VM name (optional, defaults to "default")
vm_lima_stop() {
    local name="${1:-default}"
    
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    
    msg_info "Stopping Lima VM '$name'..."
    if limactl stop "$name"; then
        msg_success "Lima VM '$name' stopped"
    else
        msg_error "Failed to stop Lima VM '$name'"
        return 1
    fi
}

# Get status of a Lima VM
# Args: $1 = VM name (optional, defaults to "default")
vm_lima_status() {
    local name="${1:-default}"
    
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    
    # Get VM info in JSON format and parse status
    local json
    json=$(limactl list --json 2>/dev/null)
    
    if [[ -z "$json" ]]; then
        msg_warning "No Lima VMs found"
        return 0
    fi
    
    # Use limactl list filtered by name for status
    limactl list | grep -E "^$name|^NAME" || msg_warning "VM '$name' not found"
}

# Open shell in a Lima VM
# Args: $1 = VM name (optional, defaults to "default")
vm_lima_shell() {
    local name="${1:-default}"
    
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    
    msg_info "Opening shell in Lima VM '$name'..."
    limactl shell "$name"
}

# Delete a Lima VM
# Args: $1 = VM name (required)
vm_lima_delete() {
    local name="$1"
    
    if [[ -z "$name" ]]; then
        msg_error "VM name required for delete operation"
        return 1
    fi
    
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    
    msg_warning "This will delete VM '$name' and all its data."
    read -r -p "Are you sure? [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            msg_info "Deleting Lima VM '$name'..."
            if limactl delete "$name" --force; then
                msg_success "Lima VM '$name' deleted"
            else
                msg_error "Failed to delete Lima VM '$name'"
                return 1
            fi
            ;;
        *)
            msg_info "Delete cancelled"
            ;;
    esac
}

# Create a new Lima VM
# Args: $1 = VM name (required), $2 = template (optional)
vm_lima_create() {
    local name="$1"
    local template="${2:-default}"
    
    if [[ -z "$name" ]]; then
        msg_error "VM name required for create operation"
        return 1
    fi
    
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    
    msg_info "Creating Lima VM '$name' from template '$template'..."
    if limactl create --name="$name" "template://$template"; then
        msg_success "Lima VM '$name' created"
        msg_info "Run 'fc vm start $name' to start the VM"
    else
        msg_error "Failed to create Lima VM '$name'"
        return 1
    fi
}

# Get IP address of a Lima VM
# Args: $1 = VM name (optional, defaults to "default")
vm_lima_ip() {
    local name="${1:-default}"
    
    if ! vm_lima_available; then
        msg_error "Lima (limactl) is not installed"
        return 1
    fi
    
    # Parse IP from limactl list JSON output
    local json
    json=$(limactl list --json 2>/dev/null)
    
    if [[ -z "$json" ]]; then
        msg_error "No Lima VMs found"
        return 1
    fi
    
    # Extract SSH address which contains the IP
    local ssh_address
    ssh_address=$(limactl show-ssh "$name" 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+' | head -1)
    
    if [[ -n "$ssh_address" ]]; then
        echo "$ssh_address"
    else
        msg_warning "Could not determine IP for VM '$name'"
        msg_info "VM may be stopped or not using bridged networking"
        return 1
    fi
}

# Get provider name
vm_lima_provider_name() {
    echo "lima"
}
