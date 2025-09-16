#!/usr/bin/env bash
# Run JDBC-based DB test against fullstack_sqlite.db
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN="$SCRIPT_DIR/fullstack_sqlite_jdbc_test.jmx"
JTL="$SCRIPT_DIR/fullstack_sqlite_jdbc_result.jtl"
REPORT_DIR="$SCRIPT_DIR/fullstack_sqlite_jdbc_report"

THREADS=1
RAMP=1
LOOPS=1

# allow overriding via args
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --threads|-t) THREADS="$2"; shift 2 ;;
    --ramp|-r) RAMP="$2"; shift 2 ;;
    --loops|-l) LOOPS="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 2 ;;
  esac
done

# detect jmeter
if command -v jmeter >/dev/null 2>&1; then
  JMETER_CMD="jmeter"
else
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  BUNDLED="$REPO_ROOT/apache-jmeter-5.6.3/bin/jmeter"
  if [ -x "$BUNDLED" ]; then
    JMETER_CMD="$BUNDLED"
  else
    echo "jmeter not found on PATH and bundled JMeter not found at $BUNDLED." >&2
    exit 2
  fi
fi

# ensure JDBC driver present in JMeter lib
JAR="$SCRIPT_DIR/libs/sqlite-jdbc-3.36.0.3.jar"
if [ ! -f "$JAR" ]; then
  echo "JDBC jar not found at $JAR; run download_sqlite_jdbc.sh first" >&2
  exit 2
fi

# copy jar into bundled jmeter lib if possible
JMETER_BASENAME="$(basename "$JMETER_CMD")"
if [ "$JMETER_BASENAME" = "jmeter" ]; then
  # We have a path to an executable named jmeter. Try to resolve the JMeter home.
  JMETER_ROOT="$(cd "$(dirname "$(dirname "$JMETER_CMD")")" && pwd)" || true
  if [ -n "$JMETER_ROOT" ] && [ -d "$JMETER_ROOT/lib" ]; then
    echo "Copying JDBC jar into JMeter lib: $JMETER_ROOT/lib/"
    cp -n "$JAR" "$JMETER_ROOT/lib/" || echo "warning: copy to $JMETER_ROOT/lib/ failed; you may need to copy the jar manually"
  else
    echo "Could not auto-detect JMeter home to copy JDBC jar. If you are using a system JMeter, copy $JAR into its lib/ directory." >&2
  fi
else
  # If the executable is not named 'jmeter' (unlikely), attempt similar copy assuming it is the bundled path
  JMETER_ROOT="$(cd "$(dirname "$(dirname "$JMETER_CMD")")" && pwd)" || true
  if [ -n "$JMETER_ROOT" ] && [ -d "$JMETER_ROOT/lib" ]; then
    echo "Copying JDBC jar into bundled JMeter lib: $JMETER_ROOT/lib/"
    cp -n "$JAR" "$JMETER_ROOT/lib/" || echo "warning: copy to $JMETER_ROOT/lib/ failed; you may need to copy the jar manually"
  else
    echo "Could not copy JDBC jar into JMeter lib. Please copy $JAR into the lib/ folder of the JMeter you will run." >&2
  fi
fi

rm -f "$JTL"

# Pre-check: ensure the JVM used by JMeter can load org.sqlite.JDBC
check_jdbc_driver() {
  # prefer java on PATH
  if ! command -v java >/dev/null 2>&1; then
    echo "java not found on PATH; required to verify JDBC driver can be loaded. Ensure Java 11+ is installed." >&2
    return 2
  fi

  # try to detect the JMeter lib directory
  JMETER_LIB=""
  if [ -n "${JMETER_ROOT:-}" ] && [ -d "$JMETER_ROOT/lib" ]; then
    JMETER_LIB="$JMETER_ROOT/lib"
  fi

  # Build classpath: include JMETER lib if present, otherwise just the local jar
  if [ -n "$JMETER_LIB" ]; then
    CP="$JMETER_LIB/*:$JAR"
  else
    CP="$JAR"
  fi

  # Run a small Java check to load the driver
  java -cp "$CP" org.apache.commons.cli.HelpFormatter >/dev/null 2>&1 || true
  # The above ensures wildcard jars in CP are resolved; now attempt to load the driver class
  java -cp "$CP" -Xmx32m -Djava.awt.headless=true \ 
    -e "" 2>/dev/null || true

  # Use a short inline Java program via here-doc to attempt Class.forName
  java -cp "$CP" -Xmx64m -Djava.awt.headless=true - <<'JAVA'
public class Check { public static void main(String[] args) throws Exception {
  try { Class.forName("org.sqlite.JDBC"); System.out.println("OK"); }
  catch (Throwable t) { t.printStackTrace(System.err); System.exit(2); }
}}
JAVA

  if [ $? -ne 0 ]; then
    echo "Could not load org.sqlite.JDBC in the JVM classpath. Ensure the sqlite-jdbc jar is present in the JMeter lib directory you will run." >&2
    echo "Local driver path: $JAR" >&2
    echo "If you are using a system JMeter, copy the jar into its lib/ directory or run the bundled JMeter that the script can update." >&2
    return 2
  fi
  return 0
}

check_jdbc_driver || exit 2

# Ensure DB schema exists (idempotent). If DB file missing or empty, apply schema.sql
DB_FILE="$SCRIPT_DIR/fullstack_sqlite.db"
if [ ! -f "$DB_FILE" ] || [ ! -s "$DB_FILE" ]; then
  if command -v sqlite3 >/dev/null 2>&1; then
    echo "Initializing SQLite DB from schema.sql -> $DB_FILE"
    sqlite3 "$DB_FILE" < "$SCRIPT_DIR/schema.sql"
  else
    echo "sqlite3 tool not found; unable to initialize DB. Please create $DB_FILE from schema.sql" >&2
    exit 2
  fi
fi

"$JMETER_CMD" -n -t "$PLAN" -l "$JTL" -Jthreads="$THREADS" -Jramp="$RAMP" -Jloops="$LOOPS"
JMETER_EXIT=$?
if [ $JMETER_EXIT -ne 0 ]; then
  echo "JMeter exited with code $JMETER_EXIT" >&2
  exit $JMETER_EXIT
fi

if [ ! -f "$JTL" ] || [ "$(wc -l < "$JTL")" -le 1 ]; then
  echo "JTL file $JTL is empty or missing; skipping HTML report generation." >&2
  exit 0
fi

rm -rf "$REPORT_DIR" || true
mkdir -p "$REPORT_DIR"
"$JMETER_CMD" -g "$JTL" -o "$REPORT_DIR"

echo "JDBC DB test complete. Results: $JTL. HTML report: $REPORT_DIR/index.html"
