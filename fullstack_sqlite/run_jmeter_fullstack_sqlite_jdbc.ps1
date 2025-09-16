param(
    [int]$Threads = 1,
    [int]$Ramp = 1,
    [int]$Loops = 1
)

$root = Split-Path -Parent $MyInvocation.MyCommand.Definition
Push-Location $root

function Ensure-JMeter {
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

function Ensure-LocalJarHasDriver {
    param([string]$JarPath)
    if (-not (Test-Path $JarPath)) { Write-Error "JDBC jar not found at $JarPath. Run .\download_sqlite_jdbc.sh"; exit 2 }
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem -ErrorAction SilentlyContinue
        $zip = [System.IO.Compression.ZipFile]::OpenRead($JarPath)
        $found = $false
        foreach ($entry in $zip.Entries) {
            if ($entry.FullName -eq 'org/sqlite/JDBC.class') { $found = $true; break }
        }
        $zip.Dispose()
        if (-not $found) { Write-Error "Jar does not contain org/sqlite/JDBC.class; the driver appears invalid"; exit 2 }
    } catch {
        Write-Warning "Could not inspect jar contents ($_). Proceeding but the JDBC class load may fail at runtime." 
    }
}

function Ensure-DbInitialized {
    $db = Join-Path $root 'fullstack_sqlite.db'
    $schema = Join-Path $root 'schema.sql'
    if (-not (Test-Path $db) -or (Get-Item $db).Length -eq 0) {
        Write-Host "Initializing SQLite DB from schema.sql -> $db"
        $sqlite = Get-Command sqlite3.exe -ErrorAction SilentlyContinue
        if ($sqlite) {
            $cmd = "sqlite3 `"$db`" < `"$schema`""
            cmd /c $cmd
        } else {
            Write-Warning "sqlite3 not found on PATH. The DB will not be auto-initialized. You can create it manually or start the app which may create it." 
        }
    }
}

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

$jm = Ensure-JMeter
$localJar = Join-Path $root 'libs\sqlite-jdbc-3.36.0.3.jar'
Ensure-LocalJarHasDriver -JarPath $localJar

# copy jar into JMeter lib (best-effort, no-clobber)
$jmRoot = Split-Path -Parent (Split-Path -Parent $jm)
$jmLib = Join-Path $jmRoot 'lib'
if (Test-Path $jmLib) {
    $destJar = Join-Path $jmLib (Split-Path $localJar -Leaf)
    if (-not (Test-Path $destJar)) {
        try { Copy-Item -Path $localJar -Destination $jmLib -ErrorAction Stop; Write-Host "Copied JDBC jar to $jmLib" } catch { Write-Warning "Could not copy JDBC jar to $jmLib; you may need to copy it manually" }
    } else { Write-Host "JDBC jar already present in $jmLib; skipping copy" }
} else { Write-Warning "JMeter lib directory not found at $jmLib; ensure the JDBC jar is on JMeter's classpath" }

Ensure-DbInitialized

# Wait for the app to be up (if you want to run the app first, otherwise skip)
if (-not (Wait-ForUrl -Url 'http://localhost:5004/' -TimeoutSec 30)) { Write-Warning 'App not reachable; continuing to attempt JDBC run (DB may be local file)'; }

$plan = Join-Path $root 'fullstack_sqlite_jdbc_test.jmx'
$jtl = Join-Path $root 'fullstack_sqlite_jdbc_result.jtl'
$jlog = Join-Path $root 'jmeter_jdbc.log'

if (Test-Path $jtl) { Remove-Item $jtl -Force }

Write-Host "Running JDBC JMeter test: $plan"

# Pre-check: ensure the JVM used by JMeter can load org.sqlite.JDBC
function Test-JdbcClassLoad {
    param([string]$JMeterBat, [string]$LocalJar)
    if (-not (Get-Command java -ErrorAction SilentlyContinue)) { Write-Error "java not found on PATH; required to verify JDBC driver can be loaded."; return $false }
    $jmRoot = Split-Path -Parent (Split-Path -Parent $JMeterBat)
    $jmLib = Join-Path $jmRoot 'lib'
    $cp = $LocalJar
    if (Test-Path $jmLib) { $cp = Join-Path $jmLib '*;' + $LocalJar }
    # run a tiny Java program to attempt Class.forName
    $javaCmd = "java -cp `"$cp`" -Xmx64m -Djava.awt.headless=true CheckJdbc"
    $tmp = [IO.Path]::GetTempFileName()
    $src = @'
public class CheckJdbc { public static void main(String[] args) { try { Class.forName("org.sqlite.JDBC"); System.out.println("OK"); } catch(Throwable t) { t.printStackTrace(System.err); System.exit(2);} } }
'@
    $javaFile = [IO.Path]::ChangeExtension($tmp,'.java')
    Set-Content -Path $javaFile -Value $src -Encoding UTF8
    $javac = Get-Command javac -ErrorAction SilentlyContinue
    if ($javac) {
        & javac $javaFile 2>$null
        if ($LASTEXITCODE -ne 0) { Write-Warning "javac failed; cannot perform class-load check. Proceeding."; return $true }
        $classFile = [IO.Path]::ChangeExtension($javaFile,'.class')
        $run = & java -cp "${cp};." CheckJdbc 2>&1
        Remove-Item -Force $javaFile, $classFile
        if ($LASTEXITCODE -eq 0) { Write-Host "JDBC driver class loaded successfully"; return $true } else { Write-Error "JDBC driver class could not be loaded: $run"; return $false }
    } else {
        Write-Warning "javac not found; cannot compile runtime class check. Attempting runtime java execution without compilation..."
        $run = & java -cp "$cp" -e 2>&1
        Write-Warning "Skipping strict class-load test; ensure the sqlite JDBC jar is on JMeter's lib classpath"; return $true
    }
}

if (-not (Test-JdbcClassLoad -JMeterBat $jm -LocalJar $localJar)) { Write-Error "JDBC driver not loadable in JVM; aborting."; Pop-Location; exit 2 }

& $jm -n -t $plan -l $jtl -j $jlog -Jthreads=$Threads -Jramp=$Ramp -Jloops=$Loops

if (-not (Test-Path $jtl) -or ((Get-Content $jtl -ErrorAction SilentlyContinue).Length -le 1)) { Write-Warning "JTL file $jtl is empty or missing; skipping HTML report generation"; Pop-Location; exit 0 }

$report = Join-Path $root 'fullstack_sqlite_jdbc_report'
if (Test-Path $report) { Remove-Item -Recurse -Force $report }
New-Item -ItemType Directory -Path $report | Out-Null
& $jm -g $jtl -o $report

Write-Host "JDBC DB test complete. Results: $jtl. HTML report: $(Join-Path $report 'index.html')"
Pop-Location
