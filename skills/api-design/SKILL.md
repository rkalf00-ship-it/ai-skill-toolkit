---
name: api-design
id: api-design
description: Use when designing or reviewing REST API endpoints, resource naming, HTTP methods and status codes, pagination (offset / cursor), filtering / sorting, response envelopes, error response shape, authentication / authorization headers, rate limit headers, or API versioning. Activates on REST API, endpoint design, status code, pagination, rate limiting, API versioning, error response. Skip for GraphQL schemas, gRPC services, or internal RPC contracts.
category: architecture
version: 1.1.0
triggers:
  positive:
    - REST API
    - endpoint design
    - status code
    - pagination
    - rate limiting
    - API versioning
    - error response
    - resource naming
    - HTTP method
  negative:
    - GraphQL schema only
    - gRPC service
    - internal RPC
requires:
---

# API Design Patterns

Conventions for consistent, developer-friendly REST APIs.

## Contract

Inputs:
- Resource, operation, actor, auth model, success / error cases.
- Existing API conventions or compatibility constraints.
- Pagination, filtering, sorting, versioning, rate-limit requirements (when relevant).

Outputs:
- Endpoint matrix with methods, paths, request / response shapes, status codes.
- Error response model and validation behavior.
- Test checklist or OpenAPI snippet when useful.

Verification:
- Check HTTP semantics, auth boundaries, pagination limits, error consistency.
- Pair with `security-review` for sensitive, authenticated, payment, or file-upload APIs.
- Pair with `backend-patterns` for the implementation behind the chosen surface.

## When to Activate

- Designing new API endpoints
- Reviewing existing API contracts
- Adding pagination, filtering, or sorting
- Implementing error handling for APIs
- Planning API versioning strategy
- Building public or partner-facing APIs

## Quick Decision Guide

| Need | Pick | Reference |
|------|------|-----------|
| New collection endpoint | Plural resource noun, kebab-case, no verbs | `references/resource-design.md` |
| Action that doesn't fit CRUD | `POST /resource/:id/action` | `references/resource-design.md` |
| Returning created resource | `201 Created` + `Location` header | `references/status-codes.md` |
| Validation failure | `422 Unprocessable Entity` (or `400`) with field errors | `references/status-codes.md` `references/response-format.md` |
| Auth missing | `401 Unauthorized` | `references/status-codes.md` |
| Auth present but lacks permission | `403 Forbidden` | `references/status-codes.md` |
| Conflict (duplicate, version) | `409 Conflict` | `references/status-codes.md` |
| Admin dashboard list (small data) | Offset pagination | `references/pagination.md` |
| Infinite scroll / large dataset | Cursor pagination | `references/pagination.md` |
| Public/partner API | Cursor (default) + offset (optional) | `references/pagination.md` |
| Filter / sort / search | Query params with conventions | `references/filtering.md` |
| Rate limit exceeded | `429 Too Many Requests` + `Retry-After` | `references/rate-limit-headers.md` |
| Breaking change | New URL version (`/api/v2/...`) | `references/versioning.md` |

## Reference Index

- `references/resource-design.md` — URL structure, naming rules, sub-resources.
- `references/status-codes.md` — Method semantics, status code reference, common mistakes.
- `references/response-format.md` — Success, collection (paginated), error envelopes; envelope variants.
- `references/pagination.md` — Offset vs cursor; when to use which; implementation.
- `references/filtering.md` — Filtering, sorting, search, sparse fieldsets.
- `references/auth-headers.md` — Bearer token, API key, resource-level + role-based authorization.
- `references/rate-limit-headers.md` — `X-RateLimit-*` headers, tiers.
- `references/versioning.md` — URL vs header versioning, deprecation policy, breaking vs non-breaking.
- `references/examples/typescript-nextjs.md` — Next.js route handler.
- `references/examples/python-drf.md` — Django REST Framework viewset.
- `references/examples/go-nethttp.md` — Go `net/http` handler.

## API Design Checklist

Before shipping a new endpoint:

- [ ] URL follows naming conventions (plural, kebab-case, no verbs)
- [ ] Correct HTTP method (GET reads, POST creates / actions, PUT replaces, PATCH partial, DELETE removes)
- [ ] Appropriate status code (not `200` for everything; `201` + Location for create; `204` for empty)
- [ ] Input validated with schema (Zod, Pydantic, Bean Validation)
- [ ] Error responses follow standard format with `code` and `message`
- [ ] Pagination implemented for list endpoints (cursor or offset)
- [ ] Authentication required (or explicitly marked as public)
- [ ] Authorization checked (user can only access their own resources)
- [ ] Rate limiting configured
- [ ] Response does not leak internal details (stack traces, SQL errors)
- [ ] Consistent naming with existing endpoints (camelCase vs snake_case)
- [ ] Documented (OpenAPI / Swagger spec updated)
