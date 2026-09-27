#!/usr/bin/env bats

@test "log_error function runs without errors and produces output" {
  . scripts/logging.sh

  run log_error "This is a test error message"

  [ "$status" -eq 0 ]
  [ "${#output}" -gt 0 ]
  [ "${lines[1]}" = "• This is a test error message" ]
}

@test "log_warn function runs without errors and produces output" {
  . scripts/logging.sh

  run log_warn "This is a test warning message"

  [ "$status" -eq 0 ]
  [ "${#output}" -gt 0 ]
  [ "${lines[1]}" = "• This is a test warning message" ]
}

@test "log_success function runs without errors and produces output" {
  . scripts/logging.sh

  run log_success "This is a test success message"

  [ "$status" -eq 0 ]
  [ "${#output}" -gt 0 ]
  [ "${lines[1]}" = "• This is a test success message" ]
}

@test "log_info function runs without errors and produces output" {
  . scripts/logging.sh

  run log_info "This is a test info message"

  [ "$status" -eq 0 ]
  [ "${#output}" -gt 0 ]
  [ "${lines[1]}" = "• This is a test info message" ]
}

@test "log_info function runs with custom label without errors and produces output" {
  . scripts/logging.sh

  run log_info --label "example" "This is a test info message"

  [ "$status" -eq 0 ]
  [ "${#output}" -gt 0 ]
  [[ "${lines[0]}" =~ "EXAMPLE" ]]
  [ "${lines[1]}" = "• This is a test info message" ]
}

@test "log_debug function runs without errors and produces output" {
  . scripts/logging.sh

  run log_debug "This is a test debug message"

  [ "$status" -eq 0 ]
  [ "${#output}" -gt 0 ]
  [ "${lines[1]}" = "• This is a test debug message" ]
}

@test "log_info treats arguments after -- as messages" {
  . scripts/logging.sh

  run log_info -- "--not-a-flag"

  [ "$status" -eq 0 ]
  [ "${lines[1]}" = "• --not-a-flag" ]
}

@test "log_info with an unsupported flag fails" {
  . scripts/logging.sh

  run log_info --bogus "message"

  [ "$status" -eq 1 ]
  [[ "$output" =~ "Unsupported flag '--bogus'" ]]
}

@test "log functions below LOG_LEVEL produce no output" {
  . scripts/logging.sh
  LOG_LEVEL=ERROR

  run log_info "hidden"
  [ "$status" -eq 0 ]
  [ -z "$output" ]

  run log_error "shown"
  [ "${lines[1]}" = "• shown" ]
}
