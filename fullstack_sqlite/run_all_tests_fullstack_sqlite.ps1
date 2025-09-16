param(
    [int]$Threads = 1,
    [int]$Ramp = 1,
    [int]$Loops = 1
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $root

Write-Host "Starting fullstack_sqlite app..."
Start-Process -NoNewWindow -FilePath pipenv -ArgumentList 'run python fullstack_sqlite\app.py' -RedirectStandardOutput fullstack_sqlite_app.log -RedirectStandardError fullstack_sqlite_app.log
Start-Sleep -Seconds 3

$jm = 'jmeter.bat'
Write-Host "Running JMeter..."
& $jm -n -t (Join-Path $root 'fullstack_sqlite\fullstack_sqlite_test_plan.jmx') -l (Join-Path $root 'fullstack_sqlite\fullstack_sqlite_non_gui_result.jtl') -j (Join-Path $root 'fullstack_sqlite\fullstack_sqlite_jmeter.log') -Jthreads=$Threads -Jramp=$Ramp -Jloops=$Loops

Write-Host "Report: $(Join-Path $root 'fullstack_sqlite\fullstack_sqlite_report\index.html')"
Pop-Location
