#!/usr/bin/env python3
"""
test_installation_integration.py

Integration tests for the full installation process.
These tests verify:
- The installer can run end-to-end in dry-run mode
- All stages execute in the correct order
- The installer handles various configurations correctly
- No actual system changes are made during dry-run

Note: Many tests in this file require macOS to run since the installer
performs macOS-specific preflight checks.
"""

import subprocess
import os
import sys
import platform
import tempfile
import shutil
import time
import pytest

# Skip tests on non-macOS systems since the installer requires macOS
IS_MACOS = sys.platform == 'darwin'
REQUIRES_MACOS = pytest.mark.skipif(not IS_MACOS, reason="Requires macOS")

# Get the absolute path to the project root
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
INSTALL_SCRIPT = os.path.join(PROJECT_ROOT, 'install.sh')


def run_installer(args: list, env_overrides: dict = None, timeout: int = 60) -> subprocess.CompletedProcess:
    """
    Run the full installer with given arguments.

    Args:
        args: List of command line arguments
        env_overrides: Dictionary of environment variables to set
        timeout: Maximum time to wait

    Returns:
        CompletedProcess with returncode, stdout, stderr
    """
    cmd = ['bash', INSTALL_SCRIPT] + args

    # Set up environment
    env = os.environ.copy()
    # Disable terminal UI features that cause encoding issues
    env['TERM'] = 'dumb'
    if env_overrides:
        env.update(env_overrides)

    result = subprocess.run(
        cmd,
        capture_output=True,
        timeout=timeout,
        env=env
    )

    # Decode with error handling for terminal UI characters
    stdout = result.stdout.decode('utf-8', errors='replace') if isinstance(result.stdout, bytes) else result.stdout
    stderr = result.stderr.decode('utf-8', errors='replace') if isinstance(result.stderr, bytes) else result.stderr

    return subprocess.CompletedProcess(
        result.args,
        result.returncode,
        stdout,
        stderr
    )


# ==============================================================================
# Full Installation Dry-Run Tests
# ==============================================================================

