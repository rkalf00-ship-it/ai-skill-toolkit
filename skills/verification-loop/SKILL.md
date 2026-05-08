---
name: verification-loop
id: verification-loop
description: Use after completing a feature or significant change, before creating a PR, or to confirm quality gates pass — runs build, type check, lint, tests (with coverage), security spot-checks, and diff review. Activates on verify before PR, build check, type check, lint check, run tests, pre-deploy verification, ready to ship, quality gate. Skip during feature design or planning — use when the implementation work is done and you need to validate it.
category: quality
version: 1.1.0
triggers:
  positive:
    - verify before PR
    - build check
    - type check
    - lint check
    - run tests
    - pre-deploy verification
    - ready to ship
    - quality gate
  negative:
    - feature design
    - planning
    - architecture decision
requires:
---

# Verification Loop Skill

Comprehensive verification system for AI coding sessions.

## Contract

Inputs:
- Changed files, task objective, repository-specific quality gates.
- Available package manager, language tooling, CI expectations.

Outputs:
- Verification report with command, result, evidence, skipped checks, residual risk.
- Fix recommendations for failing checks.

Verification:
- Detect project commands from package scripts, README / AGENTS / CONTRIBUTING, language defaults.
- Do not treat passing proxy checks as complete unless they cover the requested behavior.

## When to Use

- After completing a feature or significant code change
- Before creating a PR
- When you want to ensure quality gates pass
- After refactoring

## Verification Phases

### Phase 1 — Build

```bash
# Detect project's build command from package scripts / Makefile / language defaults
npm run build 2>&1 | tail -20
# OR
pnpm build 2>&1 | tail -20
```

If build fails, STOP and fix before continuing.

### Phase 2 — Type Check

```bash
# TypeScript projects
npx tsc --noEmit 2>&1 | head -30

# Python projects
pyright . 2>&1 | head -30
```

Report all type errors. Fix critical ones before continuing.

### Phase 3 — Lint

```bash
# JavaScript / TypeScript
npm run lint 2>&1 | head -30

# Python
ruff check . 2>&1 | head -30
```

### Phase 4 — Test Suite

```bash
# Run tests with coverage when the repository exposes a coverage command
npm run test -- --coverage 2>&1 | tail -50
```

Check repository-defined thresholds or touched-behavior coverage evidence.
Report:
- Total tests: X
- Passed: X
- Failed: X
- Coverage: X% (against repo-defined gate, when present)

### Phase 5 — Security Spot-Check

```bash
# Check for likely-committed secrets
grep -rn "sk-" --include="*.ts" --include="*.js" . 2>/dev/null | head -10
grep -rn "api_key" --include="*.ts" --include="*.js" . 2>/dev/null | head -10

# Check for stray debug statements
grep -rn "console.log" --include="*.ts" --include="*.tsx" src/ 2>/dev/null | head -10
```

For full audit, hand off to the `security-review` skill.

### Phase 6 — Diff Review

```bash
git diff --stat
git diff HEAD~1 --name-only
```

Review each changed file for:
- Unintended changes
- Missing error handling
- Potential edge cases

## Output Format

```
VERIFICATION REPORT
==================

Build:     [PASS/FAIL]
Types:     [PASS/FAIL] (X errors)
Lint:      [PASS/FAIL] (X warnings)
Tests:     [PASS/FAIL] (X/Y passed, Z% coverage)
Security:  [PASS/FAIL] (X spot-check hits)
Diff:      [X files changed]

Overall:   [READY/NOT READY] for PR

Issues to Fix:
1. ...
2. ...
```

## Continuous Mode

For long sessions, run a quick verification at major checkpoints:
- After completing each function
- After finishing a component
- Before moving to the next task

A 30-second `tsc --noEmit && npm run lint` is cheap insurance.

## Integration with Hooks

This skill complements PostToolUse hooks but provides deeper verification.
Hooks catch issues immediately at edit time; this skill provides comprehensive
review before PR submission.
