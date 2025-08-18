# Working with Jules: A Guide to Effective Testing

This document provides recommendations for how to best collaborate with me, Jules, on tasks involving unit tests. By following these guidelines, you can help me work more efficiently and effectively, leading to faster and more reliable results.

## 1. Providing a Clear Environment Setup

A well-defined environment is the most critical factor for my ability to run and validate tests. My sandbox environment is a clean slate, so I rely entirely on your instructions to configure it correctly.

**Recommendations:**

*   **Use `AGENTS.md` or `README.md`:** Create or update an `AGENTS.md` or `README.md` file in the root of your repository with a dedicated "Testing" or "Development Setup" section. This is the first place I will look for instructions.
*   **Dependency Management:**
    *   Provide the **exact command** to install all necessary dependencies (e.g., `pip install -r requirements.txt`, `npm ci`, `bundle install`).
    *   **Use lock files** (`package-lock.json`, `Gemfile.lock`, `poetry.lock`, `pnpm-lock.yaml`). This is a best practice that ensures I use the exact same dependency versions that you are using, which prevents "works on my machine" issues.
    *   Specify the required versions of core technologies (e.g., Node.js 20.x, Python 3.11) if they are not enforced by project configuration files.
*   **Environment Variables:**
    *   List all required environment variables needed to run the application and its tests.
    *   Provide a template file like `.env.example` that I can copy to `.env`. This file should contain all necessary variable keys with placeholder or sensible default values.
*   **Local Services (Databases, Caches, etc.):**
    *   If your tests require services like a database or a Redis cache, provide clear instructions for starting them.
    *   **Docker is highly recommended.** A `docker-compose.yml` file is the most effective way to define and manage these services. I can easily run `docker-compose up -d` to get a consistent environment.
    *   Include any commands needed for database setup, such as running migrations or seeding the database with test data (e.g., `npm run db:migrate`, `python manage.py seed`).

## 2. Running the Test Suite

I need to know the precise commands to execute the tests and verify my changes.

**Recommendations:**

*   **Primary Test Command:** In your setup instructions, specify the single, simple command to run the entire test suite (e.g., `npm test`, `pytest`, `mvn clean verify`).
*   **Running Specific Tests:** Provide instructions on how to run a single test file or a subset of tests. This is extremely valuable for focused, test-driven development (TDD) and allows me to debug more efficiently (e.g., `pytest tests/test_specific_feature.py`, `npm test -- src/components/Button.test.js`).
*   **`package.json` Scripts:** For Node.js projects, ensure the `package.json` `scripts` section contains well-defined scripts for `test`, `test:watch`, `test:ci`, etc.

## 3. Designing for Testability

Code that is designed to be testable makes my job much easier and results in a more robust codebase.

**Recommendations:**

*   **Mocking and Stubbing:**
    *   **Backend:** Use standard mocking libraries like Python's `unittest.mock` or `pytest-mock`, or Java's Mockito. These allow me to isolate the code under test from external dependencies like third-party APIs or databases.
    *   **Frontend:** Use libraries like Jest's built-in mocking capabilities or `msw` (Mock Service Worker) to intercept and mock API requests from the browser. This prevents tests from failing due to network or backend issues.
*   **Dependency Injection (DI):** Design your code to receive its dependencies from the outside (e.g., as function arguments or constructor parameters) rather than creating them internally. This makes it trivial to provide mock dependencies during testing.
*   **Favor Pure Functions:** Where possible, write pure functions—functions that always produce the same output for the same input and have no side effects. They are the simplest to test and reason about.

## 4. Frontend Verification

Since I don't have a screen, I use a programmatic approach to verify visual changes in web applications.

**Solution: Playwright and Screenshot Testing**

*   I can write and execute Playwright scripts to perform automated end-to-end tests.
*   My process is as follows:
    1.  I add a "Frontend Verification" step to my plan.
    2.  I follow instructions to write a Playwright script that navigates to relevant pages, interacts with elements, and takes screenshots.
    3.  These screenshots serve as a "visual diff" that you can review to confirm the changes look correct before I submit my work.

## 5. Pre-existing Conditions

**Challenge:** If tests are already failing on the main branch, it's hard for me to distinguish between new failures I've introduced and existing ones.

**Recommendations:**

*   **Confirm a Green Build:** Before assigning me a task, it is incredibly helpful if you can confirm that the test suite runs successfully on the latest version of your main branch.
*   **Communicate Known Issues:** If there are known, intermittent, or long-standing test failures, please let me know about them in the task description or in the `AGENTS.md` file.
