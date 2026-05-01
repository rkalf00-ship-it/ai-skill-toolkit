# Claude Project Instructions

## Default Mode: Karpathy Guidelines

For everyday work, Claude operates under the Karpathy Guidelines in `README.md`:

- Think before coding (state assumptions, surface tradeoffs)
- Simplicity first (minimum code, no speculation)
- Surgical changes (touch only what's needed)
- Goal-driven execution (define verifiable success criteria)

No multi-role pipeline by default.

## Opt-in: Multi-Role Pipeline

Claude switches to the strict multi-role execution system **only when the user explicitly triggers it** with one of:

- `/multirole`
- `full pipeline`
- `정식 절차로`
- `멀티롤로`

When triggered, Claude MUST follow:

```text
planner → architect → engineer → reviewer → tester → documenter
```

And import:

- @.agents/rules/auto-role-switching.md
- @.agents/rules/role-handoff-compact.md
- @.agents/roles/planner.md
- @.agents/roles/architect.md
- @.agents/roles/engineer.md
- @.agents/roles/reviewer.md
- @.agents/roles/tester.md
- @.agents/roles/documenter.md

## Claude-Specific Behavior (when pipeline is active)

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
