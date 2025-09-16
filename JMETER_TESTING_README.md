# JMeter testing — setup and how-to

This guide walks through setting up the environment (using pipenv), installing JMeter (Linux & Windows), running the two demo web apps (Bookstore and Food Ordering), and creating/executing JMeter test plans both in GUI and non-GUI modes. It also explains the structure and features of the two demo apps included in this repository and how to use the provided test plans and scripts.

If you renamed the `jmeter_bookstore` folder to `bookstore`, substitute `bookstore` where appropriate. Some paths in this repo may still use `jmeter_bookstore` — adjust accordingly.

## Prerequisites

- Python 3.10+ (Pipfile requires 3.12 but Python 3.10+ is fine for the demo).
- pipenv (recommended) for installing Python dependencies.
- Java 11+ (required for JMeter).
- JMeter (downloaded and extracted).

## 1) Set up Python environment with pipenv

From the repository root run:

```bash
# install pipenv if you don't have it
pip install --user pipenv

# install packages defined in Pipfile (this repo has Flask + dev dependencies)
pipenv install --dev

# open a shell with the virtual environment active
pipenv shell
```

Inside the pipenv shell you can run the Flask apps. The apps create their own SQLite DB files on first run (or you can manually run the small init scripts provided).

To create/seed the DBs without running Flask (optional):

```bash
python bookstore/init_db.py      # creates bookstore.db (or jmeter_bookstore/init_db.py)
python food_ordering/init_db.py  # creates food.db
```

Run the apps (in separate terminals or background processes):

```bash
# Bookstore app
cd bookstore        # or jmeter_bookstore if you haven't renamed
python app.py       # listens on http://0.0.0.0:5001

# Food ordering app (different terminal)
cd ../food_ordering
python app.py       # listens on http://0.0.0.0:5002
```

Verify the apps by opening in a browser:

- Bookstore: http://localhost:5001
- Food ordering: http://localhost:5002

## 2) Installing JMeter

JMeter requires Java. The following covers Linux and Windows.

Linux (Ubuntu/Debian example)

```bash
# install Java (OpenJDK 11)
sudo apt update
sudo apt install -y openjdk-11-jdk

# download JMeter (change version if needed)
wget https://downloads.apache.org/jmeter/binaries/apache-jmeter-5.6.3.tgz
tar -xzf apache-jmeter-5.6.3.tgz
# optional: add to PATH
export PATH="$PATH:$(pwd)/apache-jmeter-5.6.3/bin"
# verify
jmeter -v
```

Windows

1. Install Java (OpenJDK or Oracle JDK 11+). Make sure JAVA_HOME is set and `java` is on PATH.
2. Download the JMeter binary ZIP from https://jmeter.apache.org/ and extract it.
3. Run JMeter GUI by double-clicking `bin\\jmeter.bat` or run from CMD:

```cmd
cd \path\to\apache-jmeter-5.6.3\bin
jmeter.bat
```

Verify on either OS with:

```bash
jmeter -v
```

## 3) Project structure & features

Top-level folders relevant for JMeter testing:

- `bookstore/` (was `jmeter_bookstore`):
  - `app.py` — Flask app providing Home, Register, Login, Catalogue pages.
  - `init_db.py` — standalone DB init script (creates `bookstore.db`).
  - `bookstore_test_plan.jmx` — JMeter test plan exercising register/login/catalogue.
  - `bookstore_users.csv` — sample users used by the JMeter CSV Data Set Config.
  - `run_jmeter_bookstore.sh` — convenience script to run the JMeter plan in non-GUI mode.
  - `sample_results.jtl` — example JTL results file.

- `food_ordering/`:
  - `app.py` — Flask app implementing Home, Register, Login, Menu, Order (coupon), Payment, Success.
  - `init_db.py` — standalone DB init script (creates `food.db`).
  - `food_test_plan.jmx` — JMeter test plan for the order flow.
  - `food_users.csv` — CSV of usernames/coupons used by the test plan.
  - `run_jmeter_food.sh` — convenience script to run the food test plan non-GUI.
  - `sample_results.jtl` — sample results file.

Features
- Bookstore app: supports user registration and login (stored in SQLite), and shows a catalogue of books from SQLite.
- Food ordering app: supports registration/login, viewing a menu from SQLite, ordering an item with an optional coupon code `FOOD10` (10% off), and a simulated payment redirect to success.

Both apps are intentionally minimal and suitable for local load testing.

## 4) How the provided JMeter test plans are structured

- Each test plan contains:
  - A Thread Group that controls concurrency (number of virtual users and ramp-up).
  - HTTP Request samplers for the different endpoints (GET /, GET /catalogue or /menu, POST /register, POST /login, POST /order, POST /pay).
  - A CSV Data Set Config that provides username/password (and coupon for the food test) variables to the samplers.

