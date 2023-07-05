#!/usr/bin/env bats

setup() {
  # Create a temporary test.env file with the expected contents
  cat <<EOF >test.env
var1=expected_value1
var2=expected_value2
var3=expected_value3
var4="Hello World"
EOF
}

teardown() {
  # Remove the temporary test.env file
  rm test.env
}

@test "load_env_file with filename" {
  . scripts/logging.sh
  . scripts/utils.sh

  run load_env_file test.env
  echo $output
  [ "$status" -eq 0 ]

  # Verify that variables are exported
  load_env_file test.env
  [ "${var1}" = "expected_value1" ]
  [ "${var2}" = "expected_value2" ]
  [ "${var3}" = "expected_value3" ]
  [ "${var4}" = "Hello World" ]

  # Check the second line of output with a regex
  [[ "${lines[1]}" =~ Loading\ .*test.env.*\.\.\. ]]
}

@test "load_env_file with debug flag" {
  . scripts/logging.sh
  . scripts/utils.sh

  run load_env_file --debug test.env
  [ "$status" -eq 0 ]

  # Verify that variables are exported
  load_env_file test.env
  [ "${var1}" = "expected_value1" ]
  [ "${var2}" = "expected_value2" ]
  [ "${var3}" = "expected_value3" ]
  [ "${var4}" = "Hello World" ]

  # Check the debug output is shown
  [[ "${lines[4]}" =~ "var1=expected_value1" ]]
  [[ "${lines[5]}" =~ "var2=expected_value2" ]]
  [[ "${lines[6]}" =~ "var3=expected_value3" ]]
  [[ "${lines[7]}" =~ "var4=\"Hello World\"" ]]
}

@test "load_env_file with non existing env file" {
  . scripts/logging.sh
  . scripts/utils.sh

  run load_env_file --debug non_existing.env
  [ "$status" -eq 0 ]

  # Check the debug output is shown
  [[ "${lines[1]}" =~ non_existing.env\ file\ not\ found,\ skipping\.\.\. ]]
}
