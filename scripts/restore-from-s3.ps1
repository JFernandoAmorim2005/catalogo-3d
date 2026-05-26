<#
.SYNOPSIS
Restore from S3 Backup
Recovers project files from S3 backup (git bundle or tar.gz snapshot)

.DESCRIPTION
This script:
1. Lists available backups in S3 (daily and weekly)
2. Downloads selected backup
3. Restores either via git bundle or tar.gz extraction

.PARAMETER BucketName
S3 bucket name (default: jfa-backups)

.PARAMETER BackupType
Type of backup to restore: 'daily' (git bundle) or 'weekly' (tar.gz snapshot)

.PARAMETER Date
Date of backup to restore (format: YYYYMMDD or YYYYMMDD-HHMMSS)

.EXAMPLE
.\restore-from-s3.ps1 -BackupType daily -Date 20260615-143020
.\restore-from-s3.ps1 -BackupType weekly -Date 20260615
#>

param(
    [string]$BucketName = 'jfa-backups',
    [ValidateSet('daily', 'weekly')]
    [string]$BackupType = 'daily',
    [string]$Date
)

# Ensure AWS CLI is available
try {
    $null = aws --version
}
catch {
    Write-Error "AWS CLI not found. Install it or configure AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY."
    exit 1
}

Write-Host "=== S3 Backup Restore ===" -ForegroundColor Cyan
Write-Host ""

# List available backups
Write-Host "Listing available $BackupType backups..." -ForegroundColor Yellow
$s3Path = "s3://$BucketName/$BackupType/"

try {
    $backups = aws s3 ls $s3Path | Select-Object -ExpandProperty Split | Where-Object { $_ -match '^\d+' }

    if ($backups.Count -eq 0) {
        Write-Host "No backups found in $s3Path" -ForegroundColor Red
        exit 1
    }

    Write-Host ""
    Write-Host "Available backups:" -ForegroundColor Green
    $backups | ForEach-Object { Write-Host "  $_" }
    Write-Host ""
}
catch {
    Write-Error "Failed to list S3 backups: $_"
    exit 1
}

# If no date specified, use latest
if (-not $Date) {
    $Date = $backups[-1] -replace '.*backup-', '' -replace '\.(bundle|tar\.gz)', ''
    Write-Host "Using latest backup: $Date" -ForegroundColor Green
}

# Determine file extension based on backup type
$fileExt = if ($BackupType -eq 'daily') { '.bundle' } else { '.tar.gz' }
$fileName = "backup-$Date$fileExt"

Write-Host ""
Write-Host "Restoring: $fileName" -ForegroundColor Yellow

# Download backup from S3
$localFileName = Join-Path $env:TEMP $fileName
Write-Host "Downloading from S3..." -ForegroundColor Gray

try {
    aws s3 cp "$s3Path$fileName" $localFileName
    Write-Host "Downloaded to: $localFileName" -ForegroundColor Green
}
catch {
    Write-Error "Failed to download backup: $_"
    exit 1
}

Write-Host ""
Write-Host "Restore options:" -ForegroundColor Cyan
Write-Host "  1) Restore via git bundle (merges changes)"
Write-Host "  2) Restore via tar.gz extraction (full replacement)"
Write-Host "  3) Cancel"
Write-Host ""
Write-Host "Choose (1-3): " -NoNewline -ForegroundColor Yellow
$choice = Read-Host

if ($choice -eq '1' -and $BackupType -eq 'daily') {
    Write-Host ""
    Write-Host "Restoring from git bundle..." -ForegroundColor Cyan
    Write-Host "This will merge the backup into your current git repository."
    Write-Host "Confirm? (y/n): " -NoNewline -ForegroundColor Yellow
    $confirm = Read-Host

    if ($confirm -eq 'y') {
        try {
            # Create temporary bundle clone
            $tempDir = Join-Path $env:TEMP "git-bundle-temp-$([System.Guid]::NewGuid())"
            New-Item $tempDir -ItemType Directory -ErrorAction Stop | Out-Null

            git clone --bare $localFileName $tempDir

            # Fetch from bundle
            git fetch $tempDir refs/*:refs/*

            Write-Host "Git bundle restored successfully." -ForegroundColor Green
            Write-Host "Review changes with: git log --oneline"
        }
        catch {
            Write-Error "Failed to restore git bundle: $_"
        }
    }
}
elseif ($choice -eq '2') {
    Write-Host ""
    Write-Host "Restoring from tar.gz snapshot..." -ForegroundColor Cyan
    Write-Host "This will extract the backup to the current directory."
    Write-Host "WARNING: This may overwrite existing files."
    Write-Host "Confirm? (y/n): " -NoNewline -ForegroundColor Red
    $confirm = Read-Host

    if ($confirm -eq 'y') {
        try {
            # Create backup of current state
            $backupName = "pre-restore-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss').tar.gz"
            Write-Host "Creating backup of current state: $backupName" -ForegroundColor Gray
            tar czf $backupName --exclude=node_modules --exclude=.git --exclude=.github .
            Write-Host "Backup saved to: $backupName" -ForegroundColor Green

            # Extract backup
            Write-Host "Extracting snapshot..." -ForegroundColor Gray
            tar xzf $localFileName

            Write-Host "Snapshot restored successfully." -ForegroundColor Green
            Write-Host "Previous state backed up to: $backupName" -ForegroundColor Green
        }
        catch {
            Write-Error "Failed to restore tar.gz snapshot: $_"
        }
    }
}
else {
    Write-Host "Cancelled." -ForegroundColor Yellow
}

# Cleanup
Write-Host ""
Write-Host "Cleaning up temporary files..." -ForegroundColor Gray
Remove-Item $localFileName -ErrorAction SilentlyContinue
Write-Host "Done." -ForegroundColor Green
