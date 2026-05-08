# Caching Strategies

> Reference for the [backend-patterns](../SKILL.md) skill.

## Redis Caching Layer (Decorator Repository)

```typescript
class CachedMarketRepository implements MarketRepository {
  constructor(
    private baseRepo: MarketRepository,
    private redis: RedisClient
  ) {}

  async findById(id: string): Promise<Market | null> {
    const cached = await this.redis.get(`market:${id}`)
    if (cached) return JSON.parse(cached)

    const market = await this.baseRepo.findById(id)
    if (market) {
      await this.redis.setex(`market:${id}`, 300, JSON.stringify(market))
    }
    return market
  }

  async invalidateCache(id: string): Promise<void> {
    await this.redis.del(`market:${id}`)
  }
}
```

The cache lives behind the same `MarketRepository` interface, so callers don't
know about it. Switch caching on/off by composing or unwrapping the decorator.

## Cache-Aside (Direct)

```typescript
async function getMarketWithCache(id: string): Promise<Market> {
  const cacheKey = `market:${id}`

  const cached = await redis.get(cacheKey)
  if (cached) return JSON.parse(cached)

  const market = await db.markets.findUnique({ where: { id } })
  if (!market) throw new Error('Market not found')

  await redis.setex(cacheKey, 300, JSON.stringify(market))
  return market
}
```

## Invalidation Rules

- On update / delete: `redis.del(cacheKey)` (don't try to update the cached value).
- TTL is a backstop, not a strategy — the explicit invalidation must run on writes.
- For list/index caches (e.g. "active markets list"): invalidate on every member change, or use a versioned key (`markets:active:v3`).
- For multi-instance deployments: use Redis pub/sub or a cache invalidation queue.

## Anti-patterns

- **Cache stampede:** First miss after expiry triggers concurrent rebuilds. Mitigate with single-flight (lock around the rebuild) or probabilistic early expiration.
- **Negative-result caching without bound:** Caching "not found" needs short TTL or you'll persistently mask new records.
- **Caching mutable references:** Always serialize to JSON or freeze; don't share mutable objects across requests.
