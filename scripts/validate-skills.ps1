<#
.SYNOPSIS
  Validate AI Skill Toolkit SKILL.md frontmatter against the toolkit schema.

.DESCRIPTION
  Default mode: enforces only the Anthropic Skills hard-required fields (name, description).
  Strict mode (-Strict): additionally requires id, category, version, and id == folder name.
  Always warns on missing recommended fields (triggers, requires).

.PARAMETER Path
  Root folder to scan. Defaults to ./skills relative to the toolkit root.

.PARAMETER Strict
  Enable strict mode (toolkit-recommended fields become required).

.EXAMPLE
  .\scripts\validate-skills.ps1
  .\scripts\validate-skills.ps1 -Strict
  .\scripts\validate-skills.ps1 -Path skills/ui-ux-pro-max -Strict

.NOTES
  Zero external dependencies. Includes a deliberately minimal YAML parser that handles
  only the frontmatter shapes documented in skills/_schema/SKILL.schema.json.
  No inline comments, no multi-line strings, no top-level lists.
#>
[CmdletBinding()]
param(
  [string]$Path,
  [switch]$Strict
)

$ErrorActionPreference = 'Stop'

if (-not $Path) {
  $scriptDir = Split-Path -Parent $PSCommandPath
  $Path = Join-Path (Split-Path -Parent $scriptDir) 'skills'
}

if (-not (Test-Path $Path)) {
  Write-Host "ERROR: Path not found: $Path" -ForegroundColor Red
  exit 2
}

$rootPath = (Resolve-Path $Path).Path

# --------------------------------------------------------------------
# Minimal frontmatter parser
# --------------------------------------------------------------------
function ConvertFrom-SkillFrontmatter {
  param([string]$Text)

  if ($Text -notmatch '(?s)^---\r?\n(.*?)\r?\n---\r?\n') {
    return $null
  }
  $yaml = $Matches[1]

  $result         = [ordered]@{}
  $currentObject  = $null
  $currentListKey = $null
  $inList         = $false

  foreach ($line in ($yaml -split "`r?`n")) {
    if ([string]::IsNullOrWhiteSpace($line)) { continue }

    # Top-level "key: value"
    if ($line -match '^([a-zA-Z_][a-zA-Z0-9_]*):\s+(.+?)\s*$') {
      $key = $Matches[1]
      $val = $Matches[2]
      if ($val -match '^"(.*)"$' -or $val -match "^'(.*)'$") { $val = $Matches[1] }
      $result[$key]   = $val
      $currentObject  = $null
      $currentListKey = $null
      $inList         = $false
      continue
    }

    # Top-level "key:" (block start)
    if ($line -match '^([a-zA-Z_][a-zA-Z0-9_]*):\s*$') {
      $key            = $Matches[1]
      $currentObject  = [ordered]@{}
      $result[$key]   = $currentObject
      $currentListKey = $null
      $inList         = $false
      continue
    }

    # Nested inline array: "  key: [a, b, c]"
    if (($null -ne $currentObject) -and $line -match '^  ([a-zA-Z_][a-zA-Z0-9_]*):\s*\[(.*)\]\s*$') {
      $subKey = $Matches[1]
      $raw    = $Matches[2]
      $items  = New-Object System.Collections.Generic.List[string]
      if ($raw.Trim().Length -gt 0) {
        foreach ($part in ($raw -split ',')) {
          $t = $part.Trim()
          if ($t -match '^"(.*)"$' -or $t -match "^'(.*)'$") { $t = $Matches[1] }
          [void]$items.Add($t)
        }
      }
      $currentObject[$subKey] = $items.ToArray()
      $currentListKey = $null
      $inList         = $false
      continue
    }

    # Nested block start: "  key:" (followed by indented list items)
    if (($null -ne $currentObject) -and $line -match '^  ([a-zA-Z_][a-zA-Z0-9_]*):\s*$') {
      $subKey         = $Matches[1]
      $currentObject[$subKey] = New-Object System.Collections.Generic.List[string]
      $currentListKey = $subKey
      $inList         = $true
      continue
    }

    # List item under nested block: "    - value"
    if ($inList -and ($null -ne $currentObject) -and $currentListKey -and $line -match '^    -\s+(.+?)\s*$') {
      $item = $Matches[1]
      if ($item -match '^"(.*)"$' -or $item -match "^'(.*)'$") { $item = $Matches[1] }
      [void]$currentObject[$currentListKey].Add($item)
      continue
    }

    # Unrecognized line — surface as parse warning via side channel
    if (-not $script:__parseWarnings) { $script:__parseWarnings = @() }
    $script:__parseWarnings += "unparsed line: '$line'"
  }

  # Convert any remaining List[string] values to plain string[] for downstream type checks
  foreach ($k in @($result.Keys)) {
    $v = $result[$k]
    if ($v -is [System.Collections.IDictionary]) {
      foreach ($subK in @($v.Keys)) {
        if ($v[$subK] -is [System.Collections.Generic.List[string]]) {
          $v[$subK] = $v[$subK].ToArray()
        }
      }
    }
  }

  return $result
}

