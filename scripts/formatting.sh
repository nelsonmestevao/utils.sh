#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=./helpers.sh
. "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

__ansi() {
  printf '\e[%sm%s\e[0m\n' "$1" "${*:2}"
}

function bold() {
  __ansi 1 "$@"
}

function italic() {
  __ansi 3 "$@"
}

function underline() {
  __ansi 4 "$@"
}

function strikethrough() {
  __ansi 9 "$@"
}

function format() {
  local -rA COLORS=([black]=30 [red]=31 [green]=32 [yellow]=33 [blue]=34 [magenta]=35 [cyan]=36 [white]=37)
  local -rA TYPES=([bold]=1 [bright]=1 [fade]=2 [italic]=3 [underline]=4 [blink]=5 [inverse]=7 [strikethrough]=9)
  local color=0 type=0
  local texts=()

  # Unknown or missing names fall back to 0 (reset).
  # `shift 2 || shift`, so a flag without a value can't loop forever.
  while (($#)); do
    case "$1" in
      -c | --color)
        color=${COLORS[${2:-reset}]:-0}
        shift 2 || shift
        ;;
      -t | --type)
        type=${TYPES[${2:-reset}]:-0}
        shift 2 || shift
        ;;
      *)
        texts+=("$1")
        shift
        ;;
    esac
  done

  if ((color > 0)); then
    printf '\e[%s;%sm' "$type" "$color"
  else
    printf '\e[0;%sm' "$type"
  fi

  # With no text, only the style is printed, so it applies to what comes next.
  case ${#texts[@]} in
    0) ;;
    1) printf '%s\e[0;0m' "${texts[0]}" ;;
    *) printf '%s\n' "${texts[@]}" && printf '\e[0;0m' ;;
  esac
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then display_version "$UTILS_VERSION"; fi
