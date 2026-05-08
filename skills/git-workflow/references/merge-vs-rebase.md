# Merge vs Rebase

> Reference for the [git-workflow](../SKILL.md) skill.

## Merge (Preserves History)

```bash
# Creates a merge commit
git checkout main
git merge feature/user-auth

# Result:
# *   merge commit
# |\
# | * feature commits
# |/
# * main commits
```

**Use when:**
- Merging feature branches into `main`
- You want to preserve exact history
- Multiple people worked on the branch
- The branch has been pushed and others may have based work on it

## Rebase (Linear History)

```bash
# Rewrites feature commits onto target branch
git checkout feature/user-auth
git rebase main

# Result:
# * feature commits (rewritten)
# * main commits
```

**Use when:**
- Updating your local feature branch with latest `main`
- You want a linear, clean history
- The branch is local-only (not pushed)
- You're the only one working on the branch

## Rebase Workflow

```bash
# Update feature branch with latest main (before PR)
git checkout feature/user-auth
git fetch origin
git rebase origin/main

# Fix any conflicts
# Tests should still pass

# Force push (only if you're the only contributor)
git push --force-with-lease origin feature/user-auth
```

`--force-with-lease` aborts if someone else has pushed to your branch since
your last fetch — much safer than `--force`.

## When NOT to Rebase

NEVER rebase branches that:
- Have been pushed to a shared repository where others base work on them
- Are protected branches (`main`, `develop`)
- Are already merged

Why: Rebase rewrites history, breaking other people's work derived from those commits.
