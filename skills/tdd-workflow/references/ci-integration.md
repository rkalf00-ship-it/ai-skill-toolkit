# CI / Watch / Hook Integration

> Reference for the [tdd-workflow](../SKILL.md) skill.

## Watch Mode During Development

```bash
npm test -- --watch        # Jest / Vitest
pytest-watch               # Python
ginkgo watch               # Go (via Ginkgo)
```

Tests run automatically on file changes — keep this on while writing the
RED test and the implementation.

## Pre-Commit Hook (Local)

```bash
# Runs before every commit (configured via husky / pre-commit / lefthook)
npm test && npm run lint
```

Keep pre-commit hooks fast (< 30s ideal). Long-running suites belong in
pre-push or CI, not pre-commit.

## CI Integration (GitHub Actions)

```yaml
- name: Run Tests
  run: npm test -- --coverage
- name: Upload Coverage
  uses: codecov/codecov-action@v3
```

Match the runner version to local dev (Node 20 in CI when devs use Node 20)
to catch version-specific bugs early.

## When CI Fails But Local Passes

Common causes:
- **Different time zones** (CI is UTC; tests assume local TZ).
- **Different locales** (number / date formatting differs).
- **Race conditions** that surface only under CI's parallelism / load.
- **Implicit cleanup** between tests works locally because of test order;
  fails on CI's parallel sharding.
- **Missing env var** (CI doesn't have your `.env.local`).

Fix at the source — tests should be hermetic.
