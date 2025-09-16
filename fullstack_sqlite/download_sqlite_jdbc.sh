#!/usr/bin/env bash
# Downloads sqlite-jdbc 3.36.0.3 to the libs/ folder
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIBS_DIR="$SCRIPT_DIR/libs"
mkdir -p "$LIBS_DIR"
JAR_URL="https://repo1.maven.org/maven2/org/xerial/sqlite-jdbc/3.36.0.3/sqlite-jdbc-3.36.0.3.jar"
TARGET="$LIBS_DIR/sqlite-jdbc-3.36.0.3.jar"

if [ -f "$TARGET" ]; then
  echo "$TARGET already exists"
  exit 0
fi

echo "Downloading sqlite-jdbc 3.36.0.3..."
if command -v curl >/dev/null 2>&1; then
  curl -L -o "$TARGET" "$JAR_URL"
elif command -v wget >/dev/null 2>&1; then
  wget -O "$TARGET" "$JAR_URL"
else
  echo "curl or wget required to fetch the JDBC driver" >&2
  exit 2
fi

echo "Saved to $TARGET"
