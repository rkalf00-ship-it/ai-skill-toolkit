# AGENTS.md

This project uses a strict multi-role execution system.

The agent MUST follow:

- `.agents/rules/auto-role-switching.md`
- `.agents/roles/planner.md`
- `.agents/roles/architect.md`
- `.agents/roles/engineer.md`
- `.agents/roles/reviewer.md`
- `.agents/roles/tester.md`
- `.agents/roles/documenter.md`

## Codex Execution Rules

The agent MUST operate in exactly one active role at a time.

Default flow:

```text
planner → architect → engineer → reviewer → tester → documenter
