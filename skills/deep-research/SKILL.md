---
name: deep-research
id: deep-research
description: Use for thorough multi-source research with citations — competitive analysis, technology evaluation, market sizing, due diligence, current state of a topic. Uses firecrawl / exa MCPs when available, falls back to web-search or user-provided sources. Activates on research, deep dive, investigate, current state of, market sizing, competitive analysis, due diligence, cited report. Skip for codebase questions (use codebase-onboarding) or implementation tasks.
category: research
version: 1.1.0
triggers:
  positive:
    - research
    - deep dive
    - investigate
    - current state of
    - market sizing
    - competitive analysis
    - due diligence
    - cited report
  negative:
    - in this codebase
    - in this repo
    - refactor
    - implement
requires:
---

# Deep Research

Produce thorough, cited research reports from multiple web sources.

## When to Activate

- User asks to research any topic in depth
- Competitive analysis, technology evaluation, market sizing
- Due diligence on companies, investors, or technologies
- Any question requiring synthesis from multiple sources
- User says "research", "deep dive", "investigate", or "what's the current state of"

## Contract

Inputs:
- Research topic or decision question.
- Desired depth, audience, recency window, source constraints when provided.
- Sources, domains, jurisdictions, or competitors that must be included or excluded.

Outputs:
- Cited research report with executive summary, themes, key takeaways, sources, methodology.
- Clear distinction between sourced facts, estimates, and model inference.
- Explicit uncertainty notes for thin or conflicting evidence.

Verification:
- Use at least two independent sources for important claims when the topic allows it.
- Include source attribution for factual claims that are not common knowledge.
- State the search / read methodology and any source access limitations.

Failure mode:
- If firecrawl / exa MCP tools are unavailable, use the fallback ladder below.
- Never fabricate sources, citations, publication dates, or quotes.
- If no current-source access is available, stop and state that current-source
  research cannot be completed in this environment.

Fallback ladder:
1. Use any configured research MCPs named by the host environment.
2. Use the host's approved web / search / browse tool, restricted by user's
   source, date, domain, jurisdiction constraints.
3. Use user-provided URLs, PDFs, repository files, or pasted source text.
4. If none of the above exists, ask for sources or permission to enable a search tool.

Fallback output requirements:
- Label the methodology as `MCP research`, `web-search fallback`,
  `user-provided source review`, or `blocked`.
- Cite every non-obvious factual claim to a source URL / title when source access is available.
- State source limitations before recommendations when the evidence base is thin.

## MCP Requirements

At least one of:
- **firecrawl** — `firecrawl_search`, `firecrawl_scrape`, `firecrawl_crawl`
- **exa** — `web_search_exa`, `web_search_advanced_exa`, `crawling_exa`

Both together give the best coverage. Configure in `~/.claude.json` or
`~/.codex/config.toml`. These MCPs are *preferred* tools, not hard
requirements — the fallback policy above defines how to proceed when missing.

## Workflow Summary

| Step | Goal | Reference |
|------|------|-----------|
| 1 | Understand the goal (1–2 clarifying questions max) | `references/workflow.md` |
| 2 | Plan: break topic into 3–5 sub-questions | `references/workflow.md` |
| 3 | Multi-source search (15–30 sources, 2–3 keyword variations per sub-question) | `references/workflow.md` |
| 4 | Deep-read 3–5 key sources in full (don't rely on snippets) | `references/workflow.md` |
| 5 | Synthesize and write report | `references/report-template.md` |
| 6 | Deliver (chat for short, file for long) | `references/workflow.md` |

For broad topics, parallelize with subagents — see `references/parallel-research.md`.

## Quality Rules

1. **Every claim needs a source.** No unsourced assertions.
2. **Cross-reference.** If only one source says it, flag it as unverified.
3. **Recency matters.** Prefer sources from the last 12 months.
4. **Acknowledge gaps.** If you couldn't find good info on a sub-question, say so.
5. **No hallucination.** "Insufficient data found" beats a confident wrong answer.
6. **Separate fact from inference.** Label estimates, projections, opinions clearly.

## Reference Index

- `references/workflow.md` — full 6-step workflow, search strategy, deep-read tools.
- `references/report-template.md` — report structure with executive summary, themes, sources.
- `references/parallel-research.md` — using subagents for broad topics.

## Examples

```
"Research the current state of nuclear fusion energy"
"Deep dive into Rust vs Go for backend services in 2026"
"Research the best strategies for bootstrapping a SaaS business"
"What's happening with the US housing market right now?"
"Investigate the competitive landscape for AI code editors"
```
