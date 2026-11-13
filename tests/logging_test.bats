#!/usr/bin/env bats

# For `run --separate-stderr`
bats_require_minimum_version 1.5.0

load test_helper
# `load` sources the file inside a function, which also checks that the
# log levels stay global
load ../scripts/logging.sh

@test "log_error and log_warn print their label and message to stderr" {
  local spec
  for spec in log_error:FAIL log_warn:WARN; do
    run --separate-stderr "${spec%:*}" "message"

    [ "$status" -eq 0 ]
    [ -z "$output" ]
    [[ "${stderr_lines[0]}" =~ ${spec#*:} ]]
    [ "${stderr_lines[1]}" = "• message" ]
  done
}

@test "log_info, log_success and log_debug print their label and message to stdout" {
  local spec
  for spec in log_info:INFO log_success:OK log_debug:DEBUG; do
    run --separate-stderr "${spec%:*}" "message"

    [ "$status" -eq 0 ]
    [ -z "$stderr" ]
    [[ "${lines[0]}" =~ ${spec#*:} ]]
    [ "${lines[1]}" = "• message" ]
  done
}

@test "exit_message prints to stderr" {
  run --separate-stderr exit_message "message"

  [ "$status" -eq 0 ]
  [ -z "$output" ]
  [[ "$stderr" =~ "message" ]]
}

@test "log functions print one line per message" {
  run log_info "first" "second"

  [ "${lines[1]}" = "• first" ]
  [ "${lines[2]}" = "• second" ]
}

@test "log_info with a custom label" {
  run log_info --label "example" "This is a test info message"

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ "EXAMPLE" ]]
  [ "${lines[1]}" = "• This is a test info message" ]
}

@test "log_info keeps spaces and underscores in the label" {
  BLUE="" BOLD="" RESET=""
  tput() { echo 80; }

  run log_info --label "my env_x" "message"

  [ "${lines[0]}" = " MY ENV_X ╞$(repeat ═ 69)" ]
}

@test "log_info treats arguments after -- as messages" {
  run log_info -- "--not-a-flag"

  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "• --not-a-flag" ]
}

@test "log_info with an unsupported flag fails" {
  run log_info --bogus "message"

  [ "$status" -eq 1 ]
  [[ "$output" =~ "Unsupported flag '--bogus'" ]]
}

@test "log lines fit the terminal, up to 80 columns" {
  local spec
  for spec in 120:80 40:40; do
    tput() { echo "${spec%:*}"; }

    run log_info "message"

    [ "${lines[2]}" = "$(repeat ═ "${spec#*:}")" ]
  done
}

@test "log lines are 80 columns wide when the terminal size is unknown" {
  tput() { return 1; }

  run log_info "message"

  [ "$status" -eq 0 ]
  [ "${lines[2]}" = "$(repeat ═ 80)" ]
}

@test "log lines fit the terminal even when stdin is not a terminal" {
  run_in_terminal xterm 'stty cols 40; . scripts/logging.sh; log_info hi </dev/null'

  [ "$status" -eq 0 ]
  [ "${lines[2]%$'\r'}" = "$(repeat ═ 40)" ]
}

@test "log functions work without TERM" {
  run_clean -u TERM bash -c '. scripts/logging.sh; log_info hello'

  [ "$status" -eq 0 ]
  [[ ! "$output" =~ "tput" ]]
  [ "${lines[1]}" = "• hello" ]
  [ "${lines[2]}" = "$(repeat ═ 80)" ]
}

@test "log functions below LOG_LEVEL produce no output" {
  LOG_LEVEL=ERROR

  run log_info "hidden"
  [ "$status" -eq 0 ]
  [ -z "$output" ]

  run log_error "shown"
  [ "${lines[1]}" = "• shown" ]
}

@test "LOG_LEVEL=WARNING shows only warnings and errors, in any case" {
  for LOG_LEVEL in WARNING warning; do
    run log_info "hidden"
    [ -z "$output" ]

    run log_warn "shown"
    [ "${lines[1]}" = "• shown" ]

    run log_error "shown"
    [ "${lines[1]}" = "• shown" ]
  done
}

@test "an unknown LOG_LEVEL falls back to INFO" {
  for LOG_LEVEL in bogus WARN; do
    run log_debug "hidden"
    [ "$status" -eq 0 ]
    [ -z "$output" ]

    run log_info "shown"
    [ "${lines[1]}" = "• shown" ]
  done
}

@test "exit_message prints the message as it is" {
  run exit_message 'C:\temp'

  [ "$status" -eq 0 ]
  [ "${lines[0]}" = " ${RED}>>>${RESET} ${BOLD}${YELLOW}C:\\temp${RESET} ${RED}⨯${RESET}" ]
}
