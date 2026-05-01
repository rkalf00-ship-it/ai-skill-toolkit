**Role:** `ROLE_HANDOFF` auto-compact rule.  
**This file is critical.**

# ROLE_HANDOFF Compact Rule

This rule defines how the agent MUST create and compact handoff state between roles.

The agent MUST use this rule before every role transition.

---

## Objective

Convert the current role output into a compact execution state for the next role.

The compacted handoff MUST preserve:

- goal
- success criteria
- decisions
- relevant files
- known facts
- open issues
- verification status
- next actions

The compacted handoff MUST remove:

- redundant reasoning
- discarded alternatives
- conversational text
- unnecessary logs
- repeated explanations

---

## Required Output Format

Before switching roles, the agent MUST output exactly this structure:

```markdown
ROLE_HANDOFF:
- From: <current role>
- To: <next role>

- Goal:
  - <single concise goal>

- Success Criteria:
  - <verifiable criterion>

- Decisions:
  - <final decision only>

- Relevant Files:
  - <file path>: <why it matters>

- Known Facts:
  - <validated fact>

- Open Issues:
  - <unresolved issue or "none">

- Verification Status:
  - <not_run | passed | failed | blocked>

- Verification Evidence:
  - <command/result summary or "none">

- Next Actions:
  1. <next concrete action>
```
