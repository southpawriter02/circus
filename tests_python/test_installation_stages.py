#!/usr/bin/env python3
"""
test_installation_stages.py

Unit tests for individual installation stages in dry-run mode.
These tests verify that:
- Stages complete successfully in dry-run mode
- Dry-run mode produces expected "[Dry Run]" output
- No actual system changes are made during dry-run
"""

import subprocess
import os
import tempfile
import shutil
import pytest

# Get the absolute path to the project root
PROJECT_ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), '..'))
INSTALL_DIR = os.path.join(PROJECT_ROOT, 'install')
HELPERS_PATH = os.path.join(PROJECT_ROOT, 'lib', 'helpers.sh')
INIT_PATH = os.path.join(PROJECT_ROOT, 'lib', 'init.sh')


def run_stage(stage_script: str, env_overrides: dict = None, timeout: int = 30) -> subprocess.CompletedProcess:
    """
    Run an installation stage script with optional environment variable overrides.

    Args:
        stage_script: The name of the stage script (e.g., '03-homebrew-installation.sh')
        env_overrides: Dictionary of environment variables to set
        timeout: Maximum time to wait for stage completion

    Returns:
        CompletedProcess with returncode, stdout, stderr
    """
    stage_path = os.path.join(INSTALL_DIR, stage_script)

    # Create the test environment
    env = os.environ.copy()
    env['DRY_RUN_MODE'] = 'true'
    env['INTERACTIVE_MODE'] = 'false'
    env['FORCE_MODE'] = 'false'
    # Disable terminal UI features that cause encoding issues
    env['TERM'] = 'dumb'

    # Apply any overrides
    if env_overrides:
        env.update(env_overrides)

    # Build the bash command that initializes and runs the stage
    bash_cmd = f'''
        source "{INIT_PATH}"
        source "{stage_path}"
    '''

    # Use errors='replace' to handle any encoding issues from terminal UI characters
    result = subprocess.run(
        ['bash', '-c', bash_cmd],
        capture_output=True,
        timeout=timeout,
        env=env
    )

    # Decode with error handling
    stdout = result.stdout.decode('utf-8', errors='replace') if isinstance(result.stdout, bytes) else result.stdout
    stderr = result.stderr.decode('utf-8', errors='replace') if isinstance(result.stderr, bytes) else result.stderr

    return subprocess.CompletedProcess(
        result.args,
        result.returncode,
        stdout,
        stderr
    )


# ==============================================================================
# Tests for Stage 03: Homebrew Installation
# ==============================================================================

class TestHomebrewStage:
    """Tests for the Homebrew installation stage."""

    def test_dry_run_does_not_install_homebrew(self):
        """Dry run should not actually install Homebrew."""
        result = run_stage('03-homebrew-installation.sh')
        assert result.returncode == 0
        # Should contain dry run messages
        assert '[Dry Run]' in result.stdout

    def test_dry_run_shows_brew_commands(self):
        """Dry run should show what brew commands would be run."""
        result = run_stage('03-homebrew-installation.sh')
        # Should indicate what would happen
        assert 'Homebrew' in result.stdout or 'brew' in result.stdout.lower()


# ==============================================================================
# Tests for Stage 05: Oh My Zsh Installation
# ==============================================================================

