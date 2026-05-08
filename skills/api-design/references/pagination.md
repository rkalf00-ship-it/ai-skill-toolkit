# Pagination

> Reference for the [api-design](../SKILL.md) skill.

## Offset-Based (Simple)

```
GET /api/v1/users?page=2&per_page=20

# Implementation
SELECT * FROM users
ORDER BY created_at DESC
LIMIT 20 OFFSET 20;
```

**Pros:** Easy to implement, supports "jump to page N".
**Cons:** Slow on large offsets (`OFFSET 100000`), inconsistent with concurrent inserts.

## Cursor-Based (Scalable)

```
GET /api/v1/users?cursor=eyJpZCI6MTIzfQ&limit=20

# Implementation
SELECT * FROM users
WHERE id > :cursor_id
ORDER BY id ASC
LIMIT 21;  -- fetch one extra to determine has_next
```

```json
{
  "data": [...],
  "meta": {
    "has_next": true,
    "next_cursor": "eyJpZCI6MTQzfQ"
  }
}
```

**Pros:** Consistent performance regardless of position, stable with concurrent inserts.
**Cons:** Cannot jump to arbitrary page, cursor is opaque.

## When to Use Which

| Use Case | Pagination Type |
|----------|----------------|
| Admin dashboards, small datasets (<10K) | Offset |
| Infinite scroll, feeds, large datasets | Cursor |
| Public APIs | Cursor (default) with offset (optional) |
| Search results | Offset (users expect page numbers) |

## Cursor Encoding

Encode the cursor as base64 of a small JSON object containing the keyset
columns: `{"id": 123, "created_at": "2025-..."}`. Treat it as opaque from
the client's perspective — you can change the encoding without breaking them.
