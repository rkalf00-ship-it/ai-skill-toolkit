# AI Skill Toolkit

Reusable AI development skill system for Codex / Claude / Antigravity.

## Governance Model

Two modes:

- **Default** - [Karpathy Guidelines](#karpathy-guidelines) (lightweight). No mandatory pipeline.
- **Opt-in** - Multi-Role Pipeline (`planner -> architect -> engineer -> reviewer -> tester -> documenter`). Activates only when explicitly triggered by one of: `/multirole`, `full pipeline`, `formal process`, `multi-role`.

See [`AGENTS.md`](AGENTS.md) for full activation rules and pipeline file references.

# Karpathy Guidelines

Behavioral guidelines to reduce common LLM coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876) on LLM coding pitfalls.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" -> "Write tests for invalid inputs, then make them pass"
- "Fix the bug" -> "Write a test that reproduces it, then make it pass"
- "Refactor X" -> "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] -> verify: [check]
2. [Step] -> verify: [check]
3. [Step] -> verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.


## Usage

```powershell
powershell -ExecutionPolicy Bypass -File "scripts/install-to-project.ps1" -ProjectPath "YOUR_PROJECT_PATH"
```

Skills are copied once into `.agents/skills`. `.claude/skills` and `.codex/skills` are created as directory junctions pointing to that single source, so editing a skill in any of the three locations updates all of them.

Optional switches:

- `-ForcePolicy` - overwrite existing `AGENTS.md`, `CLAUDE.md`, and `.agents/AGENTS.md` in the target project (default: skip if present).
- `-ForceLinks` - replace a non-empty `.claude/skills` or `.codex/skills` directory with a junction (default: error out to protect existing content). Existing junctions are always recreated without this switch.

## License

MIT - see [LICENSE](LICENSE).
