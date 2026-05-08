# SQL Injection Prevention

> Reference for the [security-review](../SKILL.md) skill.

## NEVER Concatenate SQL

```typescript
// DANGEROUS — SQL Injection
const query = `SELECT * FROM users WHERE email = '${userEmail}'`
await db.query(query)
```

## ALWAYS Use Parameterized Queries

```typescript
// Safe — parameterized query
const { data } = await supabase
  .from('users')
  .select('*')
  .eq('email', userEmail)

// Or with raw SQL
await db.query(
  'SELECT * FROM users WHERE email = $1',
  [userEmail]
)
```

## ORM Caveats

ORMs are not automatic safety. Watch for:

- **Raw query builders** (`db.raw`, `Knex.raw`) — these still concatenate.
- **Order-by injection**: `ORDER BY ${userColumn}` cannot be parameterized — must whitelist.
- **Identifier injection**: table / column names in dynamic queries — same problem.
- **`LIKE` with user input**: parameterizes the value but you may need to escape `%` and `_` if they should be literal.

## Verification Steps

- [ ] All database queries use parameterized queries / prepared statements
- [ ] No string concatenation in SQL (grep for backticks around SELECT/INSERT/UPDATE/DELETE with `${`)
- [ ] ORM raw-query escapes verified
- [ ] `ORDER BY` / column / table names whitelisted, not user-controlled
- [ ] LIKE patterns escape `%` and `_` when user input should be literal
