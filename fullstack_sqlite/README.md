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

Notes:
- The JDBC runner will auto-initialize the SQLite DB from `schema.sql` if the DB file (`fullstack_sqlite.db`) is missing or empty. This requires the `sqlite3` CLI to be available.
- You can also pass short flags: `-t/--threads`, `-r/--ramp`, `-l/--loops`.

Example (run JDBC test with 5 threads, 5s ramp, 2 loops):

./run_jmeter_fullstack_sqlite_jdbc.sh -t 5 -r 5 -l 2

Download JDBC (for Java-based clients/tools):

./download_sqlite_jdbc.sh

Installing the JDBC driver for JMeter
-----------------------------------

1. Download the driver into this folder's `libs/` directory:

	./download_sqlite_jdbc.sh

2. If you use the bundled JMeter included at the repo root (`apache-jmeter-5.6.3`), the JDBC runner will attempt to copy the jar into the bundled JMeter `lib/` directory automatically. If that fails, copy it manually:

	cp fullstack_sqlite/libs/sqlite-jdbc-3.36.0.3.jar apache-jmeter-5.6.3/lib/

3. If you use a system-installed JMeter (i.e. `jmeter` on your PATH), copy the jar into that JMeter's `lib/` directory instead. To find that location, run:

	which jmeter

	# then copy the jar into the lib/ folder beside that jmeter executable

	cp fullstack_sqlite/libs/sqlite-jdbc-3.36.0.3.jar /path/to/jmeter/lib/

Note: copying the jar into the JMeter `lib/` directory is required so JMeter can load the `org.sqlite.JDBC` driver class for the JDBC samplers.

