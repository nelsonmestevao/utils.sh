#!/bin/sh -n
# shellcheck disable=SC2034 # used by the scripts that source this file

# The one way to call tput in these scripts: prints the value or nothing, and
# never fails or prints errors, so it can't end scripts that run with `set -e`.
# - TERM: bash sets it to "dumb" without exporting it when it's missing.
# - <&2: inside $(...) stdout is a pipe, and with stderr silenced, stdin is
#   left as the way for tput to find the terminal (e.g. for `cols`).
__tput() { TERM="${TERM:-dumb}" tput "$@" <&2 2>/dev/null || true; }

BLACK=$(__tput setaf 0)
RED=$(__tput setaf 1)
GREEN=$(__tput setaf 2)
YELLOW=$(__tput setaf 3)
BLUE=$(__tput setaf 4)
MAGENTA=$(__tput setaf 5)
CYAN=$(__tput setaf 6)
WHITE=$(__tput setaf 7)
BOLD=$(__tput bold)
UNDERLINE=$(__tput smul)
REVERSE=$(__tput rev)
RESET=$(__tput sgr0)
