# XSS and CSRF

> Reference for the [security-review](../SKILL.md) skill.

## XSS — Sanitize HTML

```typescript
import DOMPurify from 'isomorphic-dompurify'

function renderUserContent(html: string) {
  const clean = DOMPurify.sanitize(html, {
    ALLOWED_TAGS: ['b', 'i', 'em', 'strong', 'p'],
    ALLOWED_ATTR: [],
  })
  return <div dangerouslySetInnerHTML={{ __html: clean }} />
}
```

React's default JSX escaping prevents XSS automatically — you only need
sanitization when bypassing it via `dangerouslySetInnerHTML` or template
strings rendered as HTML.

## Content Security Policy

```typescript
// next.config.js
const securityHeaders = [
  {
    key: 'Content-Security-Policy',
    value: `
      default-src 'self';
      script-src 'self' 'unsafe-eval' 'unsafe-inline';
      style-src 'self' 'unsafe-inline';
      img-src 'self' data: https:;
      font-src 'self';
      connect-src 'self' https://api.example.com;
    `.replace(/\s{2,}/g, ' ').trim()
  }
]
```

`'unsafe-inline'` and `'unsafe-eval'` weaken CSP significantly. Use nonces
or hashes if your framework supports it.

## CSRF Tokens

```typescript
import { csrf } from '@/lib/csrf'

export async function POST(request: Request) {
  const token = request.headers.get('X-CSRF-Token')
  if (!csrf.verify(token)) {
    return NextResponse.json({ error: 'Invalid CSRF token' }, { status: 403 })
  }
  // ...process request
}
```

## SameSite Cookies

```typescript
res.setHeader('Set-Cookie',
  `session=${sessionId}; HttpOnly; Secure; SameSite=Strict`)
```

`SameSite=Strict` is the strongest CSRF defense for session cookies. Use `Lax`
if you need cross-site GET to keep the user logged in (e.g. clicking a link
from email).

## Verification Steps

- [ ] User-provided HTML sanitized with DOMPurify (or framework equivalent)
- [ ] CSP headers configured and tested in report-only mode first
- [ ] React's default JSX escaping not bypassed unnecessarily
- [ ] CSRF tokens on all state-changing operations OR `SameSite=Strict` session cookies
- [ ] Double-submit cookie pattern as backup if working with cross-origin clients
