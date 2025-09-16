#!/usr/bin/env bash
# Non-GUI run for bookstore test plan
# Usage: ./run_jmeter_bookstore.sh [--threads N] [--ramp R] [--loops L] [--help]
# Generates a JTL and an HTML dashboard directory.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN="$SCRIPT_DIR/bookstore_test_plan.jmx"
JTL="$SCRIPT_DIR/bookstore_non_gui_result.jtl"
REPORT_DIR="$SCRIPT_DIR/bookstore_report"

# defaults
THREADS=10
RAMP=5
LOOPS=1

print_help() {
  cat <<EOF
Usage: $(basename "$0") [--threads N] [--ramp R] [--loops L] [--help]

Runs the bookstore JMeter test plan in non-GUI mode and generates an HTML report.

Options:
  --threads N   Number of threads (default: $THREADS)
  --ramp R      Ramp-up in seconds (default: $RAMP)
  --loops L     Loop count (default: $LOOPS)
  --help        Show this help message
EOF
}

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
  print_help
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --threads) THREADS="$2"; shift 2 ;;
    --ramp) RAMP="$2"; shift 2 ;;
    --loops) LOOPS="$2"; shift 2 ;;
    --help|-h) print_help; exit 0 ;;
    *) echo "Unknown arg: $1"; print_help; exit 1 ;;
  esac
done

JMETER_CMD=""
if command -v jmeter >/dev/null 2>&1; then
  JMETER_CMD="jmeter"
else
  # try bundled jmeter under repo root
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
  BUNDLED="$REPO_ROOT/apache-jmeter-5.6.3/bin/jmeter"
  if [ -x "$BUNDLED" ]; then
    JMETER_CMD="$BUNDLED"
  else
    echo "jmeter not found on PATH and bundled JMeter not found at $BUNDLED." >&2
    echo "Install JMeter or add it to PATH, or place a copy at $REPO_ROOT/apache-jmeter-5.6.3/bin/" >&2
    exit 2
  fi
fi

echo "Running Bookstore test plan: threads=$THREADS ramp=$RAMP loops=$LOOPS"

# helper: wait for http URL to respond (timeout seconds)
wait_for_url() {
  local url="$1"
  local timeout=${2:-15}
  local interval=1
  local elapsed=0
  while [ $elapsed -lt $timeout ]; do
    if curl -s -o /dev/null "$url"; then
      return 0
    fi
    sleep $interval
    elapsed=$((elapsed + interval))
  done
  return 1
}

if ! wait_for_url "http://localhost:5001/" 15; then
  echo "Timeout waiting for http://localhost:5001/ to become available" >&2
  exit 3
fi

JMETER_LOG="$SCRIPT_DIR/jmeter_run.log"

"$JMETER_CMD" -n -t "$PLAN" -l "$JTL" -j "$JMETER_LOG" -Jthreads="$THREADS" -Jramp="$RAMP" -Jloops="$LOOPS"
JMETER_EXIT=$?
if [ $JMETER_EXIT -ne 0 ]; then
  echo "JMeter exited with code $JMETER_EXIT. See $JMETER_LOG for details." >&2
  tail -n 200 "$JMETER_LOG" || true
  exit $JMETER_EXIT
fi

echo "Generating HTML report at $REPORT_DIR"
# don't attempt to generate HTML if the JTL is empty or only contains a header
if [ ! -f "$JTL" ] || [ "$(wc -l < "$JTL")" -le 1 ]; then
  echo "JTL file $JTL is empty or missing; skipping HTML report generation." >&2
  echo "Check $JMETER_LOG for JMeter details." >&2
  exit 0
fi

rm -rf "$REPORT_DIR" || true
mkdir -p "$REPORT_DIR"
"$JMETER_CMD" -g "$JTL" -o "$REPORT_DIR"

echo "Non-GUI run complete. Results: $JTL. HTML report: $REPORT_DIR/index.html"
