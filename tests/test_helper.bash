# Helpers shared by the tests. Load with `load test_helper`.

# Like `run`, but in a child process without kcov's tracing hooks (BASH_ENV
# and PS4), which would trace child shells too. Takes `env` arguments first,
# e.g. `run_clean -u TERM bash -c '...'`.
run_clean() {
  run env -u BASH_ENV -u PS4 "$@"
}

# Run bash code on a fake terminal of the given type ("" for no TERM).
# Usage: run_in_terminal TERM CODE
run_in_terminal() {
  command -v script &>/dev/null || skip "needs script(1) to fake a terminal"

  run_clean -u COLUMNS -u LINES TERM="$1" script -qec "bash -c $(printf %q "$2")" /dev/null
}

# Print a character the given number of times
repeat() {
  printf -- "$1%.0s" $(seq "$2")
}
