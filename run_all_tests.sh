
#!/usr/bin/env bash
# Starts both Flask demo apps in background and runs non-GUI JMeter tests for each, then generates reports.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOKSTORE_DIR="$ROOT/bookstore"
FOOD_DIR="$ROOT/food_ordering"
FULLSTACK_SQLITE_DIR="$ROOT/fullstack_sqlite"

print_help() {
	cat <<EOF
Usage: $(basename "$0") [--help]

Starts both demo apps, runs the non-GUI JMeter tests for bookstore and food_ordering, then stops the apps.
Requires: jmeter on PATH, python available.
EOF
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
	print_help
	exit 0
fi

# Parse optional CLI args for threads/ramp/loops (applies to both apps by default)
THREADS=""
RAMP=""
LOOPS=""
while [[ ${#} -gt 0 ]]; do
	case "$1" in
		--threads)
			THREADS="$2"; shift 2;;
		--ramp)
			RAMP="$2"; shift 2;;
		--loops)
			LOOPS="$2"; shift 2;;
		--help|-h)
			print_help; exit 0;;
		*)
			echo "Unknown argument: $1" >&2; exit 2;;
	esac
done

JMETER_CMD=""
if command -v jmeter >/dev/null 2>&1; then
    JMETER_CMD="jmeter"
else
	REPO_ROOT="$(cd "$ROOT" && pwd)"
	BUNDLED="$REPO_ROOT/apache-jmeter-5.6.3/bin/jmeter"
	if [ -x "$BUNDLED" ]; then
		JMETER_CMD="$BUNDLED"
		echo "Using bundled JMeter at $BUNDLED"
	else
		echo "jmeter not found on PATH and bundled JMeter not found at $BUNDLED." >&2
		echo "Install JMeter or add it to PATH, or place a copy at $REPO_ROOT/apache-jmeter-5.6.3/bin/" >&2
		exit 2
	fi

fi

# Prefer to run the Flask apps under pipenv (so installed dependencies are used).
PYTHON_CMD="python"
if command -v pipenv >/dev/null 2>&1; then
  # use pipenv run if a Pipfile exists in the repo root
  if [ -f "$ROOT/Pipfile" ]; then
    PYTHON_CMD="pipenv run python"
    echo "Using pipenv to start apps: $PYTHON_CMD"
  fi
fi

echo "Starting bookstore app (background)..."
pushd "$BOOKSTORE_DIR" >/dev/null
nohup $PYTHON_CMD app.py > bookstore_app.log 2>&1 &
BOOK_PID=$!
echo "Bookstore pid: $BOOK_PID"
popd >/dev/null

echo "Starting food_ordering app (background)..."
pushd "$FOOD_DIR" >/dev/null
nohup $PYTHON_CMD app.py > food_app.log 2>&1 &
FOOD_PID=$!
echo "Food pid: $FOOD_PID"
popd >/dev/null

echo "Starting fullstack_sqlite app (background)..."
pushd "$FULLSTACK_SQLITE_DIR" >/dev/null
nohup $PYTHON_CMD app.py > fullstack_sqlite_app.log 2>&1 &
FULLSTACK_SQLITE_PID=$!
echo "Fullstack SQLite pid: $FULLSTACK_SQLITE_PID"
popd >/dev/null

# Robust cleanup: kill started apps only if still running
cleanup() {
	echo "Cleaning up..."
	if [ -n "${BOOK_PID:-}" ]; then
		if ps -p $BOOK_PID > /dev/null 2>&1; then
			echo "Killing bookstore (pid $BOOK_PID)"
			kill $BOOK_PID || true
		fi
	fi
	if [ -n "${FOOD_PID:-}" ]; then
		if ps -p $FOOD_PID > /dev/null 2>&1; then
			echo "Killing food_ordering (pid $FOOD_PID)"
			kill $FOOD_PID || true
		fi
	fi
	if [ -n "${FULLSTACK_SQLITE_PID:-}" ]; then
		if ps -p $FULLSTACK_SQLITE_PID > /dev/null 2>&1; then
			echo "Killing fullstack_sqlite (pid $FULLSTACK_SQLITE_PID)"
			kill $FULLSTACK_SQLITE_PID || true
		fi
	fi
}
trap cleanup EXIT INT TERM

# helper: wait for a URL to return HTTP 200 within timeout seconds
wait_for_url() {
	local url="$1"
	local timeout=${2:-30}
	local step=1
	local elapsed=0
	echo "Waiting for app at $url to be reachable..."
	while [ $elapsed -lt $timeout ]; do
		if command -v curl >/dev/null 2>&1; then
			if curl -s -o /dev/null -w "%{http_code}" "$url" | grep -q "^[23]..$"; then
				echo "$url is reachable"
				return 0
			fi
		else
			# fallback to netcat if curl missing (very small check)
			if command -v nc >/dev/null 2>&1; then
				hostport=$(echo "$url" | sed -E 's|https?://([^/:]+)(:([0-9]+))?.*|\1 \3|')
				host=$(echo "$hostport" | awk '{print $1}')
				port=$(echo "$hostport" | awk '{print $2}'); port=${port:-80}
				if nc -z -w1 "$host" "$port" 2>/dev/null; then
					echo "$url is accepting TCP connections"
					return 0
				fi
			fi
		fi
		sleep $step
		elapsed=$((elapsed+step))
	done
	echo "Timed out waiting for $url after ${timeout}s" >&2
	return 1
}


echo "Running JMeter tests..."
pushd "$BOOKSTORE_DIR" >/dev/null
BOOK_THREADS=${THREADS:-10}
BOOK_RAMP=${RAMP:-5}
BOOK_LOOPS=${LOOPS:-1}
wait_for_url "http://localhost:5001/" 30
./run_jmeter_bookstore.sh --threads "$BOOK_THREADS" --ramp "$BOOK_RAMP" --loops "$BOOK_LOOPS"
popd >/dev/null

pushd "$FOOD_DIR" >/dev/null
FOOD_THREADS=${THREADS:-5}
FOOD_RAMP=${RAMP:-3}
FOOD_LOOPS=${LOOPS:-1}
wait_for_url "http://localhost:5002/" 30
./run_jmeter_food.sh --threads "$FOOD_THREADS" --ramp "$FOOD_RAMP" --loops "$FOOD_LOOPS"
popd >/dev/null

pushd "$FULLSTACK_SQLITE_DIR" >/dev/null
FS_THREADS=${THREADS:-10}
FS_RAMP=${RAMP:-5}
FS_LOOPS=${LOOPS:-1}
wait_for_url "http://localhost:5004/" 30
./run_jmeter_fullstack_sqlite.sh --threads "$FS_THREADS" --ramp "$FS_RAMP" --loops "$FS_LOOPS"
popd >/dev/null

echo "Stopping apps..."
kill $BOOK_PID || true
kill $FOOD_PID || true
kill $FULLSTACK_SQLITE_PID || true

echo "All done. Reports:
 - $BOOKSTORE_DIR/bookstore_report/index.html
 - $FOOD_DIR/food_report/index.html"
