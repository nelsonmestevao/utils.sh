#!/usr/bin/env bats

load ../scripts/helpers.sh

@test "display_version without figlet" {
  command() { [ "${2:-}" = "figlet" ] && return 1 || builtin command "$@"; }

  run display_version 1.2.3 program

  [ "$status" -eq 0 ]
  [ "$output" = "program script version 1.2.3" ]
}

@test "display_version with figlet" {
  mkdir -p "${BATS_TEST_TMPDIR}/bin"
  printf '#!/usr/bin/env bash\necho "FIGLET $*"\n' >"${BATS_TEST_TMPDIR}/bin/figlet"
  chmod +x "${BATS_TEST_TMPDIR}/bin/figlet"
  PATH="${BATS_TEST_TMPDIR}/bin:$PATH"

  run display_version 1.2.3 program

  [ "$status" -eq 0 ]
  [[ "${lines[0]}" =~ "FIGLET program script" ]]
  [ "${lines[1]}" = "${RESET}version 1.2.3" ]
}

@test "display_version without version fails" {
  run display_version

  [ "$status" -ne 0 ]
  [[ "$output" =~ "You need to give a version number" ]]
}

@test "help_title_section uppercases the title" {
  run help_title_section "usage info"

  [ "$status" -eq 0 ]
  [ "$output" = "${BOLD}USAGE INFO${RESET}" ]
}
