# Mocking External Services

> Reference for the [tdd-workflow](../SKILL.md) skill.

## Principles

- **Mock at the boundary, not deep inside.** Replace the HTTP / DB client; don't
  patch arbitrary internal functions.
- **Verify the mock matches reality.** A passing test against a wrong mock is
  worse than no test. Pair every meaningful unit-mock test with at least one
  real integration test.
- **Reset between tests.** Avoid leaking state — most frameworks have
  `beforeEach`/`afterEach` resets.
- **Type your mocks.** Use the same TypeScript / Pydantic types as production
  so signature drift breaks the test, not production.

## Stack-Specific Examples

### Supabase (Postgres) Mock

```typescript
jest.mock('@/lib/supabase', () => ({
  supabase: {
    from: jest.fn(() => ({
      select: jest.fn(() => ({
        eq: jest.fn(() => Promise.resolve({
          data: [{ id: 1, name: 'Test Market' }],
          error: null,
        })),
      })),
    })),
  },
}))
```

For real DB work, prefer a test database (Postgres in Docker, sqlite in-memory)
over heavy mocks. Mocks rapidly diverge from real query behavior.

### Redis Mock

```typescript
jest.mock('@/lib/redis', () => ({
  searchMarketsByVector: jest.fn(() => Promise.resolve([
    { slug: 'test-market', similarity_score: 0.95 },
  ])),
  checkRedisHealth: jest.fn(() => Promise.resolve({ connected: true })),
}))
```

For Redis, `ioredis-mock` provides a more realistic in-memory implementation
that supports actual commands.

### OpenAI / Embedding Mock

```typescript
jest.mock('@/lib/openai', () => ({
  generateEmbedding: jest.fn(() => Promise.resolve(
    new Array(1536).fill(0.1)  // mock 1536-dim embedding
  )),
}))
```

Don't call real OpenAI in unit tests — slow, costly, non-deterministic.
Save real-API smoke tests for nightly integration runs with explicit budgets.

## Stack-Specific Equivalents (Other Languages)

- **Python**: `unittest.mock.patch`, `pytest-mock`, `responses` (HTTP), `moto` (AWS).
- **Go**: interface-based mocks (hand-rolled or `mockgen`), `httptest` for HTTP.
- **Java**: Mockito, WireMock for HTTP.
- **Ruby**: `rspec-mocks`, `webmock` for HTTP.
