<#
.SYNOPSIS
  Install AI Skill Toolkit into a target project (Windows / PowerShell).

.DESCRIPTION
  Copies the curated skills into <ProjectPath>\.agents\skills (the single source
  of truth) and creates directory junctions at .claude\skills and .codex\skills
  pointing to the same source. Also installs .agents\{rules,roles,commands,
  plugins} and policy files (AGENTS.md, CLAUDE.md, .agents\AGENTS.md).

.PARAMETER ProjectPath
  Required. Target project root.

.PARAMETER ForcePolicy
  Overwrite existing AGENTS.md / CLAUDE.md / .agents\AGENTS.md (default: skip).

.PARAMETER ForceLinks
  Replace a non-empty real .claude\skills or .codex\skills directory with a
  junction. The previous content is moved to a timestamped backup directory
  (unless -NoBackup is also passed, in which case the install aborts and tells
  you what would be lost).

.PARAMETER DryRun
  Print every action without making changes. Validates inputs, lists skills,
  reports what would be copied / overwritten / backed up. Exits 0 on success.

.PARAMETER NoBackup
  Suppress automatic backup of overwritten directories. Combined with
  -ForceLinks this becomes destructive; the script will require an interactive
  yes/no confirmation unless -Yes is also passed.

.PARAMETER Yes
  Skip interactive confirmation prompts (for CI / scripted use).

.EXAMPLE
  .\scripts\install-to-project.ps1 -ProjectPath D:\my-app
  .\scripts\install-to-project.ps1 -ProjectPath D:\my-app -DryRun
  .\scripts\install-to-project.ps1 -ProjectPath D:\my-app -ForceLinks
  .\scripts\install-to-project.ps1 -ProjectPath D:\my-app -ForceLinks -NoBackup -Yes
#>
[CmdletBinding()]
param(
  [Parameter(Mandatory=$true)]
  [string]$ProjectPath,

  [switch]$ForcePolicy,

  [switch]$ForceLinks,

  [switch]$DryRun,

  [switch]$NoBackup,

  [switch]$Yes
)

$ErrorActionPreference = "Stop"

$SkillRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$CuratedSkillPath = Join-Path $SkillRoot "skills"
$ManifestPath = Join-Path $CuratedSkillPath "manifest.json"
$AgentsSourcePath = Join-Path $SkillRoot ".agents"

if (-not (Test-Path -LiteralPath $ProjectPath)) {
  throw "ProjectPath does not exist: $ProjectPath"
}
$TargetProject = (Resolve-Path -LiteralPath $ProjectPath).Path

# Skills that ship asset directories beyond SKILL.md.
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

# --------------------------------------------------------------------
# Helpers
# --------------------------------------------------------------------
$Timestamp = (Get-Date -Format 'yyyyMMdd-HHmmss')
$BackupRoot = Join-Path $TargetProject ".agents\.backups\$Timestamp"

function Write-Action {
  param([string]$Verb, [string]$Detail)
  $prefix = if ($DryRun) { "[DRY-RUN]" } else { "[      ]" }
  Write-Host "$prefix $Verb`: $Detail"
}

function Confirm-Destructive {
  param([string]$Question)
  if ($Yes) { return $true }
  $resp = Read-Host "$Question [y/N]"
  return ($resp -eq 'y' -or $resp -eq 'Y' -or $resp -eq 'yes')
}

function Backup-Directory {
  param([string]$Source)
  if (-not (Test-Path -LiteralPath $Source)) { return $null }
  $rel = $Source.Substring($TargetProject.Length).TrimStart('\','/')
  $dest = Join-Path $BackupRoot $rel
  $destParent = Split-Path -Parent $dest
  Write-Action "BACKUP" "$Source -> $dest"
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $destParent | Out-Null
    Copy-Item -LiteralPath $Source -Destination $dest -Recurse -Force
  }
  return $dest
}

function Copy-ToolkitDirectory {
  param(
    [Parameter(Mandatory=$true)] [string]$Source,
    [Parameter(Mandatory=$true)] [string]$Destination
  )

  $ExcludedDirectoryNames = @('__pycache__', '.pytest_cache', '.mypy_cache', '.ruff_cache', 'node_modules')
  $ExcludedFileNames = @('.DS_Store', 'Thumbs.db')
  $ExcludedFileExtensions = @('.pyc', '.pyo')

  if (Test-Path -LiteralPath $Destination) {
    Write-Action "REMOVE" $Destination
    if (-not $DryRun) {
      Remove-Item -LiteralPath $Destination -Recurse -Force
    }
  }

  Write-Action "MKDIR" $Destination
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $Destination | Out-Null
  }

  if ($DryRun) {
    Write-Action "COPY-TREE" "$Source -> $Destination (skipped in dry-run)"
    return
  }

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

