#!/usr/bin/env bats

load ../../scripts/utils.sh

@test "get_os_name returns the lowercase kernel name" {
  run get_os_name

  [ "$status" -eq 0 ]
  [ "$output" = "$(uname | tr '[:upper:]' '[:lower:]')" ]
  [[ "$output" =~ ^[a-z]+$ ]]
}
