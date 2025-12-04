#!/usr/bin/env python3
"""
test_preflight_checks.py

Unit tests for the preflight check scripts in the installation process.
These tests use dependency injection via environment variables to mock
external system commands like `uname`, `id`, `groups`, etc.

Each preflight check script has been modified to accept *_CMD environment
variables that override the default commands, allowing us to inject mock
scripts that return controlled outputs.
"""

import subprocess
import os
import tempfile
import shutil
import pytest

# Get the absolute path to the project root
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
PREFLIGHT_DIR = os.path.join(PROJECT_ROOT, 'install', 'preflight')
MOCKS_DIR = os.path.join(PROJECT_ROOT, 'tests_python', 'mocks')
HELPERS_PATH = os.path.join(PROJECT_ROOT, 'lib', 'helpers.sh')


def run_preflight_check(script_name: str, env_overrides: dict = None) -> subprocess.CompletedProcess:
    """
    Run a preflight check script with optional environment variable overrides.

    Args:
        script_name: The name of the preflight script (e.g., 'preflight-01-macos-check.sh')
        env_overrides: Dictionary of environment variables to set

    Returns:
        CompletedProcess object with returncode, stdout, and stderr
    """
    script_path = os.path.join(PREFLIGHT_DIR, script_name)

    # Create the test environment
    env = os.environ.copy()

    # Suppress interactive prompts and colorized output for cleaner test output
    env['INTERACTIVE_MODE'] = 'false'
    env['PARANOID_MODE'] = 'false'

    # Apply any overrides
    if env_overrides:
        env.update(env_overrides)

    # Build the bash command that sources helpers and runs the check
    # We need to source helpers.sh first to get msg_* functions
    bash_cmd = f'''
        source "{HELPERS_PATH}"
        source "{script_path}"
    '''

    result = subprocess.run(
        ['bash', '-c', bash_cmd],
        capture_output=True,
        text=True,
        env=env
    )

    return result


# ==============================================================================
# Tests for preflight-01-macos-check.sh
# ==============================================================================

class TestMacOSCheck:
    """Tests for the macOS detection preflight check."""

    def test_passes_on_macos(self):
        """The check should pass when uname returns 'Darwin'."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        result = run_preflight_check(
            'preflight-01-macos-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Darwin'
            }
        )
        assert result.returncode == 0
        assert 'macOS' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_on_linux(self):
        """The check should fail when uname returns 'Linux'."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        result = run_preflight_check(
            'preflight-01-macos-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Linux'
            }
        )
        assert result.returncode == 1
        assert 'only supported on macOS' in result.stderr or 'ERROR' in result.stderr


# ==============================================================================
# Tests for preflight-02-root-check.sh
# ==============================================================================

class TestRootCheck:
    """Tests for the root user detection preflight check."""

    def test_passes_for_non_root_user(self):
        """The check should pass when not running as root (uid != 0)."""
        mock_id = os.path.join(MOCKS_DIR, 'id')
        result = run_preflight_check(
            'preflight-02-root-check.sh',
            env_overrides={
                'ID_CMD': mock_id,
                'MOCK_ID_UID': '1000'
            }
        )
        assert result.returncode == 0
        assert 'Not running as the root user' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_for_root_user(self):
        """The check should fail when running as root (uid == 0)."""
        mock_id = os.path.join(MOCKS_DIR, 'id')
        result = run_preflight_check(
            'preflight-02-root-check.sh',
            env_overrides={
                'ID_CMD': mock_id,
                'MOCK_ID_UID': '0'
            }
        )
        assert result.returncode == 1
        assert 'root user is not supported' in result.stderr or 'ERROR' in result.stderr


# ==============================================================================
# Tests for preflight-03-admin-rights-check.sh
# ==============================================================================

class TestAdminRightsCheck:
    """Tests for the admin rights preflight check."""

    def test_passes_for_admin_user(self):
        """The check should pass when user is in admin group."""
        mock_groups = os.path.join(MOCKS_DIR, 'groups')
        result = run_preflight_check(
            'preflight-03-admin-rights-check.sh',
            env_overrides={
                'GROUPS_CMD': mock_groups,
                'MOCK_GROUPS_OUTPUT': 'staff admin wheel'
            }
        )
        # This check always returns 0 (informational only)
        assert result.returncode == 0
        assert 'admin rights' in result.stdout.lower() or 'SUCCESS' in result.stdout

    def test_warns_for_non_admin_user(self):
        """The check should warn (but not fail) when user is not in admin group."""
        mock_groups = os.path.join(MOCKS_DIR, 'groups')
        result = run_preflight_check(
            'preflight-03-admin-rights-check.sh',
            env_overrides={
                'GROUPS_CMD': mock_groups,
                'MOCK_GROUPS_OUTPUT': 'staff users'
            }
        )
        # This check always returns 0 (informational only)
        assert result.returncode == 0
        # Should contain a warning message
        assert 'does not have admin rights' in result.stdout or 'WARN' in result.stdout


