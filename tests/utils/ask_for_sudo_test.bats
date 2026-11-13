#!/usr/bin/env bats

load ../../scripts/utils.sh

@test "ask_for_sudo asks for the password and keeps sudo alive" {
  sudo() { echo "sudo $*" >>"${BATS_TEST_TMPDIR}/calls"; }
  sleep() { :; }
  # Pretend the script has ended, so the keep-alive loop stops
  kill() { return 1; }

  ask_for_sudo
  wait

  [ "$(<"${BATS_TEST_TMPDIR}/calls")" = $'sudo -v\nsudo -n true' ]
}
