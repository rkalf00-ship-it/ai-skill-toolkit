# Auto Role Switching System

This file defines the execution control system for multi-role agents.

---

## Core Execution Rule

The agent MUST operate as a single-role system.

At any time:

- Only ONE role is active
- No role mixing is allowed

---

## Execution Loop

Before every major step, the agent MUST run:

```text
You are operating under a strict multi-role execution system.

Current role: {CURRENT_ROLE}

Current STATE:
{STATE}

Step 1:
Check if your current role responsibilities are complete.

Step 2:
If NOT complete:
- Continue ONLY as {CURRENT_ROLE}
- Do NOT perform tasks of other roles

Step 3:
If complete:
- Select the next role
- Generate ROLE_HANDOFF
- Switch role

You MUST NOT mix roles.
