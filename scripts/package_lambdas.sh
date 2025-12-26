#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="$ROOT_DIR/dist"

rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

functions=(auth_handler db_init document_processor evaluation_handler query_handler upload_handler)

for fn in "${functions[@]}"; do
  src_dir="$ROOT_DIR/src/$fn"
  zip_path="$DIST_DIR/${fn}.zip"
  (cd "$src_dir" && zip -r "$zip_path" .)
done

echo "Packaged Lambda functions to $DIST_DIR"
