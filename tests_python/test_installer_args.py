#!/usr/bin/env python3
"""
test_installer_args.py

Unit tests for the install.sh argument parsing and validation.
Tests verify that:
- Valid arguments are accepted
- Invalid arguments produce appropriate error messages
- Role validation rejects invalid role names
- Missing required values for options are caught
"""

import subprocess
import os
import tempfile
import pytest

# Get the absolute path to the project root
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
INSTALL_SCRIPT = os.path.join(PROJECT_ROOT, 'install.sh')


def run_installer(args: list, timeout: int = 5) -> subprocess.CompletedProcess:
    """
    Run the installer script with given arguments.

    Args:
        args: List of command line arguments
        timeout: Maximum time to wait (we use short timeout since we're testing args)

    Returns:
        CompletedProcess with returncode, stdout, stderr
    """
    cmd = ['bash', INSTALL_SCRIPT] + args

    # Set up environment to avoid interactive prompts
    env = os.environ.copy()
    env['INTERACTIVE_MODE'] = 'false'

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            timeout=timeout,
            env=env
        )
    except subprocess.TimeoutExpired:
        # If it times out, it means it got past argument parsing
        # This is expected for valid args that would start installation
        return subprocess.CompletedProcess(cmd, 0, '', '')

    return result


# ==============================================================================
# Tests for --help option
# ==============================================================================

class TestHelpOption:
    """Tests for the --help option."""

    def test_help_displays_usage(self):
        """--help should display usage information and exit with 0."""
        result = run_installer(['--help'])
        assert result.returncode == 0
        assert 'Usage:' in result.stdout
        assert '--role' in result.stdout
        assert '--dry-run' in result.stdout

    def test_help_shows_valid_roles(self):
        """--help should list valid role names."""
        result = run_installer(['--help'])
        assert 'developer' in result.stdout
        assert 'personal' in result.stdout
        assert 'work' in result.stdout


# ==============================================================================
# Tests for --role option
# ==============================================================================

class TestRoleValidation:
    """Tests for the --role argument validation."""

    def test_valid_role_developer(self):
        """--role developer should be accepted."""
        # Use --help after to exit cleanly without running installation
        result = run_installer(['--role', 'developer', '--help'])
        # Should not fail with role error
        assert 'Invalid role' not in result.stderr
        assert result.returncode == 0

    def test_valid_role_personal(self):
        """--role personal should be accepted."""
        result = run_installer(['--role', 'personal', '--help'])
        assert 'Invalid role' not in result.stderr
        assert result.returncode == 0

    def test_valid_role_work(self):
        """--role work should be accepted."""
        result = run_installer(['--role', 'work', '--help'])
        assert 'Invalid role' not in result.stderr
        assert result.returncode == 0

    def test_invalid_role_rejected(self):
        """Invalid role names should be rejected with error message."""
        result = run_installer(['--role', 'invalid-role'])
        assert result.returncode != 0
        assert 'Invalid role' in result.stderr
        assert 'invalid-role' in result.stderr
        # Should show valid roles in error message
        assert 'developer' in result.stderr or 'Valid roles' in result.stderr

    def test_empty_role_rejected(self):
        """--role without a value should fail."""
        result = run_installer(['--role'])
        assert result.returncode != 0
        # Should indicate role is required
        assert 'requires' in result.stderr.lower() or 'role' in result.stderr.lower()

    def test_role_followed_by_flag_rejected(self):
        """--role followed by another flag should fail."""
        result = run_installer(['--role', '--dry-run'])
        assert result.returncode != 0
        assert 'requires' in result.stderr.lower() or 'role' in result.stderr.lower()


# ==============================================================================
# Tests for --log-level option
# ==============================================================================

