# AGENTS.md

This project uses two governance modes.

## Default: Karpathy Guidelines

For everyday work the agent operates under `README.md` Karpathy Guidelines. No mandatory pipeline.

## Opt-in: Multi-Role Pipeline

The strict multi-role execution system activates **only** when the user triggers it explicitly via:

- `/multirole`
- `full pipeline`
- `formal process`
- `multi-role`

When triggered, the agent MUST follow these files in order:

1. `.agents/rules/auto-role-switching.md`
2. `.agents/rules/role-handoff-compact.md`
3. `.agents/roles/planner.md`
4. `.agents/roles/architect.md`
5. `.agents/roles/engineer.md`
6. `.agents/roles/reviewer.md`
7. `.agents/roles/tester.md`
8. `.agents/roles/documenter.md`

The agent MUST operate in exactly one active role at a time.

The agent MUST use `ROLE_HANDOFF` for every role transition.

The agent MUST compact `ROLE_HANDOFF` before switching roles.
