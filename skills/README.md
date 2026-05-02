# Curated AI Skills

This folder contains the small, portable skill set selected from the larger `repos/`
catalog for real project use.

## Selection Rules

- Exclude documentation examples and localized docs.
- Exclude duplicate copies from `.cursor`, `.kiro`, and translated docs.
- Prefer executable `SKILL.md` folders that work in Codex, Claude, or Antigravity-style project layouts.
- Remove overlapping roles and keep the clearest trigger for each job.
- Prioritize UI/UX, design, testing, security, analysis, and workflow coverage.
- Keep the final set around 14 highly reusable skills.

## Selected Skills

- `api-design`: production REST API design patterns.
- `backend-patterns`: server-side architecture and backend best practices.
- `codebase-onboarding`: architecture and onboarding analysis for unfamiliar repos.
- `deep-research`: cited multi-source research workflow.
- `documentation-lookup`: current framework and library documentation lookup.
- `e2e-testing`: Playwright E2E testing patterns.
- `frontend-patterns`: React and Next.js implementation patterns.
- `git-workflow`: branch, commit, merge, and collaboration workflow guidance.
- `mcp-server-patterns`: MCP server design and implementation.
- `repo-scan`: cross-stack source asset audit and code inventory.
- `security-review`: secure code review and implementation checklist.
- `tdd-workflow`: test-first feature, bugfix, and refactor workflow.
- `ui-ux-pro-max`: comprehensive UI/UX design skill.
- `verification-loop`: final implementation verification workflow.

## Removed As Overlap

- `browser-qa`: covered by `e2e-testing`.
- `code-tour`: covered by `codebase-onboarding`.
- `frontend-design`: covered by `ui-ux-pro-max` plus `frontend-patterns`.
- `python-patterns`: useful, but too language-specific for the default set.
- `security-scan`: narrower than `security-review`.

## Install

Run from this repository:

```powershell
.\scripts\install-to-project.ps1 -ProjectPath "D:\path\to\project"
```

Skills land in `.agents/skills` (single source); `.claude/skills` and `.codex/skills` are directory junctions to it.

- `-ForcePolicy` - overwrite an existing target `AGENTS.md`, `CLAUDE.md`, or `.agents/AGENTS.md`.
- `-ForceLinks` - replace a pre-existing non-empty `.claude/skills` or `.codex/skills` real directory with a junction.
