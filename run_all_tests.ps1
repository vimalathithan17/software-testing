<#
.SYNOPSIS
  Start both demo Flask apps, run non-GUI JMeter tests, then stop apps.

.DESCRIPTION
  This script is a Windows PowerShell equivalent of `run_all_tests.sh`.
  It expects Python available on PATH and JMeter (jmeter.bat) on PATH or accessible.

.NOTES
  Run from the repository root in an elevated or normal PowerShell prompt:
    PS> .\run_all_tests.ps1
#>

param(
    [switch]$Help
)

if ($Help) {
    Write-Output "Usage: .\run_all_tests.ps1"
    Write-Output "Starts bookstore and food_ordering apps, runs the non-GUI JMeter tests, and stops the apps."
    exit 0
}

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Split-Path -Path $PSScriptRoot -Parent
if (-not $root) { $root = Get-Location }
$bookDir = Join-Path $root 'bookstore'
$foodDir = Join-Path $root 'food_ordering'

function Test-JMeter {
    if (Get-Command jmeter.bat -ErrorAction SilentlyContinue) { return $true }
    if (Get-Command jmeter -ErrorAction SilentlyContinue) { return $true }
    return $false
}

if (-not (Test-JMeter)) {
    Write-Error "jmeter not found on PATH. Ensure JMeter is installed and jmeter.bat (or jmeter) is available on PATH."
    exit 2
}

Write-Output "Starting bookstore app (background)..."
$bookProc = Start-Process -FilePath python -ArgumentList 'app.py' -WorkingDirectory $bookDir -PassThru
Write-Output "Bookstore PID: $($bookProc.Id)"

Write-Output "Starting food_ordering app (background)..."
$foodProc = Start-Process -FilePath python -ArgumentList 'app.py' -WorkingDirectory $foodDir -PassThru
Write-Output "Food PID: $($foodProc.Id)"

# give apps a moment to start
Start-Sleep -Seconds 2

try {
    Write-Output "Running bookstore JMeter test (non-GUI)..."
    Push-Location $bookDir
    if (Get-Command jmeter.bat -ErrorAction SilentlyContinue) {
        & jmeter.bat -n -t "$bookDir\bookstore_test_plan.jmx" -l "$bookDir\bookstore_non_gui_result.jtl" -j "$bookDir\jmeter.log"
    }
    else { & jmeter -n -t "$bookDir\bookstore_test_plan.jmx" -l "$bookDir\bookstore_non_gui_result.jtl" -j "$bookDir\jmeter.log" }
    Pop-Location

    Write-Output "Running food_ordering JMeter test (non-GUI)..."
    Push-Location $foodDir
    if (Get-Command jmeter.bat -ErrorAction SilentlyContinue) {
        & jmeter.bat -n -t "$foodDir\food_test_plan.jmx" -l "$foodDir\food_non_gui_result.jtl" -j "$foodDir\jmeter.log"
    } else { & jmeter -n -t "$foodDir\food_test_plan.jmx" -l "$foodDir\food_non_gui_result.jtl" -j "$foodDir\jmeter.log" }
    Pop-Location
}
finally {
    Write-Output "Stopping apps..."
    if ($bookProc -and $bookProc.Id) { Stop-Process -Id $bookProc.Id -ErrorAction SilentlyContinue }
    if ($foodProc -and $foodProc.Id) { Stop-Process -Id $foodProc.Id -ErrorAction SilentlyContinue }
}

Write-Output "Done. Reports (check these paths):"
Write-Output "  $bookDir\bookstore_non_gui_result.jtl"
Write-Output "  $foodDir\food_non_gui_result.jtl"
