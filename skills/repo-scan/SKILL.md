---
name: repo-scan
id: repo-scan
description: Cross-stack source code asset audit - classifies every file, detects embedded third-party libraries, and delivers actionable four-level verdicts per module with interactive HTML reports.
category: research
version: 1.0.0
triggers:
  positive:
    - legacy codebase
    - structural overview
    - third-party audit
    - file classification
    - monorepo audit
    - embedded library detection
    - vendored dependencies
    - dead code inventory
  negative:
    - small project
    - single-file script
    - new project from scratch
requires:
  bin: [git]
---

# repo-scan

> Every ecosystem has its own dependency manager, but no tool looks across C++, Android, iOS, and Web to tell you: how much code is actually yours, what's third-party, and what's dead weight.

## When to Use

- Taking over a large legacy codebase and need a structural overview
- Before major refactoring - identify what's core, what's duplicate, what's dead
- Auditing third-party dependencies embedded directly in source (not declared in package managers)
- Preparing architecture decision records for monorepo reorganization

## Contract

Inputs:
- Repository path to audit.
- Desired depth: `fast`, `standard`, `deep`, or `full`.
- Optional scope filters such as modules, languages, or directories to exclude.

Outputs:
- Repository inventory summary.
- Third-party and generated-artifact findings.
- Four-level verdicts per module: Core Asset, Extract & Merge, Rebuild, Deprecate.
- Report path or clear blocker if the external scanner is unavailable.

Verification:
- Confirm `git` is available.
- Confirm the target repository path exists.
- If using the external scanner, report the pinned commit and output artifact path.

Failure mode:
- If the external scanner cannot be installed or run, perform a local fallback scan
  with native file enumeration and clearly mark the result as a lightweight audit.

## Optional External Scanner Installation

The external scanner is optional and should be reviewed before use. Fetch the
pinned commit for reproducibility.

PowerShell:

```powershell
$dest = Join-Path $env:USERPROFILE ".agents\skills\repo-scan-external"
New-Item -ItemType Directory -Force -Path $dest | Out-Null
git init $dest
git -C $dest remote add origin https://github.com/haibindev/repo-scan.git
git -C $dest fetch --depth 1 origin 2742664
git -C $dest checkout --detach FETCH_HEAD
```

Bash:

```bash
dest="${HOME}/.agents/skills/repo-scan-external"
mkdir -p "$dest"
git init "$dest"
git -C "$dest" remote add origin https://github.com/haibindev/repo-scan.git
git -C "$dest" fetch --depth 1 origin 2742664
git -C "$dest" checkout --detach FETCH_HEAD
```

> Review the source before installing or running any external agent skill.

## Core Capabilities

| Capability | Description |
|---|---|
| **Cross-stack scanning** | C/C++, Java/Android, iOS (OC/Swift), Web (TS/JS/Vue) in one pass |
| **File classification** | Every file tagged as project code, third-party, or build artifact |
| **Library detection** | 50+ known libraries (FFmpeg, Boost, OpenSSL...) with version extraction |
| **Four-level verdicts** | Core Asset / Extract & Merge / Rebuild / Deprecate |
| **HTML reports** | Interactive dark-theme pages with drill-down navigation |
| **Monorepo support** | Hierarchical scanning with summary + sub-project reports |

## Analysis Depth Levels

| Level | Files Read | Use Case |
|---|---|---|
| `fast` | 1-2 per module | Quick inventory of huge directories |
| `standard` | 2-5 per module | Default audit with full dependency + architecture checks |
| `deep` | 5-10 per module | Adds thread safety, memory management, API consistency |
| `full` | All files | Pre-merge comprehensive review |

## How It Works

1. **Classify the repo surface**: enumerate files, then tag each as project code, embedded third-party code, or build artifact.
2. **Detect embedded libraries**: inspect directory names, headers, license files, and version markers to identify bundled dependencies and likely versions.
3. **Score each module**: group files by module or subsystem, then assign one of the four verdicts based on ownership, duplication, and maintenance cost.
4. **Highlight structural risks**: call out dead-weight artifacts, duplicated wrappers, outdated vendored code, and modules that should be extracted, rebuilt, or deprecated.
5. **Produce the report**: return a concise summary plus the interactive HTML output with per-module drill-down so the audit can be reviewed asynchronously.

## Examples

On a 50,000-file C++ monorepo:
- Found FFmpeg 2.x (2015 vintage) still in production
- Discovered the same SDK wrapper duplicated 3 times
- Identified 636 MB of committed Debug/ipch/obj build artifacts
- Classified: 3 MB project code vs 596 MB third-party

## Best Practices

- Start with `standard` depth for first-time audits
- Use `fast` for monorepos with 100+ modules to get a quick inventory
- Run `deep` incrementally on modules flagged for refactoring
- Review the cross-module analysis for duplicate detection across sub-projects

## Links

- [GitHub Repository](https://github.com/haibindev/repo-scan)
