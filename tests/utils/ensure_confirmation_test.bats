#!/usr/bin/env bats

load ../../scripts/colors.sh
load ../../scripts/utils.sh

@test "ensure_confirmation with Y input" {
  run 'ensure_confirmation' <<<'Y'
  [ "$status" -eq 0 ]
}

@test "ensure_confirmation with y input" {
  run 'ensure_confirmation' <<<'y'
  [ "$status" -eq 0 ]
}

@test "ensure_confirmation with N input" {
  run 'ensure_confirmation' <<<'N'
  [ "$status" -eq 1 ]
}

@test "ensure_confirmation with n input" {
  run 'ensure_confirmation' <<<'n'
  [ "$status" -eq 1 ]
}

@test "ensure_confirmation with no input" {
  run 'ensure_confirmation' <<<''
  [ "$status" -eq 0 ]
}
