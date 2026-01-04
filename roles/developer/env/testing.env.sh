# ==============================================================================
# Testing Environment Variables
#
# Configuration for test runners and testing frameworks including Jest, pytest,
# Mocha, Playwright, and Cypress. Optimizes local test execution.
#
# USAGE:
#   These variables are set when the developer role is active.
#   Customize based on your testing stack and preferences.
#
# NOTE:
#   The CI variable is intentionally NOT set here to distinguish local
#   development from CI environments.
# ==============================================================================

# --- Test Environment Identification -----------------------------------------

# Indicate test environment (used by many frameworks)
export TEST_ENV="${TEST_ENV:-test}"
export NODE_ENV_TEST="${NODE_ENV_TEST:-test}"

# Explicitly NOT setting CI - local dev is not CI
# CI should only be set by actual CI systems (GitHub Actions, CircleCI, etc.)

# --- Terminal Colors for Test Output -----------------------------------------

# Force color output in test runners (nice for local development)
export FORCE_COLOR="${FORCE_COLOR:-1}"

# Mocha colors
export MOCHA_COLORS="${MOCHA_COLORS:-1}"

# TAP (Test Anything Protocol) colors
export TAP_COLORS="${TAP_COLORS:-1}"

# Chalk (used by many JS testing tools)
export CHALK_FORCE_COLOR="${CHALK_FORCE_COLOR:-1}"

# --- Coverage Configuration --------------------------------------------------

# Coverage output directory
export COVERAGE_DIR="${COVERAGE_DIR:-./coverage}"

# Minimum coverage thresholds (used by some tools)
export COVERAGE_THRESHOLD_LINES="${COVERAGE_THRESHOLD_LINES:-80}"
export COVERAGE_THRESHOLD_FUNCTIONS="${COVERAGE_THRESHOLD_FUNCTIONS:-80}"
export COVERAGE_THRESHOLD_BRANCHES="${COVERAGE_THRESHOLD_BRANCHES:-80}"
export COVERAGE_THRESHOLD_STATEMENTS="${COVERAGE_THRESHOLD_STATEMENTS:-80}"

# Istanbul/nyc configuration
export NYC_REPORTER="${NYC_REPORTER:-text,lcov}"

# --- Jest Configuration ------------------------------------------------------

# Jest worker configuration
# Use half the cores for better local performance
export JEST_WORKERS="${JEST_WORKERS:-50%}"

# Jest silent mode (less verbose, set to false for debugging)
# export JEST_SILENT="${JEST_SILENT:-false}"

# Jest max workers (alternative to percentage)
# export JEST_MAX_WORKERS="${JEST_MAX_WORKERS:-4}"

# Jest cache directory
export JEST_CACHE_DIRECTORY="${JEST_CACHE_DIRECTORY:-/tmp/jest-cache}"

# Disable Jest's watch mode notifications
export JEST_NOTIFY="${JEST_NOTIFY:-false}"

# --- pytest Configuration ----------------------------------------------------

# pytest default options
# -v = verbose, --tb=short = shorter tracebacks
export PYTEST_ADDOPTS="${PYTEST_ADDOPTS:--v --tb=short}"

# pytest cache directory
export PYTEST_CACHE_DIR="${PYTEST_CACHE_DIR:-.pytest_cache}"

# pytest plugins to disable (uncomment as needed)
# export PYTEST_PLUGINS="${PYTEST_PLUGINS:-no:randomly}"

# --- Mocha Configuration -----------------------------------------------------

# Mocha reporter
export MOCHA_REPORTER="${MOCHA_REPORTER:-spec}"

# Mocha timeout (ms)
export MOCHA_TIMEOUT="${MOCHA_TIMEOUT:-5000}"

# Mocha retries for flaky tests
export MOCHA_RETRIES="${MOCHA_RETRIES:-0}"

# --- Vitest Configuration ----------------------------------------------------

# Vitest reporter
export VITEST_REPORTER="${VITEST_REPORTER:-default}"

# Vitest threads
export VITEST_POOL="${VITEST_POOL:-threads}"

# --- E2E Testing Configuration -----------------------------------------------

# Base URL for E2E tests
export E2E_BASE_URL="${E2E_BASE_URL:-http://localhost:3000}"

# E2E test timeout (ms)
export E2E_TIMEOUT="${E2E_TIMEOUT:-30000}"

# Headless mode for E2E tests
export E2E_HEADLESS="${E2E_HEADLESS:-true}"

# --- Playwright Configuration ------------------------------------------------

# Playwright browser installation path
export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-$HOME/.cache/ms-playwright}"

