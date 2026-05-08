# Workflow Examples

> Reference for the [ui-ux-pro-max](../SKILL.md) skill.

## Example: AI Search Homepage

User request: "Make an AI search homepage."

### Step 1 — Analyze Requirements

- Product type: Tool (AI search engine)
- Target audience: end users looking for fast, intelligent search
- Style keywords: modern, minimal, content-first, dark mode
- Stack: (whatever the project uses — e.g. Next.js, React Native, SwiftUI)

### Step 2 — Generate Design System

```bash
python3 ${SKILL_DIR}/scripts/search.py "AI search tool modern minimal" --design-system -p "AI Search"
```

Output: complete design system with pattern, style, colors, typography, effects, anti-patterns.

### Step 3 — Supplement With Detailed Searches

```bash
# Style options for a modern tool product
python3 ${SKILL_DIR}/scripts/search.py "minimalism dark mode" --domain style

# UX best practices for search interaction and loading
python3 ${SKILL_DIR}/scripts/search.py "search loading animation" --domain ux
```

### Step 4 — Stack Guidelines

```bash
# Replace with your stack
python3 ${SKILL_DIR}/scripts/search.py "list performance navigation" --stack react-native
# or
python3 ${SKILL_DIR}/scripts/search.py "server components data fetching" --stack nextjs
```

### Step 5 — Synthesize and Implement

Combine the design system + detailed searches into the implementation. Run
through the relevant Quick Reference sections (Critical first) as a final
review before delivery — see `references/pre-delivery-checklist.md`.

## Scenarios → Starting Point

| Scenario | Trigger Examples | Start From |
|----------|-----------------|------------|
| **New project / page** | "Build a landing page", "Build a dashboard" | Step 1 → Step 2 (design system) |
| **New component** | "Create a pricing card", "Add a modal" | Step 3 (domain search: style, ux) |
| **Choose style / color / font** | "What style fits a fintech app?" | Step 2 (design system) |
| **Review existing UI** | "Review this page for UX issues", "Check accessibility" | `references/rule-categories.md` checklist |
| **Fix a UI bug** | "Button hover is broken", "Layout shifts on load" | Quick Sticking Points table in SKILL.md |
| **Improve / optimize** | "Make this faster", "Improve mobile experience" | Step 3 (domain: ux + your stack) |
| **Implement dark mode** | "Add dark mode support" | Step 3 (domain: style "dark mode") |
| **Add charts / data viz** | "Add an analytics dashboard chart" | Step 3 (domain: chart) |
| **Stack best practices** | "React performance tips", "SwiftUI navigation" | Step 4 (stack search) |
