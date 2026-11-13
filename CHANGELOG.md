# Changelog

All notable changes to this project are listed here. The format follows
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow
[Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Unreleased

### Added

- Sourcing any of the scripts on bash older than 4.4 stops with a clear error.
  Before, they failed later with errors like "unbound variable".

## 0.17.0 - 2026-11-13

### Changed

These changes can break scripts that rely on the old behavior.

- `log_error`, `log_warn` and `exit_message` print to stderr instead of stdout.
- The `WARN` log level is now `WARNING`. `LOG_LEVEL` ignores case, and an
  unknown level falls back to `INFO`. This includes the old `WARN`.
- `bold`, `italic`, `underline`, `strikethrough`, `exit_message` and
  `help_title_section` print text as given. Escapes like `\n` are no longer
  expanded.
- `execute` shows its spinner only when stdout is a terminal that can save the
  cursor position. Elsewhere it prints just the result line. It no longer
  checks `CI=true`.
- `execute` writes its temp file to `$TMPDIR` instead of `/tmp`.
- `ensure_confirmation` accepts `yes` in any case. With no input at all, it
  cancels.
- `datetime` and `timestamp` use `date -u`, so they also work with BSD and
  macOS `date`.

### Added

- `UTILS_VERSION` in `helpers.sh` holds the version that every script prints
  when it runs directly.

### Removed

- The `import` function. Source the scripts directly instead.

### Fixed

- Sourcing `utils.sh` on its own no longer breaks the `log_*` functions and
  `load_env_file` with "unbound variable". Sourcing `logging.sh` first is no
  longer needed.
- Logging also works when `logging.sh` is sourced inside a function.
- With no `TERM` (cron, Docker) or `TERM=dumb`, sourcing the scripts no longer
  ends scripts that use `set -e`. Colors are empty instead.
- `execute`:
  - Sets up its cleanup on exit correctly. In 0.16.0, the `EXIT` trap ran the
    script's own second argument (`$2`) as a command.
  - Keeps the caller's `EXIT` trap instead of replacing it.
  - Reports a failing command under `set -e`, instead of ending the script
    before it prints the result.
  - Keeps the script's exit code when background jobs are still running at
    exit. Before, it could change to 143.
  - Shows the last error line even when it has no trailing newline.
  - Removes its temp file when the script is killed.
  - Spinner frames no longer break in the C locale.
- `log_info -- message` prints the messages after `--`.
- A lowercase `LOG_LEVEL`, like `info`, no longer fails with "unbound
  variable".
- Log labels with spaces or underscores print as given.
- Log lines fit narrow terminals, also when stdin is not a terminal.
- `load_env_file` exports variables named `file`, `debug` or `lines`, and no
  longer overwrites the caller's `lines` variable.
- `format` prints text like `-n`, and no longer loops forever on a flag that
  has no value.
- `help_title_section` joins words with spaces even when the caller changes
  `IFS`.

### Development

- `make lint` now fails when shellcheck finds a problem, and checks every
  shell file. CI runs it.
- `bin/setup` installs one list of packages per OS, including `shellcheck` and
  `kcov`. On Arch it no longer runs a full system upgrade for each package.
  CI uses it.
- `increment_scripts_versions.sh` bumps the one version in `helpers.sh`, and
  fails on an unknown part instead of doing a patch bump.
- Added a Nix flake dev shell and a test coverage report with kcov in CI.
- Added tests for each fix, and for `ask_for_sudo`, the spinner and the colors.
