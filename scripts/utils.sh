#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=./logging.sh
. "$(dirname "${BASH_SOURCE[0]}")/logging.sh"

function is_installed() {
  [ -x "$(command -v "$@")" ]
}

function not_installed() {
  ! is_installed "$@"
}

function load_env_file() {
  # Odd names, so the file's variables (e.g. `file=...`) don't land in these
  # locals instead of being exported
  local __env_debug=0
  local __env_file=".env"
  local __env_lines=()

  while (($#)); do
    case "$1" in
      -d | -dbg | --dbg | --debug) __env_debug=1 ;;
      *) __env_file="$1" ;;
    esac
    shift
  done

  if [ -f "$__env_file" ]; then
    log_info --label "Environment" "Loading ${CYAN}${__env_file}${RESET}..."
    set -o allexport
    # shellcheck source=/dev/null
    source "$__env_file"
    set +o allexport
    if ((__env_debug)); then
      mapfile -t __env_lines <"$__env_file"
      log_debug "${__env_lines[@]}"
    fi
  else
    log_warn "${__env_file} file not found, skipping..."
  fi
}

function ask_for_sudo() {
  # Ask for the administrator password upfront.
  sudo -v &>/dev/null

  # Update existing `sudo` time stamp
  # until this script has finished.
  #
  # https://gist.github.com/cowboy/3118588
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done &>/dev/null &
}

function ensure_confirmation() {
  local confirmation=""

  echo -n "Are you sure you want to proceed? [Y/n] "

  # An empty answer accepts the default, but no input at all (EOF) cancels.
  read -r confirmation || [ -n "$confirmation" ] || confirmation="n"

  case "${confirmation,,}" in
    "" | y | yes) ;;
    *)
      exit_message "Operation cancelled. Exiting..."
      exit 1
      ;;
  esac
}

function get_os_name() {
  uname | tr '[:upper:]' '[:lower:]'
}

function sanitize_name() {
  local name=$1

  # Replace periods and other non-alphanumeric characters with hyphens
  echo "${name//[^a-zA-Z0-9]/-}"
}

# `-u` instead of `--utc`, so it also works with BSD/macOS date.
function datetime() {
  date -u '+%FT%TZ'
}

function timestamp() {
  date -u '+%Y%m%d%H%M%S'
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then display_version "$UTILS_VERSION"; fi
