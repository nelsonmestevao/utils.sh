#!/usr/bin/env bash

set -Eeuo pipefail

# shellcheck source=./helpers.sh
. "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"

# Add a command to a signal's trap, keeping the commands already there.
__set_trap() {
  local -r signal="$1" cmd="$2" newline=$'\n'
  local current=""

  # Skip this in a subshell: there `trap -p` shows the parent's commands,
  # which must not run again when the subshell ends. The downside: a trap the
  # subshell set itself is also replaced, as bash can't tell the two apart.
  if [ "$BASHPID" = "$$" ]; then
    # `trap -p` prints `trap -- 'commands' SIGNAL`, so the commands end up in $3.
    eval "set -- $(trap -p "$signal")"
    current="${3:-}"
  fi

  if [[ "$current" != *"$cmd"* ]]; then
    # Join with a newline, not `;`, in case the commands end in a comment or `&`.
    # shellcheck disable=SC2064 # expand the commands now, on purpose
    trap "${current:+$current$newline}$cmd" "$signal"
  fi
}

# Runs on exit, in case the script ends in the middle of `execute`: ends the
# jobs still running and removes the file with their output.
__execute_cleanup() {
  local pid

  # Jobs may end on their own meanwhile, and their exit codes must not
  # replace the script's own exit code.
  for pid in $(jobs -p); do
    kill "$pid" &>/dev/null || true
    wait "$pid" &>/dev/null || true
  done

  if [ -n "${__EXECUTE_OUTPUT:-}" ]; then
    rm -f "$__EXECUTE_OUTPUT"
  fi
}

__print_error_stream() {
  local line

  # `|| [ -n "$line" ]` keeps a last line that has no trailing newline.
  while IFS= read -r line || [ -n "$line" ]; do
    printf '    ↳ %s: %s\n' "${RED}ERROR${RESET}" "$line"
  done
}

__print_result() {
  if [ "$1" -eq 0 ]; then
    printf ' • %s %s\n' "$2" "${GREEN}✓${RESET}"
  else
    printf ' • %s %s\n' "$2" "${RED}⨯${RESET}"
  fi
}

# Ideas from https://github.com/alrra/dotfiles/blob/main/src/os/utils.sh
__show_spinner() {
  local -r PID="$1" MSG="$2"
  # An array, as slicing a string would cut these multibyte characters in the
  # C locale (cron, Docker).
  local -ra FRAMES=(⡿ ⣟ ⣯ ⣷ ⣾ ⣽ ⣻ ⢿)
  local -r RESTORE_CURSOR=$(__tput rc)
  local i=0

  # Make room below, so the text doesn't reach the bottom line of the
  # terminal: the saved cursor position doesn't follow the scrolling.
  # See also: https://unix.stackexchange.com/a/278888
  printf '\n\n\n'
  __tput cuu 3
  __tput sc

  while kill -0 "$PID" &>/dev/null; do
    printf ' • %s %s\n' "$MSG" "${FRAMES[i++ % ${#FRAMES[@]}]}"
    sleep 0.2
    printf '%s' "$RESTORE_CURSOR"
  done
}

function execute() {
  local -r CMDS="$1"
  local -r MSG="${2:-$1}"

  local exitCode=0
  local cmdsPID=""

  # Global, so the cleanup on exit can find it.
  __EXECUTE_OUTPUT="$(mktemp)"
  __set_trap "EXIT" "__execute_cleanup"

  # Execute commands in background
  eval "$CMDS" &>"$__EXECUTE_OUTPUT" &
  cmdsPID=$!

  # Animate only on a terminal that can save the cursor position (not
  # TERM=dumb or unset). Logs and pipes get just the result line.
  if [ -t 1 ] && [ -n "$(__tput sc)" ]; then
    __show_spinner "$cmdsPID" "$MSG"
  fi

  # Wait for the commands to no longer be executing
  # in the background, and then get their exit code.
  wait "$cmdsPID" &>/dev/null || exitCode=$?

  __print_result "$exitCode" "$MSG"

  if [ "$exitCode" -ne 0 ]; then
    __print_error_stream <"$__EXECUTE_OUTPUT"
  fi

  rm -f "$__EXECUTE_OUTPUT"
  __EXECUTE_OUTPUT=""

  return "$exitCode"
}

if [ "$0" = "${BASH_SOURCE[0]}" ]; then display_version "$UTILS_VERSION"; fi
