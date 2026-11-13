#!/usr/bin/env bash
#
# Bump the version that every script prints when it runs directly.
# Usage: ./increment_scripts_versions.sh [major|minor|patch]

set -Eeuo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

current=$(sed -n 's/^UTILS_VERSION=//p' scripts/helpers.sh)
IFS=. read -r major minor patch <<<"$current"

case "${1:-patch}" in
  major) new="$((major + 1)).0.0" ;;
  minor) new="${major}.$((minor + 1)).0" ;;
  patch) new="${major}.${minor}.$((patch + 1))" ;;
  *)
    echo "Usage: $0 [major|minor|patch]" >&2
    exit 1
    ;;
esac

sed -i "s/^UTILS_VERSION=.*/UTILS_VERSION=${new}/" scripts/helpers.sh
echo "${current} -> ${new}"
