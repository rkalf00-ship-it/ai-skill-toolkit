<#
.SYNOPSIS
  Test the trigger model used by AI Skill Toolkit dispatchers.

.DESCRIPTION
  This script provides empirical verification of the trigger model.

  Real LLM dispatchers (Claude Code, Codex, Cursor) decide activation by
  semantically matching user prompts against each skill's `description`,
  `triggers.positive`, and `primary_when` fields. This script approximates
  that with WORD-LEVEL overlap (after tokenization and stopword removal),
  weighted as:

    primary_when_match * 3  +  triggers_positive_match * 2  +  description_match * 1

  When no skill scores above 0, the scorer returns NO_MATCH rather than
  defaulting to the highest-priority skill — defaulting was a real bug in
  earlier versions.

  This is still a weak proxy for a real LLM. Use the -ReportPath flag and
  manually compare against your actual dispatcher's behavior to confirm.

.PARAMETER FixturesPath
  Path to trigger-fixtures.json. Defaults to ../tests/trigger-fixtures.json.

.PARAMETER ManifestPath
  Path to skills/manifest.json. Defaults to ../skills/manifest.json.

.PARAMETER SkillsRoot
  Path to skills/ directory. Defaults to ../skills.

.PARAMETER ReportPath
  Optional. If set, write a markdown report for manual dispatcher testing.

.PARAMETER Strict
  Treat ambiguous prompts (multiple skills tied) as failures.

.EXAMPLE
  .\scripts\test-trigger-routing.ps1
  .\scripts\test-trigger-routing.ps1 -Strict
  .\scripts\test-trigger-routing.ps1 -ReportPath out/dispatcher-report.md
#>
[CmdletBinding()]
param(
  [string]$FixturesPath,
  [string]$ManifestPath,
  [string]$SkillsRoot,
  [string]$ReportPath,
  [switch]$Strict
)

$ErrorActionPreference = 'Stop'

$scriptDir = Split-Path -Parent $PSCommandPath
$toolkitRoot = Split-Path -Parent $scriptDir

if (-not $FixturesPath) { $FixturesPath = Join-Path $toolkitRoot 'tests/trigger-fixtures.json' }
if (-not $ManifestPath) { $ManifestPath = Join-Path $toolkitRoot 'skills/manifest.json' }
if (-not $SkillsRoot)   { $SkillsRoot   = Join-Path $toolkitRoot 'skills' }

if (-not (Test-Path -LiteralPath $FixturesPath)) {
  Write-Host "ERROR: Fixtures not found: $FixturesPath" -ForegroundColor Red
  exit 2
}
if (-not (Test-Path -LiteralPath $ManifestPath)) {
  Write-Host "ERROR: Manifest not found: $ManifestPath" -ForegroundColor Red
  exit 2
}

$fixtures = (Get-Content -Raw -LiteralPath $FixturesPath | ConvertFrom-Json).fixtures
$manifest = Get-Content -Raw -LiteralPath $ManifestPath | ConvertFrom-Json

$manifestById = @{}
foreach ($e in @($manifest.skills)) { $manifestById[[string]$e.id] = $e }

# --------------------------------------------------------------------
# Tokenization with stopwords removed
# --------------------------------------------------------------------
$Stopwords = @(
  'a','an','the','is','are','was','were','be','been','being','am',
  'and','or','but','if','then','else','for','to','of','in','on','at','by','with','from','into','about','as','this','that','these','those',
  'i','we','you','they','he','she','it','my','our','your','their','his','her','its',
  'how','what','when','where','why','which','who','whose',
  'do','does','did','done','have','has','had','having',
  'will','would','can','could','should','may','might','must','shall',
  'use','using','used','make','made','get','got','set','let','need','want','help','please','show','tell','say',
  'just','also','very','really','only','more','most','some','any','all','each','every','no','not','too','so','than','then',
  'me','us','them','myself','yourself','itself',
  'before','after','during','while','until','since','through','because',
  'going','wanted','wants',
  '15','12','5','100','50','3','2','1','0','24','7'
) | ForEach-Object { $_.ToLower() }
$StopwordSet = @{}
foreach ($w in $Stopwords) { $StopwordSet[$w] = $true }

