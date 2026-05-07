#!/bin/bash
# SPDX-License-Identifier: Apache-2.0 OR MIT
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

UNAME_S=$(uname -s)
TAR_OWNER=""
if [ "$UNAME_S" = "Linux" ]; then
  TAR_OWNER="--owner=0 --group=0"
fi

NAME="mxsend"
VERSION="${VERSION:-0.1.0-beta.4}"
ARCH="${ARCH:-x86_64}"
BUILD="${BUILD:-2}"
SOURCE_DIR="source"
DIST_DIR="dist"

MXSEND_VERSION="${MXSEND_VERSION:-v0.1.0-beta.2}"

REPO_NAMESPACE="adminelix"
REPO_NAME="mxsend-unraid-plugin"
REPO_URL="https://github.com/${REPO_NAMESPACE}/${REPO_NAME}"

PKG_NAME="${NAME}-${VERSION}-${ARCH}-${BUILD}"
PKG_FILE="${PKG_NAME}.txz"
PLG_FILE="${NAME}.plg"

PLUGIN_URL="${REPO_URL}/releases/latest/download/${PLG_FILE}"
PACKAGE_URL="${REPO_URL}/releases/download/v${VERSION}/${PKG_FILE}"

echo "=== Building $NAME plugin v$VERSION ==="

mkdir -p "$DIST_DIR"

# ── 1. Build Slackware package (.txz) ──────────────────────────────
echo "Creating Slackware package: $PKG_FILE"

MXSEND_TARGET="${ARCH}-unknown-linux-gnu"
MXSEND_BINARY="mxsend-${MXSEND_TARGET}"
MXSEND_DEST="${SOURCE_DIR}/usr/local/bin/mxsend"

if [ ! -f "$MXSEND_DEST" ]; then
  echo "Downloading mxsend ${MXSEND_VERSION} for ${ARCH}..."
  mkdir -p "$(dirname "$MXSEND_DEST")"
  curl -sL "https://github.com/adminelix/mxsend/releases/download/${MXSEND_VERSION}/${MXSEND_BINARY}" \
    -o "$MXSEND_DEST"
fi
chmod +x "$MXSEND_DEST"

cd "$SOURCE_DIR"

# shellcheck disable=SC2086
tar -cJf "../${DIST_DIR}/${PKG_FILE}" \
  --exclude='.DS_Store' \
  $TAR_OWNER \
  install/ usr/

cd ..

echo "Package created: $(du -sh "${DIST_DIR}/${PKG_FILE}" | awk '{print $1}')"

# ── 2. Calculate SHA256 ─────────────────────────────────────────────
if command -v sha256sum &>/dev/null; then
  PKG_SHA256=$(sha256sum "${DIST_DIR}/${PKG_FILE}" | cut -d' ' -f1)
elif command -v shasum &>/dev/null; then
  PKG_SHA256=$(shasum -a 256 "${DIST_DIR}/${PKG_FILE}" | cut -d' ' -f1)
else
  echo "ERROR: No sha256sum or shasum found"
  exit 1
fi
echo "SHA256: $PKG_SHA256"

# ── 3. Generate .plg file ──────────────────────────────────────────
echo "Generating PLG: $PLG_FILE"

PLUGIN_LOC="/boot/config/plugins/${NAME}"

cat > "${DIST_DIR}/${PLG_FILE}" << PLGEOF
<?xml version='1.0' standalone='yes'?>
<!DOCTYPE PLUGIN [
<!ENTITY name         "${NAME}">
<!ENTITY author       "adminelix">
<!ENTITY version      "${VERSION}">
<!ENTITY pluginURL    "${PLUGIN_URL}">
<!ENTITY package      "${PKG_FILE}">
<!ENTITY packageURL   "${PACKAGE_URL}">
<!ENTITY packageSHA256 "${PKG_SHA256}">
<!ENTITY pluginLOC    "${PLUGIN_LOC}">
]>
<PLUGIN name="&name;" author="&author;" version="&version;"
        pluginURL="&pluginURL;"
        icon="mxsend.png"
        min="6.12.0"
        support="https://github.com/adminelix/mxsend-unraid-plugin"
        project="https://github.com/adminelix/mxsend-unraid-plugin">

<CHANGES>
### &version;
See https://github.com/adminelix/mxsend-unraid-plugin/releases for changelog.
</CHANGES>

<!-- Pre-install: remove stale package files -->
<FILE Run="/bin/bash">
<INLINE>
rm -f \$(ls &pluginLOC;/${NAME}-*.txz 2>/dev/null | grep -v '&version;')
</INLINE>
</FILE>

<!-- Install Slackware package containing binary, agent XML, and icon -->
<FILE Name="&pluginLOC;/&package;" Run="upgradepkg --install-new">
<URL>&packageURL;</URL>
<SHA256>&packageSHA256;</SHA256>
</FILE>

<FILE Run="/bin/bash" Method="remove">
<INLINE>
removepkg ${PKG_NAME}
rm -rf &pluginLOC;
rm -f /boot/config/plugins/dynamix/notifications/agents/Mxsend.sh
rm -f /boot/config/plugins/dynamix/notifications/agents-disabled/Mxsend.sh
echo "${NAME} plugin removed."
</INLINE>
</FILE>

</PLUGIN>
PLGEOF

echo "PLG generated: ${DIST_DIR}/${PLG_FILE}"
echo ""
echo "=== Build complete ==="
echo ""
echo "Output files:"
ls -lh "${DIST_DIR}/"
echo ""
echo "To install on Unraid, paste this URL in Plugins → Install Plugin:"
echo "  ${PLUGIN_URL}"
echo ""
echo "Or copy both files to flash and run:"
echo "  plugin install /boot/config/plugins/${NAME}/${NAME}.plg"
