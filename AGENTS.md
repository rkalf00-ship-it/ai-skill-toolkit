# AGENTS.md

This project uses a strict multi-role execution system.

The agent MUST follow these files in order:

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
