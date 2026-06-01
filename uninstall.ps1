# Autowikipathy uninstaller (Windows). Run from the root of the repo it was installed in.
# Leaves your wiki/ and KNOBS.md untouched.
$ErrorActionPreference = 'Stop'

# 1. Strip the activation snippet from any rules file.
foreach ($f in 'CLAUDE.md','AGENTS.md','.cursorrules') {
  if ((Test-Path $f) -and (Select-String -SimpleMatch -Quiet -Path $f -Pattern 'AUTOWIKIPATHY:BEGIN')) {
    $out = New-Object System.Collections.Generic.List[string]
    $skip = $false
    foreach ($l in (Get-Content $f)) {
      if ($l -match 'AUTOWIKIPATHY:BEGIN') { $skip = $true; continue }
      if ($l -match 'AUTOWIKIPATHY:END')   { $skip = $false; continue }
      if (-not $skip) { $out.Add($l) }
    }
    Set-Content -Path $f -Value $out -Encoding utf8
    Write-Host "  - removed activation snippet from $f"
  }
}

# 2. Remove the hook (standalone) or unchain it (foreign hook).
Remove-Item -Force -ErrorAction SilentlyContinue .git/hooks/autowikipathy-post-commit
$hook = '.git/hooks/post-commit'
if (Test-Path $hook) {
  if (Select-String -SimpleMatch -Quiet -Path $hook -Pattern 'DIR="autowikipathy"') {
    Remove-Item -Force $hook
    Write-Host '  - removed post-commit hook'
  } elseif (Select-String -SimpleMatch -Quiet -Path $hook -Pattern '# autowikipathy-hook') {
    (Get-Content $hook) | Where-Object { ($_ -notmatch 'autowikipathy-hook') -and ($_ -notmatch 'autowikipathy-post-commit') } | Set-Content $hook
    Write-Host '  - unchained Autowikipathy from your post-commit hook'
  }
}

# 3. Remove runtime state only.
Remove-Item -Recurse -Force -ErrorAction SilentlyContinue autowikipathy/.state
Write-Host 'Autowikipathy uninstalled. Your autowikipathy/wiki/ and KNOBS.md were left untouched.'
