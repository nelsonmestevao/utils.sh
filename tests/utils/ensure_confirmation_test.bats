#!/usr/bin/env bats

@test "ensure_confirmation with Y input" {
  . scripts/utils.sh
  run 'ensure_confirmation' <<<'Y'
  [ "$status" -eq 0 ] # Check that the script exited normally
}

@test "ensure_confirmation with y input" {
  . scripts/utils.sh
  run 'ensure_confirmation' <<<'y'
  [ "$status" -eq 0 ] # Check that the script exited normally
}

@test "ensure_confirmation with N input" {
  . scripts/utils.sh
  run 'ensure_confirmation' <<<'N'
  [ "$status" -eq 1 ] # Check that the script exited with error status
}

@test "ensure_confirmation with n input" {
  . scripts/utils.sh
  run 'ensure_confirmation' <<<'n'
  [ "$status" -eq 1 ] # Check that the script exited with error status
}

@test "ensure_confirmation with no input" {
  . scripts/utils.sh
  run 'ensure_confirmation' <<<''
  [ "$status" -eq 0 ] # Check that the script exited normally (default is y)
}
