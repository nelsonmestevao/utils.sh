#!/usr/bin/env bash

set -Eeuo pipefail

DIR="$(dirname "${BASH_SOURCE[0]:-$0}")/scripts"

. ${DIR}/colors.sh
. ${DIR}/formatting.sh
. ${DIR}/logging.sh
. ${DIR}/utils.sh

echo "$RED$(italic 'Italic red')"

echo $(format -c cyan "This should be Cyan")

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