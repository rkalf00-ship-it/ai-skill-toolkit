# Parallel Research with Subagents

> Reference for the [deep-research](../SKILL.md) skill.

For broad topics, use Claude Code's Task tool to parallelize.

```
Launch 3 research agents in parallel:
1. Agent 1: Research sub-questions 1-2
2. Agent 2: Research sub-questions 3-4
3. Agent 3: Research sub-question 5 + cross-cutting themes
```

Each agent searches, reads sources, returns findings. The main session
synthesizes into the final report.

## When Parallelization Helps

- Topic has 4+ independent sub-questions.
- Sources are unlikely to overlap across sub-questions.
- Total expected source count is 20+ (otherwise serial is faster).

## When Not to Parallelize

- 1–2 sub-questions — overhead of agent dispatch exceeds savings.
- Sub-questions are sequential ("first find leaders, then research each leader") — later questions depend on earlier answers.
- Strict source budget — parallel agents may double-fetch the same source.

## Subagent Brief Template

When dispatching, give each agent:
- The 1–2 specific sub-questions it owns.
- Source-domain constraints (which domains to prefer / avoid).
- Recency window.
- Output shape: short summary + cited findings list (not a full report — synthesis happens in the main session).
- Word/token budget for the response.

## Synthesis Step

After all subagents return:
1. Deduplicate sources cited across agents.
2. Cross-check claims that appear in multiple sub-questions.
3. Note where two agents found conflicting information — that's a research signal worth surfacing.
4. Write the unified report from the combined evidence base, not by concatenating subagent outputs.