# --------------------------------------------------------------------
# Pre-flight: validate skill assets, plan junctions
# --------------------------------------------------------------------
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

# Pre-flight junction safety: detect non-junction directories that would be replaced
$ReparseFlag = [IO.FileAttributes]::ReparsePoint
$JunctionConflicts = @()
foreach ($JunctionPath in $JunctionSkillDestinations) {
  if (Test-Path -LiteralPath $JunctionPath) {
    $ExistingItem = Get-Item -LiteralPath $JunctionPath -Force
    $IsReparse = ($ExistingItem.Attributes -band $ReparseFlag) -eq $ReparseFlag
    if (-not $IsReparse) {
      $HasContent = @(Get-ChildItem -LiteralPath $JunctionPath -Force -ErrorAction SilentlyContinue).Count -gt 0
      if ($HasContent) {
        $JunctionConflicts += $JunctionPath
      }
    }
  }
}

if ($JunctionConflicts.Count -gt 0) {
  Write-Host ""
  Write-Host "WARNING: The following real directories contain content and will be replaced by a junction:" -ForegroundColor Yellow
  foreach ($p in $JunctionConflicts) { Write-Host "  - $p" -ForegroundColor Yellow }

  if (-not $ForceLinks) {
    throw "Refusing to overwrite. Pass -ForceLinks to proceed (content will be backed up to $BackupRoot unless -NoBackup is given)."
  }

  if ($NoBackup) {
    Write-Host "  -NoBackup is set: existing content will be PERMANENTLY DELETED." -ForegroundColor Red
    if (-not $DryRun -and -not (Confirm-Destructive "Proceed with destructive overwrite?")) {
      Write-Host "Aborted by user."
      exit 2
    }
  } else {
    Write-Host "  Existing content will be backed up to: $BackupRoot" -ForegroundColor Cyan
  }
}

Write-Host ""
Write-Host "Skill root:      $SkillRoot"
Write-Host "Target project:  $TargetProject"
Write-Host "Curated skills:  $($Skills.Count)"
Write-Host "Backup root:     $(if ($NoBackup) { '(disabled)' } else { $BackupRoot })"
Write-Host "Mode:            $(if ($DryRun) { 'DRY RUN (no changes)' } else { 'APPLY' })"
Write-Host ""

# --------------------------------------------------------------------
# Apply: copy skills (single source of truth)
# --------------------------------------------------------------------
Write-Action "MKDIR" $PrimarySkillDestination
if (-not $DryRun) {
  New-Item -ItemType Directory -Force -Path $PrimarySkillDestination | Out-Null
}

# Backup primary skills directory if it already exists with content
if ((Test-Path -LiteralPath $PrimarySkillDestination) -and -not $NoBackup -and -not $DryRun) {
  $existingCount = @(Get-ChildItem -LiteralPath $PrimarySkillDestination -Force -ErrorAction SilentlyContinue).Count
  if ($existingCount -gt 0) {
    Backup-Directory -Source $PrimarySkillDestination | Out-Null
  }
}

foreach ($Skill in $Skills) {
  Copy-ToolkitDirectory -Source $Skill.FullName -Destination (Join-Path $PrimarySkillDestination $Skill.Name)
}

Write-Action "COPY" "$ManifestPath -> $PrimarySkillDestination"
if (-not $DryRun) {
  Copy-Item -LiteralPath $ManifestPath -Destination $PrimarySkillDestination -Force
}

# --------------------------------------------------------------------
# Apply: junctions for .claude/skills and .codex/skills
# --------------------------------------------------------------------
foreach ($JunctionPath in $JunctionSkillDestinations) {
  $JunctionParent = Split-Path -Parent $JunctionPath
  if (-not $DryRun) {
    New-Item -ItemType Directory -Force -Path $JunctionParent | Out-Null
  }

  if (Test-Path -LiteralPath $JunctionPath) {
    $ExistingItem = Get-Item -LiteralPath $JunctionPath -Force
    $IsReparse = ($ExistingItem.Attributes -band $ReparseFlag) -eq $ReparseFlag

    if ($IsReparse) {
      Write-Action "UNLINK" "$JunctionPath (existing junction)"
      if (-not $DryRun) {
        [System.IO.Directory]::Delete($JunctionPath)
      }
    } else {
      # Real directory with content: must be in $JunctionConflicts (already gated above)
      if (-not $NoBackup) {
        Backup-Directory -Source $JunctionPath | Out-Null
      }
      Write-Action "REMOVE" "$JunctionPath (real directory replaced)"
      if (-not $DryRun) {
        Remove-Item -LiteralPath $JunctionPath -Recurse -Force
      }
    }
  }

  Write-Action "JUNCTION" "$JunctionPath -> $PrimarySkillDestination"
  if (-not $DryRun) {
    New-Item -ItemType Junction -Path $JunctionPath -Target $PrimarySkillDestination | Out-Null
  }
}

