# Test Organization

> Reference for the [tdd-workflow](../SKILL.md) skill.

## File Layout (TypeScript / React example)

```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx          # Unit tests
│   │   └── Button.stories.tsx       # Storybook
│   └── MarketCard/
│       ├── MarketCard.tsx
│       └── MarketCard.test.tsx
├── app/
│   └── api/
│       └── markets/
│           ├── route.ts
│           └── route.test.ts         # Integration tests
└── e2e/
    ├── markets.spec.ts               # E2E tests
    ├── trading.spec.ts
    └── auth.spec.ts
```

## Layout Principles

- **Co-locate unit tests with source.** `Foo.test.ts` next to `Foo.ts` makes it
  obvious what's tested and lets you find one from the other.
- **Separate E2E.** They have different runners, different timing, and run in CI
  on different schedules — keep them in their own directory.
- **Match production layout in tests.** If you have `src/services/payment/`,
  tests live at `src/services/payment/payment.test.ts` (not in a parallel `tests/`
  tree that has to mirror the source structure manually).
- **Naming conventions** vary by stack: `*.test.ts` (Jest / Vitest),
  `*.spec.ts` (Playwright / Mocha), `*_test.go` (Go), `tests/test_*.py` (pytest).
  Match what the test runner expects.
