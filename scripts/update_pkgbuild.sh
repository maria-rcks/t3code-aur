#!/usr/bin/env bash
set -euo pipefail

PKGBUILD_PATH="${PKGBUILD_PATH:-PKGBUILD}"
STATE_FILE="${STATE_FILE:-upstream.sha256}"
UPSTREAM_TAG="${UPSTREAM_TAG:-}"
UPSTREAM_VERSION="${UPSTREAM_VERSION:-}"
PKGVER_CANDIDATE="${PKGVER_CANDIDATE:-}"
APPIMAGE_SHA256="${APPIMAGE_SHA256:-}"

if [[ -z "$UPSTREAM_TAG" || -z "$UPSTREAM_VERSION" ]]; then
  echo "UPSTREAM_TAG and UPSTREAM_VERSION are required" >&2
  exit 1
fi

if [[ -z "$PKGVER_CANDIDATE" ]]; then
  echo "PKGVER_CANDIDATE is required" >&2
  exit 1
fi

if [[ -z "$APPIMAGE_SHA256" ]]; then
  echo "APPIMAGE_SHA256 is required" >&2
  exit 1
fi

if [[ ! -f "$PKGBUILD_PATH" ]]; then
  echo "Missing PKGBUILD at $PKGBUILD_PATH" >&2
  exit 1
fi

current_pkgver="$(awk -F= '/^pkgver=/{print $2; exit}' "$PKGBUILD_PATH")"
current_pkgrel="$(awk -F= '/^pkgrel=/{print $2; exit}' "$PKGBUILD_PATH")"

if [[ -z "$current_pkgver" || -z "$current_pkgrel" ]]; then
  echo "Failed to read current pkgver/pkgrel from $PKGBUILD_PATH" >&2
  exit 1
fi

new_pkgver="$PKGVER_CANDIDATE"
if [[ "$new_pkgver" != "$current_pkgver" ]]; then
  new_pkgrel=1
else
  new_pkgrel=$((current_pkgrel + 1))
fi

escape_sed_replacement() {
  printf '%s' "$1" | sed -e 's/[\/&]/\\&/g'
}

new_pkgver_escaped="$(escape_sed_replacement "$new_pkgver")"
upstream_tag_escaped="$(escape_sed_replacement "$UPSTREAM_TAG")"
upstream_version_escaped="$(escape_sed_replacement "$UPSTREAM_VERSION")"
appimage_sha256_escaped="$(escape_sed_replacement "$APPIMAGE_SHA256")"

sed -Ei "s/^pkgver=.*/pkgver=${new_pkgver_escaped}/" "$PKGBUILD_PATH"
sed -Ei "s/^pkgrel=.*/pkgrel=${new_pkgrel}/" "$PKGBUILD_PATH"
sed -Ei "s/^_upstream_tag=.*/_upstream_tag='${upstream_tag_escaped}'/" "$PKGBUILD_PATH"
sed -Ei "s/^_upstream_version=.*/_upstream_version='${upstream_version_escaped}'/" "$PKGBUILD_PATH"
sed -Ei "/^sha256sums=\(/,/^\)/{0,/^[[:space:]]*'[^']*'[[:space:]]*$/{s//  '${appimage_sha256_escaped}'/}}" "$PKGBUILD_PATH"

printf '%s\n' "$APPIMAGE_SHA256" > "$STATE_FILE"

printf 'pkgver=%s\n' "$new_pkgver"
printf 'pkgrel=%s\n' "$new_pkgrel"
printf 'state_file=%s\n' "$STATE_FILE"

if [[ -n "${GITHUB_OUTPUT:-}" ]]; then
  {
    printf 'pkgver=%s\n' "$new_pkgver"
    printf 'pkgrel=%s\n' "$new_pkgrel"
    printf 'state_file=%s\n' "$STATE_FILE"
  } >> "$GITHUB_OUTPUT"
fi
