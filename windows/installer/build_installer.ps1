#requires -Version 5.1
<#
.SYNOPSIS
    Build the Bloomee Windows release and wrap it in an Inno Setup installer.

.DESCRIPTION
    Runs `flutter build windows --release`, renames bloomee.exe → Bloomee.exe to
    match the CI artifact name, locates ISCC.exe, and produces
    build\windows\x64\installer\bloomee_tunes_windows_x64_v<version>_setup.exe.

    Run from the repo root:
        powershell -ExecutionPolicy Bypass -File .\windows\installer\build_installer.ps1

.PARAMETER SkipBuild
    Skip the `flutter build windows` step (use an existing Release/ build).

.PARAMETER BuildNumber
    Optional build number passed through to flutter build. Defaults to 0.
#>
[CmdletBinding()]
param(
    [switch]$SkipBuild,
    [int]$BuildNumber = 0
)

$ErrorActionPreference = 'Stop'

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
Set-Location $repoRoot

# --- Extract version from pubspec.yaml --------------------------------------
$pubspec = Join-Path $repoRoot 'pubspec.yaml'
$versionLine = Select-String -Path $pubspec -Pattern '^version:\s*(\S+)' | Select-Object -First 1
if (-not $versionLine) { throw "version not found in $pubspec" }
$version = $versionLine.Matches[0].Groups[1].Value.Split('+')[0]
Write-Host "Bloomee version: $version" -ForegroundColor Cyan

# --- Build Flutter Windows release ------------------------------------------
if (-not $SkipBuild) {
    Write-Host "Running flutter build windows --release..." -ForegroundColor Cyan
    & flutter build windows --release --build-number $BuildNumber
    if ($LASTEXITCODE -ne 0) { throw "flutter build failed (exit $LASTEXITCODE)" }
}

$releaseDir = Join-Path $repoRoot 'build\windows\x64\runner\Release'
if (-not (Test-Path $releaseDir)) { throw "Release directory not found: $releaseDir" }

# --- Rename bloomee.exe → Bloomee.exe (matches CI artifact) -----------------
$lowerExe = Join-Path $releaseDir 'bloomee.exe'
$properExe = Join-Path $releaseDir 'Bloomee.exe'
if ((Test-Path $lowerExe) -and -not (Test-Path $properExe)) {
    Rename-Item -Path $lowerExe -NewName 'Bloomee.exe'
}
if (-not (Test-Path $properExe)) { throw "Bloomee.exe missing in $releaseDir" }

# --- Locate ISCC.exe --------------------------------------------------------
$isccCandidates = @(
    "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
    "$env:ProgramFiles\Inno Setup 6\ISCC.exe",
    "$env:LOCALAPPDATA\Programs\Inno Setup 6\ISCC.exe",
    "${env:ProgramFiles(x86)}\Inno Setup 5\ISCC.exe"
)
$iscc = $isccCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $iscc) {
    $cmd = Get-Command ISCC.exe -ErrorAction SilentlyContinue
    if ($cmd) { $iscc = $cmd.Source }
}
if (-not $iscc) {
    throw "ISCC.exe not found. Install Inno Setup 6 from https://jrsoftware.org/isdl.php"
}
Write-Host "Using Inno Setup: $iscc" -ForegroundColor Cyan

# --- Compile installer ------------------------------------------------------
$iss = Join-Path $PSScriptRoot 'bloomee.iss'
& $iscc "/DMyAppVersion=$version" $iss
if ($LASTEXITCODE -ne 0) { throw "ISCC.exe failed (exit $LASTEXITCODE)" }

$outDir = Join-Path $repoRoot 'build\windows\x64\installer'
$setupExe = Join-Path $outDir "bloomee_tunes_windows_x64_v${version}_setup.exe"
if (Test-Path $setupExe) {
    Write-Host ""
    Write-Host "Installer built: $setupExe" -ForegroundColor Green
} else {
    Write-Warning "Build finished but expected output not found at $setupExe"
}
