param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectPath,

  [switch]$ForcePolicy
)

$ErrorActionPreference = "Stop"

$SkillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$CuratedSkillPath = Join-Path $SkillRoot "skills"
$TargetProject = (Resolve-Path -LiteralPath $ProjectPath).Path

$ExpectedSkills = @(
  "api-design",
  "backend-patterns",
  "codebase-onboarding",
  "deep-research",
  "documentation-lookup",
  "e2e-testing",
  "frontend-patterns",
  "git-workflow",
  "mcp-server-patterns",
  "repo-scan",
  "security-review",
  "tdd-workflow",
  "ui-ux-pro-max",
  "verification-loop"
)

if (-not (Test-Path -LiteralPath $CuratedSkillPath)) {
  throw "Curated skills folder not found: $CuratedSkillPath"
}

$Skills = @()
foreach ($SkillName in $ExpectedSkills) {
  $SkillPath = Join-Path $CuratedSkillPath $SkillName
  $SkillFile = Join-Path $SkillPath "SKILL.md"
  if (-not (Test-Path -LiteralPath $SkillFile)) {
    throw "Expected curated skill is missing SKILL.md: $SkillName"
  }
  $Skills += Get-Item -LiteralPath $SkillPath
}

$ExtraSkills = @(Get-ChildItem -LiteralPath $CuratedSkillPath -Directory |
  Where-Object {
    (Test-Path -LiteralPath (Join-Path $_.FullName "SKILL.md")) -and
    ($ExpectedSkills -notcontains $_.Name)
  } |
  Sort-Object Name)

if ($ExtraSkills.Count -gt 0) {
  Write-Host "Ignoring non-curated skill folders: $($ExtraSkills.Name -join ', ')"
}

$Destinations = @(
  (Join-Path $TargetProject ".agents\skills"),
  (Join-Path $TargetProject ".claude\skills"),
  (Join-Path $TargetProject ".codex\skills")
)

Write-Host "Skill root: $SkillRoot"
Write-Host "Target project: $TargetProject"
Write-Host "Curated skills: $($Skills.Count)"

foreach ($Destination in $Destinations) {
  New-Item -ItemType Directory -Force -Path $Destination | Out-Null

  foreach ($Skill in $Skills) {
    Copy-Item -LiteralPath $Skill.FullName -Destination $Destination -Recurse -Force
  }

  Write-Host "Installed to: $Destination"
}

New-Item -ItemType Directory -Force -Path (Join-Path $TargetProject ".agents\rules") | Out-Null
New-Item -ItemType Directory -Force -Path (Join-Path $TargetProject ".agents\workflows") | Out-Null

$PolicyPath = Join-Path $TargetProject "AGENTS.md"
$Policy = @"
# Project AI Skill Policy

This project uses a curated cross-agent skill set copied from the AI Skill repository.

## Installed Skill Locations

- .agents/skills: Antigravity and agents-compatible tools
- .claude/skills: Claude-compatible tools
- .codex/skills: Codex-compatible tools

## Curated Skills

$($Skills | ForEach-Object { "- " + $_.Name } | Out-String)
## Usage Rules

- Prefer local SKILL.md instructions when a task matches an installed skill.
- Use `ui-ux-pro-max` for UI/UX direction and `frontend-patterns` for frontend implementation.
- Use `api-design` and `backend-patterns` for service boundaries, API shape, and server behavior.
- Use `e2e-testing`, `tdd-workflow`, and `verification-loop` before finishing feature, bugfix, or refactor work.
- Use `security-review` for authentication, secrets, payments, API endpoints, and user input.
- Use `codebase-onboarding` and `repo-scan` for analysis of unfamiliar or large codebases.
- Use research and documentation skills when current external API or library behavior matters.
"@

if ($ForcePolicy -or -not (Test-Path -LiteralPath $PolicyPath)) {
  Set-Content -LiteralPath $PolicyPath -Value $Policy -Encoding UTF8
  Write-Host "Wrote policy: $PolicyPath"
} else {
  Write-Host "Skipped existing policy: $PolicyPath (pass -ForcePolicy to overwrite)"
}

Write-Host "Done. Curated skills installed."