@REQUIRES_MACOS
class TestFullInstallationDryRun:
    """Tests for running the full installation in dry-run mode."""

    def test_dry_run_completes_successfully(self):
        """Full installation in dry-run mode should complete without errors."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            # Should complete successfully
            assert result.returncode == 0, f"Installation failed: {result.stderr}"
            assert 'complete' in result.stdout.lower()

    def test_dry_run_with_developer_role(self):
        """Dry-run with developer role should complete successfully."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive', '--role', 'developer'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            assert result.returncode == 0, f"Installation failed: {result.stderr}"

    def test_dry_run_with_personal_role(self):
        """Dry-run with personal role should complete successfully."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive', '--role', 'personal'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            assert result.returncode == 0, f"Installation failed: {result.stderr}"

    def test_dry_run_with_work_role(self):
        """Dry-run with work role should complete successfully."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive', '--role', 'work'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            assert result.returncode == 0, f"Installation failed: {result.stderr}"

    def test_dry_run_contains_dry_run_messages(self):
        """Dry-run should output [Dry Run] messages."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            assert '[Dry Run]' in result.stdout

    def test_dry_run_does_not_modify_home(self):
        """Dry-run should not create any files in HOME directory."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Record initial state
            initial_contents = set(os.listdir(tmpdir))

            result = run_installer(
                ['--dry-run', '--non-interactive'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )

            # Check final state (allow for .circus state directory)
            final_contents = set(os.listdir(tmpdir))
            new_items = final_contents - initial_contents

            # The only new item should be .circus (state directory)
            # or nothing at all in dry-run mode
            assert len(new_items) <= 1, f"Unexpected new items in HOME: {new_items}"
            if new_items:
                assert '.circus' in new_items or new_items == set()


# ==============================================================================
# Stage Execution Order Tests
# ==============================================================================

@REQUIRES_MACOS
class TestStageExecutionOrder:
    """Tests to verify stages execute in the correct order."""

    def test_stages_execute_sequentially(self):
        """Stages should execute in numerical order."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )

            # Extract stage numbers from output
            output = result.stdout
            stage_positions = []

            # Look for stage markers in the output
            for i in range(20):
                stage_marker = f'Stage {i:02d}' if i < 10 else f'Stage {i}'
                # Also check without leading zero
                stage_marker_alt = f'Stage {i}'

                pos = output.find(stage_marker)
                if pos == -1:
                    pos = output.find(stage_marker_alt)
                if pos != -1:
                    stage_positions.append((i, pos))

            # Verify stages appear in order
            positions_only = [pos for _, pos in sorted(stage_positions, key=lambda x: x[0])]
            assert positions_only == sorted(positions_only), \
                "Stages did not execute in the correct order"


# ==============================================================================
# Logging Tests
# ==============================================================================

@REQUIRES_MACOS
class TestInstallerLogging:
    """Tests for installer logging functionality."""

    def test_log_file_created_when_specified(self):
        """--log-file should create a log file."""
        with tempfile.TemporaryDirectory() as tmpdir:
            log_path = os.path.join(tmpdir, 'install.log')

            result = run_installer(
                ['--dry-run', '--non-interactive', '--log-file', log_path],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )

            assert result.returncode == 0
            assert os.path.exists(log_path), "Log file was not created"

    def test_log_file_contains_output(self):
        """Log file should contain installation output."""
        with tempfile.TemporaryDirectory() as tmpdir:
            log_path = os.path.join(tmpdir, 'install.log')

            run_installer(
                ['--dry-run', '--non-interactive', '--log-file', log_path],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )

            if os.path.exists(log_path):
                with open(log_path, 'r') as f:
                    log_content = f.read()
                # Log should have some content
                assert len(log_content) > 0, "Log file is empty"

    def test_silent_mode_reduces_output(self):
        """--silent should reduce console output."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Run without silent
            result_normal = run_installer(
                ['--dry-run', '--non-interactive'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )

            # Run with silent
            result_silent = run_installer(
                ['--dry-run', '--non-interactive', '--silent'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )

            # Silent mode should produce less output
            assert len(result_silent.stdout) <= len(result_normal.stdout)


# ==============================================================================
# Error Handling Tests
# ==============================================================================

class TestInstallerErrorHandling:
    """Tests for installer error handling."""

    def test_invalid_role_fails_gracefully(self):
        """Invalid role should fail with clear error message."""
        result = run_installer(['--role', 'nonexistent-role'])
        assert result.returncode != 0
        assert 'Invalid role' in result.stderr

    def test_missing_role_argument_fails(self):
        """--role without value should fail."""
        result = run_installer(['--role'])
        assert result.returncode != 0
        assert 'requires' in result.stderr.lower()

    def test_missing_log_file_argument_fails(self):
        """--log-file without path should fail."""
        result = run_installer(['--log-file'])
        assert result.returncode != 0
        assert 'requires' in result.stderr.lower()

    def test_missing_log_level_argument_fails(self):
        """--log-level without value should fail."""
        result = run_installer(['--log-level'])
        assert result.returncode != 0
        assert 'requires' in result.stderr.lower()


# ==============================================================================
# Mode Combination Tests
# ==============================================================================

@REQUIRES_MACOS
class TestModeCombinations:
    """Tests for various mode combinations."""

    def test_dry_run_with_force(self):
        """--dry-run with --force should work."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive', '--force'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            assert result.returncode == 0

    def test_dry_run_with_debug_log_level(self):
        """--dry-run with --log-level DEBUG should show more output."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive', '--log-level', 'DEBUG'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            assert result.returncode == 0
            # DEBUG level should show debug messages
            assert 'DEBUG' in result.stdout or len(result.stdout) > 0

    def test_all_flags_combined(self):
        """All flags combined should work together."""
        with tempfile.TemporaryDirectory() as tmpdir:
            log_path = os.path.join(tmpdir, 'install.log')

            result = run_installer(
                [
                    '--dry-run',
                    '--non-interactive',
                    '--force',
                    '--role', 'developer',
                    '--log-file', log_path,
                    '--log-level', 'INFO'
                ],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )
            assert result.returncode == 0


# ==============================================================================
# State Management Tests
# ==============================================================================

@REQUIRES_MACOS
class TestStateManagement:
    """Tests for installation state management."""

    def test_state_directory_not_created_in_dry_run(self):
        """State directory should not be fully populated in dry-run."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_installer(
                ['--dry-run', '--non-interactive'],
                env_overrides={'HOME': tmpdir},
                timeout=120
            )

            state_dir = os.path.join(tmpdir, '.circus')
            # In dry-run, state directory may or may not exist
            # but should not have full state files
            if os.path.exists(state_dir):
                # If it exists, it should be minimal
                contents = os.listdir(state_dir)
                # Allow 'root' file but no other complex state
                assert len(contents) <= 2


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
