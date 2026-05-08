# Authentication & Authorization

> Reference for the [security-review](../SKILL.md) skill.

## JWT Token Handling

```typescript
// WRONG — localStorage is vulnerable to XSS
localStorage.setItem('token', token)

// CORRECT — httpOnly cookie
res.setHeader('Set-Cookie',
  `token=${token}; HttpOnly; Secure; SameSite=Strict; Max-Age=3600`)
```

`HttpOnly` blocks JavaScript access. `Secure` restricts to HTTPS. `SameSite=Strict`
blocks the cookie on cross-site requests (CSRF defense).

## Authorization Checks

```typescript
export async function deleteUser(userId: string, requesterId: string) {
  const requester = await db.users.findUnique({ where: { id: requesterId } })

  // ALWAYS verify authorization first
  if (requester.role !== 'admin') {
    return NextResponse.json({ error: 'Unauthorized' }, { status: 403 })
  }

  await db.users.delete({ where: { id: userId } })
}
```

## Row Level Security (Supabase / Postgres)

```sql
-- Enable RLS on all tables that store user data
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);
```

RLS is **defense in depth**. Application-layer authz can be bypassed by an
admin connection string leak; RLS still blocks the query.

## Verification Steps

- [ ] Tokens stored in httpOnly cookies (not localStorage / sessionStorage)
- [ ] Authorization check **before** every sensitive operation (not just at route registration)
- [ ] Row Level Security enabled in Postgres / Supabase
- [ ] Role-based access control implemented and tested
- [ ] Session expiration and refresh handled
- [ ] Logout actually invalidates the token (server-side blacklist or short-lived tokens)
- [ ] Multi-factor authentication available for sensitive accounts
