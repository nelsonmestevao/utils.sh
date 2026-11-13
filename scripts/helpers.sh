#!/usr/bin/env bash

set -Eeuo pipefail

# Every module sources this file, so skip the work when it already ran
if declare -F display_version >/dev/null; then return 0; fi

# shellcheck source=./colors.sh
. "$(dirname "${BASH_SOURCE[0]}")/colors.sh"

# The version every script prints when it runs directly
UTILS_VERSION=0.16.0

function display_version() {
  local -r version=${1:?"You need to give a version number"}
  local -r program=${2:-$(basename "$0")}

  if command -v figlet &>/dev/null; then
    printf '%s' "${BLUE}${BOLD}"
    figlet "${program} script"
    printf '%s' "${RESET}"
    echo "version ${version}"
  else
    echo "${program} script version ${version}"
  fi
}

function help_title_section() {
  # "$*" joins with the first character of IFS, which callers may change
  local IFS=' '
  printf '%s\n' "${BOLD}${*^^}${RESET}"
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then display_version "$UTILS_VERSION"; fi
