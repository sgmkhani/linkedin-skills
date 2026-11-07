[CmdletBinding()]
param([switch]$InstallPythonDependencies,[switch]$SkipClaudeCode,[switch]$SkipCodex,[switch]$Force)
$ErrorActionPreference = "Stop"
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$SkillsSource = Join-Path $RepoRoot "skills"
Write-Host "LinkedIn Skills - Windows installer" -ForegroundColor Cyan
if (-not (Test-Path $SkillsSource -PathType Container)) { throw "The skills folder was not found. Extract the complete repository ZIP first." }
$skillDirs = @(Get-ChildItem -Path $SkillsSource -Directory | Where-Object { Test-Path (Join-Path $_.FullName "SKILL.md") -PathType Leaf })
if ($skillDirs.Count -eq 0) { throw "No valid skill folders containing SKILL.md were found." }
if ($skillDirs.Count -ne 12) { Write-Warning "Expected 12 skills; found $($skillDirs.Count). Continuing with valid folders." }
$targets = @()
if (-not $SkipCodex) { $targets += [pscustomobject]@{ Name="Codex"; Path=(Join-Path $HOME ".agents\skills") } }
if (-not $SkipClaudeCode) { $targets += [pscustomobject]@{ Name="Claude Code"; Path=(Join-Path $HOME ".claude\skills") } }
foreach ($target in $targets) {
  New-Item -ItemType Directory -Path $target.Path -Force | Out-Null
  Write-Host "Installing for $($target.Name): $($target.Path)" -ForegroundColor Yellow
  foreach ($skill in $skillDirs) {
    $destination = Join-Path $target.Path $skill.Name
    if ((Test-Path $destination) -and -not $Force) { Write-Host "  SKIP $($skill.Name) (already exists; use -Force to replace)" -ForegroundColor DarkYellow; continue }
    if (Test-Path $destination) { Remove-Item -LiteralPath $destination -Recurse -Force }
    Copy-Item -LiteralPath $skill.FullName -Destination $destination -Recurse
    if (-not (Test-Path (Join-Path $destination "SKILL.md"))) { throw "Install verification failed for $($skill.Name)" }
    Write-Host "  OK   $($skill.Name)" -ForegroundColor Green
  }
}
if ($InstallPythonDependencies) {
  $python = Get-Command python -ErrorAction SilentlyContinue
  if (-not $python) { $python = Get-Command py -ErrorAction SilentlyContinue }
  if (-not $python) { throw "Python not found. Install Python 3.10+ or omit -InstallPythonDependencies." }
  & $python.Source --version
  if ($LASTEXITCODE -ne 0) { throw "Could not run Python." }
  & $python.Source -m pip install -r (Join-Path $RepoRoot "requirements.txt")
  if ($LASTEXITCODE -ne 0) { throw "Python dependency installation failed." }
}
Write-Host ""
Write-Host "Completed: $($skillDirs.Count) skills copied to each selected agent." -ForegroundColor Green
Write-Host "Restart Codex / Claude Code to reload skills."
Write-Host "Optional offline check: python scripts/selftest.py --offline"
Write-Host "No API keys were created or transmitted. API integrations remain optional."