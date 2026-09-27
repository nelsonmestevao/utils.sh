#!/usr/bin/env bats

load ../../scripts/utils.sh

@test "is_installed with an existing command" {
  run is_installed bash
  [ "$status" -eq 0 ]
}

@test "is_installed with a missing command" {
  run is_installed this-command-does-not-exist
  [ "$status" -eq 1 ]
}

@test "not_installed with an existing command" {
  run not_installed bash
  [ "$status" -eq 1 ]
}

@test "not_installed with a missing command" {
  run not_installed this-command-does-not-exist
  [ "$status" -eq 0 ]
}
