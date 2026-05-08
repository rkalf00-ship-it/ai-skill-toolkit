---
name: e2e-testing
id: e2e-testing
description: Use for Playwright end-to-end testing — Page Object Model, configuration, locator strategy, flaky test triage, artifact (screenshot / video / trace) management, CI integration. Activates on Playwright, E2E test, end-to-end test, page object model, browser automation, flaky test, test artifacts. Skip when only unit, integration, or API tests are needed (use tdd-workflow). Skip if the project uses Cypress / Selenium / WebDriver — this skill is Playwright-specific; use the relevant framework's docs for those.
category: quality
version: 1.1.0
triggers:
  positive:
    - Playwright
    - E2E test
    - end-to-end test
    - page object model
    - browser automation
    - flaky test
    - test artifacts
    - test screenshot
    - test video
  negative:
    - unit test only
    - integration test only
    - API test only
requires:
  bin: [node]
---

# E2E Testing Patterns (Playwright)

Patterns for stable, fast, maintainable Playwright test suites.

## Contract

Inputs:
- Target user flow, application URL or launch command, browser / device targets.
- Authentication, fixture, seed data, external service constraints.
- Existing E2E framework conventions if present.

Outputs:
- Test plan or Playwright test changes.
- Locator strategy, fixtures, artifact settings, CI notes.
- Failure triage with screenshot / trace / video paths when tests run.

Verification:
- Prefer semantic locators and deterministic waits.
- Run the smallest relevant E2E subset before broader suites.
- Report skipped browser / auth prerequisites explicitly.

## When to Activate

- Adding or maintaining Playwright tests
- Designing the Page Object Model for a new feature
- Diagnosing flaky tests
- Configuring CI for browser tests
- Choosing artifact retention strategy
- Setting up wallet / web3 or financial flow E2E tests

## Quick Decision Guide

| Need | Pattern | Reference |
|------|---------|-----------|
| Reusable per-page actions | Page Object Model | `references/page-objects.md` |
| Stable locator | `data-testid` or semantic role | `references/page-objects.md` |
| Wait for async work | `waitForResponse` / locator auto-wait | `references/flaky-tests.md` |
| Reproduce intermittent failure | `--repeat-each=10` | `references/flaky-tests.md` |
| Browser / device matrix | `playwright.config.ts` projects | `references/configuration.md` |
| Capture failure evidence | Trace + screenshot + video | `references/artifacts.md` |
| Run in CI | GitHub Actions matrix + artifact upload | `references/ci.md` |
| Wallet auth in tests | `addInitScript` to inject mock provider | `references/web3-and-financial.md` |
| Skip dangerous tests in prod | `test.skip(process.env.NODE_ENV === 'production', ...)` | `references/web3-and-financial.md` |

## Reference Index

- `references/page-objects.md` — POM structure, locator best practices, test structure.
- `references/configuration.md` — `playwright.config.ts` template.
- `references/flaky-tests.md` — quarantine, repeat-each, race / network / animation fixes.
- `references/artifacts.md` — screenshots, traces, videos.
- `references/ci.md` — GitHub Actions workflow, artifact upload, retention.
- `references/test-report.md` — report template.
- `references/web3-and-financial.md` — wallet mocking, financial flow safety.

## Test File Organization

```
tests/
├── e2e/
│   ├── auth/
│   │   ├── login.spec.ts
│   │   ├── logout.spec.ts
│   │   └── register.spec.ts
│   ├── features/
│   │   ├── browse.spec.ts
│   │   ├── search.spec.ts
│   │   └── create.spec.ts
│   └── api/
│       └── endpoints.spec.ts
├── pages/
│   ├── ItemsPage.ts
│   └── AuthPage.ts
├── fixtures/
│   ├── auth.ts
│   └── data.ts
└── playwright.config.ts
```

## Stable-Test Principles

- **Auto-waiting locators only.** `page.locator(...).click()` retries until the
  element is actionable; `page.click(selector)` does not.
- **No arbitrary `waitForTimeout`.** Wait for a specific condition (response,
  selector visible, network idle).
- **Single source for selectors.** Centralize in Page Objects so a UI rename
  changes one file, not 30 tests.
- **Each test sets up its own data.** Don't depend on previous test state.
- **Fail fast in CI**: `forbidOnly: !!process.env.CI` so `test.only` left in a PR fails the build.
