# Maintainer: anon

pkgname=t3code-bin
pkgver=0.0.4
pkgrel=1
pkgdesc='T3 Code desktop app packaged from the upstream AppImage'
arch=('x86_64')
_upstream_tag='v0.0.4'
_upstream_version='0.0.4'
_appimage_name="T3-Code-${_upstream_version}-x86_64.AppImage"
url='https://github.com/pingdotgg/t3code'
license=('MIT')
depends=(
  'openai-codex-bin'
  'alsa-lib'
  'at-spi2-core'
  'cairo'
  'dbus'
  'expat'
  'gcc-libs'
  'glib2'
  'gtk3'
  'libdrm'
  'libx11'
  'libxcb'
  'libxcomposite'
  'libxdamage'
  'libxext'
  'libxfixes'
  'libxkbcommon'
  'libxrandr'
  'mesa'
  'nspr'
  'nss'
  'pango'
  'zlib'
)
optdepends=(
  'xdg-utils: open links from the desktop client'
)
provides=('t3code')
conflicts=('t3code')
options=('!strip')
source=(
  "${_appimage_name}::https://github.com/pingdotgg/t3code/releases/download/${_upstream_tag}/${_appimage_name}"
  't3code-icon.png'
  'LICENSE'
)
sha256sums=(
  '1e5910fee3cb5c78760ee6a6ae6869df5c90aa71136b043846eee4836326a55b'
  '52c86008b11f90f36b8a8f4cc43b1352d5fda9084c6e5691b806f5bca1a968b6'
  '935d8f2af0c703f9c39517ee57cc4930b19d02d533be930b63f0e82f93614b43'
)

package() {
  cd "$srcdir"

  chmod +x "$_appimage_name"
  "./$_appimage_name" --appimage-extract >/dev/null

  if [[ ! -d "$srcdir/squashfs-root" ]]; then
    echo "Failed to extract AppImage payload." >&2
    return 1
  fi

  install -d "$pkgdir/opt/$pkgname"
  cp -a "$srcdir/squashfs-root/." "$pkgdir/opt/$pkgname/"

  # AppImage payloads can carry restrictive top-level permissions.
  find "$pkgdir/opt/$pkgname" -type d -exec chmod 755 {} +
  find "$pkgdir/opt/$pkgname" -type f -exec chmod 644 {} +
  chmod 755 \
    "$pkgdir/opt/$pkgname/AppRun" \
    "$pkgdir/opt/$pkgname/chrome-sandbox" \
    "$pkgdir/opt/$pkgname/chrome_crashpad_handler" \
    "$pkgdir/opt/$pkgname/t3-code-desktop"
  if [[ -d "$pkgdir/opt/$pkgname/resources/app.asar.unpacked" ]]; then
    find "$pkgdir/opt/$pkgname/resources/app.asar.unpacked" -type f \( -name '*.node' -o -name '*.so' \) -exec chmod 755 {} +
  fi

  install -Dm755 /dev/stdin "$pkgdir/usr/bin/t3code" << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

appdir='/opt/t3code-bin'
export APPDIR="$appdir"

if [[ -z "${CODEX_CLI_PATH-}" ]] && command -v codex >/dev/null 2>&1; then
  export CODEX_CLI_PATH="$(command -v codex)"
fi

export PATH="$appdir:$appdir/usr/sbin:$PATH"
if [[ -d "$appdir/usr/lib" ]]; then
  export LD_LIBRARY_PATH="$appdir/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
fi
export XDG_DATA_DIRS="$appdir/usr/share${XDG_DATA_DIRS:+:$XDG_DATA_DIRS}"
export GSETTINGS_SCHEMA_DIR="$appdir/usr/share/glib-2.0/schemas${GSETTINGS_SCHEMA_DIR:+:$GSETTINGS_SCHEMA_DIR}"

extra_flags=()
if [[ -n "${WAYLAND_DISPLAY-}" || "${XDG_SESSION_TYPE-}" == "wayland" ]]; then
  extra_flags+=(--enable-features=UseOzonePlatform --ozone-platform=wayland --ozone-platform-hint=wayland)
else
  extra_flags+=(--ozone-platform-hint=auto)
fi

exec "$appdir/t3-code-desktop" --no-sandbox "${extra_flags[@]}" "$@"
EOF

  ln -s t3code "$pkgdir/usr/bin/t3-code-desktop"

  install -Dm644 "$srcdir/t3code-icon.png" "$pkgdir/usr/share/pixmaps/t3code.png"

  install -Dm644 /dev/stdin "$pkgdir/usr/share/applications/t3code.desktop" << 'EOF'
[Desktop Entry]
Name=T3 Code
Comment=T3 Code desktop build
Exec=t3code %U
Terminal=false
Type=Application
Icon=t3code
StartupWMClass=T3 Code (Alpha)
Categories=Development;
EOF

  install -Dm644 "$srcdir/LICENSE" "$pkgdir/usr/share/licenses/$pkgname/LICENSE"
}
