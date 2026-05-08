# Tests

This directory holds verification fixtures and test data for the toolkit
itself (not the skills' own test patterns — those live in each skill's
documentation).

## `trigger-fixtures.json`

Sample prompts paired with expected primary-skill activation, used by
`scripts/test-trigger-routing.ps1` to verify trigger-model behavior.

Each entry has:
- `prompt`: a realistic user message.
- `expected_primary`: the skill ID that should win primary routing.
- `expected_companion`: skills that should be paired with the primary.
- `should_not_activate`: skills that must NOT activate for this prompt.

Add new entries when:
- A real-world prompt routes to the wrong skill.
- You add or rename a skill (cover the new skill with at least one fixture).
- You change `primary_when` or `triggers.positive` in a way that affects routing.

## Running the routing test

```powershell
# From the toolkit root
.\scripts\test-trigger-routing.ps1

# Strict: ambiguous routing (multiple skills tied) becomes a failure
.\scripts\test-trigger-routing.ps1 -Strict

# Generate a markdown report for manual dispatcher comparison
.\scripts\test-trigger-routing.ps1 -ReportPath out/dispatcher-report.md
```

## What the test CAN and CANNOT verify

**Can verify (deterministic, scriptable):**
- Each fixture's expected skill has matching keywords in `primary_when` and `triggers.positive`.
- The keyword-based scorer's pick agrees with the expected skill.
- No two skills tie on keyword count + priority for a given prompt.

**Cannot verify (requires real LLM dispatcher):**
- Whether Claude Code / Codex / Cursor actually consume `triggers.positive` — they may match against `description` only.
- Whether the dispatcher's tokenization matches our substring scoring.
- Whether dispatcher behavior changes between model versions.

For the second category, use the `-ReportPath` flag and manually compare
against your actual dispatcher's behavior. Track regressions by re-running
periodically and diffing the reports.
