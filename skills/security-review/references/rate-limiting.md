# Rate Limiting (Security Lens)

> Reference for the [security-review](../SKILL.md) skill.
> For implementation patterns, see also `backend-patterns/references/rate-limiting.md`.

## API Rate Limiting

```typescript
import rateLimit from 'express-rate-limit'

const limiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100,
  message: 'Too many requests'
})

app.use('/api/', limiter)
```

## Stricter Limits for Expensive / Sensitive Operations

```typescript
const searchLimiter = rateLimit({
  windowMs: 60 * 1000,
  max: 10,
  message: 'Too many search requests'
})
app.use('/api/search', searchLimiter)

// Auth endpoints — even tighter to slow brute force
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 5,
  message: 'Too many auth attempts',
})
app.use('/api/auth/login',          authLimiter)
app.use('/api/auth/password-reset', authLimiter)
```

## Verification Steps

- [ ] Rate limiting on all API endpoints
- [ ] Stricter limits on expensive operations (search, ML, image processing)
- [ ] Strictest limits on auth endpoints (login, password reset, signup)
- [ ] IP-based limit for unauthenticated traffic
- [ ] User-based limit for authenticated traffic
- [ ] Rate limits enforced **after** auth so 429 doesn't leak account existence
- [ ] Multi-instance deployments use a shared store (Redis), not in-memory
