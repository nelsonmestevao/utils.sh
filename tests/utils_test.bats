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
  . scripts/utils.sh

  run load_env_file test.env
  [ "$status" -eq 0 ]

  # Verify that variables are exported
  load_env_file test.env
  [ "${var1}" = "expected_value1" ]
  [ "${var2}" = "expected_value2" ]
  [ "${var3}" = "expected_value3" ]
  [ "${var4}" = "Hello World" ]

  # Split the output string into an array
  mapfile -t output_lines <<<"$output"

  # Check the second line of output with a regex
  [[ "${output_lines[1]}" =~ Loading\ .*test.env.*\.\.\. ]]
}

@test "load_env_file with debug flag" {
  . scripts/utils.sh

  run load_env_file --debug test.env
  [ "$status" -eq 0 ]

  # Verify that variables are exported
  load_env_file test.env
  [ "${var1}" = "expected_value1" ]
  [ "${var2}" = "expected_value2" ]
  [ "${var3}" = "expected_value3" ]
  [ "${var4}" = "Hello World" ]

  # Split the output string into an array
  mapfile -t output_lines <<<"$output"

  # Check the debug output is shown
  [[ "${output_lines[4]}" =~ "var1=expected_value1" ]]
  [[ "${output_lines[5]}" =~ "var2=expected_value2" ]]
  [[ "${output_lines[6]}" =~ "var3=expected_value3" ]]
  [[ "${output_lines[7]}" =~ "var4=\"Hello World\"" ]]
}

@test "load_env_file with non existing env file" {
  . scripts/utils.sh

  run load_env_file --debug non_existing.env
  [ "$status" -eq 0 ]

  # Split the output string into an array
  mapfile -t output_lines <<<"$output"

  # Check the debug output is shown
  [[ "${output_lines[1]}" =~ non_existing.env\ file\ not\ found,\ skipping\.\.\. ]]
}
