# Fix-Codex.ps1
# Quick recovery for Codex Desktop when it is stuck on the loading spinner.

$ErrorActionPreference = "SilentlyContinue"

Write-Host "Fixing Codex..." -ForegroundColor Cyan

# 1) Stop the stuck Codex backend process.
$codex = Get-Process -Name "codex" -ErrorAction SilentlyContinue
if ($codex) {
    Stop-Process -Name "codex" -Force
    Write-Host "Stopped stuck Codex backend." -ForegroundColor Yellow
} else {
    Write-Host "No Codex backend process was running." -ForegroundColor DarkGray
}

# 2) Give the desktop app a moment to restart the backend automatically.
Start-Sleep -Seconds 5

if (Get-Process -Name "codex" -ErrorAction SilentlyContinue) {
    Write-Host "Codex backend restarted successfully." -ForegroundColor Green
    Write-Host "Return to the Codex window." -ForegroundColor Green
    Start-Sleep -Seconds 2
    exit 0
}

# 3) If it did not restart automatically, launch the Codex app from Start Menu registration.
$app = Get-StartApps | Where-Object { $_.Name -match "Codex" } | Select-Object -First 1

if ($app) {
    Write-Host "Restarting Codex Desktop..." -ForegroundColor Yellow
    Start-Process "explorer.exe" "shell:AppsFolder\$($app.AppID)"
    Start-Sleep -Seconds 3
    Write-Host "Done." -ForegroundColor Green
} else {
    Write-Host "Could not find Codex in the Start menu." -ForegroundColor Red
    Write-Host "Please open Codex manually." -ForegroundColor Yellow
}

Start-Sleep -Seconds 2
