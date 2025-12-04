#
# test_fc_commands.py
#
# This file contains the Python-based reimplementation of the integration tests
# for the `fc` command-line interface. It uses the `pytest` framework for
# test organization and the `subprocess` module to execute the `fc` command.
#

import subprocess
import os
import sys

import pytest

# Get the absolute path to the project root, so we can reliably run the
# `fc` command from anywhere.
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
FC_COMMAND = os.path.join(PROJECT_ROOT, 'bin', 'fc')

# Skip tests on non-macOS systems that expect macOS-specific output
IS_MACOS = sys.platform == 'darwin'
REQUIRES_MACOS = pytest.mark.skipif(not IS_MACOS, reason="Requires macOS")

# ==============================================================================
# Tests for the Dispatcher Logic
# ==============================================================================

def test_dispatcher_displays_help_message():
    """
    Tests that running `fc` with no command displays a dynamic help message
    with a list of available plugins.
    """
    # Run the `fc` command with no arguments.
    result = subprocess.run([FC_COMMAND], capture_output=True, text=True)

    # Assert that the command was successful and the output contains the
    # expected help text and plugin names.
    assert result.returncode == 0
    assert "Usage: fc [global options] <command> [command options]" in result.stdout
    assert "Available commands:" in result.stdout
    assert "fc-info" in result.stdout
    assert "fc-bluetooth" in result.stdout

def test_dispatcher_fails_for_unknown_command():
    """
    Tests that `fc` fails gracefully with a clear error message when an
    unknown command is provided.
    """
    # Run the `fc` command with a command that does not exist.
    result = subprocess.run(
        [FC_COMMAND, "this-command-does-not-exist"],
        capture_output=True,
        text=True
    )

    # Assert that the command failed (non-zero exit code) and that the
    # error message is printed to stderr.
    assert result.returncode != 0
    assert "Unknown command 'this-command-does-not-exist'" in result.stderr

# ==============================================================================
# Tests for Core Plugins
#
# The following tests use a dependency injection pattern to test plugins that
# rely on macOS-specific command-line tools. The scripts themselves have been
# modified to allow these commands to be overridden by environment variables.
# This is a robust way to test shell scripts that have external dependencies.
# ==============================================================================

