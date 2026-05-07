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
$skillsRoot = if ((Split-Path -Leaf $rootPath) -eq 'skills') { $rootPath } else { Split-Path -Parent $rootPath }
$toolkitRoot = Split-Path -Parent $skillsRoot

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

function Get-JsonPropertyNames {
  param([object]$Object)
  return @($Object.PSObject.Properties | ForEach-Object { $_.Name })
}

function Test-JsonRequiredProperties {
  param(
    [object]$Object,
    [string[]]$Required,
    [string]$Context
  )

  $errors = @()
  $names = Get-JsonPropertyNames $Object
  foreach ($field in $Required) {
    if ($field -notin $names) {
      $errors += "$Context missing '$field'"
    }
  }
  return $errors
}

function Test-JsonStringField {
  param(
    [object]$Object,
    [string]$Field,
    [string]$Context,
    [int]$Min = 1,
    [int]$Max = 1024,
    [string]$Pattern
  )

  $names = Get-JsonPropertyNames $Object
  if ($Field -notin $names) { return @() }

  $value = $Object.$Field
  $errors = @()
  if ($value -isnot [string]) {
    $errors += "$Context '$Field' must be a string"
  } else {
    if ($value.Length -lt $Min) { $errors += "$Context '$Field' too short ($($value.Length) chars, min $Min)" }
    if ($value.Length -gt $Max) { $errors += "$Context '$Field' exceeds $Max chars ($($value.Length))" }
    if ($Pattern -and $value -notmatch $Pattern) { $errors += "$Context '$Field' has invalid format ('$value')" }
  }
  return $errors
}

function Test-JsonArrayField {
  param(
    [object]$Object,
    [string]$Field,
    [string]$Context,
    [int]$Min = 0
  )

  $names = Get-JsonPropertyNames $Object
  if ($Field -notin $names) { return @() }

  $value = @($Object.$Field)
  if ($null -eq $Object.$Field -or $value.Count -lt $Min) {
    return @("$Context '$Field' must contain at least $Min item(s)")
  }
  return @()
}

function Test-PluginDescriptor {
  param([object]$Plugin, [string]$FilePath)

  $errors = @()
  $context = "plugin descriptor '$FilePath'"
  $errors += Test-JsonRequiredProperties -Object $Plugin -Required @('$schema','name','version','description','author','homepage','repository','license','keywords','skills','interface') -Context $context
  $errors += Test-JsonStringField -Object $Plugin -Field 'name' -Context $context -Pattern '^[a-z][a-z0-9-]*[a-z0-9]$'
  $errors += Test-JsonStringField -Object $Plugin -Field 'version' -Context $context -Pattern '^\d+\.\d+\.\d+(-[A-Za-z0-9.-]+)?(\+[A-Za-z0-9.-]+)?$'
  $errors += Test-JsonStringField -Object $Plugin -Field 'description' -Context $context -Min 10 -Max 512
  $errors += Test-JsonStringField -Object $Plugin -Field 'skills' -Context $context -Pattern '^\./[A-Za-z0-9._/-]+/$'
  $errors += Test-JsonArrayField -Object $Plugin -Field 'keywords' -Context $context -Min 1

  if ($Plugin.PSObject.Properties.Name -contains '$schema' -and $Plugin.'$schema' -ne '../../_schema/plugin.schema.json') {
    $errors += "$context '`$schema' must be '../../_schema/plugin.schema.json'"
  }

  if ($Plugin.author) {
    $errors += Test-JsonRequiredProperties -Object $Plugin.author -Required @('name') -Context "$context author"
    $errors += Test-JsonStringField -Object $Plugin.author -Field 'name' -Context "$context author"
  }

  if ($Plugin.interface) {
    $iface = $Plugin.interface
    $errors += Test-JsonRequiredProperties -Object $iface -Required @('displayName','shortDescription','longDescription','developerName','category','capabilities','websiteURL','privacyPolicyURL','termsOfServiceURL','defaultPrompt','brandColor','screenshots') -Context "$context interface"
    $errors += Test-JsonStringField -Object $iface -Field 'displayName' -Context "$context interface" -Max 64
    $errors += Test-JsonStringField -Object $iface -Field 'shortDescription' -Context "$context interface" -Max 80
    $errors += Test-JsonStringField -Object $iface -Field 'longDescription' -Context "$context interface" -Min 10 -Max 512
    $errors += Test-JsonStringField -Object $iface -Field 'developerName' -Context "$context interface" -Max 64
    $errors += Test-JsonStringField -Object $iface -Field 'brandColor' -Context "$context interface" -Pattern '^#[0-9A-Fa-f]{6}$'
    $errors += Test-JsonArrayField -Object $iface -Field 'capabilities' -Context "$context interface" -Min 1
    $errors += Test-JsonArrayField -Object $iface -Field 'defaultPrompt' -Context "$context interface" -Min 1
    if ($iface.category -and $iface.category -notin @('Engineering','Research','Design','Quality','Workflow')) {
      $errors += "$context interface 'category' has invalid value '$($iface.category)'"
    }
    foreach ($capability in @($iface.capabilities)) {
      if ($capability -notin @('Interactive','Read','Write')) {
        $errors += "$context interface capability '$capability' is invalid"
      }
    }
  }

  return $errors
}