# Playwright skip browser download (if already installed)
# export PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD="${PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD:-1}"

# Playwright test timeout
export PLAYWRIGHT_TIMEOUT="${PLAYWRIGHT_TIMEOUT:-30000}"

# Playwright headless mode
export PLAYWRIGHT_HEADLESS="${PLAYWRIGHT_HEADLESS:-true}"

# Playwright slow motion (ms delay between actions, for debugging)
# export PLAYWRIGHT_SLOW_MO="${PLAYWRIGHT_SLOW_MO:-0}"

# --- Cypress Configuration ---------------------------------------------------

# Cypress cache folder
export CYPRESS_CACHE_FOLDER="${CYPRESS_CACHE_FOLDER:-$HOME/.cache/Cypress}"

# Cypress run in headless mode
export CYPRESS_HEADLESS="${CYPRESS_HEADLESS:-true}"

# Cypress base URL
export CYPRESS_BASE_URL="${CYPRESS_BASE_URL:-http://localhost:3000}"

# Cypress video recording (disable for faster runs)
export CYPRESS_VIDEO="${CYPRESS_VIDEO:-false}"

# Cypress screenshots on failure
export CYPRESS_SCREENSHOT_ON_RUN_FAILURE="${CYPRESS_SCREENSHOT_ON_RUN_FAILURE:-true}"

# Cypress retries
export CYPRESS_RETRIES="${CYPRESS_RETRIES:-0}"

# --- Selenium/WebDriver Configuration ----------------------------------------

# Selenium Grid URL
export SELENIUM_REMOTE_URL="${SELENIUM_REMOTE_URL:-http://localhost:4444/wd/hub}"

# WebDriver browser
export WEBDRIVER_BROWSER="${WEBDRIVER_BROWSER:-chrome}"

# ChromeDriver path (if not in PATH)
# export CHROMEDRIVER_PATH="${CHROMEDRIVER_PATH:-/usr/local/bin/chromedriver}"

# --- Test Parallelization ----------------------------------------------------

# Enable parallel test execution
export TEST_PARALLEL="${TEST_PARALLEL:-true}"

# Number of parallel test processes
export TEST_PARALLEL_JOBS="${TEST_PARALLEL_JOBS:-auto}"

# --- Snapshot Testing --------------------------------------------------------

# Update snapshots mode
# Options: none, new, all
export SNAPSHOT_UPDATE="${SNAPSHOT_UPDATE:-none}"

# --- Test Data & Fixtures ----------------------------------------------------

# Test fixtures directory
export TEST_FIXTURES_DIR="${TEST_FIXTURES_DIR:-./tests/fixtures}"

# Test data directory
export TEST_DATA_DIR="${TEST_DATA_DIR:-./tests/data}"

# --- Mock Server Configuration -----------------------------------------------

# Mock server port
export MOCK_SERVER_PORT="${MOCK_SERVER_PORT:-3001}"

# MSW (Mock Service Worker) settings
export MSW_QUIET="${MSW_QUIET:-true}"

# --- Test Database -----------------------------------------------------------

# Use separate test database
export TEST_DATABASE_URL="${TEST_DATABASE_URL:-postgresql://localhost:5432/test_db}"

# Redis test database (database 1 instead of 0)
export TEST_REDIS_URL="${TEST_REDIS_URL:-redis://localhost:6379/1}"

# --- Debugging Tests ---------------------------------------------------------

# Enable debug output for tests
# export DEBUG="${DEBUG:-test:*}"

# Node.js inspect for test debugging
# export NODE_OPTIONS="${NODE_OPTIONS:---inspect}"

# --- Helper Functions --------------------------------------------------------

# Run tests with coverage
testcov() {
    npm run test -- --coverage "$@"
}

# Run tests in watch mode
testwatch() {
    npm run test -- --watch "$@"
}

# Run single test file
testfile() {
    npm run test -- "$1"
}

# Show test environment info
testinfo() {
    echo "=== Test Environment Info ==="
    echo ""
    echo "General:"
    echo "  TEST_ENV: $TEST_ENV"
    echo "  FORCE_COLOR: $FORCE_COLOR"
    echo ""
    echo "Coverage:"
    echo "  COVERAGE_DIR: $COVERAGE_DIR"
    echo ""
    echo "Jest:"
    echo "  JEST_WORKERS: $JEST_WORKERS"
    echo ""
    echo "E2E:"
    echo "  E2E_BASE_URL: $E2E_BASE_URL"
    echo "  Playwright browsers: $PLAYWRIGHT_BROWSERS_PATH"
    echo "  Cypress cache: $CYPRESS_CACHE_FOLDER"
}
