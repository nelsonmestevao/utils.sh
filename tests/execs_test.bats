#!/usr/bin/env bats

load ../scripts/execs.sh

setup() {
  export CI=true

  # Keep execute's temporary files inside the test directory
  mktemp() { command mktemp "${BATS_TEST_TMPDIR}/XXXXX"; }
}

@test "__set_trap registers the given command" {
  __set_trap EXIT __kill_all_subprocesses

  [[ "$(trap -p EXIT)" =~ "__kill_all_subprocesses" ]]
}

@test "__set_trap keeps an already registered command" {
  __set_trap EXIT __kill_all_subprocesses
  __set_trap EXIT __kill_all_subprocesses

  [ "$(trap -p EXIT)" = "trap -- '__kill_all_subprocesses' EXIT" ]
}

@test "__print_result with success" {
  run __print_result 0 "message"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "• message ${GREEN}✓${RESET}" ]]
}

@test "__print_result with failure" {
  run __print_result 2 "message"

  [ "$status" -eq 2 ]
  [[ "$output" =~ "• message ${RED}⨯${RESET}" ]]
}

@test "execute with a successful command" {
  run execute "true" "Doing nothing"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "• Doing nothing ${GREEN}✓${RESET}" ]]
  [[ ! "$output" =~ "ERROR" ]]
}

@test "execute uses the command as the default message" {
  run execute "true"

  [ "$status" -eq 0 ]
  [[ "$output" =~ "• true ${GREEN}✓${RESET}" ]]
}

@test "execute with a failing command" {
  run execute "echo first >&2; echo second >&2; exit 3" "Failing"

  [ "$status" -eq 3 ]
  [[ "$output" =~ "• Failing ${RED}⨯${RESET}" ]]
  [ "${lines[1]}" = "    ↳ ${RED}ERROR${RESET}: first" ]
  [ "${lines[2]}" = "    ↳ ${RED}ERROR${RESET}: second" ]
}

@test "execute with a failing command reports it under errexit" {
  # `run` ignores errexit, so use a child shell (without kcov's tracing hooks)
  run env -u BASH_ENV -u PS4 bash -c \
    ". scripts/execs.sh; execute 'exit 3' 'Failing'; echo unreachable"

  [ "$status" -eq 3 ]
  [[ "$output" =~ "• Failing ${RED}⨯${RESET}" ]]
  [[ ! "$output" =~ "unreachable" ]]
}

@test "execute removes its temporary file" {
  run execute "echo boom >&2; false" "Failing"

  [ "$status" -eq 1 ]
  [ -z "$(ls -A "$BATS_TEST_TMPDIR")" ]
}
