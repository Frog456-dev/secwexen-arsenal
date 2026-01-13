<#
.SYNOPSIS
    Creates timestamped backups of a target directory.

.DESCRIPTION
    This script compresses a specified directory into a .zip archive,
    stores it in a backup folder, and optionally removes old backups.

.PARAMETER SourcePath
    The directory to back up.

.PARAMETER BackupPath
    The directory where backups will be stored.

.PARAMETER RetentionDays
    Number of days to keep old backups.

.EXAMPLE
    .\Backup-Files.ps1 -SourcePath "C:\Secwexen" -BackupPath "C:\Backups" -RetentionDays 7
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$SourcePath,

    [Parameter(Mandatory = $true)]
    [string]$BackupPath,

    [int]$RetentionDays = 7
)

Write-Host "[+] Starting backup process..." -ForegroundColor Cyan

# Validate source directory
if (-not (Test-Path $SourcePath)) {
    Write-Host "[!] Source directory not found: $SourcePath" -ForegroundColor Red
    exit 1
}

# Create backup directory if missing
if (-not (Test-Path $BackupPath)) {
    Write-Host "[+] Creating backup directory..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Path $BackupPath | Out-Null
}

# Generate timestamped archive name
$Timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$ArchiveName = "backup_$Timestamp.zip"
$ArchivePath = Join-Path $BackupPath $ArchiveName

Write-Host "[+] Creating backup archive..."
Write-Host "    Source: $SourcePath"
Write-Host "    Output: $ArchivePath"

# Create ZIP archive
try {
    Compress-Archive -Path $SourcePath -DestinationPath $ArchivePath -Force
    Write-Host "[✓] Backup created successfully." -ForegroundColor Green
}
catch {
    Write-Host "[!] Backup failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Cleanup old backups
Write-Host "[+] Removing backups older than $RetentionDays days..."
$OldBackups = Get-ChildItem -Path $BackupPath -Filter "*.zip" | Where-Object {
    $_.LastWriteTime -lt (Get-Date).AddDays(-$RetentionDays)
}

foreach ($file in $OldBackups) {
    Remove-Item $file.FullName -Force
    Write-Host "    Deleted old backup: $($file.Name)"
}

Write-Host "[✓] Backup process completed." -ForegroundColor Green
