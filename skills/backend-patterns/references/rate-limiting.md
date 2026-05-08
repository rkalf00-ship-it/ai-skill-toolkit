# Rate Limiting

> Reference for the [backend-patterns](../SKILL.md) skill.

## Simple In-Memory Rate Limiter

```typescript
class RateLimiter {
  private requests = new Map<string, number[]>()

  async checkLimit(
    identifier: string,
    maxRequests: number,
    windowMs: number
  ): Promise<boolean> {
    const now = Date.now()
    const requests = this.requests.get(identifier) || []
    const recentRequests = requests.filter(time => now - time < windowMs)

    if (recentRequests.length >= maxRequests) return false  // exceeded

    recentRequests.push(now)
    this.requests.set(identifier, recentRequests)
    return true
  }
}

const limiter = new RateLimiter()

export async function GET(request: Request) {
  const ip = request.headers.get('x-forwarded-for') || 'unknown'
  const allowed = await limiter.checkLimit(ip, 100, 60_000)
  if (!allowed) {
    return NextResponse.json({ error: 'Rate limit exceeded' }, { status: 429 })
  }
  // continue
}
```

## When to Use a Distributed Limiter

In-memory only works for **single-instance** deployments. Multi-instance behind
a load balancer requires shared state — otherwise N instances allow N× the
intended rate.

For multi-instance:
- **Redis** with sorted sets or `INCR` + `EXPIRE` (sliding-window or fixed-window).
- **Cloud-native**: Cloudflare / API Gateway rate limit policies (run at the edge).
- Libraries: `rate-limiter-flexible` (Node), `slowapi` (FastAPI).

## Choosing Limits

| Endpoint type | Suggested limit |
|---------------|----------------|
| Anonymous read | 30 req/min per IP |
| Authenticated standard | 100–300 req/min per user |
| Expensive (search, ML, image) | 5–20 req/min per user |
| Auth (login, password reset) | 5 req/min per IP, then exponential backoff |
| Webhook receive | Apply backoff at sender, not 429 — webhooks usually retry |