The CSV files are used in the test plans so each virtual user can use different credentials and coupons.

## 5) Create or edit a Test Plan (GUI) — step-by-step

1. Start the application(s) you want to load test (see commands above). Make sure the target URLs/ports in the JMeter plan match (bookstore: 5001, food: 5002).

2. Start JMeter GUI:

```bash
jmeter      # or run jmeter.bat on Windows
```

3. Open an existing test plan (`File -> Open`) or create a new Test Plan.

4. Add a Thread Group (Right click Test Plan -> Add -> Threads (Users) -> Thread Group).
   - Set Number of Threads (users), Ramp-Up, Loop Count.

5. Add a CSV Data Set Config (to feed credentials):
   - Right click Thread Group -> Add -> Config Element -> CSV Data Set Config.
   - Filename: enter the full path or a path relative to the project (e.g., `bookstore/bookstore_users.csv`).
   - Variable Names: `username,password` or `username,password,coupon` for food.
   - Set Recycle on EOF = True, Stop thread on EOF = False.

6. Add HTTP Request Samplers for the pages/endpoints:
   - Right click Thread Group -> Add -> Sampler -> HTTP Request.
   - Set Server Name or IP: `localhost` and Port Number: `5001` or `5002`.
   - Set Path and Method. For POST requests, add Post Body or add Parameters under Body Data/Parameters.
   - For form fields, add parameters with names that match the HTML form (e.g., `username`, `password`).

7. Add listeners to view results:
   - Right click Thread Group -> Add -> Listener -> View Results Tree (good for debugging small runs).
   - Add Aggregate Report, Summary Report, or Graph Results for aggregated metrics.

8. Add Timers / Think Time (optional):
   - Right click Thread Group -> Add -> Timer -> Constant Timer or Uniform Random Timer.

9. Assertions (optional):
   - Right click an HTTP Request -> Add -> Assertions -> Response Assertion.
   - Use text or response code assertions to ensure test correctness.

10. Run the test in GUI by clicking the green Start button. Watch listeners for results.

Tips
- When debugging, run with a small number of threads (1–5) in GUI and use View Results Tree to inspect request/response.
- Use absolute file paths in CSV Data Set Config if you run JMeter from different working directories.

## 6) Run tests non-GUI (recommended for real load tests)

Non-GUI is faster and consumes fewer resources. Use the provided run scripts or run `jmeter` directly.


Provided convenience scripts (they auto-detect `jmeter` on PATH and will fall back to a bundled JMeter copy if present at `apache-jmeter-5.6.3/bin/jmeter`):

```bash
cd bookstore
./run_jmeter_bookstore.sh --threads 10 --ramp 5 --loops 1

cd ../food_ordering
./run_jmeter_food.sh --threads 5 --ramp 3 --loops 1
```

These run the included `.jmx` and write JTL result files (`*_non_gui_result.jtl`). By default the scripts also generate an HTML report directory next to the JTL (e.g. `bookstore/bookstore_report/` and `food_ordering/food_report/`).

There's also a convenience orchestrator `run_all_tests.sh` at the repo root which starts both Flask apps (under `pipenv run python` if a `Pipfile` is present), runs both JMeter plans, and stops the apps. It accepts global parameters which are forwarded to each test:

- `--threads N` — number of JMeter threads (virtual users)
- `--ramp R` — ramp-up time in seconds
- `--loops L` — loop count per thread

Example: run everything with a single virtual user, 1s ramp and 1 loop:

```bash
./run_all_tests.sh --threads 1 --ramp 1 --loops 1
```

You can also run JMeter directly (example):

```bash
jmeter -n -t /full/path/to/bookstore/bookstore_test_plan.jmx -l /tmp/bookstore_run.jtl -j /tmp/bookstore_jmeter.log -Jthreads=10 -Jramp=5 -Jloops=1
```

Passing properties to JMeter (useful to parameterize thread counts) works because the included test plans use JMeter property lookups such as `${__P(threads,10)}` and `${__P(ramp,5)}` and `${__P(loops,1)}`. When you call JMeter with `-Jthreads=...` (or `-Jramp=...`, `-Jloops=...`) those values override the defaults embedded in the JMX.

### Generating an HTML report from results

After a non-GUI run you can generate an HTML dashboard:

```bash
# create an empty directory for report output
rm -rf /tmp/jmeter-report || true
mkdir -p /tmp/jmeter-report

jmeter -g /tmp/bookstore_run.jtl -o /tmp/jmeter-report
# open /tmp/jmeter-report/index.html in a browser
```

