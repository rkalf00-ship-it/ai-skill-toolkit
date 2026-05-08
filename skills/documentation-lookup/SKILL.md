---
name: documentation-lookup
id: documentation-lookup
description: Use when the user asks how to use a library, framework, or API, asks for setup / configuration help, references a specific framework (React, Next.js, Prisma, Supabase, Tailwind, Vue, etc.), or needs current API reference. Fetches live docs via Context7 MCP instead of training data. Activates on how do I configure, how to use, API reference, library docs, framework setup, latest version, plus library names. Skip for questions about the user's internal API or business logic.
category: research
version: 1.1.0
triggers:
  positive:
    - how do I configure
    - how to use
    - API reference
    - library docs
    - framework setup
    - latest version
    - Next.js
    - React
    - Prisma
    - Supabase
    - Tailwind
  negative:
    - our internal API
    - this codebase
    - business logic
requires:
---

# Documentation Lookup (Context7)

When the user asks about libraries, frameworks, or APIs, fetch current
documentation via the Context7 MCP (`resolve-library-id` + `query-docs`)
instead of relying on training data.

## Contract

Inputs:
- Library, framework, API, or product name.
- Specific task, error, setup goal, or API behavior question.
- Version, runtime, language, framework constraints when provided.

Outputs:
- Answer grounded in current documentation.
- Minimal code example when useful.
- Library / version cited when behavior is version-sensitive.
- Uncertainty note when the selected docs do not directly answer the question.

Verification:
- Resolve the library ID before querying Context7.
- Prefer official or primary package documentation.
- Limit tool calls as described below; state when evidence is incomplete.

Failure mode:
- If Context7 is unavailable, use the fallback ladder below.
- Never invent API signatures, version behavior, or migration guidance when current
  documentation cannot be accessed.

Fallback ladder:
1. Use another configured documentation MCP if the host exposes one.
2. Use the host's approved web / search / browse tool restricted to official
   documentation domains or primary repositories.
3. Use user-provided documentation URLs, local docs, lockfiles, package
   manifests, or pasted excerpts.
4. If none of the above exists, ask the user to provide docs or state that
   current documentation lookup cannot be completed.

Fallback output requirements:
- Label the evidence path as `Context7`, `official-docs fallback`,
  `local/user-provided docs`, or `blocked`.
- Cite the library name and version / source when behavior is version-sensitive.
- If only local package metadata is available, distinguish installed-version
  inference from documented API behavior.

## Core Concepts

- **Context7**: MCP server that exposes live documentation; use it instead of
  training data for libraries and APIs.
- **resolve-library-id**: Returns Context7-compatible library IDs
  (e.g. `/vercel/next.js`) from a library name and query.
- **query-docs**: Fetches documentation and code snippets for a given library
  ID and question. Always call `resolve-library-id` first to get a valid ID.

## When to Use

- Setup or configuration questions ("How do I configure Next.js middleware?")
- Library-dependent code ("Write a Prisma query for...")
- API or reference information ("What are the Supabase auth methods?")
- Specific frameworks or libraries mentioned (React, Vue, Svelte, Express, Tailwind, Prisma, Supabase, etc.)

## How It Works

### Step 1 — Resolve the Library ID

Call `resolve-library-id` with:
- **libraryName**: The library or product name from the user's question (e.g. `Next.js`, `Prisma`, `Supabase`).
- **query**: The user's full question (improves relevance ranking).

You must obtain a Context7-compatible library ID (`/org/project` or
`/org/project/version`) before querying docs. Do not call `query-docs` without
a valid library ID from this step.

### Step 2 — Select the Best Match

From resolution results, choose using:
- **Name match**: Prefer exact or closest match.
- **Benchmark score**: Higher is better (100 is highest).
- **Source reputation**: Prefer High or Medium when available.
- **Version**: If the user specified a version, prefer the version-specific ID.

### Step 3 — Fetch the Documentation

Call `query-docs` with:
- **libraryId**: The selected ID from Step 2 (e.g. `/vercel/next.js`).
- **query**: The user's specific question. Be specific.

Limit: do not call `query-docs` (or `resolve-library-id`) more than 3 times per
question. If the answer is unclear after 3 calls, state the uncertainty and use
the best information available rather than guessing.

### Step 4 — Use the Documentation

- Answer the user's question using the fetched, current information.
- Include relevant code examples from the docs when helpful.
- Cite the library or version when it matters ("In Next.js 15…").

## Examples

### Next.js middleware
1. `resolve-library-id`: `libraryName: "Next.js"`, `query: "How do I set up Next.js middleware?"`.
2. Pick `/vercel/next.js` by name and benchmark score.
3. `query-docs`: `libraryId: "/vercel/next.js"`, `query: "How do I set up Next.js middleware?"`.
4. Answer with a minimal `middleware.ts` example from the docs.

### Prisma query
1. `resolve-library-id`: `libraryName: "Prisma"`, `query: "How do I query with relations?"`.
2. Select `/prisma/prisma`.
3. `query-docs` with that `libraryId` and the query.
4. Return the Prisma Client pattern (`include` or `select`) with a snippet.

## Best Practices

- **Be specific**: use the user's full question as the query.
- **Version awareness**: when the user mentions a version, use the version-specific library ID.
- **Prefer official sources**: when multiple matches exist, prefer official or primary packages.
- **No sensitive data**: redact API keys, passwords, tokens from any query sent to Context7. Treat the user's question as potentially containing secrets before passing it to the MCP.
