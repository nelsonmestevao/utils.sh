#!/usr/bin/env bats

load ../scripts/git.sh

@test "get_default_repo_branch returns main if it exists" {
  run get_default_repo_branch

  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}
