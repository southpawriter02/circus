#!/usr/bin/env bats

# ==============================================================================
#
# FILE:         fc_vm.bats
#
# DESCRIPTION:  Tests for the fc vm command for managing container VMs.
#
# ==============================================================================

load "test_helper"

# --- Setup & Teardown ---------------------------------------------------------

setup() {
    export PROJECT_ROOT
    PROJECT_ROOT="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
    export FC_COMMAND="$PROJECT_ROOT/bin/fc"
}

# ==============================================================================
# Help and Usage Tests
# ==============================================================================

@test "fc vm --help shows usage information" {
    run "$FC_COMMAND" fc-vm --help
    assert_success
    assert_output --partial "Usage: fc vm"
}

@test "fc vm --help shows all actions" {
    run "$FC_COMMAND" fc-vm --help
    assert_success
    assert_output --partial "list"
    assert_output --partial "start"
    assert_output --partial "stop"
    assert_output --partial "status"
    assert_output --partial "shell"
    assert_output --partial "delete"
    assert_output --partial "create"
    assert_output --partial "ip"
    assert_output --partial "provider"
}

@test "fc vm --help shows examples" {
    run "$FC_COMMAND" fc-vm --help
    assert_success
    assert_output --partial "Examples:"
    assert_output --partial "fc vm list"
    assert_output --partial "fc vm start"
}

@test "fc vm with no action shows usage" {
    run "$FC_COMMAND" fc-vm
    assert_success
    assert_output --partial "Usage:"
}

# ==============================================================================
# Action Tests
# ==============================================================================

@test "fc vm unknown action fails" {
    run "$FC_COMMAND" fc-vm unknown_action
    assert_failure
    assert_output --partial "Unknown action"
}

@test "fc vm unknown action shows help hint" {
    run "$FC_COMMAND" fc-vm unknown_action
    assert_failure
    assert_output --partial "--help"
}

@test "fc vm provider shows provider info" {
    run "$FC_COMMAND" fc-vm provider
    # Should succeed even if no provider installed (shows help)
    assert_success
}

@test "fc vm provider invalid fails" {
    run "$FC_COMMAND" fc-vm provider invalid_provider
    assert_failure
    assert_output --partial "Unknown provider"
}

# ==============================================================================
# Delete Action Tests
# ==============================================================================

@test "fc vm delete without name fails" {
    run "$FC_COMMAND" fc-vm delete
    assert_failure
    assert_output --partial "name required"
}

@test "fc vm create without name fails" {
    run "$FC_COMMAND" fc-vm create
    assert_failure
    assert_output --partial "name required"
}

# ==============================================================================
# Plugin File Tests
# ==============================================================================

@test "fc-vm plugin exists" {
    [ -f "$PROJECT_ROOT/lib/plugins/fc-vm" ]
}

@test "fc-vm plugin is executable" {
    [ -x "$PROJECT_ROOT/lib/plugins/fc-vm" ]
}

@test "fc-vm plugin sources init.sh" {
    run grep "source.*init.sh" "$PROJECT_ROOT/lib/plugins/fc-vm"
    assert_success
}

# ==============================================================================
# Provider Backend Tests
# ==============================================================================

@test "vm_backends directory exists" {
    [ -d "$PROJECT_ROOT/lib/vm_backends" ]
}

@test "lima backend exists" {
    [ -f "$PROJECT_ROOT/lib/vm_backends/vm_lima.sh" ]
}

@test "colima backend exists" {
    [ -f "$PROJECT_ROOT/lib/vm_backends/vm_colima.sh" ]
}

@test "lima backend has required functions" {
    run grep "vm_lima_list" "$PROJECT_ROOT/lib/vm_backends/vm_lima.sh"
    assert_success
    run grep "vm_lima_start" "$PROJECT_ROOT/lib/vm_backends/vm_lima.sh"
    assert_success
    run grep "vm_lima_stop" "$PROJECT_ROOT/lib/vm_backends/vm_lima.sh"
    assert_success
}

@test "colima backend has required functions" {
    run grep "vm_colima_list" "$PROJECT_ROOT/lib/vm_backends/vm_colima.sh"
    assert_success
    run grep "vm_colima_start" "$PROJECT_ROOT/lib/vm_backends/vm_colima.sh"
    assert_success
    run grep "vm_colima_stop" "$PROJECT_ROOT/lib/vm_backends/vm_colima.sh"
    assert_success
}

# ==============================================================================
# Configuration Tests
# ==============================================================================

@test "vm.conf.template exists" {
    [ -f "$PROJECT_ROOT/lib/templates/vm.conf.template" ]
}

@test "vm.conf.template contains VM_PROVIDER" {
    run grep "VM_PROVIDER" "$PROJECT_ROOT/lib/templates/vm.conf.template"
    assert_success
}
