# Data Access Layering

> Reference for the [backend-patterns](../SKILL.md) skill.

## Repository Pattern

```typescript
interface MarketRepository {
  findAll(filters?: MarketFilters): Promise<Market[]>
  findById(id: string): Promise<Market | null>
  create(data: CreateMarketDto): Promise<Market>
  update(id: string, data: UpdateMarketDto): Promise<Market>
  delete(id: string): Promise<void>
}

class SupabaseMarketRepository implements MarketRepository {
  async findAll(filters?: MarketFilters): Promise<Market[]> {
    let query = supabase.from('markets').select('*')
    if (filters?.status) query = query.eq('status', filters.status)
    if (filters?.limit)  query = query.limit(filters.limit)
    const { data, error } = await query
    if (error) throw new Error(error.message)
    return data
  }
  // ...other methods
}
```

The Supabase example is illustrative — the repository interface stays the same
across Postgres clients, Prisma, Drizzle, Mongo, etc. Pick the implementation
your stack uses.

## Service Layer

```typescript
class MarketService {
  constructor(private marketRepo: MarketRepository) {}

  async searchMarkets(query: string, limit = 10): Promise<Market[]> {
    const embedding = await generateEmbedding(query)
    const results = await this.vectorSearch(embedding, limit)
    const markets = await this.marketRepo.findByIds(results.map(r => r.id))
    return markets.sort((a, b) => {
      const scoreA = results.find(r => r.id === a.id)?.score ?? 0
      const scoreB = results.find(r => r.id === b.id)?.score ?? 0
      return scoreB - scoreA
    })
  }
}
```

Services own business logic. Repositories own persistence. Don't put SQL in
services and don't put business rules in repositories.

## Middleware Pattern

```typescript
export function withAuth(handler: NextApiHandler): NextApiHandler {
  return async (req, res) => {
    const token = req.headers.authorization?.replace('Bearer ', '')
    if (!token) return res.status(401).json({ error: 'Unauthorized' })
    try {
      const user = await verifyToken(token)
      req.user = user
      return handler(req, res)
    } catch {
      return res.status(401).json({ error: 'Invalid token' })
    }
  }
}

export default withAuth(async (req, res) => {
  // handler has access to req.user
})
```
