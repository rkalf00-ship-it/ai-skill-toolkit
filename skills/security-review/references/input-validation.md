# Input Validation

> Reference for the [security-review](../SKILL.md) skill.

## Always Validate User Input

```typescript
import { z } from 'zod'

const CreateUserSchema = z.object({
  email: z.string().email(),
  name:  z.string().min(1).max(100),
  age:   z.number().int().min(0).max(150),
})

export async function createUser(input: unknown) {
  try {
    const validated = CreateUserSchema.parse(input)
    return await db.users.create(validated)
  } catch (error) {
    if (error instanceof z.ZodError) {
      return { success: false, errors: error.errors }
    }
    throw error
  }
}
```

Per-language equivalents: `pydantic` (Python), `class-validator` (NestJS),
`Bean Validation` (Java), `validator` (Go).

## File Upload Validation

```typescript
function validateFileUpload(file: File) {
  // Size check (5MB max — adjust to your use case)
  const maxSize = 5 * 1024 * 1024
  if (file.size > maxSize) {
    throw new Error('File too large (max 5MB)')
  }

  // Type check (MIME)
  const allowedTypes = ['image/jpeg', 'image/png', 'image/gif']
  if (!allowedTypes.includes(file.type)) {
    throw new Error('Invalid file type')
  }

  // Extension check (defense in depth — MIME can be spoofed)
  const allowedExtensions = ['.jpg', '.jpeg', '.png', '.gif']
  const extension = file.name.toLowerCase().match(/\.[^.]+$/)?.[0]
  if (!extension || !allowedExtensions.includes(extension)) {
    throw new Error('Invalid file extension')
  }

  return true
}
```

For images, also verify magic bytes (first 4–8 bytes) match the claimed
type — `image/png` filename + `<?php` content is a classic upload-to-RCE.

## Verification Steps

- [ ] All user inputs validated with schemas
- [ ] File uploads restricted (size, type, extension, magic bytes)
- [ ] No direct use of user input in queries (see `sql-injection.md`)
- [ ] Whitelist validation, not blacklist
- [ ] Error messages don't leak schema internals (don't echo back the SQL column name)