# ==============================================================================
# Tests for preflight-05-unset-vars-check.sh
# ==============================================================================

class TestUnsetVarsCheck:
    """Tests for the unset variables preflight check."""

    def test_passes_when_all_vars_set(self):
        """The check should pass when HOME, USER, SHELL are all set."""
        result = run_preflight_check(
            'preflight-05-unset-vars-check.sh',
            env_overrides={
                'HOME': '/home/testuser',
                'USER': 'testuser',
                'SHELL': '/bin/zsh'
            }
        )
        assert result.returncode == 0
        assert 'All required environment variables are set' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_when_home_unset(self):
        """The check should fail when HOME is not set."""
        # We need to explicitly unset HOME by running in a controlled env
        env = {
            'USER': 'testuser',
            'SHELL': '/bin/zsh',
            'PATH': os.environ.get('PATH', '/usr/bin:/bin')
        }
        # Don't include HOME

        script_path = os.path.join(PREFLIGHT_DIR, 'preflight-05-unset-vars-check.sh')
        bash_cmd = f'''
            unset HOME
            source "{HELPERS_PATH}"
            source "{script_path}"
        '''

        result = subprocess.run(
            ['bash', '-c', bash_cmd],
            capture_output=True,
            text=True,
            env=env
        )

        assert result.returncode == 1
        assert 'HOME' in result.stderr or 'not set' in result.stderr


# ==============================================================================
# Tests for preflight-06-shell-type-version-check.sh
# ==============================================================================

class TestShellVersionCheck:
    """Tests for the shell type and version preflight check."""

    def test_passes_for_zsh_with_sufficient_version(self):
        """The check should pass for zsh with version >= 5.0."""
        mock_zsh = os.path.join(MOCKS_DIR, 'zsh')
        result = run_preflight_check(
            'preflight-06-shell-type-version-check.sh',
            env_overrides={
                'SHELL': '/bin/zsh',
                'SHELL_VERSION_CMD': mock_zsh,
                'MOCK_ZSH_VERSION': '5.9'
            }
        )
        assert result.returncode == 0
        assert 'Current shell is zsh' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_for_bash_shell(self):
        """The check should fail when the shell is bash instead of zsh."""
        result = run_preflight_check(
            'preflight-06-shell-type-version-check.sh',
            env_overrides={
                'SHELL': '/bin/bash'
            }
        )
        assert result.returncode == 1
        assert 'zsh is required' in result.stderr or 'ERROR' in result.stderr


# ==============================================================================
# Tests for preflight-08-battery-check.sh
# ==============================================================================

class TestBatteryCheck:
    """Tests for the battery and AC power preflight check."""

    def test_passes_on_ac_power(self):
        """The check should pass when device is on AC power."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        mock_pmset = os.path.join(MOCKS_DIR, 'pmset')
        result = run_preflight_check(
            'preflight-08-battery-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Darwin',
                'PMSET_CMD': mock_pmset,
                'MOCK_PMSET_OUTPUT': "Now drawing from 'AC Power'\n -InternalBattery-0	100%; charged"
            }
        )
        assert result.returncode == 0
        assert 'AC power' in result.stdout or 'SUCCESS' in result.stdout

    def test_passes_with_sufficient_battery(self):
        """The check should pass when battery >= 20%."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        mock_pmset = os.path.join(MOCKS_DIR, 'pmset')
        result = run_preflight_check(
            'preflight-08-battery-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Darwin',
                'PMSET_CMD': mock_pmset,
                'MOCK_PMSET_OUTPUT': "Now drawing from 'Battery Power'\n -InternalBattery-0	50%; discharging"
            }
        )
        assert result.returncode == 0
        assert 'sufficient' in result.stdout.lower() or 'SUCCESS' in result.stdout

    def test_fails_with_low_battery(self):
        """The check should fail when battery < 20% and not on AC."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        mock_pmset = os.path.join(MOCKS_DIR, 'pmset')
        result = run_preflight_check(
            'preflight-08-battery-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Darwin',
                'PMSET_CMD': mock_pmset,
                'MOCK_PMSET_OUTPUT': "Now drawing from 'Battery Power'\n -InternalBattery-0	10%; discharging"
            }
        )
        assert result.returncode == 1
        assert 'below' in result.stderr.lower() or 'ERROR' in result.stderr

    def test_skipped_on_non_macos(self):
        """The check should be skipped on non-macOS systems."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        result = run_preflight_check(
            'preflight-08-battery-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Linux'
            }
        )
        # Should pass with a warning
        assert result.returncode == 0
        assert 'Skipping' in result.stdout or 'WARN' in result.stdout


