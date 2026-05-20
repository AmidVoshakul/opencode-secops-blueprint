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

# Copy .gitignore.template to project root
$templateSrc = Join-Path $cloneDest ".gitignore.template"
$templateDest = Join-Path $TARGET_DIR ".gitignore.template"
if (Test-Path $templateSrc) {
    Copy-Item $templateSrc $templateDest -Force
    Write-Info "Copied .gitignore.template"
}

# Configure .gitignore
$gitignore = Join-Path $TARGET_DIR ".gitignore"
if (-not (Test-Path $gitignore)) {
    if (Test-Path $templateDest) {
        Copy-Item $templateDest $gitignore
        Write-Ok "Created .gitignore from template"
    }
} else {
    $gitContent = Get-Content $gitignore -Raw
    if ($gitContent -notmatch '^\.opencode/') {
        Add-Content -Path $gitignore -Value "`n# OpenCode local config (contains tokens)`n.opencode/"
        Write-Info "Added .opencode/ to .gitignore"
    }
}

# Patch config
$configFile = Join-Path $OPENCODE_DIR "opencode.json"
if (Test-Path $configFile) {
    Write-Info "Configuring project path..."
    $content = Get-Content $configFile -Raw
    $content = $content -replace "__PROJECT_PATH__", "$TARGET_DIR/"
    $content | Set-Content $configFile -NoNewline
    Write-Ok "Project path set to: $TARGET_DIR"
} else {
    Write-Warn "opencode.json not found, skipping path patch."
}

function Get-FilesystemPath {
    $fsPath = $env:FILESYSTEM_PATH

    if ($fsPath) {
        Write-Info "Using path from `$env:FILESYSTEM_PATH environment variable."
    } else {
        Write-Host ""
        $fsPath = Read-Host "Enter filesystem root path for MCP access (or set `$env:FILESYSTEM_PATH)"
        if (-not $fsPath) {
            Write-Warn "No path provided. You can configure it later in .opencode/opencode.json"
            return
        }
    }

    if (-not (Test-Path $fsPath -PathType Container)) {
        Write-Warn "Directory '$fsPath' does not exist. You can fix it later in .opencode/opencode.json"
        return
    }

    Write-Ok "Filesystem path set to: $fsPath"

    $configFile = Join-Path $OPENCODE_DIR "opencode.json"
    if (Test-Path $configFile) {
        $content = Get-Content $configFile -Raw
        $content = $content -replace "__FILESYSTEM_PATH__", $fsPath
        $content | Set-Content $configFile -NoNewline
        Write-Ok "Filesystem path configured in opencode.json"
    }
}

function Get-GitHubToken {
    $token = $env:GITHUB_PERSONAL_ACCESS_TOKEN

    if ($token) {
        Write-Info "Using token from `$env:GITHUB_PERSONAL_ACCESS_TOKEN environment variable."
    } else {
        Write-Host ""
        $token = Read-Host "Enter GitHub Personal Access Token (or set `$env:GITHUB_PERSONAL_ACCESS_TOKEN)"
        if (-not $token) {
            Write-Warn "No token provided. You can configure it later in .opencode/opencode.json"
            return
        }
    }

    Write-Info "Validating GitHub token..."
    try {
        $headers = @{ "Authorization" = "token $token" }
        $response = Invoke-WebRequest -Uri "https://api.github.com/user" -Headers $headers -Method Get -UseBasicParsing -TimeoutSec 10

        if ($response.StatusCode -eq 200) {
            $user = $response.Content | ConvertFrom-Json
            $login = $user.login
            Write-Ok "Token valid (user: $login)"

            $configFile = Join-Path $OPENCODE_DIR "opencode.json"
            if (Test-Path $configFile) {
                $content = Get-Content $configFile -Raw
                $content = $content -replace "__GITHUB_TOKEN__", $token
                $content | Set-Content $configFile -NoNewline
                Write-Ok "GitHub token configured in opencode.json"
            }
        } else {
            Write-Warn "Token validation failed (HTTP $($response.StatusCode)). You can fix it later in .opencode/opencode.json"
        }
    } catch {
        Write-Warn "Token validation failed: $($_.Exception.Message). You can fix it later in .opencode/opencode.json"
    }
}

Get-GitHubToken

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
Write-Host "  1. Launch OpenCode in your project:"
Write-Host "     opencode" -ForegroundColor Cyan
Write-Host ""
Write-Host "  2. Run initialization:"
Write-Host "     /init" -ForegroundColor Cyan
Write-Host ""
Write-Info "Install skills: npx antigravity-awesome-skills --path .opencode/skills"
Write-Info "Documentation: https://github.com/AmidVoshakul/opencode-secops-blueprint"
