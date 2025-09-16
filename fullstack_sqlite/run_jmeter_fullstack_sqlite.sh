#!/usr/bin/env bash
# Run fullstack_sqlite JMeter plan in non-GUI mode and generate HTML report
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLAN="$SCRIPT_DIR/fullstack_sqlite_test_plan.jmx"
JTL="$SCRIPT_DIR/fullstack_sqlite_non_gui_result.jtl"
REPORT_DIR="$SCRIPT_DIR/fullstack_sqlite_report"

# defaults
THREADS=10
RAMP=5
LOOPS=1

if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
  echo "Usage: $(basename "$0") [--threads N] [--ramp R] [--loops L]"
  exit 0
fi

while [[ $# -gt 0 ]]; do
  case $1 in
    --threads) THREADS="$2"; shift 2 ;;
    --ramp) RAMP="$2"; shift 2 ;;
    --loops) LOOPS="$2"; shift 2 ;;
    *) echo "Unknown arg: $1"; exit 1 ;;
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

# wait for app
wait_for_url() {
  local url="$1"
  local timeout=${2:-15}
  local elapsed=0
  while [ $elapsed -lt $timeout ]; do
    if curl -sS -o /dev/null "$url" ; then
      return 0
    fi
    sleep 1
    elapsed=$((elapsed+1))
  done
  return 1
}

echo "Waiting for app at http://localhost:5004/ to be reachable..."
if ! wait_for_url "http://localhost:5004/" 20; then
  echo "App did not become reachable after 20s; continuing anyway." >&2
fi

JMETER_LOG="$SCRIPT_DIR/jmeter_run.log"

"$JMETER_CMD" -n -t "$PLAN" -l "$JTL" -j "$JMETER_LOG" -Jthreads="$THREADS" -Jramp="$RAMP" -Jloops="$LOOPS"
JMETER_EXIT=$?
if [ $JMETER_EXIT -ne 0 ]; then
  echo "JMeter exited with code $JMETER_EXIT. See $JMETER_LOG for details." >&2
  tail -n 200 "$JMETER_LOG" || true
  exit $JMETER_EXIT
fi

if [ ! -f "$JTL" ] || [ "$(wc -l < "$JTL")" -le 1 ]; then
  echo "JTL file $JTL is empty or missing; skipping HTML report generation." >&2
  exit 0
fi

rm -rf "$REPORT_DIR" || true
mkdir -p "$REPORT_DIR"
"$JMETER_CMD" -g "$JTL" -o "$REPORT_DIR"

echo "Non-GUI run complete. Results: $JTL. HTML report: $REPORT_DIR/index.html"
