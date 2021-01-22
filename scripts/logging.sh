#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPTS_DIR=$(dirname "${BASH_SOURCE[0]:-$0}")

# shellcheck source=./colors.sh
. "${SCRIPTS_DIR}/colors.sh"

VERSION=0.3.1

function __log() {
  local LABEL="$1"
  local COLOR="$2"
  shift 2
  local MSG=("$@")
  # Get symbols from https://coolsymbol.com/
  printf "_${COLOR}${BOLD}${LABEL}${RESET}_╞%*s\n" $(($(tput cols) - ${#LABEL} - 3)) | sed -e 's/ /═/g' | sed -e 's/_/ /g'
  for M in "${MSG[@]}"; do
    echo "• $M"
  done
  printf "%*s\n" $(tput cols) | sed -e 's/ /═/g'
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
    LABEL=$(echo "$1" | tr '[a-z]' '[A-Z]')
    shift 1
  fi

  __log "${LABEL}" "$CYAN" "$@"
}
