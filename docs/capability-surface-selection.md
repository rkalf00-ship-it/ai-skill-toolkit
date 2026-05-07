# Capability Surface Selection

Use this guide when deciding whether a capability belongs in a rule, skill, MCP
server, plugin, or ordinary CLI/API workflow.

## Decision Matrix

| Surface | Use When | Avoid When |
|---|---|---|
| Rule | The behavior must apply globally and is short enough to keep in context. | The behavior is task-specific, long, or needs assets/scripts. |
| Skill | The capability is reusable, task-triggered, and mostly prompt/procedure driven. | It needs live state, external APIs, or repeated structured calls. |
| MCP server | The model needs controlled access to tools, resources, prompts, or external systems. | A one-off shell command or documented API call is enough. |
| Plugin | You need to package skills, commands, MCP config, and metadata together. | A single standalone skill covers the need. |
| CLI/API workflow | The operation is deterministic and already exposed by a stable command or API. | The model must reason over ambiguous inputs or synthesize outputs. |

## Practical Rules

- Prefer a **skill** for repeatable judgment workflows: reviews, design guidance,
  test strategy, research procedure, and implementation checklists.
- Prefer an **MCP server** when the model needs a typed interface, secrets-safe
  access boundary, rate/cost controls, or reusable resources.
- Prefer a **plugin** when a capability needs multiple installed pieces.
- Keep global **rules** short. Move long examples, checklists, and stack-specific
  guidance into skills or references.
- If a capability can be run and verified by a normal command, expose the command
  first and only wrap it in a skill when selection or interpretation needs model
  judgment.

## Required Contract

Every new capability should declare:

- Activation: when it should and should not run.
- Inputs: required user or repository facts.
- Outputs: concrete artifacts or response shape.
- Verification: how completion is checked.
- Failure mode: what to do when dependencies are missing.
