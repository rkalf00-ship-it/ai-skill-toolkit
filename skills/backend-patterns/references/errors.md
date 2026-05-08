# Error Handling

> Reference for the [backend-patterns](../SKILL.md) skill.

## Centralized Error Handler

```typescript
class ApiError extends Error {
  constructor(
    public statusCode: number,
    public message: string,
    public isOperational = true
  ) {
    super(message)
    Object.setPrototypeOf(this, ApiError.prototype)
  }
}

export function errorHandler(error: unknown, req: Request): Response {
  if (error instanceof ApiError) {
    return NextResponse.json(
      { success: false, error: error.message },
      { status: error.statusCode }
    )
  }

  if (error instanceof z.ZodError) {
    return NextResponse.json(
      { success: false, error: 'Validation failed', details: error.errors },
      { status: 400 }
    )
  }

  console.error('Unexpected error:', error)
  return NextResponse.json(
    { success: false, error: 'Internal server error' },
    { status: 500 }
  )
}

export async function GET(request: Request) {
  try {
    const data = await fetchData()
    return NextResponse.json({ success: true, data })
  } catch (error) {
    return errorHandler(error, request)
  }
}
```

`isOperational = true` distinguishes expected errors (404, 422, 409) from
programmer errors (`undefined.foo`, type errors). The operational flag lets you
decide whether to alert / page on the error.

## Retry with Exponential Backoff

```typescript
async function fetchWithRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3
): Promise<T> {
  let lastError: Error | undefined
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error as Error
      if (i < maxRetries - 1) {
        const delay = Math.pow(2, i) * 1000  // 1s, 2s, 4s
        await new Promise(resolve => setTimeout(resolve, delay))
      }
    }
  }
  throw lastError!
}

const data = await fetchWithRetry(() => fetchFromAPI())
```

Add jitter (`delay + Math.random() * 1000`) to prevent thundering herd when
many clients retry simultaneously.

Don't retry: 4xx client errors, validation failures, auth errors. Do retry:
network errors, 502 / 503 / 504, timeouts.
