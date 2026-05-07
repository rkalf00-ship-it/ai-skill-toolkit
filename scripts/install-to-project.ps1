param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectPath,

  [switch]$ForcePolicy,

  [switch]$ForceLinks
)

$ErrorActionPreference = "Stop"

$SkillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$CuratedSkillPath = Join-Path $SkillRoot "skills"
$ManifestPath = Join-Path $CuratedSkillPath "manifest.json"
$AgentsSourcePath = Join-Path $SkillRoot ".agents"
$TargetProject = (Resolve-Path -LiteralPath $ProjectPath).Path

# Skills that ship asset directories beyond SKILL.md.
# Each listed entry MUST be a non-empty directory. A plain file at the path
# (e.g. a tokenized path stub left by a broken symlink checkout) is rejected.
$RequiredAssets = @{
  "ui-ux-pro-max" = @("data", "scripts", "templates")
}

if (-not (Test-Path -LiteralPath $CuratedSkillPath)) {
  throw "Curated skills folder not found: $CuratedSkillPath"
}

if (-not (Test-Path -LiteralPath $ManifestPath)) {
  throw "Skill manifest not found: $ManifestPath"
}

if (-not (Test-Path -LiteralPath $AgentsSourcePath)) {
  throw "Toolkit .agents folder not found: $AgentsSourcePath"
}

$Manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json
$ExpectedSkills = @($Manifest.skills | ForEach-Object { $_.id })

