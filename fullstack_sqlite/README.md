Fullstack SQLite demo for JMeter testing

This folder contains a tiny Flask app backed by SQLite suitable for JMeter load testing.

Files:
- app.py — Flask app (listens on port 5004)
- schema.sql — DB schema used by the app
- static/ — simple web frontend (index.html, script.js, style.css)
- fullstack_sqlite_test_plan.jmx — JMeter plan (uses -Jthreads/-Jramp/-Jloops)
- run_jmeter_fullstack_sqlite.sh — convenience script for non-GUI runs
- run_all_tests_fullstack_sqlite.bat — Windows batch example to run the plan
- download_sqlite_jdbc.sh — downloads sqlite-jdbc 3.36.0.3 to libs/

Usage (Linux/macOS):

# install deps and start app
pipenv install --dev
pipenv run python app.py

# run test
./run_jmeter_fullstack_sqlite.sh --threads 1 --ramp 1 --loops 1

Download JDBC (for Java-based clients/tools):

./download_sqlite_jdbc.sh

