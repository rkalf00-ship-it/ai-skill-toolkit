# Flaky Test Patterns

> Reference for the [e2e-testing](../SKILL.md) skill.

## Quarantine

```typescript
test('flaky: complex search', async ({ page }) => {
  test.fixme(true, 'Flaky - Issue #123')
  // test code...
})

test('conditional skip', async ({ page }) => {
  test.skip(process.env.CI, 'Flaky in CI - Issue #123')
  // test code...
})
```

`test.fixme` marks a known-broken test as expected-failure. `test.skip` excludes
it. Either is acceptable; what's not acceptable is leaving an unmarked flaky
test that intermittently fails CI.

## Identify Flakiness

```bash
npx playwright test tests/search.spec.ts --repeat-each=10
npx playwright test tests/search.spec.ts --retries=3
```

A test that fails 1 / 10 runs is flaky, not "passing". Investigate.

## Common Causes & Fixes

### Race conditions

```typescript
// Bad: assumes element is ready
await page.click('[data-testid="button"]')

// Good: auto-wait locator
await page.locator('[data-testid="button"]').click()
```

### Network timing

```typescript
// Bad: arbitrary timeout
await page.waitForTimeout(5000)

// Good: wait for specific condition
await page.waitForResponse(resp => resp.url().includes('/api/data'))
```

### Animation timing

```typescript
// Bad: click during animation
await page.click('[data-testid="menu-item"]')

// Good: wait for stability
await page.locator('[data-testid="menu-item"]').waitFor({ state: 'visible' })
await page.waitForLoadState('networkidle')
await page.locator('[data-testid="menu-item"]').click()
```

### Time-dependent assertions

```typescript
// Bad: assertion runs too soon
expect(await page.locator('.toast').textContent()).toBe('Saved')

// Good: poll until matches
await expect(page.locator('.toast')).toHaveText('Saved')
```

`expect(...).toHave*` polls — it's the right tool for assertions about
async-rendered UI.