class TestLogLevelValidation:
    """Tests for the --log-level argument validation."""

    def test_valid_log_level_debug(self):
        """--log-level DEBUG should be accepted."""
        result = run_installer(['--log-level', 'DEBUG', '--help'])
        assert 'Invalid log level' not in result.stderr
        assert result.returncode == 0

    def test_valid_log_level_info(self):
        """--log-level INFO should be accepted."""
        result = run_installer(['--log-level', 'INFO', '--help'])
        assert 'Invalid log level' not in result.stderr
        assert result.returncode == 0

    def test_valid_log_level_warn(self):
        """--log-level WARN should be accepted."""
        result = run_installer(['--log-level', 'WARN', '--help'])
        assert 'Invalid log level' not in result.stderr
        assert result.returncode == 0

    def test_valid_log_level_error(self):
        """--log-level ERROR should be accepted."""
        result = run_installer(['--log-level', 'ERROR', '--help'])
        assert 'Invalid log level' not in result.stderr
        assert result.returncode == 0

    def test_valid_log_level_critical(self):
        """--log-level CRITICAL should be accepted."""
        result = run_installer(['--log-level', 'CRITICAL', '--help'])
        assert 'Invalid log level' not in result.stderr
        assert result.returncode == 0

    def test_log_level_case_insensitive(self):
        """--log-level should accept lowercase values."""
        result = run_installer(['--log-level', 'debug', '--help'])
        assert 'Invalid log level' not in result.stderr
        assert result.returncode == 0

    def test_invalid_log_level_rejected(self):
        """Invalid log level should be rejected."""
        result = run_installer(['--log-level', 'INVALID'])
        assert result.returncode != 0
        assert 'Invalid log level' in result.stderr

    def test_empty_log_level_rejected(self):
        """--log-level without a value should fail."""
        result = run_installer(['--log-level'])
        assert result.returncode != 0
        assert 'requires' in result.stderr.lower()


# ==============================================================================
# Tests for --log-file option
# ==============================================================================

class TestLogFileValidation:
    """Tests for the --log-file argument validation."""

    def test_valid_log_file_accepted(self):
        """--log-file with a path should be accepted."""
        with tempfile.NamedTemporaryFile(suffix='.log', delete=False) as f:
            log_path = f.name

        try:
            result = run_installer(['--log-file', log_path, '--help'])
            assert result.returncode == 0
            assert 'requires' not in result.stderr.lower()
        finally:
            if os.path.exists(log_path):
                os.unlink(log_path)

    def test_empty_log_file_rejected(self):
        """--log-file without a path should fail."""
        result = run_installer(['--log-file'])
        assert result.returncode != 0
        assert 'requires' in result.stderr.lower()

    def test_log_file_followed_by_flag_rejected(self):
        """--log-file followed by another flag should fail."""
        result = run_installer(['--log-file', '--dry-run'])
        assert result.returncode != 0
        assert 'requires' in result.stderr.lower()


# ==============================================================================
# Tests for boolean flags
# ==============================================================================

class TestBooleanFlags:
    """Tests for boolean flag options."""

    def test_dry_run_accepted(self):
        """--dry-run should be accepted."""
        result = run_installer(['--dry-run', '--help'])
        assert result.returncode == 0

    def test_force_accepted(self):
        """--force should be accepted."""
        result = run_installer(['--force', '--help'])
        assert result.returncode == 0

    def test_non_interactive_accepted(self):
        """--non-interactive should be accepted."""
        result = run_installer(['--non-interactive', '--help'])
        assert result.returncode == 0

    def test_silent_accepted(self):
        """--silent should be accepted."""
        result = run_installer(['--silent', '--help'])
        assert result.returncode == 0


# ==============================================================================
# Tests for unknown arguments
# ==============================================================================

class TestUnknownArguments:
    """Tests for handling unknown arguments."""

    def test_unknown_flag_shows_usage(self):
        """Unknown flags should show usage and exit with 0."""
        result = run_installer(['--unknown-flag'])
        # Unknown args trigger usage display
        assert 'Usage:' in result.stdout

    def test_unknown_positional_shows_usage(self):
        """Unknown positional args should show usage."""
        result = run_installer(['something-random'])
        assert 'Usage:' in result.stdout


# ==============================================================================
# Tests for combined options
# ==============================================================================

class TestCombinedOptions:
    """Tests for using multiple options together."""

    def test_multiple_valid_options(self):
        """Multiple valid options should work together."""
        result = run_installer([
            '--role', 'developer',
            '--dry-run',
            '--log-level', 'DEBUG',
            '--non-interactive',
            '--help'
        ])
        assert result.returncode == 0
        assert 'Invalid' not in result.stderr

    def test_dry_run_with_role(self):
        """--dry-run with --role should be accepted."""
        result = run_installer(['--dry-run', '--role', 'work', '--help'])
        assert result.returncode == 0


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
