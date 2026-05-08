---
name: frontend-patterns
id: frontend-patterns
description: Use when building or reviewing React / Next.js components, hooks, state management, forms, performance optimization, error boundaries, animations, or accessibility. Activates on keywords React, Next.js, useState, useEffect, custom hook, code splitting, virtualization, framer-motion, controlled form, error boundary. Skip for Vue, Svelte, Angular, Flutter, SwiftUI — those need a stack-specific skill, not React patterns translated.
category: architecture
version: 1.1.0
triggers:
  positive:
    - React component
    - useState
    - useEffect
    - custom hook
    - virtualization
    - React code splitting
    - Next.js
    - error boundary
    - framer-motion
    - controlled form
    - keyboard navigation
    - render props
    - compound component
  negative:
    - backend
    - API endpoint
    - database query
    - server-side
    - infrastructure
    - Vue
    - Svelte
    - Angular
    - Flutter
    - SwiftUI
requires:
---

# React Frontend Development Patterns

Modern frontend patterns for React, Next.js, and React-based UIs.

## Contract

Inputs:
- React or Next.js UI behavior or component to implement / review.
- Routing model, state management, styling system, accessibility constraints.
- Existing component conventions and test setup.

Outputs:
- Component / hook / state architecture recommendation or patch plan.
- Accessibility, performance, and test considerations.
- Integration notes for existing design-system or frontend conventions.

Verification:
- Prefer repository-specific build, typecheck, lint, unit, and component tests.
- Pair with `ui-ux-pro-max` for visual design decisions and `e2e-testing` for browser flows.

## Stack Boundary

Use this skill ONLY when the repository or user request is React / Next.js based.
For Vue, Svelte, Angular, Flutter, SwiftUI, or native mobile UI work, use current
official documentation and stack-specific conventions instead of translating
React patterns directly. The patterns in this skill (hooks, JSX composition,
Suspense / lazy, Context+Reducer) do not map cleanly to other component models.

## When to Activate

- Building React components (composition, props, rendering)
- Working in a Next.js or React codebase
- Managing state (useState, useReducer, Zustand, Context)
- Implementing data fetching (SWR, React Query, server components)
- Optimizing performance (memoization, virtualization, code splitting)
- Working with forms (validation, controlled inputs, Zod schemas)
- Handling client-side routing and navigation
- Building accessible, responsive UI patterns

## Quick Decision Guide

| Need | Pattern | Reference |
|------|---------|-----------|
| Reusable UI building blocks | Composition with `children` | `references/component-patterns.md` |
| Coordinated state across siblings (e.g. Tabs) | Compound components + Context | `references/component-patterns.md` |
| Flexible render strategy | Render props or custom hook | `references/component-patterns.md` |
| Reused stateful logic | Custom hook | `references/custom-hooks.md` |
| App-wide state with actions | Context + Reducer | `references/state-management.md` |
| Heavy computed value reused | `useMemo` | `references/performance.md` |
| Function passed to memoized child | `useCallback` | `references/performance.md` |
| Long list (50+ items) | Virtualization (`@tanstack/react-virtual`) | `references/performance.md` |
| Rarely-rendered heavy component | `React.lazy` + `Suspense` | `references/performance.md` |
| Form with validation | Controlled inputs + Zod schema | `references/forms.md` |
| Recover from render errors | Error Boundary class component | `references/error-boundaries.md` |
| List/modal animation | Framer Motion `AnimatePresence` | `references/animation.md` |
| Keyboard / focus management | Custom hook + ARIA roles | `references/accessibility.md` |

## Reference Index

- `references/component-patterns.md` — composition, compound components, render props.
- `references/custom-hooks.md` — useToggle, useQuery, useDebounce.
- `references/state-management.md` — Context + Reducer, when to use what.
- `references/performance.md` — memoization, code splitting, virtualization.
- `references/forms.md` — controlled forms, validation, error handling.
- `references/error-boundaries.md` — class component pattern, fallback UI.
- `references/animation.md` — Framer Motion list and modal patterns.
- `references/accessibility.md` — keyboard navigation, focus management, ARIA.

## Common Pitfalls

- **Stale closures in `useEffect`** — list dependencies explicitly; use `eslint-plugin-react-hooks`.
- **Over-memoization** — `useMemo` / `React.memo` have overhead; only apply when render cost is measurable.
- **Context for high-frequency updates** — re-renders all consumers; use Zustand / Jotai for hot state.
- **`useEffect` for derived state** — derive in render or `useMemo` instead.
- **Missing `key` on list items** — causes incorrect re-mounts and lost state.
- **Direct DOM manipulation outside refs** — breaks React's rendering model.
