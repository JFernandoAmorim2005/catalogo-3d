<#
.SYNOPSIS
Backup/Restore catalog files to/from AWS S3

.PARAMETER Mode
"backup" to upload to S3, "restore" to download from S3
#>

param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("backup", "restore")]
    [string]$Mode = "backup"
)

# Configuration
$bucketName = "jfa-backup-catalogo-3d"
$region = "eu-west-1"  # Ireland
$backupPrefix = "catalogo-3d-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"

function Test-AWSCli {
    try {
        aws --version | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Backup-To-S3 {
    Write-Host "Starting backup to S3..." -ForegroundColor Cyan
    
    # Key directories and files to backup
    $itemsToBackup = @(
        "img/",
        "data/coverage.json",
        "index.html",
        "*.html"
    )
    
    foreach ($item in $itemsToBackup) {
        Write-Host "Uploading: $item" -ForegroundColor Yellow
        
        if ($item -like "*/" -or (Test-Path -PathType Container $item)) {
            # Directory
            aws s3 sync $item "s3://$bucketName/$backupPrefix/$item" `
                --region $region `
                --include "*"
        } else {
            # File(s)
            $files = Get-Item $item -ErrorAction SilentlyContinue
            foreach ($file in $files) {
                aws s3 cp $file.FullName "s3://$bucketName/$backupPrefix/$($file.Name)" `
                    --region $region
            }
        }
    }
    
    Write-Host "Backup complete! Stored in: s3://$bucketName/$backupPrefix/" -ForegroundColor Green
}

function Restore-From-S3 {
    param(
        [string]$RestorePrefix = $backupPrefix
    )
    
    Write-Host "Starting restore from S3..." -ForegroundColor Cyan
    Write-Host "Restore point: $RestorePrefix" -ForegroundColor Yellow
    
    # Create backup of current state
    $localBackup = "backup-$(Get-Date -Format 'yyyy-MM-dd-HH-mm-ss')"
    New-Item -ItemType Directory -Path $localBackup -Force | Out-Null
    Copy-Item -Path "img/" -Destination "$localBackup/" -Recurse -Force
    Copy-Item -Path "data/coverage.json" -Destination "$localBackup/" -Force
    Write-Host "Current state backed up to: $localBackup" -ForegroundColor Green
    
    # Download from S3
    aws s3 sync "s3://$bucketName/$RestorePrefix/" . `
        --region $region `
        --delete
    
    Write-Host "Restore complete!" -ForegroundColor Green
    Write-Host "Previous state saved in: $localBackup/" -ForegroundColor Yellow
}

# Main execution
if (-not (Test-AWSCli)) {
    Write-Host "AWS CLI not found. Please install it first: https://aws.amazon.com/cli/" -ForegroundColor Red
    exit 1
}

Write-Host "Catalog S3 Backup Manager" -ForegroundColor Cyan
Write-Host "Mode: $Mode" -ForegroundColor Yellow

switch ($Mode) {
    "backup" { Backup-To-S3 }
    "restore" { Restore-From-S3 }
}
