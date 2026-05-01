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