Notes: the `-g` report generator requires a JTL produced with appropriate metrics. The default listeners produce sufficient data for the basic dashboard.

## 7) After the run — inspect results

- Open the `.jtl` files created by the run in JMeter GUI listeners: File -> Load in the View Results Tree / Aggregate Report.
- Use the generated HTML report (if created) for charts and tables.

## 8) Troubleshooting

- If JMeter reports connection refused, ensure the Flask app is running and listening on the expected port.
- If CSV variables are not substituted (empty), check the CSV Data Set Config path and that the CSV has enough lines for the number of threads (or enable recycling).
- If `jmeter` command is not found, ensure you added JMeter's `bin` directory to PATH or use the full path to `jmeter`/`jmeter.bat`.

### Common failure: 100% request failures in non-GUI runs

If you run the provided scripts and see many or 100% failures (JMeter summary shows Err: = total samples), common causes are:

- Flask app not running or listening on the expected port (bookstore default: 5001, food default: 5002). Start the app(s) first or adjust the port in `app.py` and the `.jmx`.
- CSV Data Set Config file path is incorrect (JMeter can't read the CSV used for credentials), which may cause malformed requests. Use absolute paths in the CSV Data Set Config or run the script from the plan's folder.
- Form fields in the JMeter POST samplers do not match the names expected by the Flask app (e.g., `username` vs `user`). Inspect the HTML forms in `templates/` and ensure the sampler parameters names match.

## New: fullstack_sqlite demo (SQLite-backed)

This repository now includes a small `fullstack_sqlite/` demo useful for DB-focused JMeter testing.

Contents:
- `fullstack_sqlite/app.py` — Flask to-do app (port 5004)
- `fullstack_sqlite/schema.sql` — SQLite schema
- `fullstack_sqlite/fullstack_sqlite_test_plan.jmx` — JMeter plan (uses CSV Data Set Config and property lookups)
- `fullstack_sqlite/tasks.csv` — small CSV used by the plan to provide different POST payloads
- `fullstack_sqlite/run_jmeter_fullstack_sqlite.sh` — non-GUI runner (Linux/macOS)
- `fullstack_sqlite/run_all_tests_fullstack_sqlite.ps1` — PowerShell helper for Windows
- `fullstack_sqlite/run_all_tests_fullstack_sqlite.bat` — CMD/BAT helper for Windows
- `fullstack_sqlite/download_sqlite_jdbc.sh` — downloads sqlite-jdbc 3.36.0.3 to `fullstack_sqlite/libs/`

How the plan uses CSV:
- The JMX includes a CSV Data Set Config pointing at `tasks.csv` (variable `text`). The POST sampler for `/api/tasks` uses `${text}` as the payload so each sample can post different text values.

Running the SQLite demo (quick):

Linux/macOS:
```bash
# start the app
pipenv run python fullstack_sqlite/app.py

# in another terminal run a quick test (1 thread)
./fullstack_sqlite/run_jmeter_fullstack_sqlite.sh --threads 1 --ramp 1 --loops 1
```

Windows (PowerShell):
```powershell
# start the app and run JMeter using the included PS helper
.\run_all_tests_fullstack_sqlite.ps1 -Threads 1 -Ramp 1 -Loops 1
```

Windows (CMD):
```cmd
run_all_tests_fullstack_sqlite.bat
```

Integration with top-level orchestrator:
- The repo root `run_all_tests.sh` has been updated to also start and run `fullstack_sqlite` along with the `bookstore` and `food_ordering` demos. Use the same global flags to control thread/ramp/loops for all tests:

```bash
./run_all_tests.sh --threads 1 --ramp 1 --loops 1
```

This will start three apps (bookstore on 5001, food on 5002, fullstack_sqlite on 5004), run each JMeter plan and generate reports under each folder.
- Firewall or network restrictions blocking connections between JMeter and the app.

How to debug quickly:

1. Verify the Flask apps are running and reachable with curl:

```bash
curl -i http://localhost:5001/    # bookstore home
curl -i http://localhost:5002/    # food_ordering home
```

2. Run a small test in JMeter GUI with 1 thread and a View Results Tree listener to inspect request/response payloads.

3. Ensure the CSV paths in the `.jmx` are correct. You can open the `.jmx` in a text editor and confirm the `filename` in the CSV Data Set Config is an absolute path or points to the CSV placed next to the JMX.

4. Use the included summarizer to get a quick CLI summary:

```bash
python3 tools/summary_jtl.py /full/path/to/bookstore/bookstore_non_gui_result.jtl
python3 tools/summary_jtl.py /full/path/to/food_ordering/food_non_gui_result.jtl
```

This prints total samples, failures, and average elapsed time.

## 9) Where to go next

- Add more realistic test data (large CSV of users) and configure ramp-up/threads for realistic load.
- Add assertions and timers to better simulate real user behavior and to verify server responses.
- Run distributed JMeter tests for higher load (master + workers).

If you'd like, I can:
- Add thread-group properties and an example of running with `-Jthreads` integrated into the provided scripts.
- Add a sample script that starts both Flask apps in the background (or via tmux) and runs a short non-GUI JMeter test, then generates the HTML dashboard.

---
End of guide.

## Additional: Windows non-GUI usage and viewing results without JMeter GUI

### Running JMeter non-GUI on Windows

On Windows you can run JMeter in non-GUI mode from `cmd` or PowerShell using `jmeter.bat`:

```cmd
cd C:\path\to\apache-jmeter-5.6.3\bin
jmeter.bat -n -t C:\full\path\to\bookstore_test_plan.jmx -l C:\temp\bookstore_run.jtl -j C:\temp\bookstore_jmeter.log
```

You can also generate an HTML report the same way (after the run):

```cmd
jmeter.bat -g C:\temp\bookstore_run.jtl -o C:\temp\jmeter-report
```

## Running the full workflow on Windows (PowerShell)

A PowerShell helper script is included: `run_all_tests.ps1`. To run it from PowerShell (repository root):

```powershell
# open an elevated or normal PowerShell in the repo root
.\run_all_tests.ps1
```

It starts both apps, runs the non-GUI JMeter tests (using `jmeter.bat` if available), and stops the apps. Use `.\\run_all_tests.ps1 -Help` for the script help.

If you prefer a simple Windows batch (`.bat`) snippet (CMD) that starts both apps in background and runs JMeter non-GUI, here is an example you can adapt. Save as `run_all_tests.bat` in the repo root and run from a CMD. This example assumes `jmeter.bat` is on PATH or you set `JMETER_BIN` to the extracted JMeter's `bin\jmeter.bat` path.

```bat
@echo off
setlocal
REM adjust JMETER_BIN if jmeter.bat is not on PATH
set JMETER_BIN=jmeter.bat

REM start bookstore app
start /B cmd /C "pipenv run python bookstore\app.py > bookstore_app.log 2>&1"
REM start food app
start /B cmd /C "pipenv run python food_ordering\app.py > food_app.log 2>&1"

REM wait a few seconds for apps to start
timeout /t 5 /nobreak >nul

REM run bookstore test
%JMETER_BIN% -n -t "%CD%\bookstore\bookstore_test_plan.jmx" -l "%CD%\bookstore\bookstore_non_gui_result.jtl" -j "%CD%\bookstore\bookstore_jmeter.log" -Jthreads=1 -Jramp=1 -Jloops=1

REM run food test
%JMETER_BIN% -n -t "%CD%\food_ordering\food_test_plan.jmx" -l "%CD%\food_ordering\food_non_gui_result.jtl" -j "%CD%\food_ordering\food_jmeter.log" -Jthreads=1 -Jramp=1 -Jloops=1

echo Tests complete. Reports:
echo  - %CD%\bookstore\bookstore_report\index.html
echo  - %CD%\food_ordering\food_report\index.html

endlocal
```

### View results without opening JMeter GUI

You don't need to open the JMeter GUI to inspect results. Two common options:

1) Generate and open the HTML dashboard
   - After a non-GUI run produce the dashboard:
    ```bash
    jmeter -g /path/to/run.jtl -o /path/to/report_dir
    # open report_dir/index.html in a browser
    ```
   - This provides charts, tables, and transaction metrics.

2) Quick CSV/summary via command line or small script
   - The `.jtl` file is CSV-like. You can parse it to compute simple KPIs (e.g., number of failures, average response time). Example Python summarizer below.

Create a file `tools/summary_jtl.py` with the following content:

```python
import csv
import sys

def summarize(jtl_path):
   total = 0
   failures = 0
   total_time = 0
   with open(jtl_path, newline='') as f:
      reader = csv.DictReader(f)
      for r in reader:
         total += 1
         if r.get('success','').lower() not in ('true','1'):
            failures += 1
         try:
            total_time += float(r.get('elapsed',0))
         except:
            pass
   print(f'total samples: {total}')
   print(f'failures: {failures}')
   if total:
      print(f'avg elapsed (ms): {total_time/total:.2f}')

if __name__ == '__main__':
   if len(sys.argv) < 2:
      print('usage: python summary_jtl.py /path/to/results.jtl')
   else:
      summarize(sys.argv[1])
```

Run it like:

```bash
python tools/summary_jtl.py /path/to/bookstore_non_gui_result.jtl
```

This prints a quick summary on the terminal (samples, failures, average response time). For more advanced parsing you can use pandas or convert the JTL into other tools.

