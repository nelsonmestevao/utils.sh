#==============================================================================
NO_COLOR=\x1b[0m
OK_COLOR=\x1b[32m
ERROR_COLOR=\x1b[31m
WARN_COLOR=\x1b[33m
OK_STRING=$(OK_COLOR)✓$(NO_COLOR)
ERROR_STRING=$(ERROR_COLOR)⨯$(NO_COLOR)
WARN_STRING=$(WARN_COLOR)!$(NO_COLOR)
#==============================================================================

.PHONY: setup # Install package dependencies for development
setup:
	@bin/setup

.PHONY: format # Run code formatters
fmt format:
	@shfmt -w -i 2 -l -ci .

.PHONY: lint # Lint the source code
lint:
	@find scripts -name "*.sh" -exec shellcheck -xa {} \;

.PHONY: test # Run the test suite
test:
	@find tests -name "*_test.bats" -exec bats {} \;

.PHONY: help # Generate list of targets with descriptions
help:
	@grep '^.PHONY: .* #' Makefile | sed 's/\.PHONY: \(.*\) # \(.*\)/\t\1\t\2/'
