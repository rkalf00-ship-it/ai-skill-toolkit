# Test Report Template

> Reference for the [e2e-testing](../SKILL.md) skill.

```markdown
# E2E Test Report

**Date:** YYYY-MM-DD HH:MM
**Duration:** Xm Ys
**Status:** PASSING / FAILING

## Summary
- Total: X | Passed: Y (Z%) | Failed: A | Flaky: B | Skipped: C

## Failed Tests

### test-name
**File:** `tests/e2e/feature.spec.ts:45`
**Error:** Expected element to be visible
**Screenshot:** artifacts/failed.png
**Recommended Fix:** [description]

## Artifacts
- HTML Report: playwright-report/index.html
- Screenshots: artifacts/*.png
- Videos: artifacts/videos/*.webm
- Traces: artifacts/*.zip
```

Use this format for human-readable summaries on PR comments or release notes.
For machine consumption, the Playwright JSON / JUnit reporter is the right
output (already configured via `reporter` in `playwright.config.ts`).
