<#
.SYNOPSIS
    Real-time process monitoring for suspicious or high-resource processes.

.DESCRIPTION
    This script monitors running processes, detects unusual CPU or memory usage,
    flags suspicious process names, and logs all alerts for defensive analysis.

.NOTES
    Author: secwexen
    Script: Monitor-Processes.ps1
#>

$LogFile = "C:\computer-name\logs\process_monitor.log"
$SuspiciousNames = @("mimikatz", "meterpreter", "cobalt", "beacon", "powersploit", "keylogger")

# Ensure log directory exists
$logDir = Split-Path $LogFile
if (-not (Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir | Out-Null
}

function Write-Log {
    param([string]$Message)

    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
    $entry = "[$timestamp] $Message"

    Write-Host $entry
    Add-Content -Path $LogFile -Value $entry
}

Write-Log "[+] Starting process monitor..."
Write-Log "    Log file: $LogFile"

while ($true) {
    $processes = Get-Process | Sort-Object CPU -Descending

    foreach ($proc in $processes) {
        # High CPU usage
        if ($proc.CPU -gt 50) {
            Write-Log "[!] High CPU usage detected: $($proc.ProcessName) - CPU: $([math]::Round($proc.CPU,2))"
        }

        # High memory usage
        if ($proc.WorkingSet64 -gt 500MB) {
            Write-Log "[!] High memory usage detected: $($proc.ProcessName) - RAM: $([math]::Round($proc.WorkingSet64/1MB,2)) MB"
        }

        # Suspicious process names
        foreach ($name in $SuspiciousNames) {
            if ($proc.ProcessName -match $name) {
                Write-Log "[!] Suspicious process detected: $($proc.ProcessName)"
            }
        }
    }

    Start-Sleep -Seconds 5
}
