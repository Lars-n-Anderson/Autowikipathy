# Autowikipathy installer (Windows). Run from the ROOT of the git repo to add it to:
#   powershell -File install.ps1 [path-to-Autowikipathy-source]
# Idempotent: safe to re-run.
param([string]$Src = $PSScriptRoot)
$ErrorActionPreference = 'Stop'
if (-not (Test-Path .git)) { Write-Error 'Run from the root of a git repository (no .git here).'; exit 1 }
if (-not (Test-Path (Join-Path $Src 'template/autowikipathy'))) { Write-Error "Autowikipathy source not found at $Src/template"; exit 1 }
$mark = '# autowikipathy-hook'

# 1. Scaffold autowikipathy/ if absent; always ensure runtime state exists.
if (-not (Test-Path autowikipathy)) {
  Copy-Item -Recurse (Join-Path $Src 'template/autowikipathy') autowikipathy
  Write-Host '  + scaffolded autowikipathy/'
} else {
  Write-Host '  = autowikipathy/ already present (left as-is)'
}
New-Item -ItemType Directory -Force autowikipathy/.state | Out-Null
if (-not (Test-Path autowikipathy/.state/count)) { [IO.File]::WriteAllText((Join-Path (Get-Location) 'autowikipathy/.state/count'), '0') }

# 2. Install / chain the post-commit hook (Copy-Item preserves the LF line endings sh needs).
New-Item -ItemType Directory -Force .git/hooks | Out-Null
$hook = '.git/hooks/post-commit'
if (-not (Test-Path $hook)) {
  Copy-Item (Join-Path $Src 'template/hooks/post-commit') $hook
  Write-Host '  + installed post-commit hook'
} elseif (Select-String -SimpleMatch -Quiet -Path $hook -Pattern $mark) {
  Write-Host '  = post-commit hook already has Autowikipathy'
} else {
  Copy-Item (Join-Path $Src 'template/hooks/post-commit') .git/hooks/autowikipathy-post-commit
  Add-Content -Path $hook -Value "`n$mark`nsh `"`$(dirname `"`$0`")/autowikipathy-post-commit`" || true"
  Write-Host '  + chained Autowikipathy onto your existing post-commit hook'
}

# 3. Append the activation snippet to a rules file (create AGENTS.md if none exist).
$rules = $null
foreach ($f in 'CLAUDE.md','AGENTS.md','.cursorrules') { if (Test-Path $f) { $rules = $f; break } }
if (-not $rules) { $rules = 'AGENTS.md' }
if ((Test-Path $rules) -and (Select-String -SimpleMatch -Quiet -Path $rules -Pattern 'AUTOWIKIPATHY:BEGIN')) {
  Write-Host "  = activation snippet already in $rules"
} else {
  Add-Content -Path $rules -Value ''
  Get-Content (Join-Path $Src 'template/snippet.md') | Add-Content -Path $rules
  Write-Host "  + added activation snippet to $rules"
}
Write-Host 'Autowikipathy installed. Tune it in autowikipathy/KNOBS.md; remove it with uninstall.ps1.'
