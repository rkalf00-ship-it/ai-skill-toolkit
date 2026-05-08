# HTTP Methods and Status Codes

> Reference for the [api-design](../SKILL.md) skill.

## Method Semantics

| Method | Idempotent | Safe | Use For |
|--------|-----------|------|---------|
| GET | Yes | Yes | Retrieve resources |
| POST | No | No | Create resources, trigger actions |
| PUT | Yes | No | Full replacement of a resource |
| PATCH | No* | No | Partial update of a resource |
| DELETE | Yes | No | Remove a resource |

*PATCH can be made idempotent with proper implementation (e.g. JSON Patch with version checks).

## Status Code Reference

```
# Success
200 OK                    - GET, PUT, PATCH (with response body)
201 Created               - POST (include Location header)
204 No Content            - DELETE, PUT (no response body)

# Client Errors
400 Bad Request           - Validation failure, malformed JSON
401 Unauthorized          - Missing or invalid authentication
403 Forbidden             - Authenticated but not authorized
404 Not Found             - Resource doesn't exist
409 Conflict              - Duplicate entry, state conflict
422 Unprocessable Entity  - Semantically invalid (valid JSON, bad data)
429 Too Many Requests     - Rate limit exceeded

# Server Errors
500 Internal Server Error - Unexpected failure (never expose details)
502 Bad Gateway           - Upstream service failed
503 Service Unavailable   - Temporary overload, include Retry-After
```

## Common Mistakes

```
# BAD: 200 for everything
{ "status": 200, "success": false, "error": "Not found" }

# GOOD: Use HTTP status codes semantically
HTTP/1.1 404 Not Found
{ "error": { "code": "not_found", "message": "User not found" } }

# BAD: 500 for validation errors
# GOOD: 400 or 422 with field-level details

# BAD: 200 for created resources
# GOOD: 201 with Location header
HTTP/1.1 201 Created
Location: /api/v1/users/abc-123
```

## 400 vs 422

- `400 Bad Request`: malformed JSON, missing required field, type mismatch.
- `422 Unprocessable Entity`: well-formed JSON, valid types, but semantically invalid (e.g. start_date after end_date).

Some APIs use only `400` for both — that is acceptable as long as you're consistent.
