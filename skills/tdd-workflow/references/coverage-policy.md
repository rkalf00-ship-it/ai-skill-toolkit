# Coverage Policy

> Reference for the [tdd-workflow](../SKILL.md) skill.

## Run Coverage

```bash
# Use the repository's existing command
npm run test:coverage    # Node
pytest --cov             # Python
go test -cover ./...     # Go
bundle exec rspec --format documentation  # Ruby (with simplecov)
```

## Choosing Thresholds

The toolkit explicitly does **not** prescribe a fixed percentage. Reasons:

- Different codebases have different rational coverage levels (UI shells lower
  than business logic).
- A specific number creates incentives to game the metric (test trivial getters
  to lift coverage without testing behavior).
- Repositories that already define a threshold should keep using it.

Guidelines for adding a threshold to a repo that has none:
- Set a **floor** that protects current state, not an aspiration. Run coverage
  on `main`, take the current number, set the threshold a few points below it.
- Discuss with the team / user before adding — agreed thresholds are kept,
  imposed ones are bypassed.
- Prefer per-directory thresholds for critical modules over a single global
  number.

Example Jest config (only after explicit discussion):

```json
{
  "jest": {
    "coverageThreshold": {
      "global":    { "branches": 75, "functions": 75, "lines": 75, "statements": 75 },
      "src/auth/": { "branches": 90, "functions": 90, "lines": 90, "statements": 90 }
    }
  }
}
```

## Reading the Report

- **Lines / Statements** — easiest to increase, weakest signal.
- **Branches** — covers if / else / switch arms; better signal of behavior coverage.
- **Functions** — every function called at least once.

Branch coverage gaps usually point to untested error paths and edge conditions
— prioritize fixing those over chasing line %.

## What Coverage Does Not Measure

- Test quality (assertions can be missing or trivial).
- Property / fuzz coverage (the inputs you didn't think to try).
- Integration boundaries (mocked dependencies don't tell you about real wiring).
- Concurrency, timing, and race conditions.

Use coverage as a **floor**, not a ceiling — high coverage with weak tests is
worse than honest gaps.
