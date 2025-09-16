param(
    [int]$Threads = 1,
    [int]$Ramp = 1,
    [int]$Loops = 1
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $root

function Wait-ForUrl {
    param([string]$Url, [int]$TimeoutSec = 30)
    $sw = [Diagnostics.Stopwatch]::StartNew()
    Write-Host "Waiting for $Url (timeout ${TimeoutSec}s)..."
    while ($sw.Elapsed.TotalSeconds -lt $TimeoutSec) {
        try {
            $r = Invoke-WebRequest -Uri $Url -UseBasicParsing -Method Head -TimeoutSec 5 -ErrorAction Stop
            if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) { Write-Host "$Url is reachable"; return $true }
        } catch { Start-Sleep -Seconds 1 }
    }
    Write-Error "Timed out waiting for $Url"
    return $false
}

function Ensure-JMeter {
    # Try to find jmeter.bat on PATH, otherwise fallback to bundled copy in repo root
    $jm = $null
    $cmd = Get-Command jmeter.bat -ErrorAction SilentlyContinue
    if ($cmd) { $jm = $cmd.Source }
    if (-not $jm) {
        $bundled = Join-Path (Split-Path -Parent $root) 'apache-jmeter-5.6.3\bin\jmeter.bat'
        if (Test-Path $bundled) { $jm = $bundled; Write-Host "Using bundled JMeter at $bundled" }
    }
    if (-not $jm) { Write-Error "jmeter.bat not found on PATH and bundled JMeter not found. Install JMeter or place it at apache-jmeter-5.6.3\bin\jmeter.bat"; exit 2 }
    return $jm
}

function Ensure-JdbcJar {
    param([string]$JMeterBat)
    $localJar = Join-Path $root 'libs\sqlite-jdbc-3.36.0.3.jar'
    if (-not (Test-Path $localJar)) {
        Write-Error "JDBC jar not found at $localJar. Run .\download_sqlite_jdbc.sh (or download manually)"; exit 2
    }
    # determine jmeter lib
    $jmRoot = Split-Path -Parent (Split-Path -Parent $JMeterBat)
    $jmLib = Join-Path $jmRoot 'lib'
    if (Test-Path $jmLib) {
        try { Copy-Item -Path $localJar -Destination $jmLib -ErrorAction Stop -Force; Write-Host "Copied JDBC jar to $jmLib" } catch { Write-Warning "Could not copy JDBC jar to $jmLib; you may need to copy it manually" }
    } else { Write-Warning "JMeter lib directory not found at $jmLib; ensure the JDBC jar is on JMeter's classpath" }
}

function Ensure-DbInitialized {
    $db = Join-Path $root 'fullstack_sqlite.db'
    $schema = Join-Path $root 'schema.sql'
    if (-not (Test-Path $db) -or (Get-Item $db).Length -eq 0) {
        Write-Host "Initializing SQLite DB from schema.sql -> $db"
        $sqlite = Get-Command sqlite3.exe -ErrorAction SilentlyContinue
        if ($sqlite) {
            # use cmd.exe to run the redirection syntax
            $cmd = "sqlite3 `"$db`" < `"$schema`""
            cmd /c $cmd
        } else {
            Write-Warning "sqlite3 not found on PATH. The DB will not be auto-initialized. You can create it manually or start the app which may create it." 
        }
    }
}

Write-Host "Starting fullstack_sqlite app..."
Start-Process -NoNewWindow -FilePath pipenv -ArgumentList 'run python app.py' -RedirectStandardOutput fullstack_sqlite_app.log -RedirectStandardError fullstack_sqlite_app.log
Start-Sleep -Seconds 1

$jm = Ensure-JMeter
Ensure-JdbcJar -JMeterBat $jm
Ensure-DbInitialized

if (-not (Wait-ForUrl -Url 'http://localhost:5004/' -TimeoutSec 30)) { Write-Error 'fullstack_sqlite app did not become available in time'; exit 2 }

Write-Host "Running JMeter (non-GUI)..."
$plan = Join-Path $root 'fullstack_sqlite_test_plan.jmx'
$jtl = Join-Path $root 'fullstack_sqlite_non_gui_result.jtl'
$jlog = Join-Path $root 'fullstack_sqlite_jmeter.log'
& $jm -n -t $plan -l $jtl -j $jlog -Jthreads=$Threads -Jramp=$Ramp -Jloops=$Loops

if (-not (Test-Path $jtl) -or ((Get-Content $jtl -ErrorAction SilentlyContinue).Length -le 1)) { Write-Warning "JTL file is empty or missing; skipping HTML report generation"; Pop-Location; exit 0 }

$report = Join-Path $root 'fullstack_sqlite_report'
if (Test-Path $report) { Remove-Item -Recurse -Force $report }
New-Item -ItemType Directory -Path $report | Out-Null
& $jm -g $jtl -o $report

Write-Host "Report: $(Join-Path $report 'index.html')"
Pop-Location
