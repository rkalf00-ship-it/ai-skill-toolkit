# Git Hooks

> Reference for the [git-workflow](../SKILL.md) skill.

## Pre-Commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run linting
npm run lint || exit 1

# Run tests
npm test || exit 1

# Check for secrets
if git diff --cached | grep -E '(password|api_key|secret)'; then
    echo "Possible secret detected. Commit aborted."
    exit 1
fi
```

## Pre-Push Hook

```bash
#!/bin/bash
# .git/hooks/pre-push

# Run full test suite
npm run test:all || exit 1

# Check for console.log statements
if git diff origin/main | grep -E 'console\.log'; then
    echo "Remove console.log statements before pushing."
    exit 1
fi
```

## Sharing Hooks with the Team

`.git/hooks/` is not version-controlled. To share hooks across the team, use one of:

- **husky** (Node.js): `npm install --save-dev husky` → `npx husky init` → commit `.husky/`
- **pre-commit** (Python): `pip install pre-commit` + `.pre-commit-config.yaml`
- **lefthook**: language-agnostic, single binary

These tools install hooks via a setup script teammates run after cloning.
