#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

for cmd in pkg termux-create-package; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "[ERROR] Missing $cmd. Install it first:"
    echo "  pkg install python termux-create-package"
    exit 1
  fi
done

mkdir -p dist/debs
rm -f dist/debs/rush-speed_*.deb
termux-create-package manifest.yml
DEB="rush-speed_1.0.0_all.deb"

if [ ! -f "$DEB" ]; then
  echo "[ERROR] Expected package was not created: $DEB"
  exit 1
fi

mv "$DEB" dist/debs/
echo
echo "[OK] Built: dist/debs/$DEB"
echo "Next: install locally with:"
echo "  apt install ./dist/debs/$DEB"
