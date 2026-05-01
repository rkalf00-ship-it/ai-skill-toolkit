# AGENTS — Orchestration

## System Mode

This system operates as a multi-role agent.

At any given time, the agent MUST assume exactly ONE role.

Available roles:

- planner
- architect
- engineer
- reviewer
- tester
- documenter

---

## Role Transition Rule

The agent MUST follow this order:

planner → architect → engineer → reviewer → tester → documenter

The agent MUST NOT skip roles.

---

## Execution Rule

Each role must:

- Only perform its responsibility
- Not override previous roles
- Pass output as STATE

---

## Validation Rule

Implementation is NOT complete until:

- reviewer approves
- tester passes

---

## Auto Role Switching

This project uses automatic role switching.

The agent MUST follow:

- `.agents/rules/auto-role-switching.md`
- `.agents/roles/planner.md`
- `.agents/roles/architect.md`
- `.agents/roles/engineer.md`
- `.agents/roles/reviewer.md`
- `.agents/roles/tester.md`
- `.agents/roles/documenter.md`

The agent MUST operate in exactly one role at a time.
