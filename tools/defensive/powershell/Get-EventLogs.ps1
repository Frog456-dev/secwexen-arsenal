<#
.SYNOPSIS
    Retrieves Windows Event Logs for security auditing.

.DESCRIPTION
    This script collects logs from Security, System, and Application channels.
    It supports optional date filtering and can export results to a log file.

.PARAMETER Days
    Number of past days to retrieve logs from.

.PARAMETER Output
    Optional output file to save the collected logs.

.EXAMPLE
    .\Get-EventLogs.ps1 -Days 1
    .\Get-EventLogs.ps1 -Days 7 -Output "C:\logs\events.txt"
#>

param(
    [int]$Days = 1,
    [string]$Output = ""
)

Write-Host "[+] Collecting Windows Event Logs..." -ForegroundColor Cyan
Write-Host "    Time Range: Last $Days day(s)"

# -----------------------------
# Helper: Write to console + file
# -----------------------------
function Write-Log {
    param([string]$Message)

    Write-Host $Message
    if ($Output -ne "") {
        Add-Content -Path $Output -Value $Message
    }
}

# -----------------------------
# Time Filter
# -----------------------------
$StartTime = (Get-Date).AddDays(-$Days)

# -----------------------------
# Log Channels to Collect
# -----------------------------
$Channels = @(
    "Security",
    "System",
    "Application"
)

Write-Log ""
Write-Log "===== Event Log Summary ====="

foreach ($Channel in $Channels) {
    Write-Log ""
    Write-Log "----- $Channel Logs -----"

    try {
        $Events = Get-WinEvent -FilterHashtable @{
            LogName = $Channel
            StartTime = $StartTime
        } -ErrorAction Stop

        if ($Events.Count -eq 0) {
            Write-Log "No events found."
            continue
        }

        foreach ($Event in $Events) {
            $msg = "[EventID: $($Event.Id)] [$($Event.TimeCreated)] $($Event.ProviderName) - $($Event.Message)"
            Write-Log $msg
        }
    }
    catch {
        Write-Log "[!] Failed to read $Channel logs: $($_.Exception.Message)"
    }
}

Write-Log ""
Write-Log "[✓] Event log collection completed."

if ($Output -ne "") {
    Write-Host "[+] Logs saved to: $Output" -ForegroundColor Green
}
