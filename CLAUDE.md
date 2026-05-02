# Claude Project Instructions

@AGENTS.md

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
