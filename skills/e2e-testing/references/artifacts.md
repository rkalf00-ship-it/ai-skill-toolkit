# Artifact Management

> Reference for the [e2e-testing](../SKILL.md) skill.

## Screenshots

```typescript
await page.screenshot({ path: 'artifacts/after-login.png' })
await page.screenshot({ path: 'artifacts/full-page.png', fullPage: true })
await page.locator('[data-testid="chart"]')
  .screenshot({ path: 'artifacts/chart.png' })
```

`fullPage: true` captures everything in the scrollable region — useful for
visual diff but heavy on storage.

## Traces

In `playwright.config.ts`:

```typescript
use: { trace: 'on-first-retry' }
```

A trace records the entire browser session: DOM snapshots at each action,
network log, console output. Open with `npx playwright show-trace trace.zip`.

Manual trace control:
```typescript
await context.tracing.start({ screenshots: true, snapshots: true })
// ... test actions ...
await context.tracing.stop({ path: 'artifacts/trace.zip' })
```

## Video

```typescript
// In playwright.config.ts
use: {
  video: 'retain-on-failure',
}
```

`'retain-on-failure'` keeps video only when the test fails — saves storage.
For first-time test stabilization, use `'on'` to always record.

## Storage Hygiene

- CI: upload `playwright-report/` and `test-results/` as artifacts; set retention
  (e.g. 30 days) so storage costs don't grow forever.
- Local dev: `playwright-report/` and `test-results/` go in `.gitignore`.
- Don't commit screenshots / videos as test fixtures unless using visual
  regression intentionally — they make diffs unreviewable.
