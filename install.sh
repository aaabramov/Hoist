#!/bin/bash
set -euo pipefail

REPO="aaabramov/Hoist"
APP_NAME="Hoist.app"
INSTALL_DIR="/Applications"

echo "Fetching latest release..."
DOWNLOAD_URL=$(curl -sL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep '"browser_download_url".*\.dmg"' \
    | head -1 \
    | cut -d '"' -f 4)

if [ -z "$DOWNLOAD_URL" ]; then
    echo "Error: Could not find DMG download URL" >&2
    exit 1
fi

TMPDIR=$(mktemp -d)
DMG_PATH="${TMPDIR}/Hoist.dmg"
MOUNT_POINT="${TMPDIR}/mount"

cleanup() {
    if [ -d "$MOUNT_POINT" ]; then
        hdiutil detach "$MOUNT_POINT" -quiet 2>/dev/null || true
    fi
    rm -rf "$TMPDIR"
}
trap cleanup EXIT

echo "Downloading ${DOWNLOAD_URL}..."
curl -sL "$DOWNLOAD_URL" -o "$DMG_PATH"

echo "Mounting DMG..."
mkdir -p "$MOUNT_POINT"
hdiutil attach "$DMG_PATH" -mountpoint "$MOUNT_POINT" -nobrowse -quiet

if [ ! -d "${MOUNT_POINT}/${APP_NAME}" ]; then
    echo "Error: ${APP_NAME} not found in DMG" >&2
    exit 1
fi

echo "Installing to ${INSTALL_DIR}..."
rm -rf "${INSTALL_DIR}/${APP_NAME}"
cp -R "${MOUNT_POINT}/${APP_NAME}" "${INSTALL_DIR}/"

echo "Removing quarantine attribute..."
xattr -cr "${INSTALL_DIR}/${APP_NAME}"

echo ""
echo "Hoist has been installed to ${INSTALL_DIR}/${APP_NAME}"
echo ""

read -rp "Launch Hoist now? [Y/n] " answer
if [[ -z "$answer" || "$answer" =~ ^[Yy] ]]; then
    open "${INSTALL_DIR}/${APP_NAME}"
    echo "Hoist launched. Grant Accessibility permission when prompted."
fi
