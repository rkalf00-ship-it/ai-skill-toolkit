---
name: goal
id: goal
description: "Use when the user invokes /goal or asks for goal-based execution. Defines success criteria, routes to AI Skill Toolkit skills, runs focused work, and verifies outcomes."
category: workflow
version: 0.1.0
triggers:
  positive:
    - /goal
    - goal workflow
    - goal-based execution
    - success criteria
    - skill routing
  negative:
    - /multirole
    - full pipeline
    - formal process
requires:
  os: [windows, macos, linux]
---

# Goal Workflow

Use this skill when the user invokes `/goal <objective>` or explicitly asks for goal-based execution.

## Purpose

Turn a broad objective into a bounded execution loop:

1. Define the goal.
2. Define verifiable success criteria.
3. Route to the right AI Skill Toolkit skill.
4. Execute the smallest useful improvement.
5. Verify the result.
6. Report evidence and residual risk.

## Routing Source

Read the manifest from the first path that exists:

1. `.agents/skills/manifest.json`
2. `skills/manifest.json`
3. `ai-skill-toolkit/skills/manifest.json`

Do not load every `SKILL.md`. Use the manifest first, then open only the selected primary skill and necessary companion skills.

## Required Behavior

When `/goal <objective>` is used:

1. Restate the objective in one sentence.
2. Convert it into 3-7 verifiable success criteria.
3. Select one primary skill using `primary_when`, `category`, and `priority`.
4. Add companion skills only when they materially improve the result.
5. Suppress conflicting skills and state why.
6. Execute the work directly unless a blocker requires clarification.
7. Run relevant verification commands.
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

- Do not activate the strict multi-role pipeline unless the user also asks for `/multirole`.
- Keep scope small enough to complete and verify.
- Prefer repository-specific commands over generic examples.
- If local verification is impossible, state the blocker and run the closest practical check.
