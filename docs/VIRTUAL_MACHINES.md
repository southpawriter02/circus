# Virtual Machine Management

This guide explains how to use the `fc vm` command to manage container virtual machines on macOS.

## Overview

The `fc vm` command provides a unified interface for managing VMs through two provider backends:

| Provider | Description | Best For |
|----------|-------------|----------|
| **Colima** | Lightweight container runtime | Docker, Kubernetes development |
| **Lima** | General-purpose Linux VMs | Custom Linux environments |

## Prerequisites

Install at least one provider:

```bash
# For Docker/Kubernetes (recommended for most developers)
brew install colima docker

# For general Linux VMs
brew install lima
```

## Quick Start

```bash
# Start a VM (uses default provider and VM name)
fc vm start

# Check status
fc vm status

# Open shell in VM
fc vm shell

# Stop when done
fc vm stop
```

## Commands

### List VMs

```bash
fc vm list
```

Shows all VMs with their status, CPU, memory, and disk allocation.

### Start a VM

```bash
# Start default VM
fc vm start

# Start a named VM
fc vm start myvm
```

### Stop a VM

```bash
# Stop default VM
fc vm stop

# Stop a named VM
fc vm stop myvm
```

### VM Status

```bash
# Default VM status
fc vm status

# Named VM status  
fc vm status myvm
```

### Open Shell

```bash
# Shell into default VM
fc vm shell

# Shell into named VM
fc vm shell myvm
```

### Create a VM

```bash
# Create with default settings
fc vm create myvm

# Create from template (Lima only)
fc vm create myvm docker
```

**Lima templates**: `default`, `docker`, `podman`, `archlinux`, `debian`, `fedora`, `ubuntu`

### Delete a VM

```bash
fc vm delete myvm
```

You'll be prompted for confirmation before deletion.

### Get IP Address

```bash
fc vm ip
fc vm ip myvm
```

Note: Colima typically uses `127.0.0.1` with port forwarding.

### Provider Management

```bash
# Show current provider
fc vm provider

# Switch to Colima
fc vm provider colima

# Switch to Lima
fc vm provider lima
```

## Configuration

Configuration is stored in `~/.config/circus/vm.conf`:

```bash
# Provider: lima or colima
VM_PROVIDER="colima"

# Default VM name (optional)
VM_DEFAULT_NAME="default"
```

## Colima with Docker

Colima is the recommended provider for Docker development:

```bash
# Install
brew install colima docker docker-compose

# Start Colima
fc vm start

# Use Docker normally
docker ps
docker compose up
```

## Colima with Kubernetes

```bash
# Start with Kubernetes enabled
colima start --kubernetes

# Verify
kubectl get nodes
```

## Lima for Custom VMs

Lima provides more flexibility for custom Linux environments:

```bash
# Create Ubuntu VM
fc vm create ubuntu-dev ubuntu

# Start and enter
fc vm start ubuntu-dev
fc vm shell ubuntu-dev
```

## Troubleshooting

### "No VM provider found"

Install a provider:
```bash
brew install colima docker
```

### VM won't start

Check available resources:
```bash
# For Colima
colima start --cpu 4 --memory 8

# For Lima
limactl start --cpus 4 --memory 8
```

### Slow performance on Intel Macs

Use Rosetta for x86 emulation on Apple Silicon:
```bash
colima start --arch x86_64 --vm-type=vz --vz-rosetta
```

## See Also

- [Lima Documentation](https://lima-vm.io/)
- [Colima GitHub](https://github.com/abiosoft/colima)
- [Docker Documentation](https://docs.docker.com/)
