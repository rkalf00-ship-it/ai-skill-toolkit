---
name: backend-patterns
id: backend-patterns
description: Use for server-side architecture decisions — repository / service / middleware layering, database query optimization, N+1 prevention, caching strategies, JWT and RBAC authorization, rate limiting, background jobs / queues, structured logging. Activates on keywords repository pattern, service layer, middleware, N+1, caching, Redis, JWT, RBAC, background jobs. Use api-design skill for endpoint contract decisions; use this skill for backend internals behind a chosen API surface.
category: architecture
version: 1.1.0
triggers:
  positive:
    - repository pattern
    - service layer
    - middleware
    - N+1 query
    - database optimization
    - caching
    - Redis
    - JWT
    - RBAC
    - background jobs
    - structured logging
    - rate limiter
  negative:
    - REST URL design
    - frontend component
    - UI styling
    - mobile layout
requires:
---

# Backend Development Patterns

Backend architecture patterns for scalable server-side applications.

## Contract

Inputs:
- Existing stack, framework, and data stores.
- Backend behavior to implement or review.
- Constraints: latency, consistency, auth model, scaling, deployment, failure tolerance.

Outputs:
- Recommended backend structure or patch plan.
- Data access, service, caching, queue, error-handling decisions.
- Tests or verification commands relevant to the chosen backend layer.

Verification:
- Prefer repository-specific build, typecheck, lint, and test commands.
- For data or concurrency changes, include failure-path and rollback considerations.

## Boundary with API Design

Use `api-design` as the primary skill for endpoint naming, HTTP semantics,
pagination, filtering, versioning, status codes, and response/error contracts.
Use this skill *after* the API surface is chosen, or when the task is primarily
about service layers, repositories, database access, caching, jobs, middleware,
or operational backend behavior.

## When to Activate

- Implementing repository, service, or controller layers
- Optimizing database queries (N+1, indexing, connection pooling)
- Adding caching (Redis, in-memory, HTTP cache headers)
- Setting up background jobs or async processing
- Structuring error handling and validation for APIs
- Building middleware (auth, logging, rate limiting)

## Quick Decision Guide

| Need | Pattern | Reference |
|------|---------|-----------|
| Decouple data access from business logic | Repository pattern | `references/data-access.md` |
| Coordinate multi-step business logic | Service layer | `references/data-access.md` |
| Cross-cutting concern (auth, logging) | Middleware | `references/data-access.md` |
| Avoid N+1 in collection fetches | Batch fetch + map | `references/database.md` |
| Cache hot reads | Cache-aside (Redis) | `references/caching.md` |
| Multi-step writes that must succeed/fail together | DB transaction (or saga for cross-service) | `references/database.md` |
| Centralize error response shape | `ApiError` class + handler | `references/errors.md` |
| Transient failures (network, 503) | Retry with exponential backoff | `references/errors.md` |
| Verify identity on every request | JWT in `Authorization: Bearer …` header | `references/auth.md` |
| Permit/deny based on role | RBAC predicate before action | `references/auth.md` |
| Throttle expensive endpoint | Sliding-window rate limiter | `references/rate-limiting.md` |
| Defer slow work | Job queue (BullMQ, SQS, in-process) | `references/jobs.md` |
| Diagnose prod issues | Structured (JSON) logs with request ID | `references/logging.md` |

## Reference Index

- `references/data-access.md` — Repository, service layer, middleware patterns.
- `references/database.md` — Query optimization, N+1 prevention, transactions.
- `references/caching.md` — Redis cache layer, cache-aside pattern.
- `references/errors.md` — Centralized error handling, retry with backoff.
- `references/auth.md` — JWT validation, RBAC predicates.
- `references/rate-limiting.md` — In-memory and distributed rate limiters.
- `references/jobs.md` — Background job queue patterns.
- `references/logging.md` — Structured logging with context.

## Common Pitfalls

- **Validating only at the API layer, then trusting service inputs.** Validate at every trust boundary.
- **Returning ORM entities directly from API.** Map to DTOs to avoid leaking internal fields.
- **Caching without invalidation strategy.** Stale data is worse than no cache.
- **In-memory rate limiter on multi-instance deployments.** Use Redis-backed limiter or you'll under-throttle by N×.
- **Logging full request bodies.** Logs leak PII / secrets — redact or sample.
- **Exposing raw error messages to clients.** Wrap in generic responses; log detail server-side.
