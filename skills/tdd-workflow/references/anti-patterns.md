# Test Anti-Patterns

> Reference for the [tdd-workflow](../SKILL.md) skill.

## Testing Implementation Details

```typescript
// WRONG — coupled to internal state
expect(component.state.count).toBe(5)

// CORRECT — test what users see
expect(screen.getByText('Count: 5')).toBeInTheDocument()
```

When the implementation changes (rename state field, switch from class to hook),
the wrong test breaks even though the user-visible behavior is identical.

## Brittle Selectors

```typescript
// WRONG — breaks on any CSS refactor
await page.click('.css-class-xyz')

// CORRECT — semantic / stable selectors
await page.click('button:has-text("Submit")')
await page.click('[data-testid="submit-button"]')
```

## No Test Isolation

```typescript
// WRONG — tests depend on each other
test('creates user',          () => { /* creates a user with id 'foo' */ })
test('updates same user',     () => { /* assumes 'foo' exists */ })

// CORRECT — each test sets up its own data
test('creates user', () => {
  const user = createTestUser()
  // ...
})

test('updates user', () => {
  const user = createTestUser()
  // ...
})
```

## Other Common Mistakes

- **Asserting against the mock instead of behavior.** The test passes by
  construction — it tests that you wrote the mock, not that the code works.
- **Sleep / `setTimeout` to "wait for" async work.** Flaky and slow. Use
  `waitFor`, `await page.waitForResponse`, or proper await on the actual promise.
- **Snapshot tests for everything.** Snapshots are useful for stable output
  shapes; useless for code under active design — they get rubber-stamped.
- **Testing private methods directly.** Test through the public surface;
  if a private method needs its own tests, it's probably its own unit.
- **`it.skip` accumulating.** Skipped tests rot. Either fix or delete.
- **Tests with no failure mode.** A test that passes with the assertion
  removed is testing nothing — verify by deleting an assertion temporarily.