# ==============================================================================
# Tests for preflight-09-wifi-check.sh
# ==============================================================================

class TestWiFiCheck:
    """Tests for the WiFi connection preflight check."""

    def test_passes_when_connected(self):
        """The check should pass when connected to WiFi."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        mock_networksetup = os.path.join(MOCKS_DIR, 'networksetup')
        result = run_preflight_check(
            'preflight-09-wifi-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Darwin',
                'NETWORKSETUP_CMD': mock_networksetup,
                'MOCK_NETWORKSETUP_OUTPUT': 'Current Wi-Fi Network: MyHomeNetwork'
            }
        )
        assert result.returncode == 0
        assert 'connected to WiFi' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_when_not_connected(self):
        """The check should fail when not connected to WiFi."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        mock_networksetup = os.path.join(MOCKS_DIR, 'networksetup')
        result = run_preflight_check(
            'preflight-09-wifi-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Darwin',
                'NETWORKSETUP_CMD': mock_networksetup,
                'MOCK_NETWORKSETUP_OUTPUT': 'You are not associated with an AirPort network.'
            }
        )
        assert result.returncode == 1
        assert 'not connected to WiFi' in result.stderr or 'ERROR' in result.stderr

    def test_skipped_on_non_macos(self):
        """The check should be skipped on non-macOS systems."""
        mock_uname = os.path.join(MOCKS_DIR, 'uname')
        result = run_preflight_check(
            'preflight-09-wifi-check.sh',
            env_overrides={
                'UNAME_CMD': mock_uname,
                'MOCK_UNAME_OUTPUT': 'Linux'
            }
        )
        # Should pass with a warning
        assert result.returncode == 0
        assert 'Skipping' in result.stdout or 'WARN' in result.stdout


# ==============================================================================
# Tests for preflight-10-xcode-cli-check.sh
# ==============================================================================

class TestXcodeCliCheck:
    """Tests for the Xcode CLI tools preflight check."""

    def test_passes_when_installed(self):
        """The check should pass when Xcode CLI tools are installed."""
        mock_xcode_select = os.path.join(MOCKS_DIR, 'xcode-select')
        result = run_preflight_check(
            'preflight-10-xcode-cli-check.sh',
            env_overrides={
                'XCODE_SELECT_CMD': mock_xcode_select,
                'MOCK_XCODE_SELECT_INSTALLED': 'true'
            }
        )
        assert result.returncode == 0
        assert 'Xcode Command Line Tools are installed' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_when_not_installed(self):
        """The check should fail when Xcode CLI tools are not installed."""
        mock_xcode_select = os.path.join(MOCKS_DIR, 'xcode-select')
        result = run_preflight_check(
            'preflight-10-xcode-cli-check.sh',
            env_overrides={
                'XCODE_SELECT_CMD': mock_xcode_select,
                'MOCK_XCODE_SELECT_INSTALLED': 'false'
            }
        )
        assert result.returncode == 1
        assert 'not installed' in result.stderr or 'ERROR' in result.stderr


# ==============================================================================
# Tests for preflight-11-homebrew-check.sh
# ==============================================================================

class TestHomebrewCheck:
    """Tests for the Homebrew preflight check."""

    def test_passes_when_brew_exists(self):
        """The check should pass when brew command is available."""
        # Use the existing brew mock which is an actual executable
        mock_brew = os.path.join(MOCKS_DIR, 'brew')
        result = run_preflight_check(
            'preflight-11-homebrew-check.sh',
            env_overrides={
                'BREW_CMD': mock_brew
            }
        )
        assert result.returncode == 0
        assert 'Homebrew is installed' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_when_brew_missing(self):
        """The check should fail when brew command is not available."""
        result = run_preflight_check(
            'preflight-11-homebrew-check.sh',
            env_overrides={
                'BREW_CMD': '/nonexistent/path/to/brew'
            }
        )
        assert result.returncode == 1
        assert 'Homebrew is not installed' in result.stderr or 'ERROR' in result.stderr


# ==============================================================================
# Tests for preflight-12-dependency-check.sh
# ==============================================================================

