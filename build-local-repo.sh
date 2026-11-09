#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail
cd "$(dirname "$0")"

if ! command -v termux-apt-repo >/dev/null 2>&1; then
  echo "[ERROR] Install termux-apt-repo first: pkg install termux-apt-repo"
  exit 1
fi
if [ ! -d repo-input ] || ! find repo-input -maxdepth 1 -name '*.deb' -print -quit | grep -q .; then
  echo "[ERROR] Put at least one .deb file in repo-input/"
  exit 1
fi

rm -rf public
mkdir -p public
termux-apt-repo repo-input public/apt stable main
cat > public/index.html <<'HTML'
<!doctype html>
<html lang="en"><meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>RUSH SPEED APT repository</title>
<h1>RUSH SPEED</h1>
<p>Termux APT repository. Follow the installation instructions in the GitHub README.</p>
</html>
HTML
echo "[OK] Repository generated in public/apt"
