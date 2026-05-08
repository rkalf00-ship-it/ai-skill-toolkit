# CI / CD Integration

> Reference for the [e2e-testing](../SKILL.md) skill.

## GitHub Actions

```yaml
# .github/workflows/e2e.yml
name: E2E Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test
        env:
          BASE_URL: ${{ vars.STAGING_URL }}
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: playwright-report
          path: playwright-report/
          retention-days: 30
```

`if: always()` uploads the report even when tests fail — that's exactly when
you need it.

## Performance Tips

- **Cache `~/.cache/ms-playwright`** for browser binaries (`actions/cache@v4`).
- **Shard tests** across jobs for large suites:
  ```yaml
  strategy:
    matrix:
      shard: [1/4, 2/4, 3/4, 4/4]
  steps:
    - run: npx playwright test --shard ${{ matrix.shard }}
  ```
- **Run only changed projects** in monorepos via path filters.
- **Pre-warm `webServer`** if the app takes >30s to boot.

## Common CI Pitfalls

- **Headless rendering differences**: pixel-diff tests vary between local
  rendering and Linux CI fonts. Either use the same OS for visual regression,
  or generate baselines on CI.
- **Single worker contention**: `workers: 1` in CI is safe but slow. Move to
  `workers: 2-4` once stable.
- **Browser binary mismatch**: pin Playwright version (`package.json`) and run
  `npx playwright install` matching it.