function Get-Tokens {
  param([string]$Text)
  if (-not $Text) { return @() }
  $lower = $Text.ToLower()
  $matches = [regex]::Matches($lower, '[a-z][a-z0-9+\-]*[a-z0-9]|[a-z]')
  $tokens = @()
  foreach ($m in $matches) { $tokens += $m.Value }
  $filtered = @()
  foreach ($t in $tokens) {
    if ($t.Length -lt 2) { continue }
    if ($StopwordSet.ContainsKey($t)) { continue }
    $filtered += $t
  }
  return $filtered
}

function Score-Overlap {
  param([string[]]$PromptTokens, [string[]]$KeywordPhrases)
  # Two-tier matching:
  #  - Full phrase match (all tokens present) = 1.0
  #  - Strong partial match (>=75% of tokens, AND at least 2 tokens) = 0.5
  # 50% partial was tried and caused false positives via common single tokens
  # like "review" / "test" / "main"; the 75%+min2 rule keeps partial credit
  # only for genuinely close paraphrases (e.g. "merge vs rebase" -> "rebase or merge").
  if (-not $KeywordPhrases) { return 0 }
  $promptSet = @{}
  foreach ($t in $PromptTokens) { $promptSet[$t] = $true }
  $score = 0.0
  foreach ($phrase in $KeywordPhrases) {
    $tokens = Get-Tokens $phrase
    if ($tokens.Count -eq 0) { continue }
    $hits = 0
    foreach ($pt in $tokens) { if ($promptSet.ContainsKey($pt)) { $hits++ } }
    if ($hits -eq $tokens.Count) { $score += 1.0 }
    elseif ($tokens.Count -ge 2 -and ($hits / $tokens.Count) -ge 0.75) { $score += 0.5 }
  }
  return $score
}

# --------------------------------------------------------------------
# Parse SKILL.md frontmatter (triggers + description)
# --------------------------------------------------------------------
function Get-SkillFrontmatter {
  param([string]$SkillId)
  $skillFile = Join-Path $SkillsRoot "$SkillId/SKILL.md"
  if (-not (Test-Path -LiteralPath $skillFile)) { return @{ description = ''; triggers = @() } }
  $content = Get-Content -Raw -LiteralPath $skillFile
  if ($content -notmatch '(?s)^---\r?\n(.*?)\r?\n---\r?\n') {
    return @{ description = ''; triggers = @() }
  }
  $yaml = $Matches[1]

  $desc = ''
  $triggers = @()
  $inPositive = $false
  foreach ($line in ($yaml -split "`r?`n")) {
    if ($line -match '^description:\s*(.+?)\s*$') {
      $val = $Matches[1].Trim('"',"'")
      $desc = $val
      $inPositive = $false
      continue
    }
    if ($line -match '^\s*positive:\s*$') { $inPositive = $true; continue }
    if ($line -match '^\s*negative:\s*$') { $inPositive = $false; continue }
    if ($line -match '^[a-zA-Z_]')         { $inPositive = $false; continue }
    if ($inPositive -and $line -match '^\s*-\s+(.+?)\s*$') {
      $triggers += $Matches[1].Trim('"',"'")
    }
  }
  return @{ description = $desc; triggers = $triggers }
}

$frontmatterById = @{}
foreach ($id in $manifestById.Keys) {
  $frontmatterById[$id] = Get-SkillFrontmatter -SkillId $id
}

# --------------------------------------------------------------------
# Composite scorer
# --------------------------------------------------------------------
function Score-Match {
  param([string]$Prompt, [string]$SkillId)
  $entry = $manifestById[$SkillId]
  $fm = $frontmatterById[$SkillId]
  $promptTokens = Get-Tokens $Prompt

  $primaryHits     = Score-Overlap -PromptTokens $promptTokens -KeywordPhrases @($entry.primary_when)
  $triggerHits     = Score-Overlap -PromptTokens $promptTokens -KeywordPhrases $fm.triggers
  $descriptionHits = Score-Overlap -PromptTokens $promptTokens -KeywordPhrases @($fm.description)

  # Weighted composite
  $composite = ($primaryHits * 3) + ($triggerHits * 2) + ($descriptionHits * 1)

  return @{
    primary_when_hits      = $primaryHits
    triggers_positive_hits = $triggerHits
    description_hits       = $descriptionHits
    composite              = $composite
    priority               = [int]$entry.priority
  }
}

