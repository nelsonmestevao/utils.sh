#!/usr/bin/env bash

set -Eeuo pipefail

import() {
  local -r SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")

  # shellcheck source=/dev/null
  . "${SCRIPTS_DIR}/${1}"
}

# shellcheck source=./colors.sh
import colors.sh

function help_title_section() {
  local -r TITLE=$(echo "$@" | tr '[:lower:]' '[:upper:]')
  echo -e "${BOLD}${TITLE}${RESET}"
}

function get_version() {
  local -r version=${2:-0.4.0}

  declare -A info=(
    ["full"]=$version
    ["major"]=$(echo "$version" | cut -d. -f1)
    ["minor"]=$(echo "$version" | cut -d. -f2)
    ["revision"]=$(echo "$version" | cut -d. -f3)
  )

  echo "${info[${1:-full}]}"
}

function display_version() {
  local program="${1:-$(basename "$0")}"
  local version=${2:-$(get_version)}
  if not_installed figlet; then
    echo "${program} script version ${version}"
  else
    echo -n "${BLUE}${BOLD}"
    figlet "${program} script"
    echo -n "${RESET}"
    echo "version ${version}"
  fi
}
