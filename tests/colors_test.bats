#!/usr/bin/env bats

load test_helper

@test "colors use the terminal's codes" {
  run_clean TERM=xterm bash -c '. scripts/colors.sh; echo "$RED"'

  [ "$output" = "$(TERM=xterm tput setaf 1)" ]
}

@test "colors are empty without TERM or on a dumb terminal, instead of failing" {
  local env_arg
  for env_arg in "-u TERM" "TERM=dumb"; do
    # shellcheck disable=SC2086 # split `-u TERM` on purpose
    run_clean $env_arg bash -c 'set -e; . scripts/colors.sh; echo "[${RED}${BOLD}${RESET}]"'

    [ "$status" -eq 0 ]
    [ "$output" = "[]" ]
  done
}
