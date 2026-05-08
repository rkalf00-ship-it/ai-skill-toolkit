# Secrets Management

> Reference for the [security-review](../SKILL.md) skill.

## NEVER Do This

```typescript
const apiKey = "sk-proj-xxxxx"   // Hardcoded secret
const dbPassword = "password123" // In source code
```

## ALWAYS Do This

```typescript
const apiKey = process.env.OPENAI_API_KEY
const dbUrl  = process.env.DATABASE_URL

// Verify secrets exist
if (!apiKey) {
  throw new Error('OPENAI_API_KEY not configured')
}
```

## Verification Steps

- [ ] No hardcoded API keys, tokens, or passwords
- [ ] All secrets in environment variables
- [ ] `.env.local` (and any other env files) in `.gitignore`
- [ ] No secrets in git history (use `git log -p -S "sk_"` to spot-check)
- [ ] Production secrets in hosting platform (Vercel, Railway, AWS Secrets Manager, etc.)

## If a Secret Was Committed

1. **Rotate the secret immediately** — assume it is compromised regardless of when it was committed.
2. Remove it from current code and `.gitignore` the env file.
3. Scrub it from git history with `git filter-repo` (preferred) or `bfg-repo-cleaner`.
4. Force-push (coordinate with team — this rewrites history).
5. Audit access logs for unauthorized use during the exposure window.
