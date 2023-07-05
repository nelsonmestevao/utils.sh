#!/usr/bin/env bats

@test "get_default_repo_branch returns main if it exists" {
  . scripts/git.sh

  run get_default_repo_branch

  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

