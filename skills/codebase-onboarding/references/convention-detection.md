# Phase 3: Convention Detection

> Reference for the [codebase-onboarding](../SKILL.md) skill.

Identify patterns the codebase already follows. Conventions are evidence-based,
not aspirational.

## Naming Conventions

- File naming: kebab-case, camelCase, PascalCase, snake_case
- Component / class naming patterns
- Test file naming: `*.test.ts`, `*.spec.ts`, `*_test.go`

## Code Patterns

- Error handling style: try / catch, Result types, error codes
- Dependency injection or direct imports
- State management approach
- Async patterns: callbacks, promises, async / await, channels

## Git Conventions

- Branch naming from recent branches (`git branch -r --sort=-committerdate | head -20`)
- Commit message style from recent commits (`git log --oneline -30`)
- PR workflow (squash, merge, rebase) — inferred from `git log --merges` patterns

If the repo has no commits or only a shallow history (e.g. `git clone --depth 1`),
skip this section and note "Git history unavailable or too shallow to detect
conventions". Don't make up plausible-sounding defaults.

## Detecting via Sampling

Don't read every file. Pick representative samples:

- One component file from `src/components/` to confirm React naming.
- One API route to see error-handling style.
- One service / business-logic file to see patterns.
- One test file to see assertion library and structure.

Three or four samples are usually enough to confirm a pattern exists. If
samples disagree, the codebase has inconsistent conventions — flag that
honestly rather than picking one.
