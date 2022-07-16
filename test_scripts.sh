#!/usr/bin/env bash

set -Eeuo pipefail

SCRIPTS_DIR="$(dirname "${BASH_SOURCE[0]:-$0}")/scripts"

. ${SCRIPTS_DIR}/colors.sh
. ${SCRIPTS_DIR}/fmt.sh
. ${SCRIPTS_DIR}/logging.sh
. ${SCRIPTS_DIR}/utils.sh

echo "$RED$(italic Nelson)"
format -c magenta
strikethrough "Nelson"
format -c cyan "Nelson"
format -c yellow
underline "Nelson"

log_error "Terrible things happen"
log_warn "Alarming things happen"
log_success "Everything is good"

bold "Nelson"
