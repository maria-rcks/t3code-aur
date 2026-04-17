#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_REPO="${UPSTREAM_REPO:-pingdotgg/t3code}"
STATE_FILE="${STATE_FILE:-upstream.sha256}"
RELEASE_TAG_REGEX="${RELEASE_TAG_REGEX:-^v}"
RELEASE_PRERELEASE="${RELEASE_PRERELEASE:-false}"
RELEASE_VERSION_PREFIX="${RELEASE_VERSION_PREFIX:-v}"
ASSET_REGEX="${ASSET_REGEX:-^T3-Code-.*-x86_64\.AppImage$}"
out_file="${GITHUB_OUTPUT:-}"

releases_json="$(gh api "repos/$UPSTREAM_REPO/releases?per_page=100")"
release_json="$(jq -c \
  --arg regex "$RELEASE_TAG_REGEX" \
  --arg prerelease "$RELEASE_PRERELEASE" '
    map(
      select(
        (.draft | not)
        and (.prerelease == ($prerelease == "true"))
        and (.tag_name | test($regex))
      )
    )
    | first // empty
  ' <<<"$releases_json")"

upstream_tag="$(jq -r '.tag_name // empty' <<<"$release_json")"
if [[ -z "$upstream_tag" ]]; then
  echo "Failed to resolve matching upstream tag from $UPSTREAM_REPO" >&2
  exit 1
fi

asset_json="$(jq -c --arg regex "$ASSET_REGEX" '
  .assets
  | map(select(.name | test($regex)))
  | first // empty
' <<<"$release_json")"

if [[ -z "$asset_json" || "$asset_json" == "null" ]]; then
  echo "Failed to find x86_64 AppImage asset in latest release for $UPSTREAM_REPO" >&2
  exit 1
fi

appimage_name="$(jq -r '.name // empty' <<<"$asset_json")"
appimage_url="$(jq -r '.browser_download_url // empty' <<<"$asset_json")"
appimage_sha256="$(jq -r '.digest // empty' <<<"$asset_json")"
appimage_sha256="${appimage_sha256#sha256:}"

if [[ -z "$appimage_name" || -z "$appimage_url" ]]; then
  echo "Incomplete AppImage asset metadata returned by GitHub." >&2
  exit 1
fi

if [[ -z "$appimage_sha256" ]]; then
  tmp_dir="$(mktemp -d)"
  trap 'rm -rf "$tmp_dir"' EXIT
  curl -fL --retry 3 --retry-delay 2 "$appimage_url" -o "$tmp_dir/$appimage_name"
  appimage_sha256="$(sha256sum "$tmp_dir/$appimage_name" | awk '{print $1}')"
fi

upstream_version="${upstream_tag#"$RELEASE_VERSION_PREFIX"}"
pkgver_candidate="$(printf '%s' "$upstream_version" | tr '-' '_' | tr -cd '[:alnum:]_.+')"

previous_sha256=""
if [[ -f "$STATE_FILE" ]]; then
  previous_sha256="$(tr -d '[:space:]' < "$STATE_FILE")"
fi

changed="false"
if [[ "$appimage_sha256" != "$previous_sha256" ]]; then
  changed="true"
fi

printf 'changed=%s\n' "$changed"
printf 'upstream_tag=%s\n' "$upstream_tag"
printf 'upstream_version=%s\n' "$upstream_version"
printf 'pkgver_candidate=%s\n' "$pkgver_candidate"
printf 'appimage_name=%s\n' "$appimage_name"
printf 'appimage_url=%s\n' "$appimage_url"
printf 'appimage_sha256=%s\n' "$appimage_sha256"
printf 'state_file=%s\n' "$STATE_FILE"
printf 'release_prerelease=%s\n' "$RELEASE_PRERELEASE"
printf 'release_tag_regex=%s\n' "$RELEASE_TAG_REGEX"
printf 'release_version_prefix=%s\n' "$RELEASE_VERSION_PREFIX"

if [[ -n "$out_file" ]]; then
  {
    printf 'changed=%s\n' "$changed"
    printf 'upstream_tag=%s\n' "$upstream_tag"
    printf 'upstream_version=%s\n' "$upstream_version"
    printf 'pkgver_candidate=%s\n' "$pkgver_candidate"
    printf 'appimage_name=%s\n' "$appimage_name"
    printf 'appimage_url=%s\n' "$appimage_url"
    printf 'appimage_sha256=%s\n' "$appimage_sha256"
    printf 'state_file=%s\n' "$STATE_FILE"
    printf 'release_prerelease=%s\n' "$RELEASE_PRERELEASE"
    printf 'release_tag_regex=%s\n' "$RELEASE_TAG_REGEX"
    printf 'release_version_prefix=%s\n' "$RELEASE_VERSION_PREFIX"
  } >> "$out_file"
fi
