# OpenCode SecOps Blueprint Installer (PowerShell)
# Usage: Invoke-WebRequest -Uri https://raw.githubusercontent.com/AmidVoshakul/opencode-secops-blueprint/main/install.ps1 | Invoke-Expression
#        or: .\install.ps1

$ErrorActionPreference = "Stop"

$REPO_URL = "https://github.com/AmidVoshakul/opencode-secops-blueprint.git"
$REPO_NAME = "opencode-secops-blueprint"
$TARGET_DIR = (Get-Location).Path
$OPENCODE_DIR = Join-Path $TARGET_DIR ".opencode"

function Write-Info    { param($m) Write-Host "[INFO] $m" -ForegroundColor Blue }
function Write-Ok      { param($m) Write-Host "[OK]   $m" -ForegroundColor Green }
function Write-Warn    { param($m) Write-Host "[WARN] $m" -ForegroundColor Yellow }
function Write-Err     { param($m) Write-Host "[ERROR] $m" -ForegroundColor Red }

function Write-Progress-Bar {
    param($Current, $Total, $Label)
    $pct = [math]::Round(($Current / $Total) * 100)
    $width = 40
    $filled = [math]::Floor(($Current / $Total) * $width)
    $bar = ("#" * $filled) + (" " * ($width - $filled))
    Write-Progress -Activity "Installing Blueprint" -Status "$Label" -PercentComplete $pct
}

# Check prerequisites
Write-Info "Checking prerequisites..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Err "git is not installed. Install git and try again."
    exit 1
}
Write-Ok "All prerequisites met."

# Check existing .opencode
if (Test-Path $OPENCODE_DIR) {
    Write-Host ""
    Write-Warn "Directory .opencode/ already exists in $TARGET_DIR"
    $choice = Read-Host "Overwrite? (y/N)"
    if ($choice -ne "y" -and $choice -ne "Y") {
        Write-Info "Aborting installation."
        exit 0
    }
    $backup = Join-Path $TARGET_DIR ".opencode.backup"
    if (Test-Path $backup) { Remove-Item $backup -Recurse -Force }
    Move-Item $OPENCODE_DIR $backup
    Write-Info "Backed up existing .opencode/ to .opencode.backup/"
}

# Clone repository
Write-Info "Cloning blueprint repository..."
$tmpDir = Join-Path $env:TEMP "opencode-setup-$([System.Guid]::NewGuid())"
New-Item -ItemType Directory -Path $tmpDir | Out-Null
$cloneDest = Join-Path $tmpDir $REPO_NAME

git clone --depth 1 $REPO_URL $cloneDest 2>&1 | ForEach-Object {
    if ($_ -match "remote:|Receiving|Resolving") {
        Write-Host "`r$_" -ForegroundColor Cyan -NoNewline
    }
}
Write-Host ""

if ($LASTEXITCODE -ne 0) {
    Write-Err "Failed to clone repository."
    Remove-Item $tmpDir -Recurse -Force
    exit 1
}

# Copy files
Write-Info "Copying blueprint files..."
$srcOpencode = Join-Path $cloneDest ".opencode"
New-Item -ItemType Directory -Path $OPENCODE_DIR -Force | Out-Null

$excludeFiles = @("AGENTS.md", "LICENSE", "README.md")
$excludeDirs = @(".git", "docs")

$allFiles = Get-ChildItem -Path $srcOpencode -Recurse -File
$totalFiles = $allFiles.Count
$copied = 0

foreach ($file in $allFiles) {
    $relPath = $file.FullName.Substring($srcOpencode.Length + 1)
    $fileName = $file.Name

    if ($excludeFiles -contains $fileName) { continue }

    $parts = $relPath -split '\\'
    $skip = $false
    foreach ($part in $parts) {
        if ($excludeDirs -contains $part) { $skip = $true; break }
    }
    if ($skip) { continue }

    $destFile = Join-Path $OPENCODE_DIR $relPath
    $destDir = Split-Path $destFile -Parent
    if (-not (Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }

    Copy-Item $file.FullName $destFile -Force
    $copied++
    Write-Progress-Bar -Current $copied -Total $totalFiles -Label $relPath
}

Write-Progress -Activity "Installing Blueprint" -Completed
Write-Host ""
Write-Ok "Copied $copied files to .opencode/"

# Patch config
$configFile = Join-Path $OPENCODE_DIR "opencode.json"
if (Test-Path $configFile) {
    Write-Info "Configuring project path..."
    $content = Get-Content $configFile -Raw
    $content = $content -replace [regex]::Escape("/home/amid/Develop/opencode-secops-blueprint/"), "$TARGET_DIR/"
    $content | Set-Content $configFile -NoNewline
    Write-Ok "Project path set to: $TARGET_DIR"
} else {
    Write-Warn "opencode.json not found, skipping path patch."
}

# Cleanup
Remove-Item $tmpDir -Recurse -Force

# Post-install
Write-Host ""
Write-Host "========================================================" -ForegroundColor Green
Write-Host "  OpenCode SecOps Blueprint installed successfully!" -ForegroundColor Green
Write-Host "========================================================" -ForegroundColor Green
Write-Host ""
Write-Info "Next steps:"
Write-Host ""
Write-Host "  1. Set your GitHub token:"
Write-Host "     `$env:GITHUB_PERSONAL_ACCESS_TOKEN = `"your-pat-here`"" -ForegroundColor Cyan
Write-Host "     (Add to `$PROFILE for persistence)"
Write-Host ""
Write-Host "  2. Launch OpenCode in your project:"
Write-Host "     opencode" -ForegroundColor Cyan
Write-Host ""
Write-Host "  3. Run initialization:"
Write-Host "     /init" -ForegroundColor Cyan
Write-Host ""
Write-Info "Documentation: https://github.com/AmidVoshakul/opencode-secops-blueprint"
