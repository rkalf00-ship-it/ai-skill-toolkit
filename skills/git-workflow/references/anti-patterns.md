# Git Anti-Patterns

> Reference for the [git-workflow](../SKILL.md) skill.

```
# BAD: Committing directly to main
git checkout main
git commit -m "fix bug"

# GOOD: Use feature branches and PRs
```

```
# BAD: Committing secrets
git add .env  # Contains API keys

# GOOD: Add to .gitignore, use environment variables
# If accidentally committed: rotate the secret immediately, then scrub history
```

```
# BAD: Giant PRs (1000+ lines)
# GOOD: Break into smaller, focused PRs (<500 lines)
```

```
# BAD: "Update" / "WIP" commit messages
git commit -m "update"
git commit -m "fix"

# GOOD: Descriptive messages
git commit -m "fix(auth): resolve redirect loop after login"
```

```
# BAD: Rewriting public history
git push --force origin main

# GOOD: Use revert for public branches
git revert HEAD

# GOOD: For your own feature branches, use --force-with-lease
git push --force-with-lease origin feature/my-branch
```

```
# BAD: Long-lived feature branches (weeks/months)
# GOOD: Keep branches short (days), rebase frequently onto main
```

```
# BAD: Committing generated files
git add dist/
git add node_modules/

# GOOD: Add to .gitignore
```

```
# BAD: --no-verify to skip hooks
git commit --no-verify -m "..."

# GOOD: Fix the underlying issue the hook caught
```
