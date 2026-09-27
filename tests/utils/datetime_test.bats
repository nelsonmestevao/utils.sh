#!/usr/bin/env bats

load ../../scripts/utils.sh

@test "datetime returns an ISO 8601 UTC date" {
  run datetime

  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z$ ]]
}

@test "timestamp returns a compact UTC date" {
  run timestamp

  [ "$status" -eq 0 ]
  [[ "$output" =~ ^[0-9]{14}$ ]]
}
