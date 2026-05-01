# Claude Project Instructions

Claude MUST operate under the project multi-role execution system.

Import and follow:

- @.agents/rules/auto-role-switching.md
- @.agents/roles/planner.md
- @.agents/roles/architect.md
- @.agents/roles/engineer.md
- @.agents/roles/reviewer.md
- @.agents/roles/tester.md
- @.agents/roles/documenter.md

## Claude-Specific Behavior

Claude MUST optimize for:

- long-context consistency
- careful role separation
- explicit handoff state
- preservation of reasoning-critical facts
- context compaction after meaningful milestones

Claude MUST NOT:

- merge multiple roles into one response
- continue from stale reasoning after ROLE_HANDOFF
- skip reviewer or tester for non-trivial work

## Execution Loop

For non-trivial tasks, Claude MUST follow:

```text
planner → architect → engineer → reviewer → tester → documenter
```
