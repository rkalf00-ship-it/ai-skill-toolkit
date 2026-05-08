---
name: tdd-workflow
id: tdd-workflow
description: Use when writing new features, fixing bugs, or refactoring with behavior change. Enforces RED / GREEN / REFACTOR loop with verifiable RED state, behavior-first tests over implementation tests, and repository-defined coverage gates (no fixed-percentage default). Activates on TDD, test-driven, write tests first, RED green refactor, reproducer test, bug fix with tests, test coverage. Skip for prototypes, exploration, PoCs, or throwaway scripts where evidence is not needed.
category: quality
version: 1.1.0
triggers:
  positive:
    - TDD
    - test-driven
    - write tests first
    - RED green refactor
    - test coverage
    - failing test
    - reproducer test
    - bug fix with tests
  negative:
    - prototype
    - exploration
    - PoC
    - throwaway script
requires:
---

# Test-Driven Development Workflow

Guide behavior-changing work through a practical RED / GREEN / REFACTOR loop.
Use repository-defined test and coverage policy instead of imposing a universal
percentage.

## Contract

Inputs:
- Feature, bug, or refactor goal.
- Existing test framework, test commands, repository coverage policy.
- Behavior that should change or remain stable.

Outputs:
- RED test (or justified skip for non-behavioral changes).
- Minimal implementation plan and GREEN verification evidence.
- Refactor notes and coverage impact when relevant.

Verification:
- Use repository coverage thresholds if present.
- If no threshold exists, focus coverage on touched behavior rather than enforcing a global percentage.

## When to Activate

- Writing new features or functionality
- Fixing bugs or issues
- Refactoring existing code
- Adding API endpoints
- Creating new components

## Core Principles

### 1. Behavior Test Before Production Code

For behavior-changing work, add or update the smallest test that would fail
before the change, then implement code to make it pass.

For documentation, formatting-only, configuration-only, or exploratory work,
state why a RED test is not applicable and use the closest practical verification.

### 2. Coverage Requirements

- Use repository-defined coverage thresholds when they exist.
- If the repository has no coverage policy, focus coverage on touched behavior
  and critical paths.
- Cover meaningful edge cases, error scenarios, boundary conditions relevant to the change.
- Do not invent a global coverage percentage for repositories that do not define one.

### 3. Git Checkpoints (When Repo is Under Git)

Compact preferred workflow:
- one commit for failing test added and RED validated (`test: add reproducer for <X>`)
- one commit for minimal fix applied and GREEN validated (`fix: <X>`)
- one optional commit for refactor complete (`refactor: clean up after <X>`)

Verify each checkpoint commit is reachable from the current `HEAD` on the
active branch and belongs to the current task sequence — do not count commits
from other branches as evidence.

## TDD Workflow Steps

### Step 1 — Write User Journeys

```
As a [role], I want to [action], so that [benefit]
```

### Step 2 — Generate Test Cases

For each user journey, create comprehensive test cases including happy path,
edge cases, fallback behavior. See `references/test-patterns.md` for unit /
integration / E2E patterns.

### Step 3 — Run Tests (They Should Fail) — RED Gate

```bash
<repository test command>     # e.g. npm test, pytest, go test ./..., bundle exec rspec
```

Before modifying behavior-changing production code, verify a valid RED state:

- **Runtime RED:** target compiles, the new / changed test is executed, result is RED.
- **Compile-time RED:** the new test references the buggy / missing path; the compile failure is itself the intended RED signal.
- In either case, the failure is caused by the intended business-logic bug,
  undefined behavior, or missing implementation — **not** by unrelated syntax
  errors, broken setup, or missing dependencies.

A test that was written but not compiled and executed does not count as RED.

If under Git, create a checkpoint commit immediately after RED is validated.

### Step 4 — Implement Code

Write the minimum code to make tests pass. Stage but defer the commit until
GREEN is confirmed.

### Step 5 — Run Tests Again — GREEN Gate

Rerun the same relevant test target after the fix and confirm the previously
failing test is now GREEN.

Only after a valid GREEN result may you proceed to refactor.

If under Git, create a checkpoint commit (`fix: <X>`) immediately after GREEN
is validated.

### Step 6 — Refactor

Improve code quality while keeping tests green:
- Remove duplication
- Improve naming
- Optimize when measurable
- Enhance readability

If under Git, create a checkpoint commit (`refactor: ...`) once tests still pass.

### Step 7 — Verify Coverage Policy

```bash
<repository coverage command>
# Verify repository-defined thresholds OR touched-behavior coverage when no policy exists
```

## Reference Index

- `references/test-patterns.md` — unit (Jest / Vitest), API integration, E2E (Playwright) patterns.
- `references/test-organization.md` — file-layout conventions.
- `references/mocking.md` — generic mocking principles + stack-specific examples (Supabase, Redis, OpenAI).
- `references/coverage-policy.md` — choosing thresholds, reading coverage reports.
- `references/anti-patterns.md` — testing implementation details, brittle selectors, no isolation.
- `references/ci-integration.md` — pre-commit hooks, GitHub Actions, watch mode.

## Best Practices

1. **Write behavior tests first** — for behavior-changing production code.
2. **One assert per test** — focus on a single behavior.
3. **Descriptive test names** — explain what is tested.
4. **Arrange-Act-Assert** — clear structure.
5. **Mock external dependencies** — isolate unit tests; pair with real integration tests.
6. **Test edge cases** — null, undefined, empty, large values, boundary conditions.
7. **Test error paths** — not just happy paths.
8. **Keep tests fast** — unit tests under 50ms each.
9. **Clean up after tests** — no shared state between tests.
10. **Review coverage reports** — identify gaps in touched behavior.

## Success Metrics

- Repository coverage policy satisfied (or touched behavior covered when no policy exists)
- All tests passing (green)
- No skipped or disabled tests carried over without justification
- Fast test execution (under ~30s for unit tests)
- E2E tests cover critical user flows
- Tests catch the intended bug class before production

---

**Behavior-changing work needs executable evidence.** Prefer tests when
practical; when a test is not applicable, record the reason and the closest
verification used.
