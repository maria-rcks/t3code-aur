<div align="center">
  <img src="t3code-icon.png" alt="T3 Code icon" width="128" />

# t3code AUR packages

[![AUR version](https://img.shields.io/aur/version/t3code-bin?style=flat-square&label=AUR)](https://aur.archlinux.org/packages/t3code-bin)
[![AUR votes](https://img.shields.io/aur/votes/t3code-bin?style=flat-square&label=votes)](https://aur.archlinux.org/packages/t3code-bin)
[![AUR last updated](https://img.shields.io/aur/last-modified/t3code-bin?style=flat-square&label=updated)](https://aur.archlinux.org/packages/t3code-bin)
[![License](https://img.shields.io/badge/license-MIT-111111?style=flat-square)](./LICENSE)

Automated AUR packaging for **T3 Code** on Arch Linux.
</div>

## Install from the AUR

Use your favorite AUR helper:

```bash
yay -S t3code-bin
# or
paru -S t3code-bin

# nightly builds
yay -S t3code-nightly-bin
# or
paru -S t3code-nightly-bin
```

## What this repo does

- Tracks upstream T3 Code releases and nightly prereleases.
- Packages the upstream x86_64 AppImage for Arch Linux.
- Publishes `t3code-bin` and `t3code-nightly-bin` to the AUR automatically.

## Repo layout

- `PKGBUILD`, `.SRCINFO`, `upstream.sha256`: stable package metadata for `t3code-bin`
- `packages/t3code-nightly-bin/`: nightly package metadata for `t3code-nightly-bin`
- `scripts/`: shared release-check, PKGBUILD update, and AUR publish helpers
- `.github/workflows/publish-aur.yml`: matrix workflow for stable and nightly publishing

## Links

- AUR package: https://aur.archlinux.org/packages/t3code-bin
- AUR nightly package: https://aur.archlinux.org/packages/t3code-nightly-bin
- Upstream project: https://github.com/pingdotgg/t3code
