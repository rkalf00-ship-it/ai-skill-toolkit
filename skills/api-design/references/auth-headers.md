# Authentication & Authorization

> Reference for the [api-design](../SKILL.md) skill.

## Token-Based Auth

```
# Bearer token in Authorization header
GET /api/v1/users
Authorization: Bearer eyJhbGciOiJIUzI1NiIs...

# API key (for server-to-server)
GET /api/v1/data
X-API-Key: sk_live_abc123
```

Use Bearer for end-user tokens (JWT, OAuth). Use a custom header (e.g.
`X-API-Key`) for static service-to-service keys to keep them distinguishable
in logs and middleware.

## Authorization Patterns

```typescript
// Resource-level: check ownership
app.get("/api/v1/orders/:id", async (req, res) => {
  const order = await Order.findById(req.params.id)
  if (!order) return res.status(404).json({ error: { code: "not_found" } })
  if (order.userId !== req.user.id) {
    return res.status(403).json({ error: { code: "forbidden" } })
  }
  return res.json({ data: order })
})

// Role-based: check permissions
app.delete("/api/v1/users/:id", requireRole("admin"), async (req, res) => {
  await User.delete(req.params.id)
  return res.status(204).send()
})
```

## 404 vs 403

When a user is authenticated but lacks permission to read a resource that
exists, you have a choice:

- `403 Forbidden` — honest, easier to debug, but **leaks existence** of the resource.
- `404 Not Found` — opaque, used by GitHub for private repos to avoid leaking that they exist.

For sensitive resources, prefer `404`. For internal admin tools where existence-leakage doesn't matter, `403` is clearer.
