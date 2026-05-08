# Structured Logging

> Reference for the [backend-patterns](../SKILL.md) skill.

## Structured Logger

```typescript
interface LogContext {
  userId?: string
  requestId?: string
  method?: string
  path?: string
  [key: string]: unknown
}

class Logger {
  log(level: 'info' | 'warn' | 'error', message: string, context?: LogContext) {
    console.log(JSON.stringify({
      timestamp: new Date().toISOString(),
      level,
      message,
      ...context,
    }))
  }

  info(message: string, context?: LogContext)  { this.log('info', message, context) }
  warn(message: string, context?: LogContext)  { this.log('warn', message, context) }
  error(message: string, error: Error, context?: LogContext) {
    this.log('error', message, {
      ...context,
      error: error.message,
      stack: error.stack,
    })
  }
}

const logger = new Logger()

export async function GET(request: Request) {
  const requestId = crypto.randomUUID()
  logger.info('Fetching markets', {
    requestId, method: 'GET', path: '/api/markets',
  })
  try {
    const markets = await fetchMarkets()
    return NextResponse.json({ success: true, data: markets })
  } catch (error) {
    logger.error('Failed to fetch markets', error as Error, { requestId })
    return NextResponse.json({ error: 'Internal error' }, { status: 500 })
  }
}
```

Production stacks: prefer **pino** (Node), **structlog** (Python), **zerolog**
(Go) — they ship with sampling, level filters, and async writes built in.

## What to Log

- Request entry: method, path, requestId, userId (if authenticated).
- Request exit: status, duration_ms, response_size.
- Errors: full error + stack + relevant context (request body usually NO — see below).
- Business events: payment received, account created, plan changed.

## What NOT to Log

- **Passwords, tokens, API keys, secrets** — even in error messages or stack traces.
- **Full request bodies** for routes that accept PII / payment data.
- **PII without business need** — emails, phone numbers, addresses.
- Health-check spam (200 every second floods storage).

## Correlation IDs

Generate a `requestId` at the entry middleware and propagate it through every
log line and downstream call. This lets you reconstruct a single request from
distributed logs.
