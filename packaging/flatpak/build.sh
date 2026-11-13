#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
cd "$ROOT"

command -v flatpak-builder >/dev/null || { echo "flatpak-builder is required" >&2; exit 1; }
command -v flatpak >/dev/null || { echo "flatpak is required" >&2; exit 1; }

cd "$ROOT/linux"
if [[ "${1:-}" != "--from-existing" ]]; then
  npm install
  npm run dist
fi

DEB="$(find dist -maxdepth 1 -type f -name 'ShareXF-*-amd64.deb' -print -quit)"
[ -n "$DEB" ] || { echo "No x86_64 .deb found in linux/dist" >&2; exit 1; }

ROOTFS="$ROOT/linux/dist/flatpak-root"
rm -rf "$ROOTFS"
dpkg-deb -x "$DEB" "$ROOTFS"

flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak-builder --user --force-clean --install-deps-from=flathub \
  --repo="$ROOT/linux/dist/flatpak-repo" \
  "$ROOT/linux/dist/flatpak-build" \
  "$ROOT/packaging/flatpak/org.sharexf.ShareXF.yml"

flatpak build-bundle "$ROOT/linux/dist/flatpak-repo" \
  "$ROOT/linux/dist/ShareXF.flatpak" org.sharexf.ShareXF stable

echo "Built linux/dist/ShareXF.flatpak"
