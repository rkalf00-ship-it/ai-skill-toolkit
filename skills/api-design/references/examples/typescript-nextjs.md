# TypeScript (Next.js App Router)

> Reference for the [api-design](../../SKILL.md) skill.

```typescript
import { z } from "zod"
import { NextRequest, NextResponse } from "next/server"

const createUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1).max(100),
})

export async function POST(req: NextRequest) {
  const body = await req.json()
  const parsed = createUserSchema.safeParse(body)

  if (!parsed.success) {
    return NextResponse.json({
      error: {
        code: "validation_error",
        message: "Request validation failed",
        details: parsed.error.issues.map(i => ({
          field: i.path.join("."),
          message: i.message,
          code: i.code,
        })),
      },
    }, { status: 422 })
  }

  const user = await createUser(parsed.data)

  return NextResponse.json(
    { data: user },
    {
      status: 201,
      headers: { Location: `/api/v1/users/${user.id}` },
    },
  )
}
```
