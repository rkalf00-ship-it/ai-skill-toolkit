---
name: git-workflow
id: git-workflow
description: Use for Git workflow decisions — branching strategy (GitHub Flow / GitFlow / trunk-based), commit message conventions, merge vs rebase, conflict resolution, PR description, semantic versioning, tags, changelogs, and Git hooks. Activates on keywords like branching, commit, rebase, merge, PR, tag, changelog. Skip when implementing business logic or UI changes — those use the relevant patterns skill instead.
category: workflow
version: 1.1.0
triggers:
  positive:
    - branching strategy
    - commit message
    - GitHub Flow
    - GitFlow
    - trunk-based
    - merge vs rebase
    - PR description
    - conflict resolution
    - semantic versioning
    - git tag
    - changelog
  negative:
    - feature implementation
    - business logic
    - UI design
requires:
  bin: [git]
---

# Git Workflow Patterns

Best practices for Git version control, branching, and collaborative development.

## Contract

Inputs:
- Current repository state, desired workflow operation, team/release constraints.
- Branch, commit, PR, tag, or changelog requirements.

Outputs:
- Concrete git command sequence or workflow recommendation.
- Commit / PR / tag / changelog text when requested.
- Risk notes for history rewriting, conflicts, or protected branches.

Verification:
- Inspect `git status`, branches, remotes, and relevant diffs before advising destructive operations.
- Never rewrite shared history without explicit approval.

## When to Activate

- Setting up Git workflow for a new project
- Choosing branching strategy
- Writing commit messages or PR descriptions
- Resolving merge conflicts
- Managing releases and version tags
- Onboarding new team members to Git practices

## Quick Decision Guide

| Situation | Recommended Approach |
|-----------|---------------------|
| Continuous deployment, small/medium team | GitHub Flow → `references/branching-strategies.md` |
| 5+ devs, feature flags, multi-deploy/day | Trunk-based → `references/branching-strategies.md` |
| Scheduled releases, regulated industry | GitFlow → `references/branching-strategies.md` |
| Local feature branch, no shared history | Rebase onto main, force-push with `--force-with-lease` |
| Shared/published branch | Merge — never rebase |
| Production bug | Hotfix branch from `main` |
| Breaking change | New major version (semver MAJOR bump) |

## Reference Index

Load only the reference relevant to the current task:

- `references/branching-strategies.md` — GitHub Flow, Trunk-based, GitFlow with diagrams and rules.
- `references/commit-conventions.md` — Conventional Commits format, types, good/bad examples, message templates.
- `references/merge-vs-rebase.md` — When to merge, when to rebase, force-push safety, anti-patterns.
- `references/pr-workflow.md` — PR title format, description template, review checklists.
- `references/conflict-resolution.md` — Identify, resolve, prevent merge conflicts.
- `references/branch-management.md` — Naming conventions, cleanup, stash workflow.
- `references/release-management.md` — Semantic versioning, tags, changelog generation.
- `references/git-config.md` — Essential configs, useful aliases, gitignore patterns.
- `references/common-workflows.md` — New feature, PR updates, fork sync, undoing mistakes.
- `references/git-hooks.md` — Pre-commit and pre-push hook templates.
- `references/anti-patterns.md` — Common Git mistakes and corrections.

## Quick Reference

| Task | Command |
|------|---------|
| Create branch | `git checkout -b feature/name` |
| Switch branch | `git checkout branch-name` |
| Delete branch (safe) | `git branch -d branch-name` |
| Merge branch | `git merge branch-name` |
| Rebase branch | `git rebase main` |
| View history graph | `git log --oneline --graph --all` |
| View changes | `git diff` |
| Stage interactively | `git add -p` |
| Commit | `git commit -m "..."` |
| Push (first time) | `git push -u origin branch-name` |
| Stash | `git stash push -m "..."` |
| Undo last commit (keep changes) | `git reset --soft HEAD~1` |
| Revert pushed commit | `git revert <sha>` |

## Safety Rules

- **NEVER `git push --force` on `main` / shared branches.** Use `--force-with-lease` only for your own feature branches that no one else has based work on.
- **NEVER commit secrets.** Add `.env*` to `.gitignore`. If committed accidentally, rotate the secret immediately and use `git filter-repo` to scrub history.
- **NEVER `git reset --hard` without confirming there is no uncommitted work** (`git status` first).
- **For destructive operations on others' work, ask first.** Force-pushing, deleting branches with unmerged work, rewriting published commits — all require explicit user approval.

## Conventional Commit Format (Quick)

```
<type>(<scope>): <subject>

[optional body — explain why, not what]

[optional footer — Closes #123, BREAKING CHANGE: ...]
```

Types: `feat` | `fix` | `docs` | `style` | `refactor` | `test` | `chore` | `perf` | `ci` | `revert`

Full table with examples and templates: `references/commit-conventions.md`.