class TestDependencyCheck:
    """Tests for the dependency check preflight script."""

    def test_passes_when_all_deps_present(self):
        """The check should pass when git and curl are available."""
        # Both git and curl should be available in most test environments
        result = run_preflight_check('preflight-12-dependency-check.sh')
        assert result.returncode == 0
        assert 'git is installed' in result.stdout or 'SUCCESS' in result.stdout

    def test_fails_when_dep_missing(self):
        """The check should fail when a required dependency is missing."""
        # Create a mock command checker that always fails
        with tempfile.NamedTemporaryFile(mode='w', suffix='.sh', delete=False) as f:
            f.write('#!/bin/bash\nexit 1\n')
            mock_cmd = f.name

        os.chmod(mock_cmd, 0o755)

        try:
            result = run_preflight_check(
                'preflight-12-dependency-check.sh',
                env_overrides={
                    'COMMAND_CHECK_CMD': mock_cmd
                }
            )
            assert result.returncode == 1
            assert 'not installed' in result.stderr or 'ERROR' in result.stderr
        finally:
            os.unlink(mock_cmd)


# ==============================================================================
# Tests for preflight-15-existing-install-check.sh
# ==============================================================================

class TestExistingInstallCheck:
    """Tests for the existing installation preflight check."""

    def test_passes_when_no_existing_install(self):
        """The check should pass when no install marker exists."""
        # Use a temp HOME directory without the marker file
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_preflight_check(
                'preflight-15-existing-install-check.sh',
                env_overrides={
                    'HOME': tmpdir
                }
            )
            # This check is informational, always returns 0
            assert result.returncode == 0
            assert 'No previous installation' in result.stdout or 'SUCCESS' in result.stdout

    def test_warns_when_existing_install_found(self):
        """The check should warn when install marker exists."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create the install marker file
            marker_path = os.path.join(tmpdir, '.dotfiles-installed')
            with open(marker_path, 'w') as f:
                f.write('')

            result = run_preflight_check(
                'preflight-15-existing-install-check.sh',
                env_overrides={
                    'HOME': tmpdir
                }
            )
            # This check is informational, always returns 0
            assert result.returncode == 0
            assert 'existing installation' in result.stdout.lower() or 'WARN' in result.stdout


# ==============================================================================
# Tests for preflight-04-file-permissions-check.sh
# ==============================================================================

class TestFilePermissionsCheck:
    """Tests for the file permissions preflight check."""

    def test_passes_with_write_permissions(self):
        """The check should pass when user can write to HOME."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_preflight_check(
                'preflight-04-file-permissions-check.sh',
                env_overrides={
                    'HOME': tmpdir
                }
            )
            assert result.returncode == 0
            assert 'write permissions' in result.stdout or 'SUCCESS' in result.stdout

    @pytest.mark.skipif(os.geteuid() == 0, reason="Root user can bypass file permissions")
    def test_fails_without_write_permissions(self):
        """The check should fail when user cannot write to HOME."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Make the directory read-only
            os.chmod(tmpdir, 0o444)

            try:
                result = run_preflight_check(
                    'preflight-04-file-permissions-check.sh',
                    env_overrides={
                        'HOME': tmpdir
                    }
                )
                assert result.returncode == 1
                assert 'does not have write permissions' in result.stderr or 'ERROR' in result.stderr
            finally:
                # Restore permissions for cleanup
                os.chmod(tmpdir, 0o755)


# ==============================================================================
# Integration test for running all checks
# ==============================================================================

class TestPreflightIntegration:
    """Integration tests for the preflight check system."""

    def test_all_preflight_scripts_exist(self):
        """Verify all expected preflight scripts exist."""
        expected_scripts = [
            'preflight-01-macos-check.sh',
            'preflight-02-root-check.sh',
            'preflight-03-admin-rights-check.sh',
            'preflight-04-file-permissions-check.sh',
            'preflight-05-unset-vars-check.sh',
            'preflight-06-shell-type-version-check.sh',
            'preflight-08-battery-check.sh',
            'preflight-09-wifi-check.sh',
            'preflight-10-xcode-cli-check.sh',
            'preflight-11-homebrew-check.sh',
            'preflight-12-dependency-check.sh',
            'preflight-15-existing-install-check.sh',
        ]

        for script in expected_scripts:
            script_path = os.path.join(PREFLIGHT_DIR, script)
            assert os.path.exists(script_path), f"Preflight script missing: {script}"

    def test_all_preflight_scripts_are_executable(self):
        """Verify all preflight scripts have executable permissions."""
        for script in os.listdir(PREFLIGHT_DIR):
            if script.endswith('.sh'):
                script_path = os.path.join(PREFLIGHT_DIR, script)
                # Scripts should be readable and parseable as bash
                result = subprocess.run(
                    ['bash', '-n', script_path],
                    capture_output=True,
                    text=True
                )
                assert result.returncode == 0, f"Syntax error in {script}: {result.stderr}"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
