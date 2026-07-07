param(
  [string]$Version = "v1.0",
  [string]$OutputDir = "dist"
)

$ErrorActionPreference = "Stop"

$RepoRoot = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $RepoRoot $OutputDir
$Stage = Join-Path $OutDir "board-browser-kit"
$PackageName = "board-browser-kit-$Version.tar.gz"
$PackagePath = Join-Path $OutDir $PackageName

Write-Host "Preparing Board Browser Kit release package..."
Write-Host "Repository: $RepoRoot"
Write-Host "Staging:    $Stage"
Write-Host "Package:    $PackagePath"

if (Test-Path $Stage) {
  Remove-Item -LiteralPath $Stage -Recurse -Force
}

New-Item -ItemType Directory -Force $Stage | Out-Null

Copy-Item (Join-Path $RepoRoot "install.sh") $Stage
Copy-Item (Join-Path $RepoRoot "scripts\*") $Stage
Copy-Item (Join-Path $RepoRoot "services\*") $Stage
Copy-Item (Join-Path $RepoRoot "ui\board-firefox-home.html") $Stage

$runtimeItems = @(
  "firefox-esr",
  "firefox-libs",
  "fonts",
  "fontconfig",
  "libwayland_resize_guard.so"
)

foreach ($item in $runtimeItems) {
  $src = Join-Path $RepoRoot $item
  if (Test-Path $src) {
    Copy-Item $src $Stage -Recurse -Force
  }
}

if (-not (Test-Path (Join-Path $Stage "firefox-esr\firefox\firefox"))) {
  throw "Missing Firefox runtime. Add firefox-esr/firefox/firefox before publishing the release package."
}

if (-not (Test-Path (Join-Path $Stage "libwayland_resize_guard.so"))) {
  throw "Missing libwayland_resize_guard.so. Add the tested board Wayland guard library before publishing."
}

New-Item -ItemType Directory -Force $OutDir | Out-Null
tar -czf $PackagePath -C $OutDir "board-browser-kit"

Write-Host "Done: $PackagePath"
