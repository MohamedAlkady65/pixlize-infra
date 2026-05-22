#!/bin/bash
set -e

echo "==> Building Lambda deployment package..."

BUILD_DIR="/lambda/package"
ZIP_PATH="/lambda/output/lambda.zip"

rm -rf "$BUILD_DIR" "$ZIP_PATH"
mkdir -p "$BUILD_DIR"
mkdir -p "/lambda/output"

cd /lambda/code
pip install --no-cache-dir -r "/lambda/code/requirements.txt" -t "$BUILD_DIR" -q

cp "/lambda/code/handler.py" "/lambda/code/processors.py" "$BUILD_DIR/"

cd "$BUILD_DIR"
zip -r "$ZIP_PATH" . -q

echo "==> Done: $ZIP_PATH ($(du -sh "$ZIP_PATH" | cut -f1))"
