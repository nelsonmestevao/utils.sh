#!/usr/bin/env bats

# Only utils.sh, which must bring the logging functions with it
load ../../scripts/utils.sh

setup() {
  cd "$BATS_TEST_TMPDIR"
  cat <<'ENV' >test.env
var1=expected_value1
var2=expected_value2
var3=expected_value3
var4="Hello World"
ENV
}

@test "load_env_file with filename" {
  run load_env_file test.env

  [ "$status" -eq 0 ]
  [[ "${lines[1]}" =~ Loading\ .*test.env.*\.\.\. ]]
}

@test "load_env_file exports the variables" {
  load_env_file test.env >/dev/null

  [ "${var1}" = "expected_value1" ]
  [ "${var2}" = "expected_value2" ]
  [ "${var3}" = "expected_value3" ]
  [ "${var4}" = "Hello World" ]
  [[ "$(declare -p var1)" =~ "declare -x" ]]
}

@test "load_env_file uses .env by default" {
  echo "from_default=yes" >.env

  load_env_file >/dev/null

  [ "${from_default}" = "yes" ]
}

@test "load_env_file with debug flag" {
  run load_env_file --debug test.env

  [ "$status" -eq 0 ]
  [[ "${lines[4]}" =~ "var1=expected_value1" ]]
  [[ "${lines[5]}" =~ "var2=expected_value2" ]]
  [[ "${lines[6]}" =~ "var3=expected_value3" ]]
  [[ "${lines[7]}" =~ "var4=\"Hello World\"" ]]
}

@test "load_env_file exports variables named file, debug and lines" {
  printf 'file=from_env\ndebug=from_env\nlines=from_env\n' >names.env

  load_env_file --debug names.env >/dev/null

  [ "${file}" = "from_env" ]
  [ "${debug}" = "from_env" ]
  [ "${lines}" = "from_env" ]
  [[ "$(declare -p file)" =~ "declare -x" ]]
}

@test "load_env_file with non existing env file" {
  run load_env_file --debug non_existing.env

  [ "$status" -eq 0 ]
  [[ "${lines[1]}" =~ non_existing.env\ file\ not\ found,\ skipping\.\.\. ]]
}
