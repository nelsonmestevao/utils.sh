#!/usr/bin/env bats

load test_helper
load ../scripts/execs.sh

setup() {
  # Keep execute's temporary files in a folder of their own
  export TMPDIR="${BATS_TEST_TMPDIR}/tmp"
  mkdir -p "$TMPDIR"
}

# Run code in a child shell, after sourcing execs.sh.
# Extra arguments become $1, $2, ... in the code.
run_in_bash() {
  run_clean bash -c ". scripts/execs.sh; $1" bash "${@:2}"
}

@test "__set_trap registers the given command" {
  __set_trap EXIT __execute_cleanup

  [[ "$(trap -p EXIT)" =~ "__execute_cleanup" ]]
}

@test "__set_trap keeps the commands already there and adds its own once" {
  run_in_bash '
    trap "echo cleanup" EXIT
    __set_trap EXIT "echo added"
    __set_trap EXIT "echo added"'

  [ "$status" -eq 0 ]
  [ "$output" = $'cleanup\nadded' ]
}

@test "__set_trap works after a trap that ends in a comment or a newline" {
  local trap_cmd
  for trap_cmd in "echo cleanup # tidy" $'echo cleanup\n'; do
    run_in_bash 'trap "$1" EXIT; __set_trap EXIT "echo added"' "$trap_cmd"

    [ "$status" -eq 0 ]
    [ "$output" = $'cleanup\nadded' ]
  done
}

@test "__set_trap in a subshell leaves out the parent's commands" {
  run_in_bash '
    trap "echo parent" EXIT
    echo "$(__set_trap EXIT __execute_cleanup; trap -p EXIT)"'

  [ "$output" = $'trap -- \'__execute_cleanup\' EXIT\nparent' ]
}

@test "__execute_cleanup ends the running jobs and removes the output file" {
  sleep 30 &
  local -r pid=$!
  __EXECUTE_OUTPUT="$(mktemp)"

  __execute_cleanup

  run kill -0 "$pid"
  [ "$status" -ne 0 ]
  [ ! -e "$__EXECUTE_OUTPUT" ]
}

@test "__print_result with success" {
  run __print_result 0 "message"

  [ "$status" -eq 0 ]
  [ "$output" = " • message ${GREEN}✓${RESET}" ]
}

@test "__print_result with failure" {
  run __print_result 2 "message"

  [ "$status" -eq 0 ]
  [ "$output" = " • message ${RED}⨯${RESET}" ]
}

@test "__show_spinner shows a frame for each check while the process runs" {
  # The C locale counts bytes, so this also checks that the multibyte
  # frames are not cut in pieces
  local LC_ALL=C
  tput() { :; }
  sleep() { :; }
  # The process is running for two checks, then ends
  local checks=0
  kill() { ((checks++ < 2)); }

  run __show_spinner 1234 "Working"

  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = " • Working ⡿" ]
  [ "${lines[1]}" = " • Working ⣟" ]
}

@test "execute with a successful command" {
  run execute "true" "Doing nothing"

  [ "$status" -eq 0 ]
  # No spinner frames outside a terminal, only the result
  [ "$output" = " • Doing nothing ${GREEN}✓${RESET}" ]
}

@test "execute uses the command as the default message" {
  run execute "true"

  [ "$status" -eq 0 ]
  [ "$output" = " • true ${GREEN}✓${RESET}" ]
}

@test "execute with a failing command" {
  run execute "echo first >&2; echo second >&2; exit 3" "Failing"

  [ "$status" -eq 3 ]
  [ "${lines[0]}" = " • Failing ${RED}⨯${RESET}" ]
  [ "${lines[1]}" = "    ↳ ${RED}ERROR${RESET}: first" ]
  [ "${lines[2]}" = "    ↳ ${RED}ERROR${RESET}: second" ]
}

@test "execute prints the message and error lines as they are" {
  run execute "echo '  C:\\new' >&2; printf 'no newline' >&2; false" 'Path C:\temp'

  [ "$status" -eq 1 ]
  [ "${lines[0]}" = " • Path C:\\temp ${RED}⨯${RESET}" ]
  [ "${lines[1]}" = "    ↳ ${RED}ERROR${RESET}:   C:\\new" ]
  [ "${lines[2]}" = "    ↳ ${RED}ERROR${RESET}: no newline" ]
}

@test "execute with a failing command reports it under errexit" {
  # `run` ignores errexit, so use a child shell
  run_in_bash "execute 'exit 3' 'Failing'; echo unreachable"

  [ "$status" -eq 3 ]
  [[ "$output" =~ "• Failing ${RED}⨯${RESET}" ]]
  [[ ! "$output" =~ "unreachable" ]]
}

@test "execute keeps the caller's EXIT trap" {
  run_in_bash 'trap "echo cleanup" EXIT; execute true Working'

  [ "$status" -eq 0 ]
  [ "${lines[-1]}" = "cleanup" ]
}

@test "on exit, running jobs end and the exit code stays the same" {
  run_in_bash 'execute true Working; sleep 30 &>/dev/null & echo "$!" >"$1"; exit 0' \
    "${BATS_TEST_TMPDIR}/pid"

  [ "$status" -eq 0 ]
  [[ ! "$output" =~ "No such process" ]]
  run kill -0 "$(<"${BATS_TEST_TMPDIR}/pid")"
  [ "$status" -ne 0 ]
}

@test "execute removes its temporary file" {
  run execute "echo boom >&2; false" "Failing"

  [ "$status" -eq 1 ]
  [ -z "$(ls -A "$TMPDIR")" ]
}

@test "execute removes its temporary file when the script is killed" {
  # The command kills the script ($$) in the middle of `execute`. `exec`, so
  # the cleanup ends the sleep too, instead of leaving it to hold bats' output.
  run_in_bash 'execute "kill -TERM \$\$; exec sleep 5" Working'

  [ "$status" -eq 143 ]
  [ -z "$(ls -A "$TMPDIR")" ]
}

@test "execute shows a spinner on a terminal" {
  run_in_terminal xterm '. scripts/execs.sh; execute "sleep 0.1" Sleeping'

  [ "$status" -eq 0 ]
  [[ "$output" == *"Sleeping ⡿"* ]]
  [[ "$output" == *"Sleeping "*"✓"* ]]
}

@test "execute on a terminal without cursor support shows only the result" {
  local term
  for term in dumb ""; do
    run_in_terminal "$term" '. scripts/execs.sh; execute "sleep 0.05" Sleeping; echo after'

    [ "$status" -eq 0 ]
    [[ "$output" != *"⡿"* ]]
    [[ "$output" == *"Sleeping ✓"*"after"* ]]
  done
}
