# Versioning

> Reference for the [api-design](../SKILL.md) skill.

## URL Path Versioning (Recommended)

```
/api/v1/users
/api/v2/users
```

**Pros:** Explicit, easy to route, cacheable, visible in logs.
**Cons:** URL changes between versions.

## Header Versioning

```
GET /api/users
Accept: application/vnd.myapp.v2+json
```

**Pros:** Clean URLs.
**Cons:** Harder to test (curl needs `-H`), easy to forget, harder to debug from logs.

## Versioning Strategy

```
1. Start with /api/v1/ — don't version until you need to
2. Maintain at most 2 active versions (current + previous)
3. Deprecation timeline:
   - Announce deprecation (6 months notice for public APIs)
   - Add Sunset header: Sunset: Sat, 01 Jan 2026 00:00:00 GMT
   - Return 410 Gone after sunset date
4. Non-breaking changes don't need a new version:
   - Adding new fields to responses
   - Adding new optional query parameters
   - Adding new endpoints
5. Breaking changes require a new version:
   - Removing or renaming fields
   - Changing field types
   - Changing URL structure
   - Changing authentication method
```

## What Counts as Breaking

Anything a well-behaved client could rely on. Examples:

- A field becoming optional → still breaking if old clients assume it's always present.
- Adding a new required request field → breaking.
- Tightening validation → breaking (existing valid requests now fail).
- Changing default sort order → breaking for anyone who relied on it.

When in doubt, version.