class TestOhMyZshStage:
    """Tests for the Oh My Zsh installation stage."""

    def test_dry_run_completes_successfully(self):
        """Dry run should complete without errors."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '05-oh-my-zsh-installation.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert result.returncode == 0
            assert 'Stage 05' in result.stdout

    def test_dry_run_shows_would_install_omz(self):
        """Dry run should show it would install Oh My Zsh."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '05-oh-my-zsh-installation.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert '[Dry Run]' in result.stdout
            assert 'Oh My Zsh' in result.stdout

    def test_dry_run_shows_would_install_plugins(self):
        """Dry run should show it would install plugins."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '05-oh-my-zsh-installation.sh',
                env_overrides={'HOME': tmpdir}
            )
            # Should mention plugins
            assert 'plugin' in result.stdout.lower()

    def test_dry_run_does_not_create_directories(self):
        """Dry run should not create any directories."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '05-oh-my-zsh-installation.sh',
                env_overrides={'HOME': tmpdir}
            )
            # The .oh-my-zsh directory should NOT be created
            omz_dir = os.path.join(tmpdir, '.oh-my-zsh')
            assert not os.path.exists(omz_dir)

    def test_skips_when_omz_exists(self):
        """Should skip installation when Oh My Zsh is already installed."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Pre-create the .oh-my-zsh directory
            omz_dir = os.path.join(tmpdir, '.oh-my-zsh')
            os.makedirs(omz_dir)

            result = run_stage(
                '05-oh-my-zsh-installation.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert result.returncode == 0
            assert 'already installed' in result.stdout.lower()


# ==============================================================================
# Tests for Stage 09: Dotfiles Deployment
# ==============================================================================

class TestDotfilesStage:
    """Tests for the Dotfiles deployment stage."""

    def test_dry_run_completes_successfully(self):
        """Dry run should complete without errors."""
        with tempfile.TemporaryDirectory() as tmpdir:
            # Create minimal required structure
            omz_plugins = os.path.join(tmpdir, '.oh-my-zsh', 'custom', 'plugins')
            os.makedirs(omz_plugins, exist_ok=True)

            result = run_stage(
                '09-dotfiles-deployment.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert result.returncode == 0
            assert 'Stage 09' in result.stdout

    def test_dry_run_shows_symlink_operations(self):
        """Dry run should show symlink operations."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '09-dotfiles-deployment.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert '[Dry Run]' in result.stdout
            assert 'symlink' in result.stdout.lower()

    def test_dry_run_does_not_create_symlinks(self):
        """Dry run should not create any symlinks."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '09-dotfiles-deployment.sh',
                env_overrides={'HOME': tmpdir}
            )
            # The .zshrc symlink should NOT be created
            zshrc = os.path.join(tmpdir, '.zshrc')
            assert not os.path.exists(zshrc)

    def test_dry_run_shows_executable_operations(self):
        """Dry run should show making plugins executable."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '09-dotfiles-deployment.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert 'executable' in result.stdout.lower()


# ==============================================================================
# Tests for Stage 10: Git Configuration
# ==============================================================================

class TestGitConfigStage:
    """Tests for the Git configuration stage."""

    def test_dry_run_completes_successfully(self):
        """Dry run should complete without errors."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '10-git-configuration.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert result.returncode == 0
            assert 'Stage 10' in result.stdout

    def test_dry_run_shows_symlink_operations(self):
        """Dry run should show what symlinks would be created."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '10-git-configuration.sh',
                env_overrides={'HOME': tmpdir}
            )
            assert '[Dry Run]' in result.stdout
            assert 'symlink' in result.stdout.lower() or 'gitconfig' in result.stdout.lower()

    def test_dry_run_does_not_create_files(self):
        """Dry run should not create any git config files."""
        with tempfile.TemporaryDirectory() as tmpdir:
            result = run_stage(
                '10-git-configuration.sh',
                env_overrides={'HOME': tmpdir}
            )
            # The .gitconfig file should NOT be created
            gitconfig = os.path.join(tmpdir, '.gitconfig')
            assert not os.path.exists(gitconfig)


# ==============================================================================
# Tests for Stage 14: Cleanup
# ==============================================================================

class TestCleanupStage:
    """Tests for the Cleanup stage."""

    def test_dry_run_completes_successfully(self):
        """Dry run should complete without errors."""
        result = run_stage('14-cleanup.sh')
        assert result.returncode == 0
        assert 'Stage 14' in result.stdout

    def test_dry_run_shows_cleanup_commands(self):
        """Dry run should show what cleanup commands would be run."""
        result = run_stage('14-cleanup.sh')
        # Should mention dry run for brew cleanup
        assert '[Dry Run]' in result.stdout or 'cleanup' in result.stdout.lower()


# ==============================================================================
# Generic Stage Tests
# ==============================================================================

class TestStageScriptSyntax:
    """Tests to verify all stage scripts have valid bash syntax."""

    def get_stage_scripts(self):
        """Get a list of all stage scripts."""
        scripts = []
        for f in os.listdir(INSTALL_DIR):
            if f.endswith('.sh') and f[0:2].isdigit():
                scripts.append(f)
        return sorted(scripts)

    def test_all_stages_have_valid_syntax(self):
        """All stage scripts should have valid bash syntax."""
        for script in self.get_stage_scripts():
            script_path = os.path.join(INSTALL_DIR, script)
            result = subprocess.run(
                ['bash', '-n', script_path],
                capture_output=True,
                text=True
            )
            assert result.returncode == 0, f"Syntax error in {script}: {result.stderr}"

    def test_all_stages_define_main_function(self):
        """All stage scripts should define a main() function."""
        for script in self.get_stage_scripts():
            script_path = os.path.join(INSTALL_DIR, script)
            with open(script_path, 'r') as f:
                content = f.read()
            assert 'main()' in content or 'main ()' in content, \
                f"Stage {script} does not define a main() function"


if __name__ == '__main__':
    pytest.main([__file__, '-v'])
