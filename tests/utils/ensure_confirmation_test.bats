#!/usr/bin/env bats

load ../../scripts/utils.sh

@test "ensure_confirmation accepts y, yes and an empty answer, in any case" {
  local answer
  for answer in Y y yes YES ''; do
    run ensure_confirmation <<<"$answer"

    [ "$status" -eq 0 ]
    [[ ! "$output" =~ "cancelled" ]]
  done
}

@test "ensure_confirmation cancels on any other answer" {
  local answer
  for answer in N n no nope; do
    run ensure_confirmation <<<"$answer"

    [ "$status" -eq 1 ]
    [[ "$output" =~ "Operation cancelled" ]]
  done
}

@test "ensure_confirmation cancels when there is no input" {
  run ensure_confirmation </dev/null

  [ "$status" -eq 1 ]
  [[ "$output" =~ "Operation cancelled" ]]
}

@test "ensure_confirmation accepts an answer without a trailing newline" {
  run ensure_confirmation < <(printf 'y')

  [ "$status" -eq 0 ]
}
