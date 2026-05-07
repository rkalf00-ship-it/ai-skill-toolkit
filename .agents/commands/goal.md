# /goal Command

Use `/goal` to turn a broad request into a bounded, skill-routed execution loop.

## Activation

The command activates when the user starts with `/goal` or explicitly asks to use the goal workflow.

Examples:

```text
/goal Improve this repository as a reusable AI skill toolkit.
/goal Add a secure payment endpoint with tests.
/goal Review this UI and make it production-ready.
```

## Required Behavior

1. Restate the goal in one sentence.
2. Define 3-7 verifiable success criteria.
3. Select one primary skill from `.agents/skills/manifest.json` in an installed project, or `skills/manifest.json` when working inside this toolkit repository.
4. Select only necessary companion skills from `pairs_with`.
5. Identify conflicts from `conflicts_with` and explain which skill wins.
6. Execute the smallest useful improvement loop.
7. Run the relevant verification checks.
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