function Test-PluginMarketplace {
  param([object]$Marketplace, [string]$FilePath, [string]$ToolkitRoot)

  $errors = @()
  $context = "plugin marketplace '$FilePath'"
  $errors += Test-JsonRequiredProperties -Object $Marketplace -Required @('$schema','name','interface','plugins') -Context $context
  $errors += Test-JsonStringField -Object $Marketplace -Field 'name' -Context $context -Pattern '^[a-z][a-z0-9-]*[a-z0-9]$'
  $errors += Test-JsonArrayField -Object $Marketplace -Field 'plugins' -Context $context -Min 1

  if ($Marketplace.PSObject.Properties.Name -contains '$schema' -and $Marketplace.'$schema' -ne '../../plugins/_schema/marketplace.schema.json') {
    $errors += "$context '`$schema' must be '../../plugins/_schema/marketplace.schema.json'"
  }

  if ($Marketplace.interface) {
    $errors += Test-JsonRequiredProperties -Object $Marketplace.interface -Required @('displayName') -Context "$context interface"
    $errors += Test-JsonStringField -Object $Marketplace.interface -Field 'displayName' -Context "$context interface" -Max 64
  }

  foreach ($entry in @($Marketplace.plugins)) {
    $entryContext = "$context plugin entry"
    $errors += Test-JsonRequiredProperties -Object $entry -Required @('name','source','policy','category') -Context $entryContext
    $errors += Test-JsonStringField -Object $entry -Field 'name' -Context $entryContext -Pattern '^[a-z][a-z0-9-]*[a-z0-9]$'
    if ($entry.category -and $entry.category -notin @('Engineering','Research','Design','Quality','Workflow')) {
      $errors += "$entryContext 'category' has invalid value '$($entry.category)'"
    }

    if ($entry.source) {
      $errors += Test-JsonRequiredProperties -Object $entry.source -Required @('source','path') -Context "$entryContext source"
      if ($entry.source.source -and $entry.source.source -ne 'local') {
        $errors += "$entryContext source 'source' must be 'local'"
      }
      $errors += Test-JsonStringField -Object $entry.source -Field 'path' -Context "$entryContext source" -Pattern '^\./plugins/[a-z][a-z0-9-]*[a-z0-9]$'
      if ($entry.source.path) {
        $relative = ([string]$entry.source.path).TrimStart('.','/').Replace('/', '\')
        $pluginPath = Join-Path $ToolkitRoot $relative
        $descriptorPath = Join-Path $pluginPath '.codex-plugin\plugin.json'
        if (-not (Test-Path -LiteralPath $descriptorPath)) {
          $errors += "$entryContext source path points to missing plugin descriptor: $descriptorPath"
        }
      }
    }

    if ($entry.policy) {
      $errors += Test-JsonRequiredProperties -Object $entry.policy -Required @('installation','authentication') -Context "$entryContext policy"
      if ($entry.policy.installation -and $entry.policy.installation -notin @('AVAILABLE','REQUIRED','DISABLED')) {
        $errors += "$entryContext policy installation '$($entry.policy.installation)' is invalid"
      }
      if ($entry.policy.authentication -and $entry.policy.authentication -notin @('ON_INSTALL','NONE')) {
        $errors += "$entryContext policy authentication '$($entry.policy.authentication)' is invalid"
      }
    }
  }

  return $errors
}

# --------------------------------------------------------------------
# Cross-file / cross-entry invariants (not expressible in JSON Schema)
# --------------------------------------------------------------------

# manifest.primary_when MUST be a subset of SKILL.triggers.positive
# (case-insensitive bidirectional substring match — tolerates "status code" vs "status codes").
function Test-PrimaryWhenSubset {
  param([object]$ManifestEntry, [object]$SkillFm)
  $errors = @()
  if ($null -eq $SkillFm -or -not $SkillFm.Contains('triggers')) { return $errors }
  $triggers = $SkillFm['triggers']
  if ($triggers -isnot [System.Collections.IDictionary] -or -not $triggers.Contains('positive')) {
    return $errors
  }
  $positive = @($triggers['positive']) | ForEach-Object { ([string]$_).ToLower() }
  foreach ($pw in @($ManifestEntry.primary_when)) {
    $needle = ([string]$pw).ToLower()
    $hit = $false
    foreach ($p in $positive) {
      if ($p -eq $needle -or $p.Contains($needle) -or $needle.Contains($p)) { $hit = $true; break }
    }
    if (-not $hit) {
      $errors += "manifest id '$($ManifestEntry.id)': primary_when '$pw' not found in SKILL.triggers.positive"
    }
  }
  return $errors
}

# pairs_with / conflicts_with are undirected: if A lists B, B MUST list A.
function Test-RelationSymmetry {
  param([object]$Manifest, [string]$Field)
  $errors = @()
  $byId = @{}
  foreach ($e in @($Manifest.skills)) { $byId[[string]$e.id] = $e }
  foreach ($a in @($Manifest.skills)) {
    foreach ($bId in @($a.$Field)) {
      $bIdStr = [string]$bId
      if (-not $byId.ContainsKey($bIdStr)) { continue } # unknown id surfaced by linked-id check
      $b = $byId[$bIdStr]
      $reverse = @($b.$Field) | ForEach-Object { [string]$_ }
      if ([string]$a.id -notin $reverse) {
        $errors += "manifest: $Field asymmetry — '$($a.id)' -> '$bIdStr' but reverse missing"
      }
    }
  }
  return $errors
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

$totalErrors          = 0
$totalWarnings        = 0
$pass                 = 0
$validatedIds         = @{}
$validatedFrontmatter = @{}

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

  if ($fm -and $fm.Contains('id')) {
    $validatedIds[$fm['id']]         = $file.FullName
    $validatedFrontmatter[$fm['id']] = $fm
  }
}

# --------------------------------------------------------------------
# Manifest validation
# --------------------------------------------------------------------
$manifestPath = Join-Path $skillsRoot 'manifest.json'
if (Test-Path -LiteralPath $manifestPath) {
  Write-Host ('-' * 70)
  Write-Host "Validating manifest: $manifestPath" -ForegroundColor Cyan

  try {
    $manifest = Get-Content -Raw -LiteralPath $manifestPath | ConvertFrom-Json
  } catch {
    Write-Host "  ERROR: manifest.json is not valid JSON: $($_.Exception.Message)" -ForegroundColor Red
    $totalErrors++
    $manifest = $null
  }

  if ($manifest) {
    if (-not $manifest.version) {
      Write-Host "  ERROR: manifest missing 'version'" -ForegroundColor Red
      $totalErrors++
    }
    if (-not $manifest.skills -or @($manifest.skills).Count -eq 0) {
      Write-Host "  ERROR: manifest missing non-empty 'skills' array" -ForegroundColor Red
      $totalErrors++
    } else {
      $seenManifestIds = @{}
      foreach ($entry in @($manifest.skills)) {
        $id = [string]$entry.id
        $relativePath = if ($entry.path) { [string]$entry.path } else { $id }
        $skillPath = Join-Path $skillsRoot $relativePath
        $skillFile = Join-Path $skillPath 'SKILL.md'

        if (-not $id) {
          Write-Host "  ERROR: manifest entry missing 'id'" -ForegroundColor Red
          $totalErrors++
          continue
        }
        if ($seenManifestIds.ContainsKey($id)) {
          Write-Host "  ERROR: duplicate manifest id '$id'" -ForegroundColor Red
          $totalErrors++
        }
        $seenManifestIds[$id] = $true

        if (-not $validatedIds.ContainsKey($id)) {
          Write-Host "  ERROR: manifest id '$id' has no matching SKILL.md frontmatter id" -ForegroundColor Red
          $totalErrors++
        }
        if (-not (Test-Path -LiteralPath $skillFile)) {
          Write-Host "  ERROR: manifest id '$id' points to missing skill file: $skillFile" -ForegroundColor Red
          $totalErrors++
        }
        if ($entry.category -and ($entry.category -notin $CategoryEnum)) {
          Write-Host "  ERROR: manifest id '$id' has invalid category '$($entry.category)'" -ForegroundColor Red
          $totalErrors++
        }
        if ($null -eq $entry.priority -or $entry.priority -lt 0 -or $entry.priority -gt 100) {
          Write-Host "  ERROR: manifest id '$id' priority must be 0..100" -ForegroundColor Red
          $totalErrors++
        }
        foreach ($linkedId in @($entry.conflicts_with) + @($entry.pairs_with)) {
          if ($linkedId -and -not $validatedIds.ContainsKey([string]$linkedId)) {
            Write-Host "  ERROR: manifest id '$id' references unknown skill '$linkedId'" -ForegroundColor Red
            $totalErrors++
          }
        }

        # Cross-file: primary_when MUST be a subset of SKILL.triggers.positive
        if ($validatedFrontmatter.ContainsKey($id)) {
          $subsetErrors = Test-PrimaryWhenSubset -ManifestEntry $entry -SkillFm $validatedFrontmatter[$id]
          foreach ($se in $subsetErrors) {
            Write-Host "  ERROR: $se" -ForegroundColor Red
            $totalErrors++
          }
        }
      }

      # Cross-entry: pairs_with / conflicts_with symmetry
      foreach ($relField in @('pairs_with','conflicts_with')) {
        $symErrors = Test-RelationSymmetry -Manifest $manifest -Field $relField
        foreach ($se in $symErrors) {
          Write-Host "  ERROR: $se" -ForegroundColor Red
          $totalErrors++
        }
      }

      foreach ($id in $validatedIds.Keys) {
        if (-not $seenManifestIds.ContainsKey($id)) {
          $msg = "SKILL.md id '$id' is not listed in manifest.json"
          if ($Strict) {
            Write-Host "  ERROR: $msg" -ForegroundColor Red
            $totalErrors++
          } else {
            Write-Host "  WARN:  $msg" -ForegroundColor Yellow
            $totalWarnings++
          }
        }
      }

      if ($totalErrors -eq 0) {
        Write-Host "  [PASS] manifest.json ($(@($manifest.skills).Count) skills)" -ForegroundColor Green
      }
    }
  }
} else {
  $msg = "manifest.json not found under $skillsRoot"
  if ($Strict) {
    Write-Host "ERROR: $msg" -ForegroundColor Red
    $totalErrors++
  } else {
    Write-Host "WARN:  $msg" -ForegroundColor Yellow
    $totalWarnings++
  }
}

# --------------------------------------------------------------------
# Plugin skill and descriptor validation
# --------------------------------------------------------------------
$pluginsRoot = Join-Path $toolkitRoot 'plugins'
if (Test-Path -LiteralPath $pluginsRoot) {
  $pluginSkillFiles = Get-ChildItem -Path $pluginsRoot -Recurse -Filter 'SKILL.md' -File -Force
  if (@($pluginSkillFiles).Count -gt 0) {
    Write-Host ('-' * 70)
    Write-Host "Validating plugin SKILL.md files under $pluginsRoot [STRICT mode]" -ForegroundColor Cyan

    foreach ($file in $pluginSkillFiles) {
      $script:__parseWarnings = @()
      $relPath = $file.FullName.Substring($toolkitRoot.Length).TrimStart('\','/')
      $content = Get-Content -Raw $file.FullName
      $fm = ConvertFrom-SkillFrontmatter $content
      $result = Test-SkillFrontmatter -Fm $fm -FilePath $file.FullName -Strict:$true

      $hasErr = $result.Errors.Count -gt 0
      $hasWarn = $result.Warnings.Count -gt 0

      if ($hasErr) {
        Write-Host "[FAIL] $relPath" -ForegroundColor Red
      } elseif ($hasWarn) {
        Write-Host "[WARN] $relPath" -ForegroundColor Yellow
      } else {
        Write-Host "[PASS] $relPath" -ForegroundColor Green
        $pass++
      }

      foreach ($e in $result.Errors) { Write-Host "  ERROR: $e" -ForegroundColor Red }
      foreach ($w in $result.Warnings) { Write-Host "  WARN:  $w" -ForegroundColor Yellow }
      foreach ($p in $script:__parseWarnings) { Write-Host "  PARSE: $p" -ForegroundColor DarkYellow }

      $totalErrors += $result.Errors.Count
      $totalWarnings += $result.Warnings.Count
    }
  }

  $pluginDescriptors = Get-ChildItem -Path $pluginsRoot -Recurse -Filter 'plugin.json' -File -Force | Where-Object { $_.Directory.Name -eq '.codex-plugin' }
  if (@($pluginDescriptors).Count -gt 0) {
    Write-Host ('-' * 70)
    Write-Host "Validating plugin descriptors under $pluginsRoot" -ForegroundColor Cyan

    foreach ($file in $pluginDescriptors) {
      $relPath = $file.FullName.Substring($toolkitRoot.Length).TrimStart('\','/')
      try {
        $plugin = Get-Content -Raw -LiteralPath $file.FullName | ConvertFrom-Json
        $errors = Test-PluginDescriptor -Plugin $plugin -FilePath $relPath
      } catch {
        $errors = @("plugin descriptor '$relPath' is not valid JSON: $($_.Exception.Message)")
      }

      if ($errors.Count -gt 0) {
        Write-Host "[FAIL] $relPath" -ForegroundColor Red
        foreach ($e in $errors) { Write-Host "  ERROR: $e" -ForegroundColor Red }
      } else {
        Write-Host "[PASS] $relPath" -ForegroundColor Green
        $pass++
      }
      $totalErrors += $errors.Count
    }
  }
}

$marketplacePath = Join-Path $toolkitRoot '.agents\plugins\marketplace.json'
if (Test-Path -LiteralPath $marketplacePath) {
  Write-Host ('-' * 70)
  Write-Host "Validating plugin marketplace: $marketplacePath" -ForegroundColor Cyan

  try {
    $marketplace = Get-Content -Raw -LiteralPath $marketplacePath | ConvertFrom-Json
    $marketplaceErrors = Test-PluginMarketplace -Marketplace $marketplace -FilePath '.agents/plugins/marketplace.json' -ToolkitRoot $toolkitRoot
  } catch {
    $marketplaceErrors = @("plugin marketplace '.agents/plugins/marketplace.json' is not valid JSON: $($_.Exception.Message)")
  }

  if ($marketplaceErrors.Count -gt 0) {
    Write-Host "[FAIL] .agents/plugins/marketplace.json" -ForegroundColor Red
    foreach ($e in $marketplaceErrors) { Write-Host "  ERROR: $e" -ForegroundColor Red }
  } else {
    Write-Host "[PASS] .agents/plugins/marketplace.json" -ForegroundColor Green
    $pass++
  }
  $totalErrors += $marketplaceErrors.Count
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
