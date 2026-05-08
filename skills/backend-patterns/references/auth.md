# Authentication & Authorization

> Reference for the [backend-patterns](../SKILL.md) skill.

## JWT Token Validation

```typescript
import jwt from 'jsonwebtoken'

interface JWTPayload {
  userId: string
  email: string
  role: 'admin' | 'user'
}

export function verifyToken(token: string): JWTPayload {
  try {
    return jwt.verify(token, process.env.JWT_SECRET!) as JWTPayload
  } catch {
    throw new ApiError(401, 'Invalid token')
  }
}

export async function requireAuth(request: Request) {
  const token = request.headers.get('authorization')?.replace('Bearer ', '')
  if (!token) throw new ApiError(401, 'Missing authorization token')
  return verifyToken(token)
}

export async function GET(request: Request) {
  const user = await requireAuth(request)
  const data = await getDataForUser(user.userId)
  return NextResponse.json({ success: true, data })
}
```

JWT secret must come from env var, never source. Rotate on suspected compromise.
For high-security paths, prefer short-lived tokens (15m) + refresh tokens.

## Role-Based Access Control

```typescript
type Permission = 'read' | 'write' | 'delete' | 'admin'

interface User {
  id: string
  role: 'admin' | 'moderator' | 'user'
}

const rolePermissions: Record<User['role'], Permission[]> = {
  admin:     ['read', 'write', 'delete', 'admin'],
  moderator: ['read', 'write', 'delete'],
  user:      ['read', 'write'],
}

export function hasPermission(user: User, permission: Permission): boolean {
  return rolePermissions[user.role].includes(permission)
}

export function requirePermission(permission: Permission) {
  return (handler: (request: Request, user: User) => Promise<Response>) => {
    return async (request: Request) => {
      const user = await requireAuth(request)
      if (!hasPermission(user, permission)) {
        throw new ApiError(403, 'Insufficient permissions')
      }
      return handler(request, user)
    }
  }
}

export const DELETE = requirePermission('delete')(
  async (request: Request, user: User) => {
    return new Response('Deleted', { status: 200 })
  }
)
```

For finer-grained access (per-resource), pair this with **resource ownership
checks** in the handler:

```typescript
const post = await postRepo.findById(req.params.id)
if (post.authorId !== user.id && user.role !== 'admin') {
  throw new ApiError(403, 'Not your post')
}
```
