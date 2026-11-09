# RUSH SPEED — Termux package and signed APT repository

RUSH SPEED is a lightweight Python internet speed-test CLI for Termux. It measures download and upload in separate default 7-second windows using Cloudflare's public speed-test endpoints.

> Status: publishing starter kit. It is **not published**. You must create the GitHub repository, create the signing key, build/test the `.deb`, configure the Actions secret, and enable Pages.

## Repository layout

```text
rush-speed/
├── .github/workflows/pages.yml
├── package/files/rush-speed
├── repo-input/                 # publishable .deb files go here
├── manifest.yml
├── build-deb.sh
└── build-local-repo.sh
```

## 1. Create the GitHub repository

Create a **public** repository named `rush-speed`. Keep write access limited to you and trusted maintainers.

Before the first commit:
- Replace `raiyani-rush` in `manifest.yml` with your GitHub username.
- Replace `maintainer@example.invalid` with an email address you control.

Upload the contents of this folder to the repository's `main` branch.

## 2. Create a persistent APT signing key

A signed repository is preferable to an unsigned repository using `[trusted=yes]`. Generate a dedicated key in Termux:

```bash
pkg update
pkg install gnupg
gpg --batch --pinentry-mode loopback --passphrase '' \
  --quick-generate-key "RUSH SPEED APT Repository" rsa3072 sign 0
```

Find its fingerprint:

```bash
gpg --list-secret-keys --keyid-format LONG
```

Export the private key:

```bash
gpg --armor --export-secret-keys "RUSH SPEED APT Repository" \
  > "$HOME/rush-speed-apt-private.asc"
```

The private key is sensitive. Do **not** commit it, upload it into the repository, or send it in chat.

Open your GitHub repository:
**Settings → Secrets and variables → Actions → New repository secret**

Create a secret named exactly:

```text
APT_SIGNING_PRIVATE_KEY
```

Paste the complete contents of `rush-speed-apt-private.asc` into the secret value. Keep the key private. The workflow imports it only during a protected-branch deployment and signs the APT metadata.

## 3. Build the Termux .deb on your phone

In Termux:

```bash
pkg update
pkg upgrade
pkg install python termux-create-package git
```

Clone your repository (replace the placeholder):

```bash
git clone https://github.com/raiyani-rush/rush-speed.git
cd rush-speed
chmod +x build-deb.sh
./build-deb.sh
```

Expected output:

```text
dist/debs/rush-speed_1.0.0_all.deb
```

`Architecture: all` is appropriate because the package contains Python source only, not compiled native binaries. It depends on Termux's `python` package.

## 4. Test the package locally BEFORE publishing

Install the exact package:

```bash
apt install ./dist/debs/rush-speed_1.0.0_all.deb
```

Test:

```bash
rush-speed --help
rush-speed
rush-speed --json
```

Test uninstall and reinstall:

```bash
apt remove rush-speed
apt install ./dist/debs/rush-speed_1.0.0_all.deb
```

Test on Wi-Fi and mobile data, and ideally on more than one Android device. The test uses internet data. It measures the device's route to Cloudflare, not a guaranteed maximum speed to every service. Do not publish until installation, execution, JSON output, and removal all pass.

## 5. Add the .deb to the repository input

```bash
mkdir -p repo-input
cp dist/debs/rush-speed_1.0.0_all.deb repo-input/
git add repo-input/rush-speed_1.0.0_all.deb
git commit -m "Add RUSH SPEED 1.0.0 package"
git push origin main
```

The GitHub Actions workflow imports the signing key, generates signed APT metadata, and deploys the `public/` directory to GitHub Pages.

## 6. Enable GitHub Pages

On GitHub:

1. Open `raiyani-rush/rush-speed`.
2. Open **Settings → Pages**.
3. Under **Build and deployment → Source**, select **GitHub Actions**.
4. Open **Actions** and wait for “Build and deploy Termux APT repository” to finish successfully.
5. The repository URL will be:

```text
https://raiyani-rush.github.io/rush-speed/apt
```

The public key will be available at:

```text
https://raiyani-rush.github.io/rush-speed/rush-speed-archive-keyring.gpg
```

Do not tell users the repository is live until the workflow succeeds and both URLs are reachable.

## 7. User installation instructions

Share these commands with users after replacing the GitHub username:

```bash
mkdir -p "$PREFIX/etc/apt/trusted.gpg.d" "$PREFIX/etc/apt/sources.list.d"

curl -fsSL \
  https://raiyani-rush.github.io/rush-speed/rush-speed-archive-keyring.gpg \
  -o "$PREFIX/etc/apt/trusted.gpg.d/rush-speed.gpg"

echo "deb https://raiyani-rush.github.io/rush-speed/apt stable main" \
  > "$PREFIX/etc/apt/sources.list.d/rush-speed.list"

pkg update
pkg install rush-speed
```

Then run:

```bash
rush-speed
```

Optional:

```bash
rush-speed --json
rush-speed --streams 2
rush-speed --duration 7
```

The keyring file must be obtained over HTTPS from the repository you trust. APT verifies repository metadata against this key. If the signing key is ever compromised, revoke/replace it and publish clear key-rotation instructions.

## 8. Controlled contributions

In GitHub repository settings:

- Keep the repository public, but do not grant write access to everyone.
- Add only trusted collaborators with the minimum role they need.
- Protect `main` with a ruleset / branch protection:
  - Require pull requests before merging.
  - Require at least one approval if there is another maintainer.
  - Require status checks after CI checks are added.
  - Block force pushes and branch deletion.
  - Restrict who can push to `main`, if available on your plan.
- Review changes to `package/files/rush-speed`, `manifest.yml`, and `.github/workflows/` before merging.
- Enable two-factor authentication on GitHub.
- Never commit tokens, passwords, or the APT signing private key.
- Allow GitHub Pages deployment only from the protected `main` branch.

The provided workflow deploys on pushes to `main` and manual dispatch. Pull requests do not publish.

## 9. Publishing an update

For a code update:

1. Edit `package/files/rush-speed`.
2. Increment `Version` in `manifest.yml` (for example `1.0.1`).
3. Rebuild:

```bash
./build-deb.sh
```

4. Test the new `.deb` locally.
5. Replace the old package in `repo-input/` with the new version.
6. Commit and push to `main`. The workflow regenerates the signed APT repository.

Keep old package versions only if you intentionally want rollback options; otherwise remove the old `.deb` from `repo-input/` before generating the index.

## Package details

- APT package: `rush-speed`
- Installed command: `rush-speed`
- Default duration: 7 seconds download + 7 seconds upload (14 seconds total).
- Runtime dependency: `python`
- No root or Shizuku required.
- Android/Termux compatibility depends on the installed Termux version, Python and network support. No package can promise zero errors on every device.