# --------------------------------------------------------------------
# Validation
# --------------------------------------------------------------------
$CategoryEnum = @('architecture','workflow','quality','research','design','infra')
$OsEnum       = @('windows','macos','linux')

function Test-StringField {
  param($Value, [int]$Min, [int]$Max, [string]$Name)
  if ($Value -isnot [string]) { return "'$Name' must be a string" }
  $len = $Value.Length
  if ($len -lt $Min) { return "'$Name' too short ($len chars, min $Min)" }
  if ($len -gt $Max) { return "'$Name' exceeds $Max chars ($len)" }
  return $null
}

function Test-SkillFrontmatter {
  param(
    [object]$Fm,
    [string]$FilePath,
    [bool]$Strict
  )

  $errors   = @()
  $warnings = @()

  if ($null -eq $Fm) {
    return @{ Errors = @('no frontmatter found (expected --- ... --- block)'); Warnings = @() }
  }

  # name (required, always)
  if (-not $Fm.Contains('name')) {
    $errors += "missing 'name'"
  } else {
    $err = Test-StringField -Value $Fm['name'] -Min 1 -Max 64 -Name 'name'
    if ($err) { $errors += $err }
    elseif ($Fm['name'] -notmatch '^[a-zA-Z0-9][a-zA-Z0-9 _-]*$') {
      $errors += "'name' contains invalid characters (allowed: alphanumerics, space, _, -)"
    }
  }

  # description (required, always)
  if (-not $Fm.Contains('description')) {
    $errors += "missing 'description'"
  } else {
    $err = Test-StringField -Value $Fm['description'] -Min 10 -Max 1024 -Name 'description'
    if ($err) { $errors += $err }
  }

  # id, category, version: warn (default) / error (strict)
  $folderName = Split-Path -Leaf (Split-Path -Parent $FilePath)

  if (-not $Fm.Contains('id')) {
    $msg = "missing 'id' (recommended; should equal folder name '$folderName')"
    if ($Strict) { $errors += $msg } else { $warnings += $msg }
  } else {
    if ($Fm['id'] -notmatch '^[a-z][a-z0-9-]*[a-z0-9]$') {
      $errors += "'id' must be kebab-case (got '$($Fm['id'])')"
    }
    if ($Fm['id'] -ne $folderName) {
      $errors += "'id' ($($Fm['id'])) does not match folder name ($folderName)"
    }
  }

  if (-not $Fm.Contains('category')) {
    $msg = "missing 'category' (recommended; one of: $($CategoryEnum -join ', '))"
    if ($Strict) { $errors += $msg } else { $warnings += $msg }
  } else {
    if ($Fm['category'] -notin $CategoryEnum) {
      $errors += "'category' value '$($Fm['category'])' not in [$($CategoryEnum -join ', ')]"
    }
  }

  if (-not $Fm.Contains('version')) {
    $msg = "missing 'version' (recommended; semver, e.g. 0.1.0)"
    if ($Strict) { $errors += $msg } else { $warnings += $msg }
  } else {
    if ($Fm['version'] -notmatch '^\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?(\+[A-Za-z0-9.-]+)?$') {
      $errors += "'version' value '$($Fm['version'])' is not valid semver"
    }
  }

  # triggers (recommended; never errors)
  if (-not $Fm.Contains('triggers')) {
    $warnings += "missing 'triggers' (recommended for dispatcher accuracy)"
  } else {
    $tr = $Fm['triggers']
    if ($tr -isnot [System.Collections.IDictionary]) {
      $errors += "'triggers' must be an object with 'positive' and optional 'negative'"
    } else {
      if (-not $tr.Contains('positive')) {
        $errors += "'triggers.positive' is required when 'triggers' is set"
      } elseif (-not ($tr['positive'] -is [array]) -or $tr['positive'].Count -lt 1) {
        $errors += "'triggers.positive' must be a non-empty array of strings"
      }
      if ($tr.Contains('negative') -and -not ($tr['negative'] -is [array])) {
        $errors += "'triggers.negative' must be an array of strings"
      }
    }
  }

  # requires (recommended; never errors except on bad enum)
  if (-not $Fm.Contains('requires')) {
    $warnings += "missing 'requires' (recommended; declare mcp/os/bin dependencies)"
  } else {
    $rq = $Fm['requires']
    if ($rq -isnot [System.Collections.IDictionary]) {
      $errors += "'requires' must be an object with optional 'mcp', 'os', 'bin' arrays"
    } else {
      foreach ($k in @('mcp','os','bin')) {
        if ($rq.Contains($k) -and -not ($rq[$k] -is [array])) {
          $errors += "'requires.$k' must be an array of strings"
        }
      }
      if ($rq.Contains('os') -and ($rq['os'] -is [array])) {
        foreach ($o in $rq['os']) {
          if ($o -notin $OsEnum) {
            $errors += "'requires.os' value '$o' not in [$($OsEnum -join ', ')]"
          }
        }
      }
    }
  }

  return @{ Errors = $errors; Warnings = $warnings }
}