function Best-Skill {
  param([string]$Prompt)
  $best = $null
  $bestScore = @{ composite = -1; priority = -1 }
  $tied = @()
  foreach ($id in $manifestById.Keys) {
    $score = Score-Match -Prompt $Prompt -SkillId $id
    if ($score.composite -gt $bestScore.composite -or
        ($score.composite -eq $bestScore.composite -and
         $score.priority -gt $bestScore.priority)) {
      $best = $id
      $bestScore = $score
      $tied = @($id)
    } elseif ($score.composite -eq $bestScore.composite -and
              $score.priority -eq $bestScore.priority -and
              $score.composite -gt 0) {
      $tied += $id
    }
  }
  # Critical: when nothing matches, return NO_MATCH instead of defaulting to highest priority
  if ($bestScore.composite -le 0) {
    return @{ id = $null; score = $bestScore; tied = @() }
  }
  return @{ id = $best; score = $bestScore; tied = $tied }
}

# --------------------------------------------------------------------
# Run fixtures
# --------------------------------------------------------------------
Write-Host "Running $($fixtures.Count) fixtures against $($manifestById.Count) skills" -ForegroundColor Cyan
Write-Host "Scoring: primary_when * 3  +  triggers.positive * 2  +  description * 1" -ForegroundColor DarkGray
Write-Host ('-' * 70)

$pass = 0
$fail = 0
$warn = 0
$xfail = 0  # expected failures (routing_difficulty: hard)
$xpass = 0  # surprise passes (hard fixtures that DID route)
$report = @()

