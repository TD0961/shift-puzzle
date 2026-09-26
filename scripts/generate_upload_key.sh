#!/usr/bin/env bash
# ==============================================================================
# Shift Puzzle — Secure Google Play Upload Keystore Generator
# ==============================================================================
# This script securely generates an upload keystore for Shift Puzzle and
# generates android/key.properties configured with restricted file permissions (600).
#
# IMPORTANT:
# - NEVER commit android/key.properties or *.jks to git (both are gitignored).
# - BACKUP upload-keystore.jks in a secure offline vault / password manager.
#   Google Play App Signing uses this key to authenticate your app updates.
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
ANDROID_DIR="${ROOT_DIR}/android"
KEYSTORE_PATH="${ANDROID_DIR}/app/upload-keystore.jks"
PROPERTIES_PATH="${ANDROID_DIR}/key.properties"

echo "=== Shift Puzzle Upload Keystore Generator ==="

if [ -f "${KEYSTORE_PATH}" ]; then
  echo "WARNING: Keystore already exists at ${KEYSTORE_PATH}"
  read -rp "Overwrite existing keystore? (y/N): " CONFIRM
  if [[ "${CONFIRM}" != "y" && "${CONFIRM}" != "Y" ]]; then
    echo "Aborted. Existing keystore preserved."
    exit 0
  fi
fi

# Find keytool binary
KEYTOOL_BIN="keytool"
if [ -n "${JAVA_HOME:-}" ] && [ -x "${JAVA_HOME}/bin/keytool" ]; then
  KEYTOOL_BIN="${JAVA_HOME}/bin/keytool"
elif [ -x "/home/tensae/jdk-21/bin/keytool" ]; then
  KEYTOOL_BIN="/home/tensae/jdk-21/bin/keytool"
elif [ -x "${ROOT_DIR}/jdk-21/bin/keytool" ]; then
  KEYTOOL_BIN="${ROOT_DIR}/jdk-21/bin/keytool"
fi

echo "Using keytool: ${KEYTOOL_BIN}"
echo "Generating 2048-bit RSA key for alias 'upload' (validity: 10,000 days)..."

# Prompt for passwords securely without echo
read -rsp "Enter keystore password: " STORE_PASS
echo
read -rsp "Confirm keystore password: " STORE_PASS_CONFIRM
echo

if [ "${STORE_PASS}" != "${STORE_PASS_CONFIRM}" ]; then
  echo "Error: Passwords do not match!" >&2
  exit 1
fi

if [ ${#STORE_PASS} -lt 8 ]; then
  echo "Error: Password must be at least 8 characters!" >&2
  exit 1
fi

# Generate the keystore
"${KEYTOOL_BIN}" -genkeypair \
  -v \
  -keystore "${KEYSTORE_PATH}" \
  -alias "upload" \
  -keyalg RSA \
  -keysize 2048 \
  -validity 10000 \
  -storepass "${STORE_PASS}" \
  -keypass "${STORE_PASS}" \
  -dname "CN=Shift Puzzle, OU=Mobile Games, O=Shift Puzzle, L=Global, ST=Mobile, C=US"

chmod 600 "${KEYSTORE_PATH}"

# Write android/key.properties
cat > "${PROPERTIES_PATH}" <<EOF
# Generated automatically — DO NOT COMMIT TO VERSION CONTROL
storePassword=${STORE_PASS}
keyPassword=${STORE_PASS}
keyAlias=upload
storeFile=upload-keystore.jks
EOF

chmod 600 "${PROPERTIES_PATH}"

echo "=============================================================================="
echo "SUCCESS!"
echo "Keystore created: ${KEYSTORE_PATH} (chmod 600)"
echo "Config created:   ${PROPERTIES_PATH} (chmod 600)"
echo ""
echo "CRITICAL NEXT STEP: Back up upload-keystore.jks and key.properties to your"
echo "secure team password manager or encrypted cloud vault immediately!"
echo "=============================================================================="
