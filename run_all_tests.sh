
#!/usr/bin/env bash
# Starts both Flask demo apps in background and runs non-GUI JMeter tests for each, then generates reports.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOKSTORE_DIR="$ROOT/bookstore"
FOOD_DIR="$ROOT/food_ordering"

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

sleep 2

echo "Running JMeter tests..."
pushd "$BOOKSTORE_DIR" >/dev/null
BOOK_THREADS=${THREADS:-10}
BOOK_RAMP=${RAMP:-5}
BOOK_LOOPS=${LOOPS:-1}
./run_jmeter_bookstore.sh --threads "$BOOK_THREADS" --ramp "$BOOK_RAMP" --loops "$BOOK_LOOPS"
popd >/dev/null

pushd "$FOOD_DIR" >/dev/null
FOOD_THREADS=${THREADS:-5}
FOOD_RAMP=${RAMP:-3}
FOOD_LOOPS=${LOOPS:-1}
./run_jmeter_food.sh --threads "$FOOD_THREADS" --ramp "$FOOD_RAMP" --loops "$FOOD_LOOPS"
popd >/dev/null

echo "Stopping apps..."
kill $BOOK_PID || true
kill $FOOD_PID || true

echo "All done. Reports:
 - $BOOKSTORE_DIR/bookstore_report/index.html
 - $FOOD_DIR/food_report/index.html"
