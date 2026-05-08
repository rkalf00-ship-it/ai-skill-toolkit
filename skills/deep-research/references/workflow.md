# Workflow

> Reference for the [deep-research](../SKILL.md) skill.

## Step 1: Understand the Goal

Ask 1–2 quick clarifying questions:
- "What's your goal — learning, making a decision, or writing something?"
- "Any specific angle or depth you want?"

If the user says "just research it", skip ahead with reasonable defaults.

## Step 2: Plan the Research

Break the topic into 3–5 research sub-questions. Example:
- Topic: "Impact of AI on healthcare"
  - What are the main AI applications in healthcare today?
  - What clinical outcomes have been measured?
  - What are the regulatory challenges?
  - What companies are leading this space?
  - What's the market size and growth trajectory?

## Step 3: Execute Multi-Source Search

For EACH sub-question, search using the best available source-access path.

### With firecrawl

```
firecrawl_search(query: "<sub-question keywords>", limit: 8)
```

### With exa

```
web_search_exa(query: "<sub-question keywords>", numResults: 8)
web_search_advanced_exa(query: "<keywords>", numResults: 5, startPublishedDate: "2025-01-01")
```

### Search Strategy

- 2–3 different keyword variations per sub-question
- Mix general and news-focused queries
- Aim for 15–30 unique sources total
- Source priority: academic, official, reputable news > blogs > forums

## Step 4: Deep-Read Key Sources

For the most promising URLs, fetch full content:

### With firecrawl
```
firecrawl_scrape(url: "<url>")
```

### With exa
```
crawling_exa(url: "<url>", tokensNum: 5000)
```

Read 3–5 key sources in full for depth. **Do not rely only on search snippets** —
they often miss qualifications and caveats that change the meaning.

## Step 5: Synthesize and Write Report

See `references/report-template.md`.

## Step 6: Deliver

- **Short topics**: post the full report in chat.
- **Long reports**: post the executive summary + key takeaways, save full report to a file.
