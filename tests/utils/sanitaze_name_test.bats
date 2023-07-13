#!/usr/bin/env bats

@test "sanitize_name with alphanumeric characters" {
  . scripts/utils.sh

  result="$(sanitize_name 'testName123')"

  [ "$result" == "testName123" ]
}

@test "sanitize_name with non-alphanumeric characters" {
  . scripts/utils.sh

  result="$(sanitize_name 'test.Name@123')"

  [ "$result" == "test-Name-123" ]
}

@test "sanitize_name with periods" {
  . scripts/utils.sh

  result="$(sanitize_name 'test.name')"

  [ "$result" == "test-name" ]
}

@test "sanitize_name with spaces" {
  . scripts/utils.sh

  result="$(sanitize_name 'test name')"

  [ "$result" == "test-name" ]
}

@test "sanitize_name with multiple non-alphanumeric characters" {
  . scripts/utils.sh

  result="$(sanitize_name 'test@name.com')"

  [ "$result" == "test-name-com" ]
}