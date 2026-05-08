# Sensitive Data Exposure

> Reference for the [security-review](../SKILL.md) skill.

## Logging

```typescript
// WRONG — logging sensitive data
console.log('User login:', { email, password })
console.log('Payment:',    { cardNumber, cvv })

// CORRECT — redact sensitive fields
console.log('User login:', { email, userId })
console.log('Payment:',    { last4: card.last4, userId })
```

For structured loggers (pino, winston), configure redaction paths once
globally so it can't be forgotten at the call site:

```typescript
const logger = pino({
  redact: ['req.headers.authorization', '*.password', '*.cardNumber', '*.cvv'],
})
```

## Error Messages

```typescript
// WRONG — exposing internal details
catch (error) {
  return NextResponse.json(
    { error: error.message, stack: error.stack },
    { status: 500 }
  )
}

// CORRECT — generic message to client, full detail to logs
catch (error) {
  console.error('Internal error:', error)
  return NextResponse.json(
    { error: 'An error occurred. Please try again.' },
    { status: 500 }
  )
}
```

In dev / staging, you can include stack traces. In production: never.

## Verification Steps

- [ ] No passwords, tokens, secrets, or full PII in logs
- [ ] Error messages generic for users
- [ ] Detailed errors only in server logs (with redaction config)
- [ ] No stack traces returned to clients in production
- [ ] PII in URLs avoided (URLs leak via referrer, browser history, server logs)
- [ ] Database backups encrypted at rest
- [ ] Sensitive fields encrypted at the column level if highly sensitive (SSN, full card numbers — better: don't store at all)
