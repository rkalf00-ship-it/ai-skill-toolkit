---
name: security-review
id: security-review
description: Use when adding authentication, authorization, secrets management, payment / financial features, file upload, or handling sensitive user data. Reviews and fixes vulnerabilities — secrets leakage, injection (SQL / XSS / CSRF), broken authz, weak rate limiting, sensitive data exposure, vulnerable dependencies. Activates on authentication, authorization, secrets, OWASP, XSS, SQL injection, CSRF, RLS, input validation, file upload, JWT, payment. Skip for pure UI work, animation, or code style review.
category: quality
version: 1.1.0
triggers:
  positive:
    - authentication
    - authorization
    - secrets management
    - API endpoint security
    - payment feature
    - sensitive data
    - OWASP
    - XSS
    - SQL injection
    - CSRF
    - Row Level Security
    - input validation
    - file upload
    - JWT
  negative:
    - UI design
    - frontend animation
    - code style
requires:
---

# Security Review Skill

Identify and fix security vulnerabilities in code that handles auth, secrets,
user input, sensitive data, payments, or external integrations.

## Contract

Inputs:
- Feature, diff, endpoint, data flow, or subsystem to review.
- Auth model, trust boundaries, sensitive data, deployment context.

Outputs:
- Findings ordered by severity with file / line evidence when available.
- Required fixes, verification steps, residual risks.
- Security checklist result for relevant categories only.

Verification:
- Prefer concrete code evidence over generic advice.
- Check secrets, validation, authorization, injection, XSS / CSRF, rate limits, logging, dependency risks as applicable.

## When to Activate

- Implementing authentication or authorization
- Handling user input or file uploads
- Creating new API endpoints
- Working with secrets or credentials
- Implementing payment features
- Storing or transmitting sensitive data
- Integrating third-party APIs

## Severity Triage

When you find an issue, rate it before recommending a fix:

| Severity | Examples |
|----------|----------|
| **Critical** | Hardcoded prod secret, SQL injection, missing authz on destructive endpoint, RCE |
| **High**     | XSS in user-generated content, missing rate limit on auth, weak crypto, exposed admin |
| **Medium**   | Missing CSRF, verbose error leak, missing security headers, outdated dep with known CVE |
| **Low**      | Console.log of non-sensitive data, missing rate limit on read endpoint, deprecated algo (still safe) |

## Reference Index

Load the reference matching the area under review:

- `references/secrets.md` — Hardcoded keys, env vars, `.gitignore`, secret rotation.
- `references/input-validation.md` — Schema validation (Zod), file upload checks.
- `references/sql-injection.md` — Parameterized queries, ORM usage.
- `references/auth.md` — JWT handling, authorization checks, Supabase RLS.
- `references/xss-csrf.md` — Sanitization, CSP, CSRF tokens, SameSite cookies.
- `references/rate-limiting.md` — Per-endpoint limits, expensive-op stricter limits.
- `references/sensitive-data.md` — Logging redaction, generic error messages.
- `references/dependencies.md` — `npm audit`, Dependabot, lockfile hygiene.
- `references/security-tests.md` — Automated test patterns for auth, authz, validation, rate limit.
- `references/cloud-infrastructure.md` — IAM, secrets in cloud, network, CI/CD, CDN/WAF, DR.
- `references/blockchain-solana.md` — Wallet signature verification, transaction validation (load only when reviewing Solana code).

## Pre-Deployment Security Checklist

Before ANY production deployment:

- [ ] **Secrets**: No hardcoded secrets, all in env vars
- [ ] **Input Validation**: All user inputs validated
- [ ] **SQL Injection**: All queries parameterized
- [ ] **XSS**: User content sanitized
- [ ] **CSRF**: Protection enabled
- [ ] **Authentication**: Proper token handling
- [ ] **Authorization**: Role checks in place
- [ ] **Rate Limiting**: Enabled on all endpoints
- [ ] **HTTPS**: Enforced in production
- [ ] **Security Headers**: CSP, X-Frame-Options configured
- [ ] **Error Handling**: No sensitive data in errors
- [ ] **Logging**: No sensitive data logged
- [ ] **Dependencies**: Up to date, no known vulnerabilities
- [ ] **Row Level Security**: Enabled in database (if Supabase / Postgres RLS)
- [ ] **CORS**: Properly configured
- [ ] **File Uploads**: Validated (size, type)
- [ ] **Wallet Signatures**: Verified (only if blockchain — see `references/blockchain-solana.md`)

## Resources

- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [Web Security Academy](https://portswigger.net/web-security)

---

**Remember**: Security is not optional. One vulnerability can compromise the entire platform. When in doubt, err on the side of caution.
