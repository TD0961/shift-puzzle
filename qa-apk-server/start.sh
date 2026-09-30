#!/usr/bin/env bash
set -e

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$DIR/.." && pwd)"

SOURCE_APK="$ROOT_DIR/build/app/outputs/flutter-apk/app-release.apk"
QA_APK="$DIR/shift-puzzle-qa.apk"
EXPECTED_SHA="2829b2ea9314c98d45fcd028697c5e257b8a22d7cc473598484808bcc1ac9a18"

# 1. Verify existence
if [ ! -f "$QA_APK" ]; then
    if [ -f "$SOURCE_APK" ]; then
        echo "Copying verified QA APK to server directory..."
        cp "$SOURCE_APK" "$QA_APK"
    else
        echo "[ERROR] Source QA APK not found at: $SOURCE_APK" >&2
        exit 1
    fi
fi

# 2. Verify SHA-256
ACTUAL_SHA=$(sha256sum "$QA_APK" | awk '{print $1}')
if [ "$ACTUAL_SHA" != "$EXPECTED_SHA" ]; then
    echo "[FATAL] SHA-256 mismatch!" >&2
    echo "  Expected: $EXPECTED_SHA" >&2
    echo "  Actual:   $ACTUAL_SHA" >&2
    exit 1
fi

# 3. Launch python server which handles LAN IP detection, QR generation, and HTTP serving
cd "$DIR"
exec python3 server.py
