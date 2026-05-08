# Form Handling

> Reference for the [frontend-patterns](../SKILL.md) skill.

## Controlled Form with Validation

```typescript
interface FormData {
  name: string
  description: string
  endDate: string
}

interface FormErrors {
  name?: string
  description?: string
  endDate?: string
}

export function CreateMarketForm() {
  const [formData, setFormData] = useState<FormData>({
    name: '', description: '', endDate: ''
  })
  const [errors, setErrors] = useState<FormErrors>({})

  const validate = (): boolean => {
    const newErrors: FormErrors = {}
    if (!formData.name.trim())              newErrors.name = 'Name is required'
    else if (formData.name.length > 200)    newErrors.name = 'Name must be under 200 characters'
    if (!formData.description.trim())       newErrors.description = 'Description is required'
    if (!formData.endDate)                  newErrors.endDate = 'End date is required'
    setErrors(newErrors)
    return Object.keys(newErrors).length === 0
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!validate()) return
    try {
      await createMarket(formData)
    } catch (error) {
      // Map error to field if possible
    }
  }

  return (
    <form onSubmit={handleSubmit}>
      <input
        value={formData.name}
        onChange={e => setFormData(prev => ({ ...prev, name: e.target.value }))}
        placeholder="Market name"
      />
      {errors.name && <span className="error">{errors.name}</span>}
      <button type="submit">Create Market</button>
    </form>
  )
}
```

For non-trivial forms prefer **react-hook-form** + **zod** — less boilerplate,
better performance (uncontrolled inputs), built-in validation pipeline:

```typescript
import { useForm } from 'react-hook-form'
import { zodResolver } from '@hookform/resolvers/zod'
import { z } from 'zod'

const schema = z.object({
  name: z.string().min(1).max(200),
  description: z.string().min(1),
  endDate: z.string().min(1),
})

const { register, handleSubmit, formState: { errors } } =
  useForm({ resolver: zodResolver(schema) })
```
