# utils.sh

Small bash libraries for your own scripts: colored log messages, a spinner for
slow commands, text styles, and a few helpers.

## Requirements

- bash 4.4 or newer. On macOS, `/bin/bash` is 3.2, so install a newer
  one with `brew install bash`.
- `tput` (from ncurses) for colors. Without it, the scripts print plain text.
- `figlet` (optional) for a big title in `display_version`.

## Install

Copy the `scripts/` folder into your project. Keep `LICENSE.txt` with it. For
example, to put version 0.17.0 in `vendor/utils.sh/`:

```bash
VERSION=0.17.0
mkdir -p vendor/utils.sh
curl -fsSL "https://github.com/nelsonmestevao/utils.sh/archive/refs/tags/v${VERSION}.tar.gz" |
  tar -xz -C vendor/utils.sh --strip-components=2 "utils.sh-${VERSION}/scripts"
```

To update, run it again with a newer version. Read the
[changelog](CHANGELOG.md) first: some releases change how functions behave.

## Usage

Source the files you need. Each file loads the files it depends on.

```bash
#!/usr/bin/env bash

UTILS="$(dirname "${BASH_SOURCE[0]}")/vendor/utils.sh"
. "$UTILS/utils.sh"
. "$UTILS/execs.sh"

log_info "Setting up"
execute "make build" "Building"
log_success "Done"
```

Every file except `colors.sh` turns on `set -Eeuo pipefail` in the script that
sources it.

Run a file on its own to print the version, e.g. `bash scripts/utils.sh`.

## Functions

### `logging.sh`

| Function | What it does |
| --- | --- |
| `log_info [--label NAME] MSG...` | Prints the messages under a blue `INFO` (or `NAME`) header. |
| `log_success MSG...` | Same, with a green `OK` header. |
| `log_warn MSG...` | Same, with a yellow `WARN` header, to stderr. |
| `log_error MSG...` | Same, with a red `FAIL` header, to stderr. |
| `log_debug MSG...` | Same, with a magenta `DEBUG` header. |
| `exit_message MSG` | Prints a red `>>> MSG ⨯` line to stderr. Use it before `exit 1`. |

Set `LOG_LEVEL` to hide the lower levels. From low to high: `DEBUG` (the
default), `INFO`, `WARNING`, `ERROR`. Case does not matter.

### `execs.sh`

| Function | What it does |
| --- | --- |
| `execute CMDS [MSG]` | Runs the commands with a spinner, then prints ✓ or ⨯. On failure, it prints the commands' output and returns their exit code. |

The spinner shows only on a terminal. In logs and pipes you get just the
result line.

### `formatting.sh`

| Function | What it does |
| --- | --- |
| `bold TEXT`, `italic TEXT`, `underline TEXT`, `strikethrough TEXT` | Prints the text in that style. |
| `format [-c COLOR] [-t TYPE] [TEXT...]` | Prints the text in a color and style. With no text, it prints only the style, so it applies to what comes next. |

Colors: `black`, `red`, `green`, `yellow`, `blue`, `magenta`, `cyan`,
`white`. Types: `bold`, `bright`, `fade`, `italic`, `underline`, `blink`,
`inverse`, `strikethrough`.

### `utils.sh`

Also loads `logging.sh`.

| Function | What it does |
| --- | --- |
| `is_installed CMD`, `not_installed CMD` | Checks if a command exists. |
| `load_env_file [-d] [FILE]` | Exports the variables in `FILE` (default `.env`). With `-d`, it also prints the file. |
| `ask_for_sudo` | Asks for the sudo password once, and keeps it fresh until the script ends. |
| `ensure_confirmation` | Asks "Are you sure you want to proceed? [Y/n]" and exits on no. |
| `get_os_name` | Prints the OS name in lowercase, like `linux` or `darwin`. |
| `sanitize_name NAME` | Swaps each character that is not a letter or digit for `-`. |
| `datetime` | Prints the UTC date and time, like `2026-11-13T20:13:21Z`. |
| `timestamp` | Prints the UTC date and time, like `20261113201321`. |

### `git.sh`

| Function | What it does |
| --- | --- |
| `get_default_repo_branch` | Prints the first branch it finds named `main`, `trunk`, `mainline` or `default`, locally or on `origin` or `upstream`. Falls back to `master`. |

### `helpers.sh` and `colors.sh`

Every file loads these.

| Name | What it is |
| --- | --- |
| `display_version VERSION [NAME]` | Prints the script name and version. |
| `help_title_section WORDS...` | Prints the words in bold capitals, for help text. |
| `UTILS_VERSION` | The version of these scripts. |
| `RED`, `GREEN`, `YELLOW`, `BLUE`, `MAGENTA`, `CYAN`, `WHITE`, `BLACK` | Text colors. Empty when the terminal has no colors. |
| `BOLD`, `UNDERLINE`, `REVERSE`, `RESET` | Text styles, and `RESET` to end them. |

## Development

You need `bats`, `kcov`, `make`, `shellcheck` and `shfmt`. Install them with
`make setup` on Arch, Fedora, Debian, Ubuntu or NixOS. With Nix, you can also
use `nix develop` or [direnv](https://direnv.net/).

| Command | What it does |
| --- | --- |
| `make test` | Runs the tests. |
| `make lint` | Checks the scripts with shellcheck. |
| `make format` | Formats the scripts with shfmt. |
| `make coverage` | Runs the tests with a coverage report in `coverage/`. |
| `./test_scripts.sh` | Shows what the scripts print, to check by eye. |

To release, bump the version with
`./increment_scripts_versions.sh [major|minor|patch]`, add a section for it to
[`CHANGELOG.md`](CHANGELOG.md), commit, and tag the commit `vX.Y.Z`.

## License

MIT. See [`scripts/LICENSE.txt`](scripts/LICENSE.txt).