@REQUIRES_MACOS
def test_info_plugin_runs_successfully():
    """
    Tests the `info` plugin's success case.

    - Mocks `sw_vers` and `sysctl` by pointing environment variables to mock
      scripts.
    - Asserts that the command exits with 0.
    - Asserts that the output contains the mocked system information.
    """
    mocks_dir = os.path.join(PROJECT_ROOT, 'tests_python', 'mocks')
    mock_env = os.environ.copy()
    mock_env['SW_VERS_CMD'] = os.path.join(mocks_dir, 'sw_vers')
    mock_env['SYSCTL_CMD'] = os.path.join(mocks_dir, 'sysctl')

    # Run the `fc-info` command with the modified environment.
    result = subprocess.run(
        [FC_COMMAND, "fc-info"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    # Assert that the command was successful and that the output contains
    # the mocked data.
    assert result.returncode == 0
    assert "14.5" in result.stdout
    assert "MacBookPro18,1" in result.stdout
    assert "Apple M1 Pro" in result.stdout

def test_bluetooth_plugin_runs_successfully():
    """
    Tests the `bluetooth` plugin's success case.
    """
    mocks_dir = os.path.join(PROJECT_ROOT, 'tests_python', 'mocks')
    mock_env = os.environ.copy()
    mock_env['BLUEUTIL_CMD'] = os.path.join(mocks_dir, 'blueutil')

    result = subprocess.run(
        [FC_COMMAND, "fc-bluetooth", "status"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    assert result.returncode == 0
    assert "Bluetooth is currently on." in result.stdout

def test_bluetooth_plugin_fails_when_blueutil_is_missing():
    """
    Tests that the `bluetooth` plugin fails gracefully when `blueutil` is not
    found. This is tested by pointing the `BLUEUTIL_CMD` to a non-existent path.
    """
    mock_env = os.environ.copy()
    # Point to a non-existent command
    mock_env['BLUEUTIL_CMD'] = "/path/to/non-existent/blueutil"

    result = subprocess.run(
        [FC_COMMAND, "fc-bluetooth", "status"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    assert result.returncode != 0
    assert "The 'blueutil' command is required but not found." in result.stderr

def test_redis_plugin_runs_successfully():
    """
    Tests the `redis` plugin's success case.
    """
    mocks_dir = os.path.join(PROJECT_ROOT, 'tests_python', 'mocks')
    mock_env = os.environ.copy()
    mock_env['BREW_CMD'] = os.path.join(mocks_dir, 'brew')

    result = subprocess.run(
        [FC_COMMAND, "fc-redis", "status"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    assert result.returncode == 0
    assert "redis    started" in result.stdout

def test_redis_plugin_fails_when_brew_is_missing():
    """
    Tests that the `redis` plugin fails gracefully when `brew` is not found.
    """
    mock_env = os.environ.copy()
    mock_env['BREW_CMD'] = "/path/to/non-existent/brew"

    result = subprocess.run(
        [FC_COMMAND, "fc-redis", "status"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    assert result.returncode != 0
    assert "The 'brew' command is required but not found." in result.stderr

# ==============================================================================
# Tests for Backup and Sync Plugins
# ==============================================================================

def test_backup_plugin_fails_when_rsync_is_missing():
    """
    Tests that the `backup` plugin fails gracefully when `rsync` is not found.
    """
    mock_env = os.environ.copy()
    mock_env['RSYNC_CMD'] = "/path/to/non-existent/rsync"

    result = subprocess.run(
        [FC_COMMAND, "fc-backup"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    assert result.returncode != 0
    assert "This command requires 'rsync'." in result.stderr

def test_sync_plugin_fails_when_gpg_is_missing():
    """
    Tests that the `sync` plugin fails gracefully when `gpg` is not found.
    """
    mocks_dir = os.path.join(PROJECT_ROOT, 'tests_python', 'mocks')
    mock_env = os.environ.copy()
    mock_env['GPG_CMD'] = "/path/to/non-existent/gpg"
    mock_env['RSYNC_CMD'] = os.path.join(mocks_dir, 'rsync')
    mock_env['GPG_RECIPIENT_ID'] = "test-key"

    result = subprocess.run(
        [FC_COMMAND, "fc-sync", "backup"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    assert result.returncode != 0
    assert "GPG is not installed." in result.stderr

def test_sync_plugin_fails_when_rsync_is_missing():
    """
    Tests that the `sync` plugin fails gracefully when `rsync` is not found.
    """
    mocks_dir = os.path.join(PROJECT_ROOT, 'tests_python', 'mocks')
    mock_env = os.environ.copy()
    mock_env['GPG_CMD'] = os.path.join(mocks_dir, 'gpg')
    mock_env['RSYNC_CMD'] = "/path/to/non-existent/rsync"
    mock_env['GPG_RECIPIENT_ID'] = "test-key"

    result = subprocess.run(
        [FC_COMMAND, "fc-sync", "backup"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    assert result.returncode != 0
    assert "This command requires 'rsync'." in result.stderr

@REQUIRES_MACOS
def test_sync_plugin_runs_successfully():
    """
    Tests that the `sync` plugin runs successfully when all dependencies are present.
    Note: This test requires macOS because the fc-sync plugin uses macOS-specific commands.
    """
    home_dir = os.path.expanduser("~")
    zshrc_path = os.path.join(home_dir, '.zshrc')
    with open(zshrc_path, 'w') as f:
        f.write("# dummy .zshrc")

    mocks_dir = os.path.join(PROJECT_ROOT, 'tests_python', 'mocks')
    mock_env = os.environ.copy()
    mock_env['GPG_CMD'] = os.path.join(mocks_dir, 'gpg')
    mock_env['RSYNC_CMD'] = os.path.join(mocks_dir, 'rsync')
    mock_env['BREW_CMD'] = os.path.join(mocks_dir, 'brew')
    mock_env['TAR_CMD'] = os.path.join(mocks_dir, 'tar')
    mock_env['MKTEMP_CMD'] = os.path.join(mocks_dir, 'mktemp')
    mock_env['GPG_RECIPIENT_ID'] = "test-key"

    result = subprocess.run(
        [FC_COMMAND, "fc-sync", "backup"],
        capture_output=True,
        text=True,
        env=mock_env
    )

    os.remove(zshrc_path)
    assert result.returncode == 0
    assert "Encrypted backup created at" in result.stdout
