# Dependency Security

> Reference for the [security-review](../SKILL.md) skill.

## Regular Updates

```bash
# Check for vulnerabilities
npm audit

# Fix automatically when possible
npm audit fix

# Update dependencies
npm update

# Check for outdated packages
npm outdated
```

For Python: `pip-audit`. For Go: `govulncheck`. For Ruby: `bundler-audit`.

## Lock Files

```bash
# ALWAYS commit lock files
git add package-lock.json

# Use in CI/CD for reproducible builds
npm ci  # NOT npm install — npm ci respects the lockfile strictly
```

## Verification Steps

- [ ] Dependencies kept up to date (no abandoned packages)
- [ ] No known CVEs (`npm audit` clean, or all flagged issues triaged)
- [ ] Lockfile committed and used by CI
- [ ] Dependabot / Renovate enabled on the repo
- [ ] Indirect (transitive) dependencies also reviewed when CVEs hit
- [ ] Pin major versions in `package.json` (avoid `^*` for security-critical deps)
- [ ] Subresource Integrity (`integrity=...`) on any CDN-loaded assets
