---
name: codebase-onboarding
id: codebase-onboarding
description: Use when joining a new project or setting up Claude Code in an existing repo for the first time — produces an architecture map, key entry points, conventions, common tasks, and a starter / updated CLAUDE.md / AGENTS.md. Activates on onboard me, walk me through this repo, understand this codebase, generate CLAUDE.md, new repo, joining a team. Skip when the user is already actively refactoring, fixing bugs, or implementing features — use the relevant patterns skill instead.
category: research
version: 1.1.0
triggers:
  positive:
    - onboard me
    - walk me through this repo
    - understand this codebase
    - generate CLAUDE.md
    - new repo
    - new project
    - joining a team
    - help me understand this codebase
  negative:
    - refactor
    - fix bug
    - add feature
    - implement
requires:
---

# Codebase Onboarding

Systematically analyze an unfamiliar codebase and produce a structured
onboarding guide. Designed for developers joining a new project or setting
up Claude Code in an existing repo for the first time.

## Contract

Inputs:
- Repository path and onboarding goal.
- Preferred target artifact: conversation guide, `AGENTS.md`, `CLAUDE.md`, or both.
- Existing project instructions that must be preserved.

Outputs:
- Architecture and entry-point summary.
- Detected commands, conventions, risks, common tasks.
- Updated or proposed project instruction file when requested.

Verification:
- Read existing instruction files before writing.
- Cite concrete files, scripts, and config evidence for detected conventions.
- Keep generated instruction files focused and project-specific.

## When to Use

- First time opening a project with Claude Code
- Joining a new team or repository
- "Help me understand this codebase"
- Generate a CLAUDE.md for a project
- "Onboard me" / "walk me through this repo"

## Four-Phase Workflow

| Phase | Goal | Tools | Reference |
|-------|------|-------|-----------|
| 1. Reconnaissance | Detect package manifests, frameworks, entry points, tooling, tests | Glob, Grep (parallel) | `references/reconnaissance.md` |
| 2. Architecture Mapping | Identify tech stack, architecture pattern, key directories, request lifecycle | Read selectively | `references/architecture-mapping.md` |
| 3. Convention Detection | Naming, code patterns, git conventions | Read sample files, `git log` | `references/convention-detection.md` |
| 4. Generate Artifacts | Produce onboarding guide and / or CLAUDE.md | Write | `references/output-templates.md` |

## Best Practices

1. **Don't read everything.** Reconnaissance uses Glob and Grep, not Read on every file. Read selectively only for ambiguous signals.
2. **Verify, don't guess.** If a framework is detected from config but the actual code uses something different, trust the code.
3. **Respect existing CLAUDE.md.** If one already exists, enhance it rather than replacing it. Call out what's new vs existing.
4. **Stay concise.** The onboarding guide should be scannable in 2 minutes. Details belong in the code, not the guide.
5. **Flag unknowns.** If a convention can't be confidently detected, say so rather than guessing. "Could not determine test runner" beats a wrong answer.

## Anti-Patterns to Avoid

- Generating a `CLAUDE.md` longer than 100 lines — keep it focused.
- Listing every dependency — highlight only the ones that shape how you write code.
- Describing obvious directory names — `src/` doesn't need an explanation.
- Copying the README — the onboarding guide adds structural insight the README lacks.

## Example Modes

| User says | Action | Output |
|-----------|--------|--------|
| "Onboard me to this codebase" | Full 4-phase workflow | Onboarding Guide in chat + new `CLAUDE.md` |
| "Generate a CLAUDE.md for this project" | Phases 1–3, skip Guide | Project-specific `CLAUDE.md` |
| "Update the CLAUDE.md with current project conventions" | Read existing → Phases 1–3 → merge | Updated `CLAUDE.md`, additions clearly marked |

## Reference Index

- `references/reconnaissance.md` — Phase 1 detection commands and what to look for.
- `references/architecture-mapping.md` — Phase 2 tech stack, directories, data flow.
- `references/convention-detection.md` — Phase 3 naming, patterns, git conventions.
- `references/output-templates.md` — Phase 4 Onboarding Guide and CLAUDE.md templates.
