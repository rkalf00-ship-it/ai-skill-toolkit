# Script Usage

> Reference for the [ui-ux-pro-max](../SKILL.md) skill.
> `${SKILL_DIR}` = installed path (e.g. `.claude/skills/ui-ux-pro-max`).

## Step 2: Generate Design System

```bash
python3 ${SKILL_DIR}/scripts/search.py "<product_type> <industry> <keywords>" --design-system [-p "Project Name"]
```

This:
1. Searches domains in parallel (product, style, color, landing, typography).
2. Applies reasoning rules from `ui-reasoning.csv` to select best matches.
3. Returns complete design system: pattern, style, colors, typography, effects.
4. Includes anti-patterns to avoid.

Example:
```bash
python3 ${SKILL_DIR}/scripts/search.py "beauty spa wellness service" --design-system -p "Serenity Spa"
```

## Step 2b: Persist (Master + Overrides)

```bash
python3 ${SKILL_DIR}/scripts/search.py "<query>" --design-system --persist -p "Project Name"
```

Creates:
- `design-system/MASTER.md` — Global Source of Truth.
- `design-system/pages/` — Folder for page-specific overrides.

With page-specific override:
```bash
python3 ${SKILL_DIR}/scripts/search.py "<query>" --design-system --persist -p "Project Name" --page "dashboard"
```

Adds:
- `design-system/pages/dashboard.md` — page-specific deviations from Master.

**Hierarchical retrieval**: when building a specific page, check
`design-system/pages/<page>.md` first; if it exists, its rules override
Master. Otherwise use `MASTER.md` exclusively.

## Step 3: Domain Searches

```bash
python3 ${SKILL_DIR}/scripts/search.py "<keyword>" --domain <domain> [-n <max_results>]
```

| Need | Domain | Example |
|------|--------|---------|
| Product type patterns | `product` | `--domain product "entertainment social"` |
| More style options | `style` | `--domain style "glassmorphism dark"` |
| Color palettes | `color` | `--domain color "entertainment vibrant"` |
| Font pairings | `typography` | `--domain typography "playful modern"` |
| Chart recommendations | `chart` | `--domain chart "real-time dashboard"` |
| UX best practices | `ux` | `--domain ux "animation accessibility"` |
| Individual Google Fonts | `google-fonts` | `--domain google-fonts "sans serif popular variable"` |
| Landing structure | `landing` | `--domain landing "hero social-proof"` |
| React (Native) perf | `react` | `--domain react "rerender memo list"` |
| App interface a11y | `web` | `--domain web "accessibilityLabel touch safe-areas"` |
| AI prompt / CSS keywords | `prompt` | `--domain prompt "minimalism"` |

## Step 4: Stack Guidelines

```bash
python3 ${SKILL_DIR}/scripts/search.py "<keyword>" --stack <stack>
```

Available stacks (see `data/stacks/`): angular, astro, flutter, html-tailwind,
jetpack-compose, laravel, nextjs, nuxtjs, nuxt-ui, react, react-native,
shadcn, svelte, swiftui, threejs, vue.

## Output Formats

```bash
# ASCII box (default) — best for terminal display
python3 ${SKILL_DIR}/scripts/search.py "fintech crypto" --design-system

# Markdown — best for documentation
python3 ${SKILL_DIR}/scripts/search.py "fintech crypto" --design-system -f markdown
```

## Tips

- Use **multi-dimensional keywords**: combine product + industry + tone + density.
  `"entertainment social vibrant content-dense"` beats `"app"`.
- Try keyword variations: `"playful neon"` → `"vibrant dark"` → `"content-first minimal"`.
- Always start with `--design-system` for full recommendations, then `--domain`
  to deep-dive any dimension you're unsure about.
- Always pair with `--stack <your-stack>` for implementation-specific guidance.
