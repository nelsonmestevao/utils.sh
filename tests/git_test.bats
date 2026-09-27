#!/usr/bin/env bats

load ../scripts/git.sh

@test "get_default_repo_branch returns main if it exists" {
  run get_default_repo_branch

  [ "$status" -eq 0 ]
  [ "$output" = "main" ]
}

@test "get_default_repo_branch returns trunk if main does not exist" {
  cd "$BATS_TEST_TMPDIR"
  git init -q -b trunk
  git -c user.name=test -c user.email=test@example.com commit -q --allow-empty -m init

  run get_default_repo_branch

  [ "$status" -eq 0 ]
  [ "$output" = "trunk" ]
}

@test "get_default_repo_branch falls back to master" {
  cd "$BATS_TEST_TMPDIR"
  git init -q -b feature

  run get_default_repo_branch

  [ "$status" -eq 0 ]
  [ "$output" = "master" ]
}

@test "get_default_repo_branch outside a repository returns nothing" {
  cd "$BATS_TEST_TMPDIR"
  export GIT_CEILING_DIRECTORIES="$BATS_TEST_TMPDIR"

  run get_default_repo_branch

  [ "$status" -ne 0 ]
  [ -z "$output" ]
}
