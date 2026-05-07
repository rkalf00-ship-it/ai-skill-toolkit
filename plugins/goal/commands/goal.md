# /goal

Turn a broad objective into a bounded, skill-routed execution loop.

## Arguments

- `objective`: the task or improvement goal to complete.

## Workflow

1. Restate the objective in one sentence.
2. Define 3-7 verifiable success criteria.
3. Select one primary skill from `.agents/skills/manifest.json` in an installed project, or `skills/manifest.json` when working inside this toolkit repository.
4. Add companion skills only when they materially improve the result.
5. Identify conflicting skills and state which one wins.
6. Execute the smallest useful improvement loop.
7. Run relevant verification checks.
8. Report changed files, verification evidence, and remaining risks.

## Output Shape

```markdown
GOAL:
- ...

SUCCESS CRITERIA:
- ...

SKILL ROUTING:
- Primary: ...
- Companion: ...
- Suppressed: ...

EXECUTION PLAN:
1. ...

VERIFICATION:
- ...

RESULT:
- ...
```

## Guardrails

- Do not activate the full multi-role pipeline unless the user also asks for `/multirole`.
- Do not load every skill. Use the manifest to keep context small.
- Prefer repository-specific commands over generic examples.
- If success criteria cannot be verified locally, state the blocker and provide the nearest practical check.
