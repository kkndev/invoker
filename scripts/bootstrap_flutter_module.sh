#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MODULE_DIR="$ROOT_DIR/flutter_module"

if [[ -n "${FLUTTER_CMD:-}" ]]; then
  read -r -a FLUTTER_BIN <<< "$FLUTTER_CMD"
elif command -v fvm >/dev/null 2>&1; then
  FLUTTER_BIN=(fvm flutter)
elif command -v flutter >/dev/null 2>&1; then
  FLUTTER_BIN=(flutter)
else
  echo "Flutter SDK was not found. Install Flutter or FVM first." >&2
  exit 1
fi

echo "Using Flutter command: ${FLUTTER_BIN[*]}"

"${FLUTTER_BIN[@]}" create \
  --template module \
  --platforms android,ios \
  --org com.example.hybrid \
  "$MODULE_DIR"

(
  cd "$MODULE_DIR"
  "${FLUTTER_BIN[@]}" pub get
)
