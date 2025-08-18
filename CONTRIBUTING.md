# Contributing to the Dotfiles Flying Circus

First off, thank you for considering contributing! This project is a labor of love, and every contribution helps to make it better.

This document provides guidelines for contributing to the project to ensure that the codebase remains high-quality, consistent, and maintainable.

## Getting Started: Your First Contribution

If you're looking for a way to contribute, a great place to start is by looking at the [Feature Roadmap](ROADMAP.md) or the open issues on GitHub.

### The Development Workflow

To ensure that your contributions are consistent with the project's standards, please follow this development workflow.

**Step 1: Set Up the Development Environment**

Before you begin, you need to set up the development environment. This is done by running the main installer with the `developer` role. This will install all the necessary tools, including the `pre-commit` framework.

```bash
./install.sh --role developer
```

**Step 2: Activate the Pre-Commit Hooks**

This project uses a `pre-commit` hook to automatically enforce code quality and run tests before any commit is made. This is a critical part of our quality assurance process.

To activate these hooks for your local repository, run the developer setup script:

```bash
./bin/setup-dev
```

This script will install the hooks defined in `.pre-commit-config.yaml`. Now, every time you run `git commit`, the hooks will automatically run.

For more details on the specific tests that are run and the overall testing strategy, please see the [Testing Guide](TESTING.md).

**Step 3: Make Your Changes**

Now you're ready to make your changes. Create a new branch for your feature or bugfix:

```bash
git checkout -b my-awesome-feature
```

**Step 4: Commit Your Changes**

When you are ready to commit, the pre-commit hooks will run automatically. If they find any issues (e.g., a `shellcheck` error or a failing test), the commit will be aborted. Simply fix the issues and try to commit again.

**Step 5: Open a Pull Request**

Once your changes are committed and pushed to your fork, you can open a pull request against the main repository.

## Code Style and Philosophy

*   **Clarity and Readability:** Write code that is easy to understand. Use clear variable names and add comments to explain complex logic.
*   **Robustness:** Use the helper functions in `lib/helpers.sh` for logging and error handling. Use `die "message"` for handling expected errors gracefully.
*   **Consistency:** Follow the existing code style. The `shfmt` pre-commit hook will help to automate this.

Thank you for your contribution!
