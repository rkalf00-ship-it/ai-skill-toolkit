---
name: ui-ux-pro-max
description: Use for UI/UX design decisions, component creation, accessibility review, design-system generation, color / typography / chart selection, responsive layout, dark mode, animation timing, navigation patterns. Searchable database of styles, color palettes, font pairings, UX guidelines, chart types across multiple stacks. Activates on landing page, dashboard, design system, color palette, typography, font pairing, accessibility review, component design, dark mode, responsive layout, chart type. Skip for backend logic, database schema, infrastructure, DevOps, or non-visual scripts.
id: ui-ux-pro-max
category: design
version: 0.2.0
triggers:
  positive:
    - landing page
    - dashboard
    - admin panel
    - design system
    - color palette
    - typography
    - font pairing
    - accessibility review
    - component design
    - dark mode
    - responsive layout
    - chart type selection
    - shadcn/ui
  negative:
    - backend logic only
    - database schema
    - infrastructure
    - DevOps
    - non-visual script
requires:
  bin: [python3]
---

# UI/UX Pro Max — Design Intelligence

Comprehensive design guide with searchable database of styles, color palettes,
font pairings, UX guidelines, and chart types across multiple stacks.

## Contract

Inputs:
- Product type, target users, platform, stack, brand constraints, UI task.
- Existing design system, screenshots, or component conventions when available.

Outputs:
- Design-system recommendation, component / layout guidance, or UX review findings.
- Accessibility, responsive, interaction, typography, color, performance checks.
- Script query results or generated design artifacts when applicable.

Verification:
- Start from the compact rules below, then use scripts / data only for the relevant domain.
- Check text fit, contrast, touch targets, responsive behavior, visible interaction states before delivery.

## Context Loading Policy

This skill ships large CSV data and templates. Treat those files as an indexed
knowledge base, not as prompt context.

Default behavior:
- Read this `SKILL.md` only.
- Do not open `data/*.csv`, `data/stacks/*.csv`, or `templates/**` directly during normal use.
- Use `scripts/search.py` or `scripts/design_system.py` for the specific product, style, stack, chart, color, typography, or UX domain needed by the task.
- Load a raw data / template file only when debugging the skill itself or when a script fails and the exact file is needed.

Fallback:
- If Python or the search scripts are unavailable, use the compact rule categories
  in `references/rule-categories.md` and state that the full design database was not queried.

Verification:
- Before final delivery, verify that only task-relevant domains were queried or
  explain why a broader query was necessary.

## When to Apply

This skill should be used when the task involves **UI structure, visual design
decisions, interaction patterns, or user experience quality control**.

### Must Use

- Designing new pages (Landing Page, Dashboard, Admin, SaaS, Mobile App)
- Creating or refactoring UI components (buttons, modals, forms, tables, charts, etc.)
- Choosing color schemes, typography systems, spacing standards, layout systems
- Reviewing UI code for UX, accessibility, or visual consistency
- Implementing navigation structures, animations, responsive behavior
- Making product-level design decisions (style, hierarchy, brand expression)

### Skip

- Pure backend logic
- Only API or database design
- Performance optimization unrelated to the interface
- Infrastructure / DevOps
- Non-visual scripts or automation tasks

**Decision criteria**: If the task changes how a feature **looks, feels,
moves, or is interacted with**, use this skill.

## Rule Categories by Priority

| # | Category | Impact | Domain | Reference |
|---|----------|--------|--------|-----------|
| 1 | Accessibility | CRITICAL | `ux` | `references/rule-categories.md` |
| 2 | Touch & Interaction | CRITICAL | `ux` | `references/rule-categories.md` |
| 3 | Performance | HIGH | `ux` | `references/rule-categories.md` |
| 4 | Style Selection | HIGH | `style`, `product` | `references/rule-categories.md` |
| 5 | Layout & Responsive | HIGH | `ux` | `references/rule-categories.md` |
| 6 | Typography & Color | MEDIUM | `typography`, `color` | `references/rule-categories.md` |
| 7 | Animation | MEDIUM | `ux` | `references/rule-categories.md` |
| 8 | Forms & Feedback | MEDIUM | `ux` | `references/rule-categories.md` |
| 9 | Navigation Patterns | HIGH | `ux` | `references/rule-categories.md` |
| 10 | Charts & Data | LOW | `chart` | `references/rule-categories.md` |

Critical (priority 1-2) checks must pass for any UI delivery; the rest are
prioritized by task scope.

## Reference Index

- `references/rule-categories.md` — full 10-category rule reference (~300 rules with platform attribution).
- `references/script-usage.md` — `scripts/search.py` and `scripts/design_system.py` query patterns.
- `references/professional-ui-rules.md` — icons / interaction / contrast / layout rules tables.
- `references/pre-delivery-checklist.md` — visual / interaction / dark-mode / layout / accessibility verification.
- `references/workflow-examples.md` — end-to-end example: requirements → design system → detailed search → stack guidance.

## Prerequisites

```bash
python3 --version || python --version
```

If Python is not installed:
- macOS: `brew install python3`
- Ubuntu/Debian: `sudo apt update && sudo apt install python3`
- Windows: `winget install Python.Python.3.12`

## How to Use This Skill

> **Path note:** Commands use `${SKILL_DIR}` as a placeholder. Replace with the
> actual installed path: `.claude/skills/ui-ux-pro-max`,
> `.agents/skills/ui-ux-pro-max`, or `.codex/skills/ui-ux-pro-max`.

**Step 1 — Generate design system** (for new visual direction):
```bash
python3 ${SKILL_DIR}/scripts/search.py "<product_type> <industry> <keywords>" --design-system [-p "Project Name"]
```

**Step 2 — Optional persist** (master + per-page overrides):
```bash
python3 ${SKILL_DIR}/scripts/search.py "<query>" --design-system --persist -p "Project Name" --page "dashboard"
```

**Step 3 — Detailed domain search**:
```bash
python3 ${SKILL_DIR}/scripts/search.py "<keyword>" --domain <domain> [-n <max_results>]
```

Available domains: `product`, `style`, `typography`, `color`, `landing`,
`chart`, `ux`, `google-fonts`, `react`, `web`, `prompt`.

Full query syntax, output formats, and worked examples: `references/script-usage.md`.

## Quick Sticking Points

| Problem | What to Do |
|---------|------------|
| Can't decide on style / color | Re-run `--design-system` with different keywords |
| Dark mode contrast issues | `references/rule-categories.md` §6: `color-dark-mode` + `color-accessible-pairs` |
| Animations feel unnatural | `references/rule-categories.md` §7: `spring-physics` + `easing` + `exit-faster-than-enter` |
| Form UX is poor | `references/rule-categories.md` §8: `inline-validation` + `error-clarity` + `focus-management` |
| Navigation feels confusing | `references/rule-categories.md` §9: `nav-hierarchy` + `bottom-nav-limit` + `back-behavior` |
| Layout breaks on small screens | `references/rule-categories.md` §5: `mobile-first` + `breakpoint-consistency` |
| Performance / jank | `references/rule-categories.md` §3: `virtualize-lists` + `main-thread-budget` + `debounce-throttle` |
