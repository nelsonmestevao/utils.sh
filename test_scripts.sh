#!/usr/bin/env bash
#
# Shows what the scripts print, to check it by eye in a terminal.

set -Eeuo pipefail

DIR="$(dirname "${BASH_SOURCE[0]}")/scripts"

# shellcheck source=scripts/formatting.sh
. "${DIR}/formatting.sh"
# shellcheck source=scripts/utils.sh
. "${DIR}/utils.sh"

echo "$RED$(italic 'Italic red')"

format -c cyan "This should be Cyan"
echo

strikethrough "This should be strike through"
underline "This should be underline"
bold "This should be bold"

log_error "Terrible things happen"
log_warn "Alarming things happen"
log_success "Everything is good"

log_info "Cenas maradas"
log_info --label "example" "cenas coisas"

load_env_file ".env"
load_env_file -dbg ".env"
load_env_file "non-existing.env"

ensure_confirmation

log_info --non-reall-flag "Hello"