# --------------------------------------------------------------------
# Apply: .agents/{rules,roles,commands,plugins} and plugins/
# --------------------------------------------------------------------
$AgentsRulesSource    = Join-Path $AgentsSourcePath "rules"
$AgentsRolesSource    = Join-Path $AgentsSourcePath "roles"
$AgentsCommandsSource = Join-Path $AgentsSourcePath "commands"
$AgentsPluginsSource  = Join-Path $AgentsSourcePath "plugins"
$AgentsAgentsSource   = Join-Path $AgentsSourcePath "AGENTS.md"
$PluginsSource        = Join-Path $SkillRoot "plugins"

$AgentsRulesTarget    = Join-Path $TargetProject ".agents\rules"
$AgentsRolesTarget    = Join-Path $TargetProject ".agents\roles"
$AgentsCommandsTarget = Join-Path $TargetProject ".agents\commands"
$AgentsPluginsTarget  = Join-Path $TargetProject ".agents\plugins"
$AgentsAgentsTarget   = Join-Path $TargetProject ".agents\AGENTS.md"
$PluginsTarget        = Join-Path $TargetProject "plugins"

foreach ($t in @($AgentsRulesTarget, $AgentsRolesTarget, $AgentsCommandsTarget, $AgentsPluginsTarget)) {
  Write-Action "MKDIR" $t
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $t | Out-Null }
}

function Install-AgentsSubtree {
  param([string]$Source, [string]$Target, [string]$Label)
  if (-not (Test-Path -LiteralPath $Source)) {
    Write-Host "Skipped missing source: $Source"
    return
  }
  Write-Action "INSTALL-$Label" "$Source -> $Target"
  if (-not $DryRun) {
    Get-ChildItem -LiteralPath $Source | ForEach-Object {
      Copy-Item -LiteralPath $_.FullName -Destination $Target -Recurse -Force
    }
  }
}

Install-AgentsSubtree -Source $AgentsRulesSource    -Target $AgentsRulesTarget    -Label "RULES"
Install-AgentsSubtree -Source $AgentsRolesSource    -Target $AgentsRolesTarget    -Label "ROLES"
Install-AgentsSubtree -Source $AgentsCommandsSource -Target $AgentsCommandsTarget -Label "COMMANDS"
Install-AgentsSubtree -Source $AgentsPluginsSource  -Target $AgentsPluginsTarget  -Label "PLUGINS-MARKETPLACE"

if (Test-Path -LiteralPath $PluginsSource) {
  Write-Action "MKDIR" $PluginsTarget
  if (-not $DryRun) { New-Item -ItemType Directory -Force -Path $PluginsTarget | Out-Null }
  Get-ChildItem -LiteralPath $PluginsSource | ForEach-Object {
    if ($_.PSIsContainer) {
      Copy-ToolkitDirectory -Source $_.FullName -Destination (Join-Path $PluginsTarget $_.Name)
    } else {
      Write-Action "COPY" "$($_.FullName) -> $PluginsTarget"
      if (-not $DryRun) { Copy-Item -LiteralPath $_.FullName -Destination $PluginsTarget -Force }
    }
  }
} else {
  Write-Host "Skipped missing source: $PluginsSource"
}

# --------------------------------------------------------------------
# Apply: policy files (with backup-on-overwrite)
# --------------------------------------------------------------------
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

  $exists = Test-Path -LiteralPath $Policy.Target
  if ($exists -and -not $ForcePolicy) {
    Write-Host "Skipped existing policy: $($Policy.Target) (pass -ForcePolicy to overwrite)"
    continue
  }

  if ($exists -and $ForcePolicy -and -not $NoBackup -and -not $DryRun) {
    $rel = $Policy.Target.Substring($TargetProject.Length).TrimStart('\','/')
    $bk = Join-Path $BackupRoot $rel
    $bkParent = Split-Path -Parent $bk
    Write-Action "BACKUP" "$($Policy.Target) -> $bk"
    New-Item -ItemType Directory -Force -Path $bkParent | Out-Null
    Copy-Item -LiteralPath $Policy.Target -Destination $bk -Force
  }

  Write-Action "WRITE-POLICY" $Policy.Target
  if (-not $DryRun) {
    Copy-Item -LiteralPath $Policy.Source -Destination $Policy.Target -Force
  }
}

Write-Host ""
if ($DryRun) {
  Write-Host "Dry run complete. No changes were made." -ForegroundColor Cyan
} else {
  Write-Host "Done. Curated skills and multi-role system installed." -ForegroundColor Green
  if (-not $NoBackup -and (Test-Path -LiteralPath $BackupRoot)) {
    Write-Host "Backups (if any) saved under: $BackupRoot" -ForegroundColor Cyan
  }
}