foreach ($fx in $fixtures) {
  $expected = [string]$fx.expected_primary
  $isHard = ($fx.routing_difficulty -eq 'hard')
  $best = Best-Skill -Prompt $fx.prompt

  $expectedScore  = Score-Match -Prompt $fx.prompt -SkillId $expected
  $actualId       = $best.id
  $actualScore    = $best.score
  $tied           = $best.tied

  $isNoMatch     = ($null -eq $actualId)
  $isPass        = ($actualId -eq $expected)
  $isAmbiguous   = ($tied.Count -gt 1 -and $tied -contains $expected)

  if ($isPass -and -not $isAmbiguous) {
    if ($isHard) {
      Write-Host "[XPASS] $($fx.prompt)" -ForegroundColor Cyan
      Write-Host "        -> $actualId (composite:$($actualScore.composite)) — marked hard but routed correctly; consider downgrading to 'easy'"
      $xpass++
    } else {
      Write-Host "[PASS] $($fx.prompt)" -ForegroundColor Green
      Write-Host "       -> $actualId (composite:$($actualScore.composite) [pw:$($actualScore.primary_when_hits) tr:$($actualScore.triggers_positive_hits) desc:$($actualScore.description_hits)] priority:$($actualScore.priority))"
      $pass++
    }
  } elseif ($isAmbiguous) {
    if ($Strict) {
      Write-Host "[FAIL] $($fx.prompt)" -ForegroundColor Red
      Write-Host "       AMBIGUOUS - tied: $($tied -join ', ')"
      $fail++
    } else {
      Write-Host "[WARN] $($fx.prompt)" -ForegroundColor Yellow
      Write-Host "       AMBIGUOUS - tied: $($tied -join ', ') (expected $expected was among ties)"
      $warn++
    }
  } elseif ($isHard) {
    # Expected failure — keyword scorer cannot route this prompt; documented limitation
    Write-Host "[XFAIL] $($fx.prompt)" -ForegroundColor DarkGray
    if ($isNoMatch) {
      Write-Host "        NO_MATCH (expected — see 'routing_difficulty: hard' in fixture)" -ForegroundColor DarkGray
    } else {
      Write-Host "        got: $actualId, expected: $expected (mis-routed by keywords; LLM should resolve)" -ForegroundColor DarkGray
    }
    if ($fx.difficulty_reason) {
      Write-Host "        reason: $($fx.difficulty_reason)" -ForegroundColor DarkGray
    }
    $xfail++
  } elseif ($isNoMatch) {
    Write-Host "[FAIL] $($fx.prompt)" -ForegroundColor Red
    Write-Host "       NO_MATCH - no skill scored above 0"
    Write-Host "       expected: $expected (composite would be:$($expectedScore.composite))"
    $fail++
  } else {
    Write-Host "[FAIL] $($fx.prompt)" -ForegroundColor Red
    Write-Host "       expected: $expected (composite:$($expectedScore.composite) [pw:$($expectedScore.primary_when_hits) tr:$($expectedScore.triggers_positive_hits) desc:$($expectedScore.description_hits)])"
    Write-Host "       got:      $actualId (composite:$($actualScore.composite) [pw:$($actualScore.primary_when_hits) tr:$($actualScore.triggers_positive_hits) desc:$($actualScore.description_hits)])"
    $fail++
  }

  $report += [pscustomobject]@{
    prompt           = $fx.prompt
    expected         = $expected
    keyword_winner   = if ($actualId) { $actualId } else { 'NO_MATCH' }
    difficulty       = if ($isHard) { 'hard' } else { 'easy' }
    expected_pw      = $expectedScore.primary_when_hits
    expected_tr      = $expectedScore.triggers_positive_hits
    expected_desc    = $expectedScore.description_hits
    expected_score   = $expectedScore.composite
    winner_score     = $actualScore.composite
    tied             = ($tied -join ', ')
    status           = if ($isPass -and -not $isAmbiguous) { if ($isHard) { 'XPASS' } else { 'PASS' } }
                       elseif ($isAmbiguous) { 'AMBIGUOUS' }
                       elseif ($isHard) { 'XFAIL' }
                       elseif ($isNoMatch) { 'NO_MATCH' }
                       else { 'FAIL' }
  }
}

Write-Host ('-' * 70)
$summary = "Summary: $pass passed, $warn ambiguous, $fail failed, $xfail expected-failures, $xpass surprise-passes (out of $($fixtures.Count))"
if ($fail -gt 0) {
  Write-Host $summary -ForegroundColor Red
} elseif ($warn -gt 0) {
  Write-Host $summary -ForegroundColor Yellow
} else {
  Write-Host $summary -ForegroundColor Green
}

# --------------------------------------------------------------------
# Optional markdown report
# --------------------------------------------------------------------
if ($ReportPath) {
  $reportParent = Split-Path -Parent $ReportPath
  if ($reportParent) { New-Item -ItemType Directory -Force -Path $reportParent | Out-Null }

  $md = @"
# Dispatcher Routing Report

This report shows what the **word-overlap scorer** in this script picked.
Use it to compare against what your **actual LLM dispatcher** does.

To test dispatcher behavior manually:
1. Open Claude Code / Codex / your LLM with the toolkit installed.
2. For each prompt below, paste it as a fresh message.
3. Note which skill (if any) the dispatcher activates.
4. Compare to the ``keyword_winner`` column.

If the dispatcher and keyword_winner disagree often, the dispatcher is
weighting ``description`` (or another semantic signal) differently than this
scorer assumes. Adjust ``description`` to be more discriminative.

| Prompt | Expected | Keyword Winner | Score(exp) | Score(winner) | Status |
|--------|----------|----------------|-----------:|--------------:|--------|
"@
  foreach ($r in $report) {
    $md += "`n| $($r.prompt) | $($r.expected) | $($r.keyword_winner) | $($r.expected_score) | $($r.winner_score) | $($r.status) |"
  }
  Set-Content -LiteralPath $ReportPath -Value $md -Encoding UTF8
  Write-Host "`nReport written: $ReportPath" -ForegroundColor Cyan
}

if ($fail -gt 0) { exit 1 } else { exit 0 }
