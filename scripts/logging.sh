#!/usr/bin/env bash

set -Eeuo pipefail

import() {
  local -r SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")

  # shellcheck source=/dev/null
  . "${SCRIPTS_DIR}/${1}"
}

# shellcheck source=./colors.sh
. "${SCRIPTS_DIR}/colors.sh"

VERSION=0.3.2
get_version() {
  local -r version=0.4.0

  declare -A info=(
    ["full"]=$version
    ["major"]=$(echo $version | cut -d. -f1)
    ["minor"]=$(echo $version | cut -d. -f2)
    ["revision"]=$(echo $version | cut -d. -f3)
  )

  echo "${info[$1:-full]}"
}

function __log() {
  local LABEL="$1"
  local COLOR="$2"
  shift 2
  local MSG=("$@")
  # Get symbols from https://coolsymbol.com/
  printf "_${COLOR}${BOLD}${LABEL}${RESET}_╞%*s\n" $(($(tput cols) - ${#LABEL} - 3)) " " | sed -e 's/ /═/g' | sed -e 's/_/ /g'
  for M in "${MSG[@]}"; do
    echo "• $M"
  done
  printf "%*s\n" "$(tput cols)" " " | sed -e 's/ /═/g'
}

function log_error() {
  __log "FAIL" "$RED" "$@"
}

function log_warn() {
  __log "WARN" "$ORANGE" "$@"
}

function log_success() {
  __log "OK" "$GREEN" "$@"
}

function log_info() {
  local LABEL="INFO"

  if ! [ "$#" -eq 1 ]; then
    LABEL=$(echo "$1" | tr '[:lower:]' '[:upper:]')
    shift 1
  fi

  __log "${LABEL}" "$CYAN" "$@"
}