function Copy-ToolkitDirectory {
  param(
    [Parameter(Mandatory=$true)]
    [string]$Source,

    [Parameter(Mandatory=$true)]
    [string]$Destination
  )

  $ExcludedDirectoryNames = @('__pycache__', '.pytest_cache', '.mypy_cache', '.ruff_cache', 'node_modules')
  $ExcludedFileNames = @('.DS_Store', 'Thumbs.db')
  $ExcludedFileExtensions = @('.pyc', '.pyo')

  if (Test-Path -LiteralPath $Destination) {
    Remove-Item -LiteralPath $Destination -Recurse -Force
  }

  New-Item -ItemType Directory -Force -Path $Destination | Out-Null

  foreach ($Item in (Get-ChildItem -LiteralPath $Source -Recurse -Force)) {
    $relativePath = $Item.FullName.Substring($Source.Length).TrimStart('\','/')
    if (-not $relativePath) { continue }

    $parts = $relativePath -split '[\\/]'
    if (@($parts | Where-Object { $_ -in $ExcludedDirectoryNames }).Count -gt 0) {
      continue
    }

    if (-not $Item.PSIsContainer) {
      if ($Item.Name -in $ExcludedFileNames) { continue }
      if ($Item.Extension -in $ExcludedFileExtensions) { continue }
    }

    $targetPath = Join-Path $Destination $relativePath
    if ($Item.PSIsContainer) {
      New-Item -ItemType Directory -Force -Path $targetPath | Out-Null
    } else {
      $targetParent = Split-Path -Parent $targetPath
      New-Item -ItemType Directory -Force -Path $targetParent | Out-Null
      Copy-Item -LiteralPath $Item.FullName -Destination $targetPath -Force
    }
  }
}

$Skills = @()
foreach ($SkillSpec in @($Manifest.skills)) {
  $SkillName = $SkillSpec.id
  $SkillRelativePath = if ($SkillSpec.path) { $SkillSpec.path } else { $SkillName }
  $SkillPath = Join-Path $CuratedSkillPath $SkillRelativePath
  $SkillFile = Join-Path $SkillPath "SKILL.md"
  if (-not (Test-Path -LiteralPath $SkillFile)) {
    throw "Expected curated skill is missing SKILL.md: $SkillName"
  }

  if ($RequiredAssets.ContainsKey($SkillName)) {
    foreach ($Asset in $RequiredAssets[$SkillName]) {
      $AssetPath = Join-Path $SkillPath $Asset
      if (-not (Test-Path -LiteralPath $AssetPath)) {
        throw "Required asset missing for ${SkillName}: '$Asset' (expected directory at $AssetPath)"
      }
      $AssetItem = Get-Item -LiteralPath $AssetPath
      if (-not $AssetItem.PSIsContainer) {
        throw "Required asset for ${SkillName} is a file, not a directory: $AssetPath (size=$($AssetItem.Length) bytes; likely a tokenized path stub from a broken symlink checkout)"
      }
      $AssetFileCount = (Get-ChildItem -LiteralPath $AssetPath -Recurse -File | Measure-Object).Count
      if ($AssetFileCount -eq 0) {
        throw "Required asset directory for ${SkillName} is empty: $AssetPath"
      }
    }
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

$PrimarySkillDestination = Join-Path $TargetProject ".agents\skills"
$JunctionSkillDestinations = @(
  (Join-Path $TargetProject ".claude\skills"),
  (Join-Path $TargetProject ".codex\skills")
)

Write-Host "Skill root: $SkillRoot"
Write-Host "Target project: $TargetProject"
Write-Host "Curated skills: $($Skills.Count)"

# Single source of truth: copy skills only into .agents/skills
New-Item -ItemType Directory -Force -Path $PrimarySkillDestination | Out-Null
foreach ($Skill in $Skills) {
  Copy-ToolkitDirectory -Source $Skill.FullName -Destination (Join-Path $PrimarySkillDestination $Skill.Name)
}
Copy-Item -LiteralPath $ManifestPath -Destination $PrimarySkillDestination -Force
Write-Host "Installed skills to: $PrimarySkillDestination"

# .claude/skills and .codex/skills are directory junctions to .agents/skills
$ReparseFlag = [IO.FileAttributes]::ReparsePoint
foreach ($JunctionPath in $JunctionSkillDestinations) {
  $JunctionParent = Split-Path -Parent $JunctionPath
  New-Item -ItemType Directory -Force -Path $JunctionParent | Out-Null

  if (Test-Path -LiteralPath $JunctionPath) {
    $ExistingItem = Get-Item -LiteralPath $JunctionPath -Force
    $IsReparse = ($ExistingItem.Attributes -band $ReparseFlag) -eq $ReparseFlag

    if ($IsReparse) {
      # Existing junction/symlink - replace unconditionally so the target is correct
      [System.IO.Directory]::Delete($JunctionPath)
    } else {
      $HasContent = @(Get-ChildItem -LiteralPath $JunctionPath -Force -ErrorAction SilentlyContinue).Count -gt 0
      if ($HasContent -and -not $ForceLinks) {
        throw "Cannot create junction at ${JunctionPath}: real directory exists with content. Remove it manually or pass -ForceLinks to overwrite."
      }
      Remove-Item -LiteralPath $JunctionPath -Recurse -Force
    }
  }

  New-Item -ItemType Junction -Path $JunctionPath -Target $PrimarySkillDestination | Out-Null
  Write-Host "Linked junction: $JunctionPath -> $PrimarySkillDestination"
}

$AgentsRulesSource = Join-Path $AgentsSourcePath "rules"
$AgentsRolesSource = Join-Path $AgentsSourcePath "roles"
$AgentsCommandsSource = Join-Path $AgentsSourcePath "commands"
$AgentsPluginsSource = Join-Path $AgentsSourcePath "plugins"
$AgentsAgentsSource = Join-Path $AgentsSourcePath "AGENTS.md"
$PluginsSource = Join-Path $SkillRoot "plugins"

$AgentsRulesTarget = Join-Path $TargetProject ".agents\rules"
$AgentsRolesTarget = Join-Path $TargetProject ".agents\roles"
$AgentsCommandsTarget = Join-Path $TargetProject ".agents\commands"
$AgentsPluginsTarget = Join-Path $TargetProject ".agents\plugins"
$AgentsAgentsTarget = Join-Path $TargetProject ".agents\AGENTS.md"
$PluginsTarget = Join-Path $TargetProject "plugins"

New-Item -ItemType Directory -Force -Path $AgentsRulesTarget | Out-Null
New-Item -ItemType Directory -Force -Path $AgentsRolesTarget | Out-Null
New-Item -ItemType Directory -Force -Path $AgentsCommandsTarget | Out-Null
New-Item -ItemType Directory -Force -Path $AgentsPluginsTarget | Out-Null

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

if (Test-Path -LiteralPath $AgentsCommandsSource) {
  Get-ChildItem -LiteralPath $AgentsCommandsSource | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $AgentsCommandsTarget -Recurse -Force
  }
  Write-Host "Installed commands to: $AgentsCommandsTarget"
} else {
  Write-Host "Skipped missing source: $AgentsCommandsSource"
}

if (Test-Path -LiteralPath $AgentsPluginsSource) {
  Get-ChildItem -LiteralPath $AgentsPluginsSource | ForEach-Object {
    Copy-Item -LiteralPath $_.FullName -Destination $AgentsPluginsTarget -Recurse -Force
  }
  Write-Host "Installed plugin marketplace to: $AgentsPluginsTarget"
} else {
  Write-Host "Skipped missing source: $AgentsPluginsSource"
}

if (Test-Path -LiteralPath $PluginsSource) {
  New-Item -ItemType Directory -Force -Path $PluginsTarget | Out-Null
  Get-ChildItem -LiteralPath $PluginsSource | ForEach-Object {
    if ($_.PSIsContainer) {
      Copy-ToolkitDirectory -Source $_.FullName -Destination (Join-Path $PluginsTarget $_.Name)
    } else {
      Copy-Item -LiteralPath $_.FullName -Destination $PluginsTarget -Force
    }
  }
  Write-Host "Installed plugins to: $PluginsTarget"
} else {
  Write-Host "Skipped missing source: $PluginsSource"
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
