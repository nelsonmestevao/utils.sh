#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=./helpers.sh
. "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Global (-g), so it still exists when this file is sourced inside a function.
declare -gA LOG_LEVELS=([DEBUG]=0 [INFO]=1 [WARNING]=3 [ERROR]=4)

# Set default log level
LOG_LEVEL=${LOG_LEVEL:-"DEBUG"}

function exit_message() {
  printf '\n %s %s %s\n\n' "${RED}>>>${RESET}" "${BOLD}${YELLOW}$1${RESET}" "${RED}⨯${RESET}" >&2
}

function __log() {
  local -r LEVEL="$1" LABEL="$2" COLOR="$3"
  local -r MIN_LEVEL=${LOG_LEVEL:-DEBUG}
  shift 3

  # The level is case-insensitive, and an unknown one falls back to INFO.
  if [ "${LOG_LEVELS[$LEVEL]}" -lt "${LOG_LEVELS[${MIN_LEVEL^^}]:-${LOG_LEVELS[INFO]}}" ]; then
    return 0
  fi

  local size pad_size pad line msg
  size=$(__tput cols)
  size=${size:-80}
  size=$((size < 80 ? size : 80))
  pad_size=$((size - ${#LABEL} - 3))

  # Pad with spaces, then swap them for ═ (spaces in the label stay intact).
  printf -v pad '%*s' "$((pad_size > 0 ? pad_size : 1))" ''
  printf -v line '%*s' "$size" ''

  # Get symbols from https://coolsymbol.com/
  printf ' %s ╞%s\n' "${COLOR}${BOLD}${LABEL}${RESET}" "${pad// /═}"
  for msg in "$@"; do
    echo "• $msg"
  done
  echo "${line// /═}"
}

function log_error() {
  __log "ERROR" "FAIL" "$RED" "$@" >&2
}

function log_warn() {
  __log "WARNING" "WARN" "$YELLOW" "$@" >&2
}

function log_success() {
  __log "INFO" "OK" "$GREEN" "$@"
}

function log_info() {
  local LABEL="INFO"
  local MSGS=()

  while (($#)); do
    case "$1" in
      --label)
        LABEL=${2^^}
        shift 2
        ;;
      --) # end argument parsing
        shift
        MSGS+=("$@")
        break
        ;;
      -*) # unsupported flags
        exit_message "Unsupported flag '$1' in 'log_info()' function"
        exit 1
        ;;
      *) # preserve positional arguments
        MSGS+=("$1")
        shift
        ;;
    esac
  done

  __log "INFO" "$LABEL" "$BLUE" "${MSGS[@]}"
}

function log_debug() {
  __log "DEBUG" "DEBUG" "$MAGENTA" "$@"
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then display_version "$UTILS_VERSION"; fi
