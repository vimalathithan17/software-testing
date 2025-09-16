import csv
import sys

"""
Simple summarizer for JMeter .jtl result files.

Usage:
  python summary_jtl.py /path/to/results.jtl

The script prints total samples, number of failures, and average elapsed time in ms.
It attempts to read common JTL column names like 'elapsed' or 't' and 'success' or 's'.
"""


def summarize(jtl_path: str) -> None:
    total = 0
    failures = 0
    total_time = 0.0
    with open(jtl_path, newline='') as f:
        reader = csv.DictReader(f)
        for r in reader:
            total += 1
            # success flag may be 'success' or 's'
            success = None
            for k in ("success", "s"):
                if k in r:
                    success = r[k]
                    break
            if success is not None and str(success).lower() not in ("true", "1"):
                failures += 1
            # elapsed time may be 'elapsed' or 't'
            elapsed_val = 0
            for k in ("elapsed", "t"):
                if k in r and r[k] != "":
                    try:
                        elapsed_val = float(r[k])
                        break
                    except Exception:
                        elapsed_val = 0
            total_time += elapsed_val
    print(f"total samples: {total}")
    print(f"failures: {failures}")
    if total:
        print(f"avg elapsed (ms): {total_time/total:.2f}")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("usage: python summary_jtl.py /path/to/results.jtl")
        sys.exit(1)
    summarize(sys.argv[1])
