# Release Management

> Reference for the [git-workflow](../SKILL.md) skill.

## Semantic Versioning

```
MAJOR.MINOR.PATCH

MAJOR: Breaking changes
MINOR: New features, backward compatible
PATCH: Bug fixes, backward compatible

Examples:
1.0.0 -> 1.0.1 (patch: bug fix)
1.0.1 -> 1.1.0 (minor: new feature)
1.1.0 -> 2.0.0 (major: breaking change)
```

## Creating Releases

```bash
# Create annotated tag
git tag -a v1.2.0 -m "Release v1.2.0

Features:
- Add user authentication
- Implement password reset

Fixes:
- Resolve login redirect issue

Breaking Changes:
- None"

# Push tag to remote
git push origin v1.2.0

# List tags
git tag -l

# Delete tag (use with caution if already published)
git tag -d v1.2.0
git push origin --delete v1.2.0
```

## Changelog Generation

```bash
# Generate changelog from commits
git log v1.1.0..v1.2.0 --oneline --no-merges

# Or use conventional-changelog
npx conventional-changelog -i CHANGELOG.md -s
```