# --------------------------------------------------------------------
# Main
# --------------------------------------------------------------------
$skillFiles = Get-ChildItem -Path $rootPath -Recurse -Filter 'SKILL.md' -File

if (@($skillFiles).Count -eq 0) {
  Write-Host "No SKILL.md files found under $rootPath" -ForegroundColor Yellow
  exit 0
}

$mode = if ($Strict) { 'STRICT' } else { 'DEFAULT' }
Write-Host "Validating $($skillFiles.Count) SKILL.md files under $rootPath [$mode mode]" -ForegroundColor Cyan
Write-Host ('-' * 70)

$totalErrors   = 0
$totalWarnings = 0
$pass          = 0

foreach ($file in $skillFiles) {
  $script:__parseWarnings = @()
  $relPath = $file.FullName.Substring($rootPath.Length).TrimStart('\','/')
  $content = Get-Content -Raw $file.FullName
  $fm      = ConvertFrom-SkillFrontmatter $content

  $result = Test-SkillFrontmatter -Fm $fm -FilePath $file.FullName -Strict:$Strict.IsPresent

  $hasErr  = $result.Errors.Count -gt 0
  $hasWarn = $result.Warnings.Count -gt 0

  if ($hasErr) {
    Write-Host "[FAIL] $relPath" -ForegroundColor Red
  } elseif ($hasWarn) {
    Write-Host "[WARN] $relPath" -ForegroundColor Yellow
  } else {
    Write-Host "[PASS] $relPath" -ForegroundColor Green
    $pass++
  }

  foreach ($e in $result.Errors)   { Write-Host "  ERROR: $e" -ForegroundColor Red }
  foreach ($w in $result.Warnings) { Write-Host "  WARN:  $w" -ForegroundColor Yellow }
  foreach ($p in $script:__parseWarnings) { Write-Host "  PARSE: $p" -ForegroundColor DarkYellow }

  $totalErrors   += $result.Errors.Count
  $totalWarnings += $result.Warnings.Count
}

Write-Host ('-' * 70)
$summary = "Summary: $pass passed, $totalWarnings warnings, $totalErrors errors"
if ($totalErrors -gt 0) {
  Write-Host $summary -ForegroundColor Red
  exit 1
} elseif ($totalWarnings -gt 0) {
  Write-Host $summary -ForegroundColor Yellow
  exit 0
} else {
  Write-Host $summary -ForegroundColor Green
  exit 0
}
