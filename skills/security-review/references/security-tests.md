# Security Testing Patterns

> Reference for the [security-review](../SKILL.md) skill.

## Authentication Required

```typescript
test('requires authentication', async () => {
  const response = await fetch('/api/protected')
  expect(response.status).toBe(401)
})
```

## Authorization Required

```typescript
test('requires admin role', async () => {
  const response = await fetch('/api/admin', {
    headers: { Authorization: `Bearer ${userToken}` }
  })
  expect(response.status).toBe(403)
})
```

## Input Validation

```typescript
test('rejects invalid input', async () => {
  const response = await fetch('/api/users', {
    method: 'POST',
    body: JSON.stringify({ email: 'not-an-email' })
  })
  expect(response.status).toBe(400)
})
```

## Rate Limiting

```typescript
test('enforces rate limits', async () => {
  const requests = Array(101).fill(null).map(() => fetch('/api/endpoint'))
  const responses = await Promise.all(requests)
  const tooMany = responses.filter(r => r.status === 429)
  expect(tooMany.length).toBeGreaterThan(0)
})
```

## What These Tests Don't Cover

- Time-of-check / time-of-use bugs
- Race conditions
- Logic flaws in business rules (need domain-specific tests)
- Vulnerabilities in dependencies (use `npm audit` / SCA, not unit tests)
- Misconfigurations in production (CSP, HSTS, CORS)

For depth beyond this: add integration tests against a real DB, fuzz testing
for parsers, and periodic manual penetration testing for high-value apps.
