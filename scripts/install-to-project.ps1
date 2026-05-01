param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectPath,

  [switch]$ForcePolicy
)

$ErrorActionPreference = "Stop"

$SkillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$CuratedSkillPath = Join-Path $SkillRoot "skills"
$AgentsSourcePath = Join-Path $SkillRoot ".agents"
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

if (-not (Test-Path -LiteralPath $AgentsSourcePath)) {
  throw "Toolkit .agents folder not found: $AgentsSourcePath"
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

$SkillDestinations = @(
  (Join-Path $TargetProject ".agents\skills"),
  (Join-Path $TargetProject ".claude\skills"),
  (Join-Path $TargetProject ".codex\skills")
)

Write-Host "Skill root: $SkillRoot"
Write-Host "Target project: $TargetProject"
Write-Host "Curated skills: $($Skills.Count)"

foreach ($Destination in $SkillDestinations) {
  New-Item -ItemType Directory -Force -Path $Destination | Out-Null

  foreach ($Skill in $Skills) {
    Copy-Item -LiteralPath $Skill.FullName -Destination $Destination -Recurse -Force
  }

  Write-Host "Installed skills to: $Destination"
}

$AgentsRulesSource = Join-Path $AgentsSourcePath "rules"
$AgentsRolesSource = Join-Path $AgentsSourcePath "roles"
$AgentsAgentsSource = Join-Path $AgentsSourcePath "AGENTS.md"

$AgentsRulesTarget = Join-Path $TargetProject ".agents\rules"
$AgentsRolesTarget = Join-Path $TargetProject ".agents\roles"
$AgentsAgentsTarget = Join-Path $TargetProject ".agents\AGENTS.md"

New-Item -ItemType Directory -Force -Path $AgentsRulesTarget | Out-Null
New-Item -ItemType Directory -Force -Path $AgentsRolesTarget | Out-Null

if (Test-Path -LiteralPath $AgentsRulesSource) {
  Get-ChildItem -LiteralPath $AgentsRulesSource | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $AgentsRulesTarget -Recurse -Force
  }
  Write-Host "Installed multi-role rules to: $AgentsRulesTarget"
} else {
  Write-Host "Skipped missing source: $AgentsRulesSource"
}

if (Test-Path -LiteralPath $AgentsRolesSource) {
  Get-ChildItem -LiteralPath $AgentsRolesSource | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $AgentsRolesTarget -Recurse -Force
  }
  Write-Host "Installed multi-role roles to: $AgentsRolesTarget"
} else {
  Write-Host "Skipped missing source: $AgentsRolesSource"
}

$PolicyFiles = @(
  @{ Source = (Join-Path $SkillRoot "AGENTS.md"); Target = (Join-Path $TargetProject "AGENTS.md") },
  @{ Source = (Join-Path $SkillRoot "CLAUDE.md"); Target = (Join-Path $TargetProject "CLAUDE.md") },
  @{ Source = $AgentsAgentsSource;                Target = $AgentsAgentsTarget }
)

foreach ($Policy in $PolicyFiles) {
  if (-not (Test-Path -LiteralPath $Policy.Source)) {
    Write-Host "Skipped missing source: $($Policy.Source)"
    continue
  }

  if ($ForcePolicy -or -not (Test-Path -LiteralPath $Policy.Target)) {
    Copy-Item -LiteralPath $Policy.Source -Destination $Policy.Target -Force
    Write-Host "Wrote policy: $($Policy.Target)"
  } else {
    Write-Host "Skipped existing policy: $($Policy.Target) (pass -ForcePolicy to overwrite)"
  }
}

Write-Host "Done. Curated skills and multi-role system installed."
